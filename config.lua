Config = {}

-- Who may use it. AutoAces adds `add_ace group.<name> dps.film allow` for every group
-- listed at start, so server.cfg needs no line. Set AutoAces = false and add the
-- aces yourself if you prefer.
Config.Ace = 'dps.film'
Config.AutoAces = true
Config.AceGroups = { 'admin', 'god' }

-- Key and command. The key is a default; players rebind it under Settings > Key Bindings > FiveM.
Config.Command = 'film'
Config.Key = 'F9'

-- What gets hidden while filming.
Config.Hide = {
    radar = true,                 -- minimap and every base-game HUD element (per frame while on)
    hudCommand = 'togglehud',     -- jg-hud's own toggle command; '' to skip
    chat = true,                  -- blocks the chat key and clears the box
}

-- Camera feel. Speeds are metres per second; the camera eases toward the stick.
Config.Camera = {
    speed = 2.0,                  -- W A S D and Q E (walking pace; was 6.0, Damon 10-04)
    fast = 3.0,                   -- multiplier while Shift is held
    slow = 0.25,                  -- multiplier while Ctrl is held
    sensitivity = 3.0,            -- mouse look, degrees per full stick deflection per frame
    smoothing = 0.05,             -- movement: 0.05 glides, 0.3 snaps
    lookSmoothing = 0.15,         -- mouse look: lower = softer pans
    fov = 50.0,
    fovStep = 2.0,                -- scroll wheel changes FOV by this much
    fovMin = 15.0,
    fovMax = 100.0,
    pitchLimit = 89.0,
}

-- Keep the world streamed around the camera by moving the (invisible, frozen) ped
-- with it. Off, the camera can only travel a few hundred metres from the ped.
Config.MovePedWithCamera = true
