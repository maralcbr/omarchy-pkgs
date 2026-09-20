# Mac rename inventory (`asahi` → `mac`)

Research only. No code was changed for this document.

Sources (2026-09-20):

- `omarchy-pkgs` this worktree (`e/T0a`, based on `origin/asahi-quattro`): `rg -i --hidden --glob '!.git/**' asahi` and `find -iname '*asahi*'`
- `omarchy-mx-mac` **`origin/main`** at `69ad90fa438c588b6539fcc38b2fbbd431fe21ec` via `git grep` / `git ls-tree` (working tree ignored)
- `~/omarchy-lab` read-only (`rg` excluding nested `macvdmtool/.git`)
- Installed-Mac snapshot: `scratchpad/E/m2-asahi-inventory.txt`

## Policy

The word `asahi` leaves **our** names. The generic term is `mac`.

| Class | Meaning |
| --- | --- |
| **KEEP** | Names Asahi-project software we consume. Do not rename. |
| **RENAME** | Our identifier. Proposed `mac` name is given. |
| **IMMUTABLE** | Already published: git tags, R2 object keys, `docs/releases` acceptance files, and GitHub release assets on those tags. Never renamed. New code dual-reads them. |
| **MIGRATE** | Installed-Mac state. Ship new name, keep old as alias for **one release**, then drop. |

`apple*` names stay, except the collision **`omarchy-apple-boot` → `omarchy-mac-boot`**.

`linux-asahi` is not a PKGBUILD in this worktree. `linux-aurora` `provides=`/`conflicts=` `linux-asahi`. The name stays as the channel-less fallback package from `[asahi-alarm]`. Do not invent `linux-mac`.

## Counts

### Raw matches (`asahi`, case-insensitive)

| Tree | Files (name or content) | Content lines |
| --- | ---: | ---: |
| omarchy-pkgs HEAD | 105 | 2526 |
| omarchy-mx-mac `origin/main` | 234 | 2561 |
| omarchy-lab (excl. nested `.git`) | 5 | 11 |
| Installed Mac (live + backups + packages) | 38 paths + 17 packages | — |

### Class counts (inventory records)

A file that mixes classes is counted in **each** class it contains. Path-renames are counted separately from content.

| Class | Count | What was counted |
| --- | ---: | --- |
| **KEEP** | **26** | Distinct Asahi-project identifiers (catalog below) |
| **RENAME paths** | **105** | `git mv` targets: 71 pkgs + 33 mx-mac (32 files + `test/vm/asahi-fresh/`) + 1 lab |
| **RENAME files** | **313** | Files needing identifier `sed` (pkgs 103, mx-mac 210, lab 1 conf). Excludes 2 KEEP-only kernel `config` files, 7 KEEP engine/research filenames, 17 IMMUTABLE acceptance files |
| **IMMUTABLE** | **150** | 131 pkgs tags + 2 R2 pointer keys + 17 mx-mac acceptance files. Plus published GitHub **assets** on those tags (not double-counted) |
| **MIGRATE** | **10** | Live installed names (8 paths + 2 package names). Historical backup dirs are left as local history |

Mixed files are the norm in release tools: they **RENAME** our bin/env names, **KEEP** `asahi-alarm`/`linux-asahi`/`asahi-scripts`, and **IMMUTABLE**-cite published tags.

## KEEP catalog (26 identifiers)

Do not `sed` these. Naive `s/asahi/mac/g` destroys them.

| Identifier | Why KEEP |
| --- | --- |
| `[asahi-alarm]`, `asahi-alarm-keyring`, `asahi-alarm.db`, `asahi-alarm/asahi-alarm` | Asahi ALARM mirror |
| `asahi-scripts` | Asahi package; `omarchy-apple-boot` / `m1n1-aurora` depend on it |
| `asahi-fwextract` | Asahi firmware extractor |
| `linux-asahi`, `linux-asahi-headers`, `vmlinuz-linux-asahi`, `initramfs-linux-asahi` | Asahi kernel package (fallback recipe name; no `pkgbuilds/linux-asahi` here) |
| `mesa-asahi` | Asahi Mesa (name does not appear in pkgs HEAD; KEEP if introduced) |
| `vulkan-asahi`, `libvulkan_asahi.so` | Asahi Vulkan ICD |
| `asahi-audio` **package** | Asahi audio (distinct from **our** `asahi-audio-no-suspend.conf`) |
| `alsa-ucm-conf-asahi` | Asahi UCM |
| `asahi-bless` | Asahi boot picker |
| `asahi-desktop-meta` | Asahi meta package |
| `uboot-asahi` | Asahi U-Boot package we consume |
| `m1n1` / `/usr/lib/asahi-boot/` | Asahi boot chain paths from m1n1/u-boot |
| `PinnedAsahiEngine*`, `PinnedAsahiPlan*` | Wrappers around the Asahi installer engine |
| `omarchy_asahi.py`, `AsahiStage1Adapter`, `AsahiAdapterError`, `AsahiInPlaceRepairAdapter` | Python overlay of the Asahi installer |
| AsahiLinux/`asahi-installer`, `asahiInstallerTag` / `Revision` / `DataRevision` | Upstream installer pin |
| `/usr/lib/initcpio/hooks/asahi`, `/usr/lib/initcpio/install/asahi`, hook token `asahi` | Shipped by `asahi-scripts`, not us |
| `CONFIG_DRM_ASAHI`, `CONFIG_DRM_ASAHI_DEBUG_ALLOCATOR` | Kernel DRM for Asahi GPU |
| `asahilinux.org`, `AsahiLinux`, `github.com/AsahiLinux/*` | Upstream URLs / copyright |
| `asahi_firmware` (e.g. `bluetooth.py`) | Asahi firmware Python modules |
| `*.asahi1-*` version strings (e.g. `7.1.6.asahi1-1`) | Upstream pkgver |
| `ASAHI_ALARM_SERVER` / `asahi_alarm_*` | Our env **wrapping the Asahi ALARM mirror** — KEEP the `asahi-alarm` token |

## IMMUTABLE catalog

### Git tags on omarchy-pkgs (131) — never rename

| Prefix | Count |
| --- | ---: |
| `asahi-packages-candidate-<40hex>` | 37 |
| `asahi-packages-stable-<40hex>` | 18 |
| `asahi-packages-channel-N` | 7 |
| `asahi-packages-<40hex>` (legacy, e.g. `asahi-packages-784daa3e…`) | 1 |
| `asahi-quattro-channel-N` plus floating `asahi-quattro-channel` | 21 |
| `asahi-quattro-<8hex>` (runtime releases) | 46 |
| `asahi-platform-snapshot-20260910` | 1 |

Future minting uses `mac-packages-*` / `mac-quattro-*`. Consumers dual-read old prefixes forever.

### R2 object keys — never rename

