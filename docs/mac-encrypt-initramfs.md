# Keyboard and vendor firmware before the LUKS passphrase prompt

The sd-encrypt passphrase prompt runs in the systemd initramfs, before
`sysroot.mount`. Until this change, `omarchy-vendorfw.service` ran
`After=sysroot.mount`, so the internal keyboard and trackpad were not
guaranteed to work at unlock.

## Modules (linux-aurora)

There is no `apple-mtp` / `apple_mtp` module. MTP HID is `dockchannel-hid`.

| Module | Aurora config | Role | Machines |
|---|---|---|---|
| `hid_apple` | `=m` | Keyboard HID driver | All listed Macs |
| `hid_magicmouse` | `=m` | SPI trackpad HID driver | M1 Pro `j314s`, M1 Air |
| `dockchannel-hid` | `=m` | DockChannel HID transport (MTP) | M2 Air, M2 Max `j416c`; modular on every aurora kernel |
| `usbhid` | `=m` | External USB keyboard at the prompt | All |
| `spi-hid-apple-of` | `=y` | SPI HID transport | M1 Air, M1 Pro `j314s` — built-in, not a MODULES entry |
| `apple-dockchannel`, `apple-rtkit-helper`, `spi-apple` | `=y` | Bus helpers | Built-in, not MODULES entries |

`files/etc/mkinitcpio.conf.d/92-omarchy-mac-hid.conf` adds a name to
`MODULES` only when `modinfo -F filename` returns a real path, so a kernel
that builds a driver in (or omits it) does not fail later `mkinitcpio -P`
runs. Origin: `omarchy-mx-mac install/hardware/apple/fix-asahi-hid-race.sh`.

## Firmware

Keyboard firmware is not required. The MTP trackpad (and therefore a working
pointing device at the prompt on M2 Air / M2 Max `j416c`) needs the vendor
blob unpacked from the ESP:

- ESP path: `vendorfw/firmware.cpio` (Asahi vendorfw; also `vendorfw/firmware.tar` for the post-boot unit)
- Unpacked to: `/vendorfw` → `/lib/firmware/vendor` (symlink in the initramfs)
- MTP blob: `/lib/firmware/vendor/apple/tpmtfw-<board>.bin`
  - `apple/tpmtfw-j416c.bin` — M2 Max 16"
  - `apple/tpmtfw-j413.bin` — M2 Air
  - M1 Pro `j314s` / M1 Air use SPI HID and do not need `tpmtfw` for input

If the build chroot already has those blobs, the `omarchy-vendorfw` install
hook copies them to `/vendorfw/apple/` in the image (not under
`/lib/firmware/vendor`, which is a symlink to `/vendorfw`).

## Ordering

1. `systemd-modules-load` loads `MODULES` (`hid_apple`, `hid_magicmouse`,
   `dockchannel-hid`, `usbhid`, …).
2. `omarchy-vendorfw.service` mounts the ESP (`PARTUUID` from
   `/proc/device-tree/chosen/asahi,efi-system-partition`, else FAT UUID
   `4F4D-5801`), unpacks `vendorfw/firmware.cpio`, retriggers udev.
   `Before=cryptsetup-pre.target`, pulled in by `cryptsetup-pre.target.wants`
   and `initrd.target.wants`.
3. `sd-encrypt` / `systemd-cryptsetup@root` runs (passphrase prompt).
4. After `sysroot.mount`, `omarchy-vendorfw-sysroot.service` copies `/vendorfw`
   onto `/sysroot/lib/firmware/vendor` for Wi-Fi/BT on the running system.

`90-omarchy-asahi.conf` still inserts the `asahi` and `omarchy-vendorfw` hooks
before `filesystems`. T4a's `omarchy-mac-encrypt` stays after this vendorfw
stage.

## What this test covers

`test/omarchy-mac-hid-initramfs` generates an initramfs in an Arch container
with the drop-ins, checks `lsinitcpio` for the HID modules, `tpmtfw-*.bin`,
and the `cryptsetup-pre.target.wants` symlink, and runs `systemd-analyze
verify` on the initrd units.

## What still needs the real hardware (owner, morning)

KVM cannot exercise DockChannel, SPI HID, or MTP firmware load. Confirm on
M1 Pro `j314s` and M2 Max `j416c`, and on an M1/M2 Air:

- Encrypted boot: internal keyboard types the passphrase at sd-encrypt.
- Trackpad moves the cursor (or is at least present) at that prompt on MTP
  machines.
- After unlock, Wi-Fi/BT still get vendor firmware (sysroot copy).
- `mkinitcpio -P` on each aurora lane (`stable`/`rc`/`edge`) still succeeds.
