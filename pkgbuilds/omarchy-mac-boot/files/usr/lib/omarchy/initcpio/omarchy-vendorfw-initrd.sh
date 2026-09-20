#!/usr/bin/sh
# Unpack ESP vendorfw/firmware.cpio before cryptsetup so MTP firmware is
# on /lib/firmware/vendor for the sd-encrypt passphrase prompt.
# Does not overlay sysroot; omarchy-vendorfw.service still copies onto
# the unlocked root after sysroot.mount.
set -eu

image_esp_uuid=4F4D-5801
mnt=/run/omarchy-vendorfw-esp
extract=/run/omarchy-vendorfw-extract
record=/run/omarchy-vendorfw-initrd.staged

if [ -e "$record" ]; then
    exit 0
fi

esp=
dt=/proc/device-tree/chosen/asahi,efi-system-partition
if [ -e "$dt" ]; then
    esp=$(tr -d '\0' <"$dt")
fi

dev=
i=0
while [ "$i" -lt 50 ]; do
    if [ -e "/dev/disk/by-uuid/$image_esp_uuid" ]; then
        dev="/dev/disk/by-uuid/$image_esp_uuid"
        break
    fi
    if command -v blkid >/dev/null 2>&1; then
        found=$(blkid -U "$image_esp_uuid" 2>/dev/null || true)
        if [ -n "$found" ]; then
            dev=$found
            break
        fi
    fi
    if [ -n "$esp" ] && [ -e "/dev/disk/by-partuuid/$esp" ]; then
        dev="/dev/disk/by-partuuid/$esp"
        break
    fi
    sleep 0.1
    i=$((i + 1))
done
[ -n "$dev" ] || exit 0

mkdir -p "$mnt"
mount -o ro "$dev" "$mnt"
if [ ! -f "$mnt/vendorfw/firmware.cpio" ]; then
    umount "$mnt"
    exit 0
fi

mkdir -p "$extract"
mount -t tmpfs -o mode=0755 omarchy-vendorfw-extract "$extract"
(cd "$extract" && cpio -i <"$mnt/vendorfw/firmware.cpio")
umount "$mnt"

src=$extract/vendorfw
if [ ! -d "$src" ]; then
    src=$extract
fi

vendor=/lib/firmware/vendor
if [ -L "$vendor" ]; then
    dest=/vendorfw
    mkdir -p "$dest"
elif [ -d "$vendor" ]; then
    dest=$vendor
else
    mkdir -p /lib/firmware
    dest=/vendorfw
    mkdir -p "$dest"
    ln -s /vendorfw "$vendor"
fi
# Copy into the destination; never mount tmpfs over an existing vendor tree.
cp -r "$src"/. "$dest"/

{
    printf 'dev=%s\n' "$dev"
    printf 'dest=%s\n' "$dest"
} >"$record"

if command -v udevadm >/dev/null 2>&1; then
    udevadm trigger --action=add --subsystem-match=hid --subsystem-match=input --subsystem-match=spi --subsystem-match=platform || true
    udevadm settle --timeout=10 || true
fi