| Key | Public URL (default) |
| --- | --- |
| `pointers/asahi-quattro-channel` | `https://downloads.aicodelabs.com.au/pointers/asahi-quattro-channel` |
| `pointers/asahi-packages-channel` | `https://downloads.aicodelabs.com.au/pointers/asahi-packages-channel` |

From `bin/publish-asahi-channel-pointer` (`POINTER_KEY=pointers/${POINTER_NAME:-$CHANNEL_TAG_PREFIX}`). After rename, **write a new** `pointers/mac-*-channel` and keep reading/serving the old keys as aliases for one release. Do not overwrite historical bytes under a new key and delete the old one in the same step.

### `docs/releases` acceptance files (mx-mac `origin/main`, 17) — never rename

`docs/releases/asahi-packages-candidate-{009293b,06923606,23521851,437d2aed,5a3a266d,650a68d,802c6a85,83973903,8ea94e69,901e39bd,a9bf4e5d,afd72814,c7c5d590,ca4b5ee,cf3de447,e7574274,f701b12}-acceptance.txt`

omarchy-pkgs has **no** `docs/releases/` tree.

### Published GitHub release assets (immutable names)

On the tags above: `asahi-quattro-release`, `asahi-quattro-release.sig`, `asahi-quattro-bundle.manifest`, `asahi-quattro-bundle.manifest.sig`, `asahi-quattro-channel`, `asahi-packages-channel`, `install-asahi-quattro`, `asahi-repository-signing.asc` (as a **release asset**), `*-aarch64-apple-silicon-asahi-os-package.zip`. Source tree copies of the signing key **file** still RENAME (`keys/` / `default/`).

Historical bootstrap URLs in pkgs `README.md` (`asahi-quattro-channel-25`, `asahi-quattro-fe8d2bf8`) stay.

## MIGRATE catalog (installed Mac)

Snapshot: M2 inventory `m2-asahi-inventory.txt`. Pacman sections on that Mac: `[omarchy-aurora]`, `[omarchy]`, `[asahi-alarm]`, `[core]`, `[extra]`, `[alarm]`, `[aur]`.

### Do not migrate (KEEP on disk)

| Path / name | Owner |
| --- | --- |
| `[asahi-alarm]` | Asahi ALARM. The only asahi-named pacman **section**. Our repos are already `[omarchy]` / `[omarchy-aurora]`. |
| `/usr/lib/initcpio/hooks/asahi` | `asahi-scripts` |
| `/usr/lib/initcpio/install/asahi` | `asahi-scripts` |
| Packages `alsa-ucm-conf-asahi`, `asahi-alarm-keyring`, `asahi-audio`, `asahi-bless`, `asahi-desktop-meta`, `asahi-fwextract`, `asahi-scripts`, `uboot-asahi`, `vulkan-asahi` | Asahi / ALARM |
| `/var/lib/omarchy/backups/asahi-bundle-*`, `asahi-repository-*` | Historical backups. New backups use `mac-*`. Do not rewrite old trees. |

### Migrate (old name = alias for one release)

| # | Old | New | Step |
| --- | --- | --- | --- |
| 1 | `/etc/mkinitcpio.conf.d/90-omarchy-asahi.conf` | `90-omarchy-mac.conf` | Package ships **both** (or symlink old → new). Keep hook token `asahi` inside. Regenerating initramfs only after the conf still injects `asahi` + `omarchy-vendorfw`. |
| 2 | `/etc/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf` | `mac-audio-no-suspend.conf` | Install new drop-in; symlink old name one release. Restart wireplumber after both exist. Also the user copy `~/.config/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf` (migration `1788345489.sh`). |
| 3 | `/var/lib/omarchy/asahi-quattro-release` (+ `.pending`, `.tmp`) | `mac-quattro-release` | Writers dual-write; readers accept either. Then symlink old → new. |
| 4 | `/var/lib/omarchy/asahi-package-repository` | `mac-package-repository` | Same as (3). Contents still cite IMMUTABLE `asahi-packages-channel-*` / `asahi-packages-stable-*` tags. |
| 5 | `/var/lib/omarchy/asahi-btrfs-initramfs-ready` | `mac-btrfs-initramfs-ready` | `fix-asahi-btrfs-race.sh` / `OMARCHY_ASAHI_BTRFS_READY`. Touch new marker if old exists; keep old as alias. |
| 6 | pkg `omarchy-apple-boot` | `omarchy-mac-boot` | `replaces`/`provides`/`conflicts` the old name. Admission tests and `omarchy-update-system-pkgs --needed` follow the new pkgname in the **same** transaction as (1). |
| 7 | pkg `omarchy-settings-asahi` (on the Mac; **absent** from pkgs HEAD / mx-mac `origin/main`) | current `omarchy-settings` / `omarchy-settings-dev` | `replaces=(omarchy-settings-asahi)` on the settings package that now owns those files. |
| 8 | `/etc/pacman.conf` `Server=` URLs containing `asahi-packages-stable-<sha>` / legacy `asahi-packages-<sha>` | unchanged URLs | Those **tag** names are IMMUTABLE. Code dual-reads old and new prefixes. Do not rewrite `pacman.conf` Servers that still point at old tags. |
| 9 | GitHub Actions env `asahi-quattro-release` and concurrency groups `asahi-quattro-release` / `asahi-package-repository` | `mac-quattro-release` / `mac-package-repository` | Create the new GitHub Environment **before** workflow sed. Leave the old env one release for in-flight runs. |
| 10 | Branch `asahi-quattro` | `mac-quattro` | After mechanical PRs. Workflows currently require `refs/heads/asahi-quattro`. Dual-accept both refs for one release, then rename default branch. |

### Ordering constraint

1. Land **dual-read** (markers, tag prefixes, hook conf contents, package `replaces`) **before** any `git mv`.
2. Create GitHub Environment `mac-quattro-release`.
3. Ship `omarchy-mac-boot` that still installs a `90-omarchy-asahi.conf` **symlink** and still adds hook `asahi`.
4. Migration script: new marker files, then aliases, then `mkinitcpio -P` only if (1) succeeded.
5. Wireplumber conf after boot stack (audio is not required to boot).
6. Mechanical `git mv` / `sed` PRs **last**.
7. One subsequent release drops aliases and the old GitHub env / branch trigger.

Never migrate `[asahi-alarm]` or `asahi-scripts` hooks in the same change as (1): losing hook `asahi` unboots vendor firmware.

## omarchy-pkgs (this tree) — by file

Class letters: K KEEP, R RENAME, I IMMUTABLE, M MIGRATE (code that **writes** installed names).

### `.github/scripts/`

| File | Class | Action |
| --- | --- | --- |
| `verify-asahi-package-transaction.sh` | R | → `verify-mac-package-transaction.sh` |
| `verify-asahi-repository-lifecycle.sh` | R+K | → `verify-mac-repository-lifecycle.sh`. KEEP `[asahi-alarm]`, `asahi-scripts`, `asahi-alarm-keyring`, `pacman-key --populate asahi-alarm` |
| `verify-asahi-settings-zram-layout.sh` | R | → `verify-mac-settings-zram-layout.sh` (filename only; body has no `asahi`) |

