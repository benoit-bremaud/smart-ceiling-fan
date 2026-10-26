# Safety rules

The project touches a **230 V ceiling fan**. These rules apply to every task.

1. **Bench first, low voltage only.** Prototype the ESP32-C3, ESPHome entities and wiring
   logic with LEDs / a low-voltage load in place of the fan and light. No mains on the bench.
2. **No bare mains circuitry.** Any part connected to mains is a **certified, isolated**
   product (CE-marked fan/light controller or relay module in an insulated enclosure,
   rated for the fan motor and the light). No homemade mains-side board, no uncertified
   AliExpress relay boards.
3. **Match the load.** A fan motor is inductive (often capacitor-speed): the module must be
   rated for it. A plain relay is not a speed controller, and a dimmer is not a fan
   speed control.
4. **Isolation and fusing.** The ESP32 is powered by a certified low-voltage supply, never
   directly from the mains side.
5. **Installation by a qualified electrician**, or checked by one before first power-up:
   breaker off, verified dead, correct earthing.
6. **No secrets in Git.** Wi-Fi credentials only via `!secret` and a gitignored
   `esphome/secrets.yaml`.
