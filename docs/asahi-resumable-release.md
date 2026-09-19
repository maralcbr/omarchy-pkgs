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
package signatures, architectures, commits, and the exact 58-package inventory.

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

The controller's `authorize-iso` stage dispatches
`authorize-arm64-iso.yml` and waits for the protected
`arm64-iso-generation` environment. ISO generation cannot start until the
configured reviewer approves the exact source, package, ISO, candidate,
manifest, version, and date inputs. Public filenames use
`omarchy-VERSION-DATE-aarch64.iso`, for example
`omarchy-4.0.1.m.1-2026.08.26-aarch64.iso`.

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

## One release command

`bin/asahi-release` takes an omarchy-mx-mac commit on public `main` to
installed Macs and runs until it is done or hits a hard stop. Run it from a
fresh `origin/asahi-quattro` checkout, with Bash 5 (Homebrew bash on macOS) and
a signed-in `gh`:

```bash
bin/asahi-release --dry-run <commit>                 # the plan; changes nothing
bin/asahi-release <commit>                           # the release
bin/asahi-release --update-macs <commit>             # then omarchy update on both Macs
```

What it does:

1. **Pin.** Points `pkgbuilds/omarchy-source.conf` at the commit through a
   squash-merged PR. Skipped when the commit is already pinned; the release
   then ships what `asahi-quattro` holds.
2. **Candidate.** Builds an incremental candidate on the nearest published
   candidate in `asahi-quattro`'s history, and pins the result by tag,
   `CANDIDATE` SHA-256 and commit. Every later step checks all three again,
   with the descriptor and manifest signatures and the release inventory.
3. **Path.** If the candidate's package set (every package its `CANDIDATE`
   lists, by name, version and archive SHA-256) is the one the live package
   channel publishes, only the runtime can have changed: the **fast path**
   publishes the next runtime channel and stops there. Otherwise, whether this
   candidate rebuilt the difference or inherited it from a predecessor that
   was never promoted, the **full path** runs VM acceptance on the M1 Pro,
   promotes the candidate there, publishes the package channel, then the
   runtime channel. A live set that cannot be verified takes the full path.
   If the live set moves while a release classified fast or empty waits, and
   the candidate's set no longer matches it, the release stops once and takes
   the full path when resumed. A runtime run it already dispatched and that is
   still waiting for approval is cancelled by its ID first, so it cannot hold
   the package channel behind the shared gate; one that has published stops
   the release for the operator.
4. **Macs** (with `--update-macs`). `omarchy update -y` on the M2 Max, its
   checks (no reboot block, no failed units, the new runtime and package set
   recorded, `omarchy-apple-silicon-boot-check`), then the same on the M1 Pro.
   It never reboots.

It then prints one report. The OS payload and the installer catalog are not
part of it; the catalog signature is the owner's.

VM acceptance ships the harness at the exact commit (`git archive`) to
`~/omarchy-release/<release>/` on the M1 Pro, runs
`test/vm/asahi-fresh/run --optional-packages --wait-for-lease` with the
candidate exports and the harness's own Arch Linux ARM mirror, and copies its
evidence back to `~/vm-evidence/<candidate tag>/<run id>/`. It needs the
harness with per-run evidence: its `run.txt` must pass and name this run ID,
the candidate tag and `CANDIDATE` digest, the runtime manifest digest and
source (`candidate_sha256=`, `runtime_manifest_sha256=`, `runtime_source=`),
and the harness's default mirror, and every log must match its hash there.
The acceptance record written next to the evidence (`acceptance.txt`) is what
the promotion uses; commit it to omarchy-mx-mac as
`docs/releases/asahi-packages-candidate-<8hex>-acceptance.txt`. A record of the
same candidate already on omarchy-mx-mac `main` stands in for a new run when
every line is `key=value`, no key appears twice, it says `status=accepted` and
`release_blocking_defects=none`, and its candidate tag, digest and signer (and
runtime source and manifest digest, where it has them) are this release's. No
stable set is promoted, adopted or published without one of the two.

The promotion runs on the M1 Pro as a detached job in
`~/omarchy-release/<release>/promote-<attempt>/`, from an archive of
omarchy-pkgs at the candidate commit. The job is recorded before it starts and
reads the GitHub token from stdin, never from a command line or a file. A
resumed release waits for a running job and reads a finished one's exit
status; it never starts a second promotion beside one it cannot account for.

Hosts and paths come from `ASAHI_RELEASE_VM_HOST` (default `omarchy-m1-pro`),
`ASAHI_RELEASE_UPDATE_HOSTS` (default `omarchy-m2-max omarchy-m1-pro`, in that
order), `ASAHI_RELEASE_SSH_USER` (`maralc`) and `ASAHI_RELEASE_VM_STATE_DIR`
(the harness state directory under the M1 Pro's home, shared with hand runs so
their lease covers both).

### Identities and gates

Each dispatch records its intent (workflow, the `asahi-quattro` commit, the
actor, the runs that already existed) before it is sent, and the run ID after.
A run is this dispatch's only if it is a new `workflow_dispatch` run of that
workflow on that commit by that actor and, for the channel workflows, carries
the exact `run-name` built from its inputs. Anything other than exactly one
match stops. A recorded dispatch with no run is never sent again on its own:
GitHub may show it late, or on another commit. Once the Actions page shows no
run of it, resume with `--dispatch-again candidate` (or `packages`,
`runtime`). An environment gate is approved only for `asahi-quattro-release`,
only on that run, and only after checking what the waiting job will publish:
the plan artifact for the candidate, the exact runtime artifact against the
candidate's manifest, or the promoted set against the candidate.