### `.github/workflows/`

| File | Class | Action |
| --- | --- | --- |
| `export-asahi-repository-certificate.yml` | R | → `export-mac-repository-certificate.yml`; env `asahi-quattro-release` → `mac-quattro-release` |
| `promote-asahi-quattro-runtime.yml` | R+I | → `promote-mac-quattro-runtime.yml`; dual-read old tags |
| `publish-asahi-channel-pointer.yml` | R+I | → `publish-mac-channel-pointer.yml`; R2 keys I |
| `publish-asahi-packages-channel.yml` | R+I | → `publish-mac-packages-channel.yml` |
| `release-asahi-package-candidate.yml` | R+I+K | → `release-mac-package-candidate.yml`; `PREVIOUS_PACKAGE_RELEASE: asahi-packages-784daa3e…` is I; cache `asahi-builder-aarch64-edge-v1` → `mac-builder-aarch64-edge-v1` (cache miss OK) |
| `release-asahi-package-incremental.yml` | R+I | → `release-mac-package-incremental.yml` |
| `release-asahi-packages.yml` | R+I | → `release-mac-packages.yml`; group `asahi-package-repository` → `mac-package-repository` |
| `release-asahi-quattro.yml` | R+I | → `release-mac-quattro.yml`; `branches` / `GITHUB_REF` `asahi-quattro`; asset names I on old tags |
| `test-asahi-release-inputs.yml` | R | → `test-mac-release-inputs.yml`; `branches: [asahi-quattro]` |
| `authorize-arm64-iso.yml` | R | one `asahi` mention (content) |
| `publish-arm64-iso.yml` | R | env `asahi-quattro-release` |
| `release-apple-bootstrap.yml` | R+K+I | KEEP `[asahi-alarm]`; env R; `apple*` stays |
| `release-aurora-edge.yml` | R+K | env R; `asahi-builder-aarch64-edge-v2`; m1n1-aurora / Asahi independent channel K |
| `release-aurora-package.yml` | R | env + `refs/heads/asahi-quattro` |

### `bin/`

| File | Class | New name / notes |
| --- | --- | --- |
| `asahi-release` | R+I+M | → `mac-release`. `ASAHI_RELEASE_*` → `MAC_RELEASE_*`. `environment=asahi-quattro-release`. Default `OMARCHY_ASAHI_RELEASE_FILE=/var/lib/omarchy/asahi-quattro-release` M. Lab config coupling. |
| `asahi-release-controller` | R | → `mac-release-controller`. `ASAHI_CONTROLLER_TEST_MODE` → `MAC_CONTROLLER_TEST_MODE` |
| `asahi-runtime-release` | R | → `mac-runtime-release` |
| `asahi-cache` | R | → `mac-cache` |
| `asahi-candidate-assemble` | R | → `mac-candidate-assemble` |
| `asahi-candidate-lineage` | R | → `mac-candidate-lineage` |
| `asahi-candidate-provenance` | R | → `mac-candidate-provenance` |
| `asahi-incremental-plan` | R | → `mac-incremental-plan` |
| `asahi-package-build-key` | R | → `mac-package-build-key` |
| `asahi-package-candidate-descriptor` | R | → `mac-package-candidate-descriptor` |
| `asahi-package-payload` | R | → `mac-package-payload` |
| `asahi-package-retention-plan` | R | → `mac-package-retention-plan` |
| `asahi-signing-subkey-validate` | R | → `mac-signing-subkey-validate` |
| `asahi-verify-candidate` | R | → `mac-verify-candidate` |
| `asahi-verify-packages-channel` | R+I | → `mac-verify-packages-channel`. Channel file `asahi-packages-channel` is I on old tags |
| `asahi-bundle-manifest` | R | → `mac-bundle-manifest`. Asset `asahi-quattro-bundle.manifest` is I |
| `install-asahi-quattro` | R+I+M | → `install-mac-quattro`. Published asset name I. Writes `/var/lib/omarchy/asahi-quattro-release` M |
| `release-asahi-quattro` | R+I | → `release-mac-quattro` |
| `reuse-asahi-package` | R+I | → `reuse-mac-package` |
| `promote-asahi-package-candidate` | R+I | → `promote-mac-package-candidate` |
| `publish-asahi-channel-pointer` | R+I | → `publish-mac-channel-pointer`. `CHANNEL_TAG_PREFIX=asahi-*-channel` minting R, existing R2 keys I. Default signing key `keys/asahi-repository-signing.asc` R |
| `publish-asahi-packages-channel` | R+I | → `publish-mac-packages-channel` |
| `verify-asahi-runtime-version` | R | → `verify-mac-runtime-version` |
| `apple-bootstrap-check` | R+M+K | `apple*` stays. Marker `asahi-package-repository` M |
| `apple-bootstrap-inputs` | R+I | |
| `build-apple-bootstrap` | R+M+I | writes `asahi-package-repository` M |
| `aurora-package-descriptor` | R | planner / asahi inventory refs |
| `aurora-verify-edge-release` | R | pointer tests grep `asahi-quattro-channel` |

### `docs/`, `keys/`, planner lists

| File | Class | Action |
| --- | --- | --- |
| `docs/asahi-planner-replay.md` | R+I | → `mac-planner-replay.md`. Cites `asahi-packages-candidate-*` I |
| `docs/asahi-resumable-release.md` | R+K+I | → `mac-resumable-release.md`. KEEP `asahi-fwextract`, `asahi-scripts`. Planner path `pkgbuilds/asahi-source-outputs` R |
| `keys/asahi-repository-signing.asc` | R | → `keys/mac-repository-signing.asc`. **Same basename as published release assets** — those assets stay |
| `pkgbuilds/asahi-planner-classes` | R | → `mac-planner-classes`. Every `bin/asahi-*` row R |
| `pkgbuilds/asahi-repository-packages` | R | → `mac-repository-packages`. Contains `omarchy-apple-boot` (collision → `omarchy-mac-boot`) |
| `pkgbuilds/asahi-repository-sources` | R | → `mac-repository-sources` |
| `pkgbuilds/asahi-source-outputs` | R | → `mac-source-outputs` |

### `pkgbuilds/` (packages)

