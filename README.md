# dps-filmmode

One key hides every HUD layer and gives you an eased free camera, for clean recording on a Qbox FiveM server.

## What it is for

Staff who record trailers and clips need a clean screen and a camera that moves smoothly. Turning
off the minimap, the HUD and the chat one by one is slow, and it is easy to forget one. Film mode
does all of it with one command and puts it all back when you stop.

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

## On its own, and with other scripts

**On its own.** With `ox_lib` you get the free camera, a hidden minimap and base-game HUD, and
the ace check. On a server with no extra HUD that is a clean screen.

**With Qbox (qbx_core).** Film mode stops by itself when the player logs out to character
select. The script only listens for the logout event.

**With a paid HUD (jg-hud).** A custom HUD draws on top of the game, so hiding the base-game HUD
does not hide it. Film mode runs the HUD's own `togglehud` command when you start and again when
you stop. It only runs that one command, so a HUD update does not break it unless the command
name changes. For another HUD, set `Config.Hide.hudCommand` to its toggle command.

**With a chat resource ([dps-chat](https://github.com/DaemonAlex/dps-chat) or the default
chat).** Film mode blocks the chat key and sends `chat:clear`, so no box or message shows in the
shot. With dps-chat there is no feed to clear. The dps-chat command box has its own key binding
and still opens during film mode, so do not press that key while you record.

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

## Recent changes

- **12 November 2026.** README: what it is for, how it works alone and with paid scripts, other
  DPS scripts.
- **4 October 2026.** No default key. Use `/film`, or bind "Film mode" yourself. F9 clashed with
  the admin menu, and Home was tried as the default first.
- **4 October 2026.** Level flight, a smoother camera at walking pace (speed 2.0, was 6.0), and a
  fix for the admin check.
- **28 September 2026.** Version 1.0.0: the HUD kill switch and the free camera.

## Author

Made by [DaemonAlex](https://github.com/DaemonAlex) for DelPerroSands.

## Other DPS scripts

All of these are made for DelPerroSands and run together on one Qbox server. Each one works on
its own. The ones marked "pairs with" do more when both are running.

| Script | What it does |
|---|---|
| [dps-inventory](https://github.com/DaemonAlex/dps-inventory) | The inventory: ox_inventory with equipment slots, backpacks, armour plates and a self status panel, in the DelPerroSands colours. |
| [dps-medical](https://github.com/DaemonAlex/dps-medical) | Patient records, illness and diagnostic tests. A companion to wasabi_ambulance. Pairs with dps-inventory: symptoms and diagnoses show on the status panel. |
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart. Pairs with dps-medical. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet and react to a robbery, then player-owned shops. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-autoshops](https://github.com/DaemonAlex/dps-autoshops) | Self-service repair shops when no mechanic is on duty. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-rotations](https://github.com/DaemonAlex/dps-rotations) | Moves dealers, harvests and other spots on a fixed schedule. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
