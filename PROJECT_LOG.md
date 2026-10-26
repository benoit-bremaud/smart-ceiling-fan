# Project Log — smart-ceiling-fan

Chronological operational logbook. Complements `git log`: records decisions, context,
and findings that the commit history alone does not capture. Newest entries on top.

---

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