| File | Class | Action |
| --- | --- | --- |
| `linux-aurora/config` | K | `CONFIG_DRM_ASAHI*` only |
| `linux-aurora-edge/config` | K | same |
| `linux-aurora/PKGBUILD` | K+R | KEEP `linux-asahi` provides/conflicts and “asahi-alarm linux-asahi package”. RENAME prose “default Asahi lane” → “default Mac lane” |
| `linux-aurora-edge/PKGBUILD` | K+R | same |
| `m1n1-aurora/PKGBUILD` | K | `depends=('asahi-scripts>=…')`; “Asahi package and channel remain independent” |
| `m1n1-aurora/README.md` | K | Asahi/m1n1 |
| `nordvpn-bin/PKGBUILD` | R | comment “Asahi extra” → “Mac extra” |
| `omarchy-apple-boot/` **dir** | R | → `pkgbuilds/omarchy-mac-boot/`; `pkgname=omarchy-mac-boot` with `replaces=(omarchy-apple-boot)` |
| `omarchy-apple-boot/90-omarchy-asahi.conf` | R+K+M | → `90-omarchy-mac.conf`. KEEP hook token `asahi`. M on `/etc/mkinitcpio.conf.d/` |
| `omarchy-apple-boot/PKGBUILD` | R+K+M | KEEP `depends=('asahi-scripts' …)`; backup path R |
| `omarchy-apple-boot/omarchy-vendorfw.initcpio-install` | K | “asahi hook's early/late runscripts” |
| `omarchy-apple-boot/omarchy-vendorfw.service` | K | asahi hook counterpart |
| `omarchy-apple-boot/omarchy-vendorfw.sh` | K | same |
| `omarchy-apple-boot/apple-image-finalize` | R+K | `apple*` stays; asahi hook / conf refs |
| `omarchy-first-boot/omarchy-first-boot` | R+K+I+M | `OMARCHY_ASAHI_*` → `OMARCHY_MAC_*`; KEEP `linux-asahi`, `asahi-alarm`; pointer URLs / tag regexes I+dual-read |
| `omarchy-settings-dev/PKGBUILD` | K | comment `linux-asahi` zswap default |

### `test/` (pkgs)

Every `test/asahi-*` → `test/mac-*` (R). Tests `grep` workflow filenames, `bin/` names, env `asahi-quattro-release`, tag regexes (I), and `[asahi-alarm]` (K). Highest grep volume: `test/asahi-release` (248), `test/asahi-packages-channel` (118), `test/asahi-installer-discovery` (77), `test/asahi-channel-pointer` (72).

| File | Class | Notes |
| --- | --- | --- |
| `test/asahi-iso-approval-workflow` | R | filename; body has no `asahi` (greps ISO workflow) |
| `test/fixtures/apple-image-parity/asahi.{manifest,reference,differences}` | R | → `mac.*` (our image lane vs aurora, not the Asahi kernel) |
| `test/fixtures/apple-image-parity/{aurora.manifest,shared-paths}` | R | path `90-omarchy-asahi.conf` |
| `test/apple-bootstrap` | R+I+M | `environment: asahi-quattro-release`; `refs/heads/asahi-quattro`; marker file |
| `test/apple-image-parity` | R | fixture names |
| `test/aurora-*` | R | workflow env / pointer greps |
| `test/omarchy-apple-boot` | R+M | hashes `90-omarchy-asahi.conf`; follow pkg → `test/omarchy-mac-boot` |
| `test/omarchy-first-boot` | R+K+I | `asahi-alarm` K; `linux-asahi` K; `OMARCHY_ASAHI_*` R |

### Other pkgs

| File | Class | Notes |
| --- | --- | --- |
| `README.md` | R+K+I | KEEP “Asahi Linux”, `linux-asahi`, “Asahi Arch Minimal”. IMMUTABLE bootstrap URLs (`asahi-quattro-channel-25`, `install-asahi-quattro`, `asahi-quattro-fe8d2bf8`). RENAME remaining “Asahi Quattro” product prose |

Branch names (`asahi-quattro`, `fix/asahi-*`, `runtime/asahi-*`) are history; only default **`asahi-quattro` → `mac-quattro`** is in scope (after mechanical PR).

## omarchy-mx-mac (`origin/main`) — by file

`apple*` installer tree stays. Engine wrappers KEEP.

### KEEP filenames (do not `git mv`)

| File | Class |
| --- | --- |
| `apps/omarchy-apple-installer/Engine/overlay/src/omarchy_asahi.py` | K (Asahi installer overlay) |
| `apps/omarchy-apple-installer/Engine/overlay/tests/test_omarchy_asahi.py` | K |
| `apps/omarchy-apple-installer/Sources/OmarchyAppleInstaller/PinnedAsahiEngineExecutor.swift` | K |
| `apps/omarchy-apple-installer/Sources/OmarchyAppleInstaller/PinnedAsahiPlanning.swift` | K |
| `apps/omarchy-apple-installer/Tests/…/PinnedAsahiEngineExecutorTests.swift` | K |
| `apps/omarchy-apple-installer/Tests/…/PinnedAsahiPlanningTests.swift` | K |
| `docs/research/asahi-installer-integration-contract.md` | K (contract with Asahi installer) |

Content in those files that is **our** lane (`asahi-quattro`, `omarchy-install-asahi-fresh`) is still RENAME inside KEEP-named files.

### IMMUTABLE filenames (do not `git mv`)

All 17 `docs/releases/asahi-packages-candidate-*-acceptance.txt`.

Other `docs/releases/*.md` (v4.0.x-mac, preparation, release-notes): RENAME our product “Asahi” prose; KEEP/IMMUTABLE tag citations.

### RENAME paths

| Old | New |
| --- | --- |
| `bin/omarchy-install-asahi-fresh` | `bin/omarchy-install-mac-fresh` |
| `bin/omarchy-update-asahi-bundle` | `bin/omarchy-update-mac-bundle` |
| `bin/omarchy-update-asahi-repository` | `bin/omarchy-update-mac-repository` |
| `default/asahi-repository-signing.asc` | `default/mac-repository-signing.asc` |
| `default/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf` | `…/mac-audio-no-suspend.conf` |
| `etc/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf` | `…/mac-audio-no-suspend.conf` |
| `install/hardware/apple/fix-asahi-btrfs-race.sh` | `fix-mac-btrfs-race.sh` (`apple/` dir stays) |
| `install/hardware/apple/fix-asahi-hid-race.sh` | `fix-mac-hid-race.sh` |
| `install/omarchy-base-asahi.packages` | `install/omarchy-base-mac.packages` |
| `install/omarchy-other-asahi.packages` | `install/omarchy-other-mac.packages` |
| `test/shell.d/asahi-bootstrap-channel-test.sh` | `mac-bootstrap-channel-test.sh` |
| `test/shell.d/asahi-bootstrap-test.sh` | `mac-bootstrap-test.sh` |
| `test/shell.d/asahi-btrfs-race-test.sh` | `mac-btrfs-race-test.sh` |
| `test/shell.d/asahi-bundle-update-test.sh` | `mac-bundle-update-test.sh` |
| `test/shell.d/asahi-fresh-deferred-test.sh` | `mac-fresh-deferred-test.sh` |
| `test/shell.d/asahi-fresh-install-test.sh` | `mac-fresh-install-test.sh` |
| `test/shell.d/asahi-fresh-offline-test.sh` | `mac-fresh-offline-test.sh` |
| `test/shell.d/asahi-fresh-vm-run-test.sh` | `mac-fresh-vm-run-test.sh` |
| `test/shell.d/asahi-package-candidate-test.sh` | `mac-package-candidate-test.sh` |
| `test/shell.d/asahi-package-repository-test.sh` | `mac-package-repository-test.sh` |
| `test/shell.d/asahi-packages-test.sh` | `mac-packages-test.sh` |
| `test/shell.d/asahi-repository-update-test.sh` | `mac-repository-update-test.sh` |
| `test/shell.d/asahi-update-test.sh` | `mac-update-test.sh` |
| `test/shell.d/migrate-asahi-test.sh` | `migrate-mac-test.sh` |
| `test/shell.d/aurora-asahi-headers-migration-test.sh` | keep `linux-asahi-headers` in body; file → `aurora-linux-asahi-headers-migration-test.sh` (still K token) |
| `test/vm/asahi-fresh/` | `test/vm/mac-fresh/` (whole tree, including files whose **content** has no `asahi`) |

