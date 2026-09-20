#!/usr/bin/sh
# Origin: pkgbuilds/omarchy-apple-boot/omarchy-vendorfw.sh
# Early (default): unpack ESP vendorfw/firmware.cpio into the initramfs
# before cryptsetup so MTP firmware is on /lib/firmware/vendor for the
# passphrase prompt. Late (sysroot): copy that tree onto the unlocked root.
set -eu

image_esp_uuid=4F4D-5801
mnt=/run/omarchy-vendorfw-esp

stage_from_esp() {
    if [ -d /vendorfw ] && { [ -e /vendorfw/.vendorfw.manifest ] || [ -e /vendorfw/apple ]; }; then
        return 0
    fi

    esp=
    dt=/proc/device-tree/chosen/asahi,efi-system-partition
    if [ -e "$dt" ]; then
        esp=$(tr -d '\0' <"$dt")
    fi

    dev=
    i=0
    while [ "$i" -lt 50 ]; do
        if [ -n "$esp" ] && [ -e "/dev/disk/by-partuuid/$esp" ]; then
            dev="/dev/disk/by-partuuid/$esp"
            break
        fi
        if [ -e "/dev/disk/by-uuid/$image_esp_uuid" ]; then
            dev="/dev/disk/by-uuid/$image_esp_uuid"
            break
        fi
        sleep 0.1
        i=$((i + 1))
    done
    [ -n "$dev" ] || return 0

    mkdir -p "$mnt"
    mount -o ro "$dev" "$mnt"
    if [ -f "$mnt/vendorfw/firmware.cpio" ]; then
        (cd / && cpio -i <"$mnt/vendorfw/firmware.cpio")
    fi
    umount "$mnt"
}

stage_into_sysroot() {
    [ -d /vendorfw ] || return 0
    dst=/sysroot/lib/firmware/vendor
    mkdir -p "$dst"
    mount -t tmpfs -o mode=0755 vendorfw "$dst"
    cp -r /vendorfw/. "$dst"/
}

retrigger_hid() {
    [ -d /vendorfw ] || return 0
    command -v udevadm >/dev/null 2>&1 || return 0
    udevadm trigger --action=add --subsystem-match=hid --subsystem-match=input --subsystem-match=spi --subsystem-match=platform || true
    udevadm settle --timeout=10 || true
}

case "${1:-esp}" in
    sysroot) stage_into_sysroot ;;
    *)
        stage_from_esp
        retrigger_hid
        ;;
esac
