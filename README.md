# dps-filmmode

One key hides every HUD layer and gives you an eased free camera, for clean recording on a Qbox FiveM server.

## Features

- Hides the minimap and every base-game HUD element for as long as film mode is on.
- Runs your HUD's toggle command (default `togglehud`) on start and runs it again on stop.
- Blocks the chat key and clears the chat box, then turns chat back on at the end.
- Free camera with eased movement and eased mouse look.
- Level movement: W A S D stay flat whatever the camera pitch. Q and E change height.
- Fast and slow speed multipliers, and scroll wheel zoom (FOV).
- Your ped is made invisible and invincible. Out of a vehicle it is also frozen and has collision off.
- The ped follows the camera so the world keeps streaming around it.
- On exit the camera is destroyed, the ped goes back to where it stood, and all layers return.
- Access is controlled by an ace permission, checked on the server.
- The only thread (the camera loop) runs while film mode is on.
- Film mode stops by itself when the resource stops or the player logs out.

## Prerequisites

- `ox_lib` (listed in `dependencies`, used for callbacks, notifications and printing).
- `qbx_core`: the client listens for the `qbx_core:client:playerLoggedOut` event to stop film mode.
- A chat resource that handles the `chat:clear` event (the default FiveM chat does).
- Optional: a HUD with a toggle command, such as jg-hud's `togglehud`. Set `Config.Hide.hudCommand` to its command, or `''` to skip.

## Installation

1. Copy the `dps-filmmode` folder into your resources folder.
2. Add `ensure dps-filmmode` to `server.cfg`. Put it after `ox_lib` and `qbx_core`.
3. Set up access. The server checks `IsPlayerAceAllowed(source, Config.Ace)`. A player needs that ace to start film mode.
   - `Config.Ace` is the ace name. Default `dps.film`.
   - `Config.AutoAces`: when `true`, the resource runs `add_ace group.<name> <Config.Ace> allow` for every name in `Config.AceGroups` each time it starts. You need no line in `server.cfg`.
   - `Config.AceGroups`: the groups that get the ace. Default `admin` and `god`.
   - If `Config.AutoAces` is `false`, nothing is added. Add the lines yourself, for example `add_ace group.admin dps.film allow`.
   - Players must be members of those groups through your normal ace principals, for example `add_principal identifier.license:xxxx group.admin`.
   - To give one more group access, add its name to `Config.AceGroups`, or add `add_ace group.<name> dps.film allow` yourself.
4. Restart the server, or run `ensure dps-filmmode`.
5. In game, type `/film`. To use a key, bind "Film mode" under Settings > Key Bindings > FiveM.

## Configuration

All options are in `config.lua`.

| Option | Default | What it does |
|---|---|---|
| `Config.Ace` | `'dps.film'` | Ace permission a player needs. |
| `Config.AutoAces` | `true` | Adds the ace to every group in `Config.AceGroups` at resource start. |
| `Config.AceGroups` | `{ 'admin', 'god' }` | Groups that receive the ace when `AutoAces` is on. |
| `Config.Command` | `'film'` | Chat command that toggles film mode. |
| `Config.Key` | `''` | Default key. Empty means no key: players bind it themselves under Settings > Key Bindings > FiveM. If you set one, pick a key no other script uses (many admin menus use F9). |
| `Config.Hide.radar` | `true` | Hides the minimap and every base-game HUD element, every frame while on. |
| `Config.Hide.hudCommand` | `'togglehud'` | Command run to toggle your HUD on start and again on stop. Use `''` to skip. |
| `Config.Hide.chat` | `true` | Blocks the chat key, clears the chat box, and re-enables chat on stop. |
| `Config.Camera.speed` | `2.0` | Movement speed in metres per second. |
| `Config.Camera.fast` | `3.0` | Speed multiplier while Shift is held. |
| `Config.Camera.slow` | `0.25` | Speed multiplier while Ctrl is held. |
| `Config.Camera.sensitivity` | `3.0` | Mouse look, in degrees per full stick deflection per frame. |
| `Config.Camera.smoothing` | `0.05` | Movement easing. `0.05` glides, `0.3` snaps. |
| `Config.Camera.lookSmoothing` | `0.15` | Mouse look easing. Lower gives softer pans. |
| `Config.Camera.fov` | `50.0` | Starting field of view. |
| `Config.Camera.fovStep` | `2.0` | FOV change for each scroll notch. |
| `Config.Camera.fovMin` | `15.0` | Smallest FOV (most zoomed in). |
| `Config.Camera.fovMax` | `100.0` | Largest FOV (most zoomed out). |
| `Config.Camera.pitchLimit` | `89.0` | Maximum look up and look down angle, in degrees. |
| `Config.MovePedWithCamera` | `true` | Moves the invisible ped with the camera so the world stays streamed. When `false`, the camera can only travel a few hundred metres from the ped. |

## Controls

All other game controls are disabled while film mode is on.

| Input | Action |
|---|---|
| `/film` (or your own key) | Start or stop film mode |
| `Esc` | Stop film mode |
| `W` / `S` | Move forward / back (level) |
| `A` / `D` | Move left / right |
| `E` | Move up |
| `Q` | Move down |
| `Shift` | Fast (`Config.Camera.fast`) |
| `Ctrl` | Slow (`Config.Camera.slow`) |
| Mouse | Look |
| Scroll up | Zoom in (lower FOV) |
| Scroll down | Zoom out (higher FOV) |

## Troubleshooting

| Problem | Fix |
|---|---|
| "You are not allowed to use film mode." | The player lacks the ace. Check `Config.Ace`, that the player is in a group listed in `Config.AceGroups`, and that `Config.AutoAces` is on or you added the ace yourself. |
| Film mode turns on with another menu, or nothing happens on the key. | Another script shares the key: change `Config.Key`, and rebind it under Settings > Key Bindings > FiveM. Check that the resource is started. The key may be rebound under Settings > Key Bindings > FiveM. Try `/film`. |
| "Could not create the camera." | The camera failed to create. Try again. If it repeats, check the client console for errors. |
| The HUD stays visible. | Your HUD has its own toggle. Set `Config.Hide.hudCommand` to that command. |
| The HUD toggles the wrong way after stopping. | The HUD command is a toggle. If your HUD was already hidden before film mode, the command shows it. Set `Config.Hide.hudCommand = ''` in that case. |
| Chat is not cleared. | Your chat resource does not handle `chat:clear`. |
| The world stops loading when you fly far. | Set `Config.MovePedWithCamera = true`. |
| Camera feels too fast or too slow. | Change `Config.Camera.speed`, `fast` and `slow`. |
| Camera feels too floaty or too sharp. | Change `Config.Camera.smoothing` and `lookSmoothing`. |
| Ace line missing at start. | Look for `film mode ace ... added for groups` in the server console. It prints only when `Config.AutoAces` is on. |

## License

MIT.