### Resume

State lives in `${XDG_STATE_HOME:-~/.local/state}/omarchy-release/`: one
directory per release with a record per finished step, the dispatch records,
the log and the evidence. Run the same command again to resume. A dispatch
whose run ID was never recorded is looked up, not sent again; a VM run,
promotion or Mac update that outlived the command is reattached to. Only one
release runs at a time: `release.lock` is held with `flock(2)` for as long as
the command runs and is released by the kernel when it exits or dies, so there
is never a stale lock to clear. A release in progress refuses a release of
another commit. `bin/asahi-release --abandon` sets the release in progress
aside (its records are kept) so another can start. A finished release is
identified by its omarchy-mx-mac commit and its `asahi-quattro` commit
together: rerunning it reports it, and a later package change released with
the same runtime source is a new release.

### Hard stops

Each prints one message and the command to resume with.

| Stop | What to do |
| --- | --- |
| a signature, digest or inventory does not verify | the published bytes are not what this release pinned; find out why before anything else |
| a dispatch matches no run, or several | for several, cancel the extra runs and resume; for none, check the Actions page, then resume with `--dispatch-again STEP` only if no run exists |
| a run waits on another environment | this command never approves it; approve or cancel it by hand |
| a run failed | fix the cause and resume, which dispatches it again (the channel workflows are their own repair) |
| VM acceptance failed | read the evidence it names; resuming starts a new run |
| a kernel or boot package moved | test exactly that on a real Mac and resume with `--hardware-evidence FILE` (below); VM acceptance cannot qualify a kernel |
| a promotion job is neither running nor finished | check the M1 Pro for a promotion process and a draft stable release; once neither exists, remove the `progress/promote` record it names and resume |
| a channel is public but its pointer is not | run the repair command it prints, approve its gate, resume |
| a draft or half-published release exists | a publication stopped half way; resolve it by hand, then resume |
| another release superseded this one's runtime, or it would move Macs back | release from the live runtime's commit instead |
| the candidate carries packages it did not rebuild that differ from the live ones, and its chain of candidates (each `PROVENANCE.json` predecessor, verified) does not lead back to the candidate the live set came from | rebuild them (a full candidate) and release again; they may be older builds than the live ones |
| the live package set cannot be verified now | nothing is published until it verifies; resume then |
| the live runtime's source cannot be read | fetch that commit into the command's omarchy-mx-mac cache, or check the channel, then resume |
| an update fails its checks or sets a reboot block | nothing runs on the next Mac; fix the Mac (see the deployment runbook), resume |

A boot package (a kernel, m1n1, U-Boot, `asahi-fwextract`, `asahi-scripts`,
`omarchy-apple-boot`, `limine-mkinitcpio-hook` or a DKMS module) moves when the
full path would publish it at another version than the live package set
(the highest package channel's stable set, verified through its signed
`CANDIDATE`), or when its recipe under `pkgbuilds/` changed since that set.
One rebuilt at the same version from an unchanged recipe, as a full rebuild
does, is not a move: installed Macs keep their copy, and the report and the
acceptance record list it as rebuilt at the same version. When the live set
cannot be read or verified, every boot package in the set, rebuilt or
inherited, counts as moved. Kernel pins in the runtime are compared with the
exact source of the live runtime channel, never with a stand-in; when that
source cannot be read, the release stops. The comparison records which package
channel and runtime channel it was made against; before every public step and gate
approval the command reads them again, and if another publication moved either
one it compares again, so hardware evidence always matches what installed Macs
would move to from what they have now. It also decides again whether this
release's runtime still has to be published. The hardware record that counts
is the copy the command keeps, validated after it is copied.

A hardware record is free text plus lines that must match what the release
publishes exactly, no more and no fewer; the stop prints them:

```
candidate_sha256=<the candidate's CANDIDATE digest>
boot=<package> <epoch:pkgver-pkgrel>     # one per moved boot package
pin=aurora-packages-<commit>             # one per repinned Aurora kernel
```

### What the fast path skips

Most fixes touch only the runtime pair (`omarchy-dev`, `omarchy-settings-dev`:
scripts, configuration, migrations). For those the repository packages stay
byte-identical to the predecessor candidate, so the fast path skips, on
purpose:

- **VM acceptance and package promotion.** Nothing in the repository set
  changed; the runtime is gated by the shell tests on the source commit and by
  the upgrade over the predecessor in the candidate build.
- **The clean-install lifecycle.** Those packages were clean-installed when
  the predecessor was gated. `assemble-and-verify` runs only the upgrade for a
  runtime-only candidate, from a pacman cache kept between runs.
- **A new OS payload.** Fresh installs sync their repositories and update on
  first boot, so the image only needs rebuilding when the package set changes,
  or on a cadence.

A runtime that repins the Aurora kernel (`default/aurora-qualified-release`)
still needs `--hardware-evidence`. `bin/asahi-runtime-release <commit>` is the
fast path alone: it stops when the candidate rebuilt a repository package, and
`bin/asahi-release <commit>` resumes that release on the full path.
