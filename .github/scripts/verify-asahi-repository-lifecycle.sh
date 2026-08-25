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

sudo install -d -m 0755 /var/cache/pacman/candidate /var/cache/pacman/previous
sudo pacman-key --init
sudo pacman-key --add "$candidate_dir/verify-signing-key.gpg"
sudo pacman-key --lsign-key "$candidate_fingerprint"

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
    package=$(bsdtar -xOf "$archive" .PKGINFO | sed -n 's/^pkgname = //p')
    grep -Fxq "$package" "$packages_file" || continue
    [[ -z ${previous_package_seen[$package]:-} ]] || continue
    previous_package_seen[$package]=1
    previous_packages+=("$package")
  done
  (( ${#previous_packages[@]} > 0 )) || {
    echo "Previous repository has no packages in the candidate inventory" >&2
    exit 1
  }
  sudo pacman -Syu --noconfirm --config "$previous_dir/pacman.conf" \
    "${previous_packages[@]}"
fi

sudo pacman -Syu --noconfirm --config "$candidate_dir/pacman.conf" $packages

declare -A expected_versions=()
shopt -s nullglob
archives=("$candidate_dir"/*.pkg.tar.*)
for archive in "${archives[@]}"; do
  [[ $archive == *.sig ]] && continue
  metadata=$(bsdtar -xOf "$archive" .PKGINFO)
  package=$(sed -n 's/^pkgname = //p' <<<"$metadata")
  version=$(sed -n 's/^pkgver = //p' <<<"$metadata")
  [[ -n $package && -n $version && -z ${expected_versions[$package]:-} ]] || {
    echo "Invalid candidate package metadata: ${archive##*/}" >&2
    exit 1
  }
  expected_versions[$package]=$version
done

while IFS= read -r package; do
  installed_version=$(pacman -Q "$package" | awk '{ print $2 }')
  [[ $installed_version == "${expected_versions[$package]:-}" ]] || {
    echo "Installed $package version does not match the candidate" >&2
    exit 1
  }
done <"$packages_file"

for pc_package in limine snapper amd-ucode intel-ucode; do
  ! pacman -Q "$pc_package" >/dev/null 2>&1 || {
    echo "Candidate transaction introduced PC package $pc_package" >&2
    exit 1
  }
done

sudo pacman -Syu --noconfirm --config "$candidate_dir/pacman.conf"
while IFS= read -r package; do
  installed_version=$(pacman -Q "$package" | awk '{ print $2 }')
  [[ $installed_version == "${expected_versions[$package]}" ]]
done <"$packages_file"

sha256sum /var/lib/pacman/sync/*.db
echo "Verified $mode lifecycle for $(wc -l <"$packages_file") candidate packages"
