# smart-ceiling-fan

Make a ceiling fan and its light remotely controllable with a small **ESP32-C3 SuperMini**
running **ESPHome**, so the fan and the light can be switched on and off from anywhere.

Born from [espectre-lab](https://github.com/benoit-bremaud/espectre-lab): its experiments
(Wi-Fi CSI motion detection) show the ceiling fan more than doubles the idle noise, and a
remotely switchable fan would let those tests run while nobody is home.

> **Status:** conception. Nothing is wired yet. Personal, curiosity-driven project, no
> commercial goal.

## Safety first

A ceiling fan runs on mains voltage. Read [docs/safety.md](docs/safety.md) before touching
anything: the ESP32 is prototyped at low voltage first, and any mains part uses certified,
isolated hardware, installed or checked by a qualified electrician.

## Goals

- Switch the fan (off + speeds) and the light remotely, standalone through the ESPHome
  `web_server` (Home Assistant optional, same as espectre-lab).
- Expose entities that experiments can drive (for example fan on during a CSI baseline).
- Keep it simple: smallest design that works, UML before code.

## Backlog

Work is tracked in the GitHub Project *smart-ceiling-fan* (Todo / In Progress / Done).
