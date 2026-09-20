# Keyboard and vendor firmware before the LUKS passphrase prompt

The sd-encrypt passphrase prompt runs in the systemd initramfs, before
`sysroot.mount`. `omarchy-vendorfw.service` still runs `After=sysroot.mount`
(byte-identical to omarchy-apple-boot) so non-encrypted Macs keep today's
post-mount copy onto the unlocked root. Encrypted boots add a distinct
predecessor, `omarchy-vendorfw-initrd.service`, ordered
`Before=cryptsetup-pre.target` with `DefaultDependencies=no`.

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
- Unpacked to: `/vendorfw` → `/lib/firmware/vendor` (symlink in the initramfs; the kernel firmware loader searches `/lib/firmware/vendor`)
- MTP blob: `/lib/firmware/vendor/apple/tpmtfw-<board>.bin`
  - `apple/tpmtfw-j416c.bin` — M2 Max 16"
  - `apple/tpmtfw-j413.bin` — M2 Air
  - M1 Pro `j314s` / M1 Air use SPI HID and do not need `tpmtfw` for input

The install hook does **not** pre-create `/vendorfw/apple` or bake blobs into
the image. That directory was treated as "already staged" and skipped ESP
mount/extract. Firmware comes from the ESP at boot.

`etc/systemd/system/omarchy-vendor-firmware.service` stays with T3a. Its
timestamp (`/var/lib/omarchy/vendor-firmware.stamp` vs
`/boot/efi/vendorfw/firmware.tar`) and `mountpoint /lib/firmware/vendor`
skip still apply after switch-root: the initrd late unit copies the **full**
ESP vendorfw tree onto sysroot, so a current stamp does not hide Wi-Fi/BT.

## Ordering

1. `systemd-modules-load` loads `MODULES` (`hid_apple`, `hid_magicmouse`,
   `dockchannel-hid`, `usbhid`, …).
2. `omarchy-vendorfw-initrd.service` discovers the ESP by FAT UUID
   `4F4D-5801` (`/dev/disk/by-uuid/`, else `blkid -U`, else the device-tree
   PARTUUID), mounts it, unpacks `vendorfw/firmware.cpio` into a tmpfs, and
   copies those files onto `/lib/firmware/vendor` without mounting tmpfs over
   an existing vendor tree. It records the staging in
   `/run/omarchy-vendorfw-initrd.staged`. Pulled by
   `cryptsetup-pre.target.wants`, `Before=cryptsetup-pre.target`.
3. `sd-encrypt` / `systemd-cryptsetup@root` runs (passphrase prompt). T4a
   `omarchy-mac-encrypt.service` is `After=omarchy-vendorfw-initrd.service`.
4. After `sysroot.mount`, `omarchy-vendorfw.service` (original script) mounts
   the ESP by PARTUUID and copies `/vendorfw` onto
   `/sysroot/lib/firmware/vendor` for Wi-Fi/BT on the running system.

`90-omarchy-asahi.conf` still inserts the `asahi` and `omarchy-vendorfw`
hooks before `filesystems`. The asahi **runtime** hook does not run under
the systemd initrd; the systemd units above do. The asahi **install** hook
still adds platform modules and the `/lib/firmware/vendor` → `/vendorfw`
symlink.

## What this test covers

`test/omarchy-mac-hid-initramfs` generates an initramfs in an Arch container
with `systemd`, `asahi` (real package, or a stub with the same install
semantics), `sd-encrypt` and `omarchy-vendorfw`. mkinitcpio failures fail
the test. `lsinitcpio` must list the HID modules, both vendorfw units, and
the generated wants links. `systemd-analyze verify` is strict (nonzero
fails). The early helper is run against a fixture ESP (fake `blkid` / UUID
node) and must call `mount` and `cpio` and land firmware at
`/lib/firmware/vendor` without hiding a file already there.

## What still needs the real hardware (owner, morning)

KVM cannot exercise DockChannel, SPI HID, or MTP firmware load. Confirm on
M1 Pro `j314s` and M2 Max `j416c`, and on an M1/M2 Air:

- Encrypted boot: internal keyboard types the passphrase at sd-encrypt.
- Trackpad moves the cursor (or is at least present) at that prompt on MTP
  machines.
- After unlock, Wi-Fi/BT still get vendor firmware (sysroot copy).
- Non-encrypted boot still extracts after `sysroot.mount` as before.
- `mkinitcpio -P` on each aurora lane (`stable`/`rc`/`edge`) still succeeds.
