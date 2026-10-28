# Project Log — smart-ceiling-fan

Chronological operational logbook. Complements `git log`: records decisions, context,
and findings that the commit history alone does not capture. Newest entries on top.

---

## 2026-10-28 — Pre-push secret and personal-data gate (#9, PR #10, squash cfc2031)

**Context.** Public repository: secrets and personal/network data must be refused before
they leave the machine. Ported the gate reviewed in espectre-lab#36 (`18a126d`).

**What landed.** `.gitleaks.toml` (default rules + private/CGNAT/link-local IPv4, homelab
hosts, home paths, personal e-mails, MAC, literal Wi-Fi credentials in YAML),
`scripts/hooks/pre-push` (fail closed), `scripts/install-hooks.sh`, a 40-case canary
(`scripts/test-secret-gate.sh`) run in CI, SHA-pinned Node 24 actions, Dependabot for
actions, `esphome/secrets.yaml.example`, `.env*` gitignored.

**Findings.**

- The first local version (`767f0a0`) failed open on an unfetched remote sha; fixed by
  scanning `--not --remotes=<remote>`.
- A worktree-level `core.hooksPath` (absolute, pointing at the main checkout) made the
  worktree run the old hook. `install-hooks.sh` now removes it, but only when
  `extensions.worktreeConfig` is on (otherwise `--worktree` means `--local`).
- Five Codex rounds hardened the Wi-Fi regex (quoted values and keys, list items, flow
  mappings, block scalars, same-line values). The owner capped it there: further YAML
  variants (anchors…) go to #11, possibly as a YAML-aware check.

**Decisions.** SonarQube waived for this shell/config PR (no Sonar project yet), tracked in
#12. Follow-ups: #11 (gate Nice-to-haves + YAML variants), #12 (SonarQube).

## 2026-10-26 — Project created

**Context.** In espectre-lab (Wi-Fi CSI motion detection) the ceiling fan more than doubles
the idle noise (0.10 → 0.23). The owner could not switch it on remotely to run test A2
(espectre-lab#17) while away; the only remotely controllable devices were a string of
lights and two neon tubes around the bed. Idea: put an ESP32-C3 SuperMini in the fan to
control fan and light.

**Decisions.**

- Stack: ESPHome on ESP32-C3 SuperMini, standalone `web_server`, same as espectre-lab.
- Repository **public** until the first production deployment (owner rule), no secrets.
- Safety rules written first (`docs/safety.md`): bench at low voltage, certified mains
  hardware only, electrician for the installation.
- UML study before code; hardware choice by MCDA.
