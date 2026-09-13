# Aurora bootloader compatibility

Pins m1n1 v1.6.1 (06a4601a351ebfd1abb6abba9a44c34e40d94776), backports RC, NHI and PCIe adapter alias fallbacks, and embeds the existing Omarchy boot logos. The v1.6.1 storage and memory code is retained. Latest Aurora main remains unqualified after a root-device boot failure.

This Aurora-only replacement provides m1n1 and conflicts with the upstream package. It owns the standard `/usr/lib/asahi-boot/m1n1.bin` path. The existing asahi-scripts path hook regenerates boot.bin when this input, the kernel DTBs, or U-Boot changes. No additional hook or administrator configuration file is installed. Existing `/etc/default/update-m1n1` overrides are preserved; intentional custom input overrides must be reconciled during machine qualification.

The source tarball is SHA256-pinned and fails closed on archive drift. Rust 1.89.0 and the bare-metal target are explicitly installed in the network-enabled build environment. Runtime asahi-scripts dependencies are deferred in that isolated builder, then resolved on the target.

Qualify actual package installation, vendor-hook execution, unchanged loader and logos after regeneration, physical boot, and two displays. A successful build alone is not hardware acceptance. This replacement is selected only for Aurora images; Asahi images retain upstream m1n1.
