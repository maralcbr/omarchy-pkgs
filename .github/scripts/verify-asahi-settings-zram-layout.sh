#!/bin/bash

# Apple Silicon runtimes released before zram was allowed reject any bundle
# carrying the zram-generator drop-in or the zswap tmpfile, and the bundle
# updater always installs the newest channel. The settings package must keep
# shipping zram through paths every supported runtime accepts.

set -euo pipefail

BUNDLE_DIR=${BUNDLE_DIR:-/bundle}

fail() {
  echo "Settings zram layout verification: $*" >&2
  exit 1
}

shopt -s nullglob
archives=()
for archive in "$BUNDLE_DIR"/omarchy-settings-dev-*.pkg.tar.*; do
  [[ $archive == *.sig ]] || archives+=("$archive")
done
(( ${#archives[@]} == 1 )) || fail "expected exactly one omarchy-settings-dev archive in $BUNDLE_DIR"
archive=${archives[0]}

paths=$(bsdtar -tf "$archive" | sed 's|^\./||')
grep -Fxq usr/lib/systemd/zram-generator.conf <<<"$paths" ||
  fail "$(basename "$archive") does not ship the zram vendor config"
if grep -Eq '^(usr/lib/systemd/zram-generator\.conf\.d|etc/tmpfiles\.d/omarchy-zswap\.conf)(/|$)' <<<"$paths"; then
  fail "$(basename "$archive") carries a zram path that older Apple Silicon runtimes reject"
fi
bsdtar -xOf "$archive" etc/sysctl.d/99-omarchy-sysctl.conf | grep -Fxq 'vm.swappiness=150' ||
  fail "$(basename "$archive") does not ship the zram reclaim tuning"

echo "Verified zram layout in $(basename "$archive")"
