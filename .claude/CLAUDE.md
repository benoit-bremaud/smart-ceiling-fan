# Project conventions — smart-ceiling-fan

## What this is

Make a 230 V ceiling fan and its light remotely controllable with an ESP32-C3 SuperMini
running ESPHome. Personal, curiosity-driven. Companion of `espectre-lab`.

## Stack

- **ESPHome** (YAML) on ESP32-C3 SuperMini (board id `esp32-c3-devkitm-1`).
- Markdown + Mermaid UML (`docs/architecture/diagrams/`) for conception.

## Commands (once `esphome/` exists)

- Validate : `esphome config esphome/<file>.yaml`
- Compile / flash / logs : `esphome compile|run|logs esphome/<file>.yaml`
- Secrets live in `esphome/secrets.yaml` (gitignored; copy from `secrets.yaml.example`).

## Project-specific conventions

- **Mains safety is non-negotiable** (`docs/safety.md`): bench at low voltage, certified
  isolated mains hardware only, never design or describe bare mains wiring.
- UML-first: model the feature before writing the YAML.
- Wi-Fi credentials NEVER committed.
- Public repo: run `scripts/install-hooks.sh` once per clone (needs `gitleaks` on PATH); the
  `pre-push` hook refuses secrets and personal/network data. `scripts/test-secret-gate.sh` proves it.