Filename-only (no content match): `default/asahi-repository-signing.asc`, `fix-asahi-btrfs-race.sh`, `fix-asahi-hid-race.sh`, `test/vm/asahi-fresh/{container/start-vm,guest/alarm-snapshot,guest/optional-packages}`.

### Content-only (sed; `apple*` filenames stay)

`.github/workflows/{optional-packages,packages,release}.yml` — grep pkgs workflow/tag names (R+I).

`.gitignore`, `.opencode/skills/update-omarchy-quattro/SKILL.md`, `CHANGELOG.md`, `README.md` — R+K+I.

**Installer app** (besides KEEP files): overlay `omarchy_{execution,planner,runtime,stage1}.py` and tests; `source-lock.json`, `installer_data.json`, `0001-omarchy-engine-runtime.patch`, `rebuild-python-overlay.py`, `verify-source-lock.py` + tests; Swift callers of `PinnedAsahi*` (KEEP type names, RENAME our URLs/tags); `scripts/{assemble-candidate-v8.sh,cutover-wizard,make-unsigned-catalog.py,release-inputs*.json}`; `docs/e2e-runbook.md`; Design/Development prose. `Packaging/README.md`.

**bin/** (stay apple-named unless listed above): `omarchy-apple-platform-stack-verify`, `omarchy-apple-silicon-*`, `omarchy-debug-apple`, `omarchy-hw-apple-kernel`, `omarchy-migrate` (`asahi=1` → `mac=1` / `apple_silicon`; disposition strings “Asahi” → “Mac”), `omarchy-pkg-repository-*`, `omarchy-reinstall-pkgs`, `omarchy-setup-direct-boot`, `omarchy-update`, `omarchy-update-apple-boot-admission` (filename stays; pkgname → `omarchy-mac-boot`), `omarchy-update-aurora-repository`, `omarchy-update-available`, `omarchy-upgrade-to-quattro` (73 matches — tag/channel/bin couplings).

`--asahi-packages` → `--mac-packages`. `OMARCHY_ASAHI_*` / `OMARCHY_VM_ASAHI_*` → `OMARCHY_MAC_*` / `OMARCHY_VM_MAC_*`.

**install/**: `omarchy-base-mac.packages` still **lists** KEEP packages (`asahi-desktop-meta`, `asahi-fwextract`, `linux-asahi`, `linux-asahi-headers`). `omarchy-other-mac.packages` KEEP `vulkan-asahi`. `install/hardware/pacman.sh` I bootstrap tag `asahi-packages-784daa3e…` + `OMARCHY_ASAHI_*`. `install/hardware/{all,vulkan}.sh`, `post-install/pacman.sh`, `install-omarchy-mx-mac{,.sh}`, `apple-silicon-platform-stack.json`, speaker-pop scripts.

**migrations/**: `1784401744.sh` KEEP `vulkan-asahi`; `1787491150.sh` R prose; `1787497040.sh` R script path; `1788345489.sh` M wireplumber paths; `1789107528.sh` M btrfs marker; `1789444024.sh` KEEP `linux-asahi`; `1789879296.sh` KEEP `linux-asahi-headers` (repair, do not rename the package).

**tests** (high volume): `asahi-bundle-update-test.sh` 112, `asahi-repository-update-test.sh` 103, `asahi-bootstrap-channel-test.sh` 56, `apple-silicon-channel-test.sh` 50, `apple-silicon-boot-check-test.sh` 39, `asahi-fresh-install-test.sh` 38, `aurora-asahi-headers-migration-test.sh` 38, `migrate-asahi-test.sh` 33, `upgrade-to-quattro-test.sh` 32. All `grep` bin names / tag literals / `--asahi-packages`.

**docs/** (non-acceptance): `apple-silicon-deployment.md` 115, `build-architecture-mx-mac.html` 71, `docs/research/asahi-installer-integration-contract.md` 67 (KEEP file), `apple-silicon-distribution-channels.md` 50, `apple-silicon-installer-safety-plan.md` 46, plus parity/changelog/DHH notes. Evidence trees: KEEP Asahi Linux citations; RENAME our lane names.

**site/index.html**, `manual/49-omarchy-on.md`, `scripts/cleanup-tonights-extras.py`: R/I.

`default/wireplumber/scripts/node/software-dsp.lua`: mentions asahi-audio stack — KEEP package, RENAME our conf filename if referenced.

## omarchy-lab

| File | Class | Action |
| --- | --- | --- |
| `asahi-release.conf` | R | → `mac-release.conf`. `ASAHI_RELEASE_*` → `MAC_RELEASE_*`. Comment `bin/asahi-release` / `ASAHI_RELEASE_CONFIG=~/omarchy-lab/asahi-release.conf` |
| `README.md` | K | `asahi-bless`; `AsahiLinux/macvdmtool` |
| `NEW-INSTALL.md` | K | `asahi-bless --list-volumes` |
| `serve/setup-test-mac.sh` | K | `asahi-bless` |
| `macvdmtool/README.md` | K | “Asahi Linux Contributors” — third-party clone, do not edit |
| `macvdmtool/.git/**` | — | out of scope |

## Cross-repo couplings

| Coupling | Repos | Risk |
| --- | --- | --- |
| `bin/asahi-release` + `ASAHI_RELEASE_CONFIG` + `~/omarchy-lab/asahi-release.conf` | pkgs, lab | Operator release stops if only one side moves |
| `keys/asahi-repository-signing.asc` ↔ `default/asahi-repository-signing.asc` | pkgs, mx-mac | Same key, two paths; also a **published asset** basename I |
| Planner `pkgbuilds/asahi-planner-classes` lists every `bin/asahi-*` | pkgs | Must `git mv` bins and rewrite the class file together |
| Workflows invoke `bin/asahi-*` and `test/asahi-*` | pkgs | Workflow `git mv` + `sed` in one PR |
| Tests `grep -Fq 'environment: asahi-quattro-release'` / `group: asahi-quattro-release` / `refs/heads/asahi-quattro` | pkgs | GitHub env + branch must exist before CI |
| mx-mac tests `grep` pkgs workflow names (`publish-asahi-channel-pointer.yml`, `promote-asahi-quattro-runtime.yml`) and tags `asahi-packages-stable-` | both | Mechanical PRs same day; dual-read already landed |
| `omarchy-install-asahi-fresh`, `omarchy-update-asahi-*` ↔ pkgs `install-asahi-quattro`, channel tags, pointer URLs | both | Fresh install / update |
| `--asahi-packages` flag ↔ tests and `omarchy-base-asahi.packages` | mx-mac | Flag + path + package list |
| `omarchy-apple-boot` pkgname ↔ mx-mac `omarchy-update-apple-boot-admission` / `omarchy-update-system-pkgs` / apple-boot tests | both | Collision rename |
| Pointer URLs `downloads.aicodelabs.com.au/pointers/asahi-*-channel` | pkgs first-boot, mx-mac update, installer | I keys; dual-read |
| `origin/asahi-quattro` mentioned from mx-mac | both | Branch rename last |
| `linux-asahi` / `linux-asahi-headers` in mx-mac package lists, first-boot, aurora headers migration | both | KEEP package; aurora provides it |
| PinnedAsahi\* / `omarchy_asahi.py` imported by runtime/planner/stage1 | mx-mac only | KEEP; do not “mac” the engine |
| `asahi-audio-no-suspend.conf` in default/ + etc/ + migration + Mac `/etc/wireplumber` | mx-mac + MIGRATE | Three copies + user config |
| GitHub cache scope `asahi-builder-aarch64-edge-v{1,2}` | pkgs | Rename = cold cache only |

## PR split (mechanical PRs last)

**Already required before these lists** (separate, non-mechanical PRs): dual-read of old tag prefixes, R2 keys, marker paths, mkinitcpio conf symlink, `replaces=(omarchy-apple-boot)`, GitHub Environment `mac-quattro-release`, workflows accepting `asahi-quattro` **or** `mac-quattro`.

Then **one mechanical PR per repo**, same window, pkgs first so mx-mac greps can follow.

### A. omarchy-lab (tiny; can land with pkgs)

```bash
git mv asahi-release.conf mac-release.conf
sed -i '' \
  -e 's/bin\/asahi-release/bin\/mac-release/g' \
  -e 's/ASAHI_RELEASE_/MAC_RELEASE_/g' \
  -e 's/asahi-release\.conf/mac-release.conf/g' \
  mac-release.conf
```

Do not touch `asahi-bless` or `macvdmtool`.

### B. omarchy-pkgs mechanical PR — ordered `git mv`

```bash
# scripts + workflows
git mv .github/scripts/verify-asahi-package-transaction.sh .github/scripts/verify-mac-package-transaction.sh
git mv .github/scripts/verify-asahi-repository-lifecycle.sh .github/scripts/verify-mac-repository-lifecycle.sh
git mv .github/scripts/verify-asahi-settings-zram-layout.sh .github/scripts/verify-mac-settings-zram-layout.sh
git mv .github/workflows/export-asahi-repository-certificate.yml .github/workflows/export-mac-repository-certificate.yml
git mv .github/workflows/promote-asahi-quattro-runtime.yml .github/workflows/promote-mac-quattro-runtime.yml
git mv .github/workflows/publish-asahi-channel-pointer.yml .github/workflows/publish-mac-channel-pointer.yml
git mv .github/workflows/publish-asahi-packages-channel.yml .github/workflows/publish-mac-packages-channel.yml
git mv .github/workflows/release-asahi-package-candidate.yml .github/workflows/release-mac-package-candidate.yml
git mv .github/workflows/release-asahi-package-incremental.yml .github/workflows/release-mac-package-incremental.yml
git mv .github/workflows/release-asahi-packages.yml .github/workflows/release-mac-packages.yml
git mv .github/workflows/release-asahi-quattro.yml .github/workflows/release-mac-quattro.yml
git mv .github/workflows/test-asahi-release-inputs.yml .github/workflows/test-mac-release-inputs.yml

# bin
git mv bin/asahi-bundle-manifest bin/mac-bundle-manifest
git mv bin/asahi-cache bin/mac-cache
git mv bin/asahi-candidate-assemble bin/mac-candidate-assemble
git mv bin/asahi-candidate-lineage bin/mac-candidate-lineage
git mv bin/asahi-candidate-provenance bin/mac-candidate-provenance
git mv bin/asahi-incremental-plan bin/mac-incremental-plan
git mv bin/asahi-package-build-key bin/mac-package-build-key
git mv bin/asahi-package-candidate-descriptor bin/mac-package-candidate-descriptor
git mv bin/asahi-package-payload bin/mac-package-payload
git mv bin/asahi-package-retention-plan bin/mac-package-retention-plan
git mv bin/asahi-release bin/mac-release
git mv bin/asahi-release-controller bin/mac-release-controller
git mv bin/asahi-runtime-release bin/mac-runtime-release
git mv bin/asahi-signing-subkey-validate bin/mac-signing-subkey-validate
git mv bin/asahi-verify-candidate bin/mac-verify-candidate
git mv bin/asahi-verify-packages-channel bin/mac-verify-packages-channel
git mv bin/install-asahi-quattro bin/install-mac-quattro
git mv bin/promote-asahi-package-candidate bin/promote-mac-package-candidate
git mv bin/publish-asahi-channel-pointer bin/publish-mac-channel-pointer
git mv bin/publish-asahi-packages-channel bin/publish-mac-packages-channel
git mv bin/release-asahi-quattro bin/release-mac-quattro
git mv bin/reuse-asahi-package bin/reuse-mac-package
git mv bin/verify-asahi-runtime-version bin/verify-mac-runtime-version

# docs, keys, planner lists
git mv docs/asahi-planner-replay.md docs/mac-planner-replay.md
git mv docs/asahi-resumable-release.md docs/mac-resumable-release.md
git mv keys/asahi-repository-signing.asc keys/mac-repository-signing.asc
git mv pkgbuilds/asahi-planner-classes pkgbuilds/mac-planner-classes
git mv pkgbuilds/asahi-repository-packages pkgbuilds/mac-repository-packages
git mv pkgbuilds/asahi-repository-sources pkgbuilds/mac-repository-sources
git mv pkgbuilds/asahi-source-outputs pkgbuilds/mac-source-outputs

# package collision
git mv pkgbuilds/omarchy-apple-boot pkgbuilds/omarchy-mac-boot
git mv pkgbuilds/omarchy-mac-boot/90-omarchy-asahi.conf pkgbuilds/omarchy-mac-boot/90-omarchy-mac.conf

# tests
git mv test/asahi-bundle-manifest test/mac-bundle-manifest
git mv test/asahi-candidate-incremental test/mac-candidate-incremental
git mv test/asahi-channel-pointer test/mac-channel-pointer
git mv test/asahi-incremental-release test/mac-incremental-release
git mv test/asahi-incremental-workflow test/mac-incremental-workflow
git mv test/asahi-input-classification test/mac-input-classification
git mv test/asahi-installer-discovery test/mac-installer-discovery
git mv test/asahi-iso-approval-workflow test/mac-iso-approval-workflow
git mv test/asahi-iso-r2-publication-workflow test/mac-iso-r2-publication-workflow
git mv test/asahi-iso-r2-staging test/mac-iso-r2-staging
git mv test/asahi-package-build-key test/mac-package-build-key
git mv test/asahi-package-candidate-descriptor test/mac-package-candidate-descriptor
git mv test/asahi-package-lifecycle test/mac-package-lifecycle
git mv test/asahi-package-payload test/mac-package-payload
git mv test/asahi-package-promotion test/mac-package-promotion
git mv test/asahi-package-repository test/mac-package-repository
git mv test/asahi-package-retention test/mac-package-retention
git mv test/asahi-package-reuse test/mac-package-reuse
git mv test/asahi-packages-channel test/mac-packages-channel
git mv test/asahi-release test/mac-release
git mv test/asahi-release-controller test/mac-release-controller
git mv test/asahi-runtime-promotion test/mac-runtime-promotion
git mv test/asahi-runtime-release test/mac-runtime-release
git mv test/asahi-runtime-version test/mac-runtime-version
git mv test/asahi-signing-subkey test/mac-signing-subkey
git mv test/fixtures/apple-image-parity/asahi.differences test/fixtures/apple-image-parity/mac.differences
git mv test/fixtures/apple-image-parity/asahi.manifest test/fixtures/apple-image-parity/mac.manifest
git mv test/fixtures/apple-image-parity/asahi.reference test/fixtures/apple-image-parity/mac.reference
git mv test/omarchy-apple-boot test/omarchy-mac-boot
```

### B. omarchy-pkgs mechanical `sed` (most specific first)

Never run a global `s/asahi/mac/gi`. Apply **in this order** on the tree after `git mv`:

```bash
# 1. Path / tool names (ours)
sed -i '' \
  -e 's/asahi-planner-classes/mac-planner-classes/g' \
  -e 's/asahi-repository-packages/mac-repository-packages/g' \
  -e 's/asahi-repository-sources/mac-repository-sources/g' \
  -e 's/asahi-source-outputs/mac-source-outputs/g' \
  -e 's/asahi-planner-replay/mac-planner-replay/g' \
  -e 's/asahi-resumable-release/mac-resumable-release/g' \
  -e 's/keys\/asahi-repository-signing\.asc/keys\/mac-repository-signing.asc/g' \
  -e 's/90-omarchy-asahi\.conf/90-omarchy-mac.conf/g' \
  -e 's/pkgbuilds\/omarchy-apple-boot/pkgbuilds\/omarchy-mac-boot/g' \
  -e 's/pkgname=omarchy-apple-boot/pkgname=omarchy-mac-boot/g' \
  -e 's/verify-asahi-/verify-mac-/g' \
  -e 's/test-asahi-release-inputs/test-mac-release-inputs/g' \
  -e 's/export-asahi-repository-certificate/export-mac-repository-certificate/g' \
  -e 's/promote-asahi-quattro-runtime/promote-mac-quattro-runtime/g' \
  -e 's/publish-asahi-channel-pointer/publish-mac-channel-pointer/g' \
  -e 's/publish-asahi-packages-channel/publish-mac-packages-channel/g' \
  -e 's/release-asahi-package-incremental/release-mac-package-incremental/g' \
  -e 's/release-asahi-package-candidate/release-mac-package-candidate/g' \
  -e 's/release-asahi-packages/release-mac-packages/g' \
  -e 's/release-asahi-quattro/release-mac-quattro/g' \
  -e 's/install-asahi-quattro/install-mac-quattro/g' \
  -e 's/promote-asahi-package-candidate/promote-mac-package-candidate/g' \
  -e 's/reuse-asahi-package/reuse-mac-package/g' \
  -e 's/bin\/asahi-/bin\/mac-/g' \
  -e 's/test\/asahi-/test\/mac-/g' \
  -e 's/test\/omarchy-apple-boot/test\/omarchy-mac-boot/g' \
  -e 's/asahi-builder-aarch64/mac-builder-aarch64/g'

# 2. Env / GitHub / branch (ours). Dual-read must already accept old values.
sed -i '' \
  -e 's/ASAHI_RELEASE_/MAC_RELEASE_/g' \
  -e 's/ASAHI_QUATTRO_/MAC_QUATTRO_/g' \
  -e 's/ASAHI_PACKAGE_/MAC_PACKAGE_/g' \
  -e 's/ASAHI_CONTROLLER_/MAC_CONTROLLER_/g' \
  -e 's/ASAHI_RUNTIME_/MAC_RUNTIME_/g' \
  -e 's/ASAHI_CANDIDATE_/MAC_CANDIDATE_/g' \
  -e 's/ASAHI_KEYRING_/MAC_KEYRING_/g' \
  -e 's/ASAHI_STAGE_/MAC_STAGE_/g' \
  -e 's/ASAHI_CURRENT_/MAC_CURRENT_/g' \
  -e 's/ASAHI_KEY=/MAC_KEY=/g' \
  -e 's/OMARCHY_ASAHI_/OMARCHY_MAC_/g' \
  -e 's/environment: asahi-quattro-release/environment: mac-quattro-release/g' \
  -e "s/group: asahi-quattro-release/group: mac-quattro-release/g" \
  -e 's/asahi-package-repository/mac-package-repository/g' \
  -e 's/asahi-package-verify-/mac-package-verify-/g' \
  -e 's/asahi-quattro-verify-/mac-quattro-verify-/g' \
  -e 's/refs\/heads\/asahi-quattro/refs\/heads\/mac-quattro/g' \
  -e 's/branches: \[asahi-quattro\]/branches: [mac-quattro]/g' \
  -e 's/_omarchy_asahi_/_omarchy_mac_/g'

# 3. Future minting prefixes ONLY in assignment/format sites, not in
#    historical URL citations (README bootstrap, PREVIOUS_PACKAGE_RELEASE).
#    Those stay asahi-packages-* / asahi-quattro-* (IMMUTABLE).
```

**Forbidden substitutions:** `asahi-alarm`, `asahi-scripts`, `asahi-fwextract`, `linux-asahi`, `asahi-audio` (package), `asahi-bless`, `asahi-desktop-meta`, `uboot-asahi`, `asahi-installer`, `PinnedAsahi`, `omarchy_asahi`, `AsahiLinux`, `asahilinux.org`, `CONFIG_DRM_ASAHI`, hook `== asahi`, `ASAHI_ALARM_`, `pointers/asahi-`, `releases/download/asahi-`.

After sed: `rg -i asahi` should only hit KEEP + IMMUTABLE citations + this inventory.

### C. omarchy-mx-mac mechanical PR — ordered `git mv`

```bash
git mv bin/omarchy-install-asahi-fresh bin/omarchy-install-mac-fresh
git mv bin/omarchy-update-asahi-bundle bin/omarchy-update-mac-bundle
git mv bin/omarchy-update-asahi-repository bin/omarchy-update-mac-repository
git mv default/asahi-repository-signing.asc default/mac-repository-signing.asc
git mv default/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf \
       default/wireplumber/wireplumber.conf.d/mac-audio-no-suspend.conf
git mv etc/wireplumber/wireplumber.conf.d/asahi-audio-no-suspend.conf \
       etc/wireplumber/wireplumber.conf.d/mac-audio-no-suspend.conf
git mv install/hardware/apple/fix-asahi-btrfs-race.sh install/hardware/apple/fix-mac-btrfs-race.sh
git mv install/hardware/apple/fix-asahi-hid-race.sh install/hardware/apple/fix-mac-hid-race.sh
git mv install/omarchy-base-asahi.packages install/omarchy-base-mac.packages
git mv install/omarchy-other-asahi.packages install/omarchy-other-mac.packages
git mv test/shell.d/asahi-bootstrap-channel-test.sh test/shell.d/mac-bootstrap-channel-test.sh
git mv test/shell.d/asahi-bootstrap-test.sh test/shell.d/mac-bootstrap-test.sh
git mv test/shell.d/asahi-btrfs-race-test.sh test/shell.d/mac-btrfs-race-test.sh
git mv test/shell.d/asahi-bundle-update-test.sh test/shell.d/mac-bundle-update-test.sh
git mv test/shell.d/asahi-fresh-deferred-test.sh test/shell.d/mac-fresh-deferred-test.sh
git mv test/shell.d/asahi-fresh-install-test.sh test/shell.d/mac-fresh-install-test.sh
git mv test/shell.d/asahi-fresh-offline-test.sh test/shell.d/mac-fresh-offline-test.sh
git mv test/shell.d/asahi-fresh-vm-run-test.sh test/shell.d/mac-fresh-vm-run-test.sh
git mv test/shell.d/asahi-package-candidate-test.sh test/shell.d/mac-package-candidate-test.sh
git mv test/shell.d/asahi-package-repository-test.sh test/shell.d/mac-package-repository-test.sh
git mv test/shell.d/asahi-packages-test.sh test/shell.d/mac-packages-test.sh
git mv test/shell.d/asahi-repository-update-test.sh test/shell.d/mac-repository-update-test.sh
git mv test/shell.d/asahi-update-test.sh test/shell.d/mac-update-test.sh
git mv test/shell.d/migrate-asahi-test.sh test/shell.d/migrate-mac-test.sh
git mv test/shell.d/aurora-asahi-headers-migration-test.sh \
       test/shell.d/aurora-linux-asahi-headers-migration-test.sh
git mv test/vm/asahi-fresh test/vm/mac-fresh
```

Do **not** `git mv` `omarchy_asahi.py`, `PinnedAsahi*`, `docs/research/asahi-installer-integration-contract.md`, or `docs/releases/asahi-packages-candidate-*-acceptance.txt`.

### C. omarchy-mx-mac mechanical `sed`

```bash
sed -i '' \
  -e 's/omarchy-install-asahi-fresh/omarchy-install-mac-fresh/g' \
  -e 's/omarchy-update-asahi-bundle/omarchy-update-mac-bundle/g' \
  -e 's/omarchy-update-asahi-repository/omarchy-update-mac-repository/g' \
  -e 's/--asahi-packages/--mac-packages/g' \
  -e 's/omarchy-base-asahi\.packages/omarchy-base-mac.packages/g' \
  -e 's/omarchy-other-asahi\.packages/omarchy-other-mac.packages/g' \
  -e 's/fix-asahi-btrfs-race/fix-mac-btrfs-race/g' \
  -e 's/fix-asahi-hid-race/fix-mac-hid-race/g' \
  -e 's/asahi-audio-no-suspend\.conf/mac-audio-no-suspend.conf/g' \
  -e 's/default\/asahi-repository-signing\.asc/default\/mac-repository-signing.asc/g' \
  -e 's/test\/vm\/asahi-fresh/test\/vm\/mac-fresh/g' \
  -e 's/test\/shell.d\/asahi-/test\/shell.d\/mac-/g' \
  -e 's/migrate-asahi-test/migrate-mac-test/g' \
  -e 's/OMARCHY_ASAHI_/OMARCHY_MAC_/g' \
  -e 's/OMARCHY_VM_ASAHI_/OMARCHY_VM_MAC_/g' \
  -e 's/omarchy-apple-boot/omarchy-mac-boot/g'
```

Forbidden: same KEEP list as pkgs, plus `PinnedAsahi`, `omarchy_asahi`, `asahiInstaller*`, `vulkan-asahi`, `linux-asahi`, `asahi-fwextract`, `asahi-scripts`, `asahi-bless`, `asahi-desktop-meta`, `alsa-ucm-conf-asahi`, `uboot-asahi`, `docs/releases/asahi-packages-candidate-`.

`omarchy-apple-boot` → `omarchy-mac-boot` is the **only** `apple*` exception. Do not rename `omarchy-apple-installer`, `omarchy-update-apple-boot-admission`, or `apple-silicon-*`.

### D. After both mechanical PRs

1. Rename GitHub default branch `asahi-quattro` → `mac-quattro`.
2. Point R2 `pointers/mac-quattro-channel` and `pointers/mac-packages-channel` at the same bytes as the old keys (alias).
3. Next OS release: drop on-disk aliases (MIGRATE step 7 in the ordering list).

## Riskiest ten (see also counts above)

1. Branch + `GITHUB_REF == refs/heads/asahi-quattro` (CI goes dark if renamed out of order).
2. GitHub Environment `asahi-quattro-release` (tests grep the literal; signing jobs gate on it).
3. R2 `pointers/asahi-*-channel` (IMMUTABLE; a blind key rename orphans every Mac).
4. Tag minting `asahi-packages-*` / `asahi-quattro-*` vs dual-read of 131 existing tags.
5. `/var/lib/omarchy/asahi-quattro-release` (update/first-boot identity).
6. `/var/lib/omarchy/asahi-package-repository` (channel state).
7. `omarchy-apple-boot` → `omarchy-mac-boot` (pacman target, admission, image-written files).
8. `90-omarchy-asahi.conf` vs KEEP hook `asahi` (wrong sed = unbootable firmware).
9. `asahi-repository-signing.asc` source vs published asset of the same name.
10. `bin/asahi-release` + `ASAHI_RELEASE_*` + lab `asahi-release.conf` (operator path).

Honorable mention: a global sed that rewrites `linux-asahi`, `[asahi-alarm]`, or `asahi-scripts`.
