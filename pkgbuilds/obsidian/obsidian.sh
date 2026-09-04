#!/bin/bash

OBSIDIAN_USER_FLAGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/user-flags.conf"

# Allow users to override command-line options
if [[ -f "${OBSIDIAN_USER_FLAGS_FILE}" ]]; then
   OBSIDIAN_USER_FLAGS=$(grep -v '^#' "$OBSIDIAN_USER_FLAGS_FILE")
fi

# Launch the bundled Electron; Arch Linux ARM ships no electron package
exec /usr/lib/obsidian/obsidian --ozone-platform-hint=auto $OBSIDIAN_USER_FLAGS "$@"
