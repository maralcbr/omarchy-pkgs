# Resumable native ARM64 releases

The ARM64 release path separates package publication, native ISO construction,
acceptance, and promotion into restartable stages. The controller never updates
or reboots its macOS host and always stops at `publication-hold`; publishing an
ISO or moving an ISO channel requires a separate explicit authorization.

## Package modes

`signing-check` validates release credentials without building. `verify` builds
and tests without publishing. `incremental` verifies an immutable predecessor,
rebuilds only invalidated package groups, preserves every reused archive and
signature byte-for-byte, recreates repository metadata, and emits
`PROVENANCE.json`. `full` rebuilds the complete inventory. Unknown changes,
shared builder or toolchain changes, signing trust changes, base-image changes,
or inventory changes fail closed to a full rebuild.

The planner treats `omarchy-settings-dev` and `omarchy-dev` as an atomic group.
Every package is attributed to a source through
`pkgbuilds/asahi-source-outputs`; split packages therefore rebuild together.
Before reuse, `asahi-verify-candidate` verifies the pinned candidate digest,
signed descriptor and runtime manifest, checksums, signing fingerprint,
package signatures, architectures, commits, and the exact 39-package inventory.

## Native M4 controller

Create an input JSON containing exact source, package, ISO, predecessor, key,
and builder identities plus per-stage commands. The builder identity must be 10
CPUs and 24 GiB. Initialize with:

```bash
bin/asahi-release-controller init "$HOME/omarchy-release-runs/RUN_ID" inputs.json
bin/asahi-release-controller resume "$HOME/omarchy-release-runs/RUN_ID"
bin/asahi-release-controller status "$HOME/omarchy-release-runs/RUN_ID"
```

Each command may be a string (local) or an object with `kind` (`local`, `ssh`,
or `github`) and `command`. A GitHub dispatch command writes its run ID to
`$ASAHI_STAGE_GITHUB_RUN_ID_FILE`; later resumes query that exact run instead of
dispatching again. Each resume advances one stage or reattaches to its detached
PID and status file. State and evidence files are replaced atomically under the
run directory. An existing GitHub run or local artifact may be recorded with
`adopt` after its identity is independently checked. SSH exit 255 records
`waiting-reconnect`, never failure; the remote command must recheck its durable
status file when resumed.

Invoke the controller with Bash 5 on macOS (normally
`/opt/homebrew/bin/bash`). Its run lock is an atomic directory operation and
does not require Linux `flock` on the host.

After correcting a non-product harness failure, `retry RUN_DIR STAGE` archives
the failed attempt under `evidence/attempts` and makes only that stage runnable
again. Complete stages and active stages cannot be reset.

The dedicated Lima VM uses `controller/lima/arm64-iso-builder.yaml`: native
AArch64 Arch Linux, 10 CPUs, 24 GiB, no container runtime, and a writable mount
of `~/omarchy-release-runs`. Inside it, run `controller/native-build-iso` as root
against a pinned ISO source tree and mounted artifact directory. It invokes
`build-iso.sh` directly, reuses only the scoped offline-mirror cache mounted
from `~/omarchy-release-runs/cache`, starts with a clean archiso work tree, and
records the single output ISO checksum.

Acceptance commands must reference that exact ISO path and expected SHA-256.
Headless encrypted acceptance and graphical Plymouth, LUKS, SDDM, and desktop
acceptance are independent gates. Package promotion and source/package tagging
must consume the accepted candidate identities. The generated ISO remains
unpublished at the final hold.

## Cache and shadow validation

`asahi-cache` stores immutable objects by SHA-256 using per-object locks and
temporary-file replacement, verifies every read, and supports an explicit byte
budget prune. Cache corruption is fatal and never silently becomes reuse.

Before enabling incremental publication, run the same pinned inputs through
incremental and full modes. Compare package inventories, `.PKGINFO`, clean and
upgrade transaction results, runtime manifests, and ISO inputs. Differences
must be explained by signatures or repository metadata; package payload
differences require a full fallback. Record elapsed time and transferred bytes
for both runs in the controller evidence directory.
