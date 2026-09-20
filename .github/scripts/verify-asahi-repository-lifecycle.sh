#!/bin/bash

set -euo pipefail

mode=${1:-}
candidate_dir=${CANDIDATE_DIR:-/candidate}
previous_dir=${PREVIOUS_DIR:-/previous}
packages_file=${PACKAGES_FILE:-/workspace/pkgbuilds/asahi-repository-packages}
candidate_fingerprint=${CANDIDATE_FINGERPRINT:-}
previous_fingerprint=${PREVIOUS_FINGERPRINT:-5983B1CA32CB778F4D74D24ECFF35022CA5B5959}

[[ $mode == "clean" || $mode == "upgrade" ]] || {
  echo "Usage: verify-asahi-repository-lifecycle.sh clean|upgrade" >&2
  exit 64
}
[[ $candidate_fingerprint =~ ^[A-F0-9]{40}$ ]] || {
  echo "Candidate signing fingerprint is invalid" >&2
  exit 1
}
[[ -s $packages_file ]] || {
  echo "Package inventory is missing" >&2
  exit 1
}

packages=$(paste -sd' ' "$packages_file")

# The ALARM mirrors regularly stall or drop mid-transaction; a failed
# download is retryable while every verification in this script is not.
pacman_with_retry() {
  local attempt
  for attempt in 1 2 3; do
    sudo pacman "$@" && return 0
    (( attempt < 3 )) || return 1
    echo "pacman transaction failed (attempt $attempt); retrying after mirror backoff" >&2
    sleep 20
  done
}

pacman_transaction() {
  pacman_with_retry -Syu --noconfirm "$@"
}

sudo install -d -m 0755 /var/cache/pacman/candidate /var/cache/pacman/previous
sudo pacman-key --init
sudo pacman-key --add "$candidate_dir/verify-signing-key.gpg"
sudo pacman-key --lsign-key "$candidate_fingerprint"

# Only Asahi ALARM publishes asahi-scripts, which omarchy-apple-boot needs; the inventory configs stay without it.
asahi_work=$(mktemp -d)
curl --fail --location --silent --show-error --proto '=https' --tlsv1.2 --retry 3 \
  --output "$asahi_work/asahi-alarm-keyring.pkg.tar.xz" \
  https://github.com/asahi-alarm/asahi-alarm/releases/download/aarch64/asahi-alarm-keyring-20241216-1-any.pkg.tar.xz
echo "798f4b283ad2819aee950d042f26566ae1a68f87c12247301ce449bea3b2d81e  $asahi_work/asahi-alarm-keyring.pkg.tar.xz" |
  sha256sum --check
printf '%s\n' '[options]' 'Architecture = aarch64' 'LocalFileSigLevel = Never' >"$asahi_work/keyring.conf"
sudo pacman -U --noconfirm --config "$asahi_work/keyring.conf" "$asahi_work/asahi-alarm-keyring.pkg.tar.xz"
# Pacman does not bind keys to repositories: every repository in this container now accepts these keys.
sudo pacman-key --populate asahi-alarm

# Forced, because a newer cached database (the builder image keeps its own) would shadow the predecessor's dated snapshot.
first_config=$candidate_dir/pacman.conf
[[ $mode == "clean" ]] || first_config=$previous_dir/pacman.conf
{
  awk '/^\[/ { keep = ($0 != "[omarchy]") } keep' "$first_config"
  printf '%s\n' '' '[asahi-alarm]' 'SigLevel = Required DatabaseOptional' \
    'Server = https://github.com/asahi-alarm/asahi-alarm/releases/download/$arch'
} >"$asahi_work/pacman.conf"
pacman_with_retry -Syy --noconfirm --config "$asahi_work/pacman.conf"
pacman -Sp --needed --print-format '%r/%n %v' --config "$asahi_work/pacman.conf" asahi-alarm/asahi-scripts |
  tee "$asahi_work/resolved"
[[ $(awk '{ print $1 }' "$asahi_work/resolved") == asahi-alarm/asahi-scripts ]] || {
  echo "The Asahi ALARM transaction must resolve to asahi-scripts and nothing else" >&2
  exit 1
}
pacman_with_retry -S --needed --noconfirm --config "$asahi_work/pacman.conf" asahi-alarm/asahi-scripts
pacman -Q asahi-scripts
sha256sum /var/lib/pacman/sync/asahi-alarm.db

