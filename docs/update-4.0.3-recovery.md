# Perplexity 4.0.3 candidate recovery

The imported 26.9.1+build61614 vendor source returned HTTP 403. Advance to
26.9.2+build67951-1 using the current Perplexity Debian package indices:
https://packages.perplexity.ai/deb/dists/stable/main/binary-arm64/Packages
and https://packages.perplexity.ai/deb/dists/stable/main/binary-amd64/Packages.
Both architecture hashes were refreshed; the ARM source checksum and native
makepkg build passed. The unsigned package preserves the launcher, desktop
entry, AppArmor profile and mode 4755 Chromium sandbox. Package repository,
incremental workflow, version and settings upgrade tests passed.

Local build used makepkg --nodeps in a disposable ARM container. It does not
prove a signed installation transaction or graphical launch. Signed candidate
and VM acceptance remain required. No release channel was changed.
