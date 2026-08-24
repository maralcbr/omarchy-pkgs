#!/bin/bash

set -euo pipefail

BUNDLE_DIR=${BUNDLE_DIR:-/bundle}
EXPECTED_PACKAGES=(
  omarchy-keyring
  omarchy-settings-dev
  omarchy-dev
  omarchy-nvim
  quickshell-git
  ttf-jetbrains-mono-nerd-basic
)

shopt -s nullglob
all_archives=("$BUNDLE_DIR"/*.pkg.tar.*)
archives=()
for archive in "${all_archives[@]}"; do
  [[ $archive == *.sig ]] || archives+=("$archive")
done
(( ${#archives[@]} == 6 )) || {
  echo "Transaction verification requires exactly six package archives" >&2
  exit 1
}

repo_dir=$(mktemp -d)
db_dir=$(mktemp -d)
cache_dir=$(mktemp -d)
pacman_conf=$(mktemp)
cleanup() {
  rm -rf "$repo_dir" "$cache_dir" "$pacman_conf"
  sudo rm -rf "$db_dir"
}
trap cleanup EXIT

declare -A versions=()
declare -A archive_by_package=()
for archive in "${archives[@]}"; do
  metadata=$(bsdtar -xOf "$archive" .PKGINFO)
  package=$(sed -n 's/^pkgname = //p' <<<"$metadata")
  version=$(sed -n 's/^pkgver = //p' <<<"$metadata")
  [[ -n $package && -n $version && -z ${versions[$package]:-} ]] || {
    echo "Invalid or duplicate package metadata in $(basename "$archive")" >&2
    exit 1
  }
  versions[$package]=$version
  archive_by_package[$package]=$archive
  ln -s "$archive" "$repo_dir/$(basename "$archive")"
done

for package in "${EXPECTED_PACKAGES[@]}"; do
  [[ -n ${versions[$package]:-} ]] || {
    echo "Transaction bundle is missing $package" >&2
    exit 1
  }
done

runtime_metadata=$(bsdtar -xOf "${archive_by_package[omarchy-dev]}" .PKGINFO)
required_runtime_deps=(
  omarchy-keyring
  omarchy-settings-dev
  omarchy-nvim
  quickshell
  ttf-jetbrains-mono-nerd-basic
)
for dependency in "${required_runtime_deps[@]}"; do
  awk -F' = ' -v expected="$dependency" '
    $1 == "depend" {
      actual=$2
      sub(/[<>=].*$/, "", actual)
      if (actual == expected) found=1
    }
    END { exit !found }
  ' <<<"$runtime_metadata" || {
    echo "omarchy-dev is missing required runtime dependency $dependency" >&2
    exit 1
  }
done

quickshell_metadata=$(bsdtar -xOf "${archive_by_package[quickshell-git]}" .PKGINFO)
awk -F' = ' '
  $1 == "provides" {
    actual=$2
    sub(/[=].*$/, "", actual)
    if (actual == "quickshell") found=1
  }
  END { exit !found }
' <<<"$quickshell_metadata" || {
  echo "quickshell-git does not provide the quickshell runtime dependency" >&2
  exit 1
}

repo-add "$repo_dir/asahi-verify.db.tar.zst" "$repo_dir"/*.pkg.tar.* >/dev/null

awk -v repo_dir="$repo_dir" '
  /^\[[^]]+\]$/ && $0 != "[options]" && !inserted {
    print "[asahi-verify]"
    print "SigLevel = Never"
    print "Server = file://" repo_dir
    print ""
    inserted=1
  }
  { print }
' /etc/pacman.conf >"$pacman_conf"

sudo pacman --config "$pacman_conf" --dbpath "$db_dir" --cachedir "$cache_dir" \
  --noconfirm -Sy >/dev/null
transaction=$(sudo pacman --config "$pacman_conf" --dbpath "$db_dir" --cachedir "$cache_dir" \
  --noconfirm -Sp --print-format '%n|%v|%r' -- "${EXPECTED_PACKAGES[@]}")

for package in "${EXPECTED_PACKAGES[@]}"; do
  expected="$package|${versions[$package]}|asahi-verify"
  grep -Fxq "$expected" <<<"$transaction" || {
    echo "Pacman did not select the exact bundled $package version" >&2
    exit 1
  }
done

echo "Pacman resolved the exact six-package transaction"
