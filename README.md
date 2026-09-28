# dps-filmmode

One key hides every HUD layer and hands you a smooth free camera, so what you record is only the world. Press it again and everything comes back exactly as it was.

## What it does

- Hides the minimap and every base-game HUD element, jg-hud (through its own toggle command), and the chat box, for as long as film mode is on.
- Puts you in a free camera with eased movement: W A S D to move, Q and E for down and up, mouse to look, Shift for fast, Ctrl for slow, scroll wheel to zoom (FOV).
- Your character goes invisible and frozen, and follows the camera so the world keeps streaming around it. On exit you are put back where you started.
- Nothing runs while film mode is off: no threads, no per-frame work.

## Install

1. Copy the folder into your resources tree and `ensure dps-filmmode` (on DPS the `[dps]` bucket is ensured as a whole).
2. Done. The ace `dps.film` is added for the `admin` and `god` groups at start (`Config.AutoAces`). Give someone else access with `add_ace group.<name> dps.film allow`, or set `Config.AutoAces = false` and manage the lines yourself.

## Use

- `F9` or `/film` toggles it. Rebind the key under Settings > Key Bindings > FiveM.
- Record with OBS or ShadowPlay on your PC; the server does no recording.
- Voice, notifications from other scripts and other players' overhead UI are not touched.

## Customisation

Every knob is in `config.lua`: ace name and groups, command and key, which layers to hide (`radar`, `hudCommand`, `chat`), camera speed, fast and slow multipliers, mouse sensitivity, smoothing, FOV range and step, and whether the ped follows the camera.

## Requirements

ox_lib. Works with or without jg-hud (set `Config.Hide.hudCommand = ''` if your HUD has no toggle command, or put your HUD's command there).

## License

MIT.
