# Incremental planner replay

Replayed 2026-09-19 (Brisbane) over every published
`asahi-packages-candidate-*` since the incremental lane began: 25 pairs,
901e39bd (runtime channel 26) through 3ac471cf (runtime channel 42).

## Method

- **Pair:** each candidate with the predecessor recorded in its `PLAN.json`
  for an incremental dispatch, otherwise the previous published candidate.
- **Planner:** `bin/asahi-incremental-plan` as of asahi-quattro 3ac471cf, with
  the candidate commit's repository lists. It ran once on the pair's
  `git diff --name-only` and once on each changed path, to list every
  rebuild-all trigger rather than only the last one it reports.
- **Justified:** the path changes package bytes (builder, toolchain, recipe) or
  the repository definition. Contract changes (planner, assembly, verifier,
  candidate workflows and gate scripts) change no package bytes, but R2 keeps
  them fail-closed.

## Headline

- **Published:** 19 full (13 selected by the operator, 6 planner fallbacks) and
  6 incremental.
- **Current planner:** 18 of 25 pairs fall back, with 187 path triggers.
- **Unjustified:** 129 triggers in 10 pairs, all paths no candidate build reads:
  - 40 package directories that are not aarch64 repository sources, such as
    `cursor-bin`, `claude-code` and the `elephant-*` set;
  - `bin/install-asahi-quattro` (4 pairs), `bin/apple-image-parity-capture`,
    `bin/asahi-cache`, `bin/asahi-package-retention-plan`,
    `bin/asahi-release-controller`, `bin/reuse-asahi-package`,
    `bin/stage-arm64-iso-r2`, `bin/verify-asahi-runtime-version` and
    `controller/*`.
- **Remaining:** 58 triggers. 21 are byte or definition inputs:
  `build/build.sh` twice and the three repository lists 19 times. 37 are
  contract changes, kept fail-closed.
- **After the fix:** 3 more pairs plan incremental: cf3de447, 802c6a85 and
  8ea94e69. The operator published all three full. 15 pairs still fall back.
  7 of them fall back on contract changes alone, which is now the largest
  avoidable cost.
- **Earlier fixes:** the current planner already exempts `bin/asahi-runtime-release`
  (#131; it forced ca4b5ee3 and 84f93ff3 full) and the Aurora lane
  (`pkgbuilds/linux-aurora/rust-toolchain.toml` forced fd2a4c33 full).

## Pairs

In the table, "op" means the operator selected full. "Now" is the current
planner's plan for an incremental dispatch; the number is the rebuilt package
count.

| Candidate ← predecessor | Runtime | Published | Now | Fallback triggers | Justified | After |
|---|---|---|---|---|---|---|
| 901e39bd ← a04c1a0c | 26 | full (fallback) | full | lane introduced: incremental workflow, lifecycle gate, planner, assembly, provenance, verifier; `asahi-source-outputs`; `asahi-cache`, `asahi-release-controller`, `stage-arm64-iso-r2`, `controller/*` | yes, except the last four | full |
| 5a3a266d ← 901e39bd | 27 | full (op) | full | `build/build.sh`; repository lists; both candidate workflows; transaction and lifecycle gates; bundle manifest, assembly, provenance, descriptor, verifier; `install-asahi-quattro`, `reuse-asahi-package` | builder and lists yes; contract kept; last two no | full |
| f701b12e ← 5a3a266d | 28 | full (op) | full | repository lists; both candidate workflows | lists yes; contract kept | full |
| 650a68db ← f701b12e | 29 | full (fallback) | full | both candidate workflows (gate snapshot) | contract kept | full |
| fd2a4c33 ← 650a68db | 30 | full (fallback) | full | incremental workflow (runtime-only lane) | contract kept | full |
| ca4b5ee3 ← 650a68db | 30 | full (fallback) | full | incremental workflow; planner | contract kept | full |
| cc672b30 ← ca4b5ee3 | – | full (op) | full | repository lists; both candidate workflows | lists yes; contract kept | full |
| e0740d2e ← cc672b30 | – | incremental | inc 1 | – | – | inc 1 |
| 74b8da66 ← e0740d2e | 31 | full (fallback) | full | incremental workflow (transaction evidence) | contract kept | full |
| c3e98be6 ← 74b8da66 | – | full (op) | full | planner; `verify-asahi-runtime-version` | contract kept; tool no | full |
| 83973903 ← c3e98be6 | 32 | incremental | inc 2 | – | – | inc 2 |
| 3d86b8f3 ← 83973903 | 32 | full (op) | full | repository lists; both candidate workflows; 40 package directories outside the aarch64 sources | lists yes; contract kept; directories no | full |
| 7ca86f0c ← 3d86b8f3 | 32 | full (op) | full | repository lists; both candidate workflows; zram layout gate; `claude-code`, `github-copilot-cli` | lists yes; contract kept; directories no | full |
| e7574274 ← 7ca86f0c | 32 | full (op) | full | `build/build.sh`; lifecycle gate | builder yes; contract kept | full |
| 8ac8d678 ← e7574274 | 33 | incremental | inc 2 | – | – | inc 2 |
| cf3de447 ← 8ac8d678 | 34 | full (op) | full | `claude-code`, `crush-bin`, `cursor-cli`, `dropbox`, `heroic-games-launcher-bin` | no | **inc 5** |
| 437d2aed ← cf3de447 | 35 | full (op) | full | candidate descriptor; `asahi-package-retention-plan` | contract kept; tool no | full |
| 802c6a85 ← 437d2aed | 36 | full (op) | full | `install-asahi-quattro`; `cursor-bin` | no | **inc 2** |
| 8ea94e69 ← 802c6a85 | 37 | full (op) | full | `install-asahi-quattro` | no | **inc 2** |
| f7bbba95 ← 8ea94e69 | 38 | incremental | inc 3 | – | – | inc 3 |
| 84f93ff3 ← f7bbba95 | 39 | full (fallback) | inc 3 | – (`asahi-runtime-release`, fixed in #131) | – | inc 3 |
| 23521851 ← 84f93ff3 | 39 | full (op) | full | planner (#131) | contract kept | full |
| 06923606 ← 23521851 | 40 | full (op) | full | repository lists; both candidate workflows; planner; `apple-image-parity-capture`, `install-asahi-quattro` | lists yes; contract kept; tools no | full |
| cb27b001 ← 06923606 | 41 | incremental | inc 2 | – | – | inc 2 |
| 3ac471cf ← cb27b001 | 42 | incremental | inc 2 | – | – | inc 2 |

## Classification

`bin/asahi-incremental-plan --classify` gives every tracked path exactly one
class:

- **package** or **runtime:** a repository source directory or runtime group
  and the runtime source pin. It rebuilds only its target.
- **rebuild-all:** `bin/build`, `build/*`, `helpers/*`, signing trust and the
  repository lists.
- **contract:** planning, assembly and verification tools, both candidate
  workflows and their gate scripts. It fails closed.
- **none:** documentation, tests, other workflows, operator tools, and the
  runtime, image, Aurora and x86_64 lanes. Those globs live in
  `pkgbuilds/asahi-planner-classes` (`pattern|reason`, one per line). Appending
  lines, with existing lines unchanged and in order, is itself none; editing,
  removing or reordering a line is a contract change. It also covers package
  directories outside the repository sources: each source builds alone from
  its own directory, and a directory joins the build only through the
  repository lists.

Unknown paths still force a full rebuild. `test/asahi-input-classification`
runs on every pull request and fails when any tracked file is unclassified.