if [[ $mode == "upgrade" ]]; then
  [[ -s $previous_dir/omarchy-release.gpg ]] || {
    echo "Previous repository key is missing" >&2
    exit 1
  }
  sudo pacman-key --add "$previous_dir/omarchy-release.gpg"
  sudo pacman-key --lsign-key "$previous_fingerprint"

  declare -a previous_packages=()
  declare -A previous_package_seen=()
  for archive in "$previous_dir"/*.pkg.tar.*; do
    [[ -f $archive && $archive != *.sig ]] || continue
    package=$(bsdtar -xOqf "$archive" .PKGINFO | sed -n 's/^pkgname = //p')
    grep -Fxq "$package" "$packages_file" || continue
    [[ -z ${previous_package_seen[$package]:-} ]] || continue
    previous_package_seen[$package]=1
    previous_packages+=("$package")
  done
  (( ${#previous_packages[@]} > 0 )) || {
    echo "Previous repository has no packages in the candidate inventory" >&2
    exit 1
  }
  pacman_transaction --config "$previous_dir/pacman.conf" \
    "${previous_packages[@]}"
fi

pacman_transaction --config "$candidate_dir/pacman.conf" $packages

declare -A expected_versions=()
shopt -s nullglob
archives=("$candidate_dir"/*.pkg.tar.*)
for archive in "${archives[@]}"; do
  [[ $archive == *.sig ]] && continue
  metadata=$(bsdtar -xOqf "$archive" .PKGINFO)
  package=$(sed -n 's/^pkgname = //p' <<<"$metadata")
  version=$(sed -n 's/^pkgver = //p' <<<"$metadata")
  [[ -n $package && -n $version && -z ${expected_versions[$package]:-} ]] || {
    echo "Invalid candidate package metadata: ${archive##*/}" >&2
    exit 1
  }
  expected_versions[$package]=$version
done

# nullglob turns an unreadable or empty candidate mount into an empty map;
# name that condition instead of failing on the first inventory package.
(( ${#expected_versions[@]} > 0 )) || {
  echo "Candidate directory has no readable package archives: $candidate_dir" >&2
  exit 1
}

# A candidate package that replaces another (provides/conflicts/replaces) answers
# `pacman -Q <old>` with its own name and version: accept the old name when its
# replacement is installed at the candidate's version for the replacement.
while IFS= read -r package; do
  installed_line=$(pacman -Q "$package" 2>/dev/null || true)
  installed_name=${installed_line%% *}
  installed_version=${installed_line#* }
  if [[ -n $installed_name && $installed_name != "$package" && -z ${expected_versions[$package]:-} ]]; then
    if pacman -Qi "$installed_name" 2>/dev/null | awk -F': *' '$1 ~ /^Replaces/ { print $2 }' | tr ' ' '\n' | grep -Fxq "$package"; then
      package=$installed_name
    fi
  fi
  [[ $installed_version == "${expected_versions[$package]:-}" ]] || {
    echo "Installed $package version does not match the candidate" >&2
    echo "  installed: ${installed_version:-<none>}" >&2
    echo "  candidate: ${expected_versions[$package]:-<absent from candidate directory>}" >&2
    pacman -Si "$package" 2>/dev/null | sed -n 's/^Repository/  repository/p' >&2 || true
    exit 1
  }
done <"$packages_file"

for required_dependency in limine snapper; do
  pacman -Q "$required_dependency" >/dev/null 2>&1 || {
    echo "Candidate transaction omitted ARM dependency $required_dependency" >&2
    exit 1
  }
done

for pc_package in amd-ucode intel-ucode; do
  ! pacman -Q "$pc_package" >/dev/null 2>&1 || {
    echo "Candidate transaction introduced PC package $pc_package" >&2
    exit 1
  }
done

pacman_transaction --config "$candidate_dir/pacman.conf"
while IFS= read -r package; do
  installed_version=$(pacman -Q "$package" | awk '{ print $2 }')
  [[ $installed_version == "${expected_versions[$package]}" ]]
done <"$packages_file"

sha256sum /var/lib/pacman/sync/*.db
echo "Verified $mode lifecycle for $(wc -l <"$packages_file") candidate packages"
