# Test candidate set lab lane

A test lane, not a release lane. Pushing this branch builds the packages of the Apple Silicon test candidate set that come from one omacom/omarchy-mac commit (`omarchy`, `omarchy-settings`, `omarchy-mac`, `omarchy-mac-boot`) as an unsigned Actions artifact. Pins are in `lab/candidate-set.env`; `lab/build` does the work and runs outside CI on any aarch64 Arch host as a non-root user.

The workflow reads no secrets and creates no release, database or channel. The set is assembled, recorded and signed with omacom/omarchy-mac `tools/release/candidate-set`.
