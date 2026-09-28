--[[
    dps-filmmode client.

    One toggle. On: hide every HUD layer, freeze and hide the ped, hand the player a
    scripted camera with eased movement. Off: destroy the camera, put the ped back
    where it was, restore every layer. The only thread is the camera loop, which
    exists solely while film mode is on.
]]

local on = false
local cam = nil
local origin = nil          -- vector3 where the ped stood when filming began
local originHeading = 0.0
local hudToggled = false    -- whether we sent the HUD toggle command (so we send it back)

local function notify(msg, kind)
    lib.notify({ title = 'Film mode', description = msg, type = kind or 'inform' })
end

local function camRotation()
    local rot = GetGameplayCamRot(2)
    return vector3(rot.x, 0.0, rot.z)
end

local function dirFrom(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function rightFrom(rot)
    local z = math.rad(rot.z)
    return vector3(math.cos(z), math.sin(z), 0.0)
end

local function hideLayers()
    local h = Config.Hide or {}
    if h.chat then
        SetTextChatEnabled(false)
        TriggerEvent('chat:clear')
    end
    if type(h.hudCommand) == 'string' and h.hudCommand ~= '' then
        ExecuteCommand(h.hudCommand)
        hudToggled = true
    end
    if h.radar then DisplayRadar(false) end
end

local function showLayers()
    local h = Config.Hide or {}
    if h.chat then SetTextChatEnabled(true) end
    if hudToggled and type(h.hudCommand) == 'string' and h.hudCommand ~= '' then
        ExecuteCommand(h.hudCommand)
    end
    hudToggled = false
    if h.radar then DisplayRadar(true) end
end

local function stop()
    if not on then return end
    on = false
    local ped = cache.ped
    if cam and DoesCamExist(cam) then
        RenderScriptCams(false, true, 400, true, true)
        DestroyCam(cam, false)
    end
    cam = nil
    if ped and DoesEntityExist(ped) then
        if origin and not cache.vehicle then
            SetEntityCoordsNoOffset(ped, origin.x, origin.y, origin.z, false, false, false)
            SetEntityHeading(ped, originHeading)
        end
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true, false)
        SetEntityInvincible(ped, false)
    end
    showLayers()
    notify('Off. HUD is back.')
end

local function loop()
    local c = Config.Camera or {}
    local speed = c.speed or 6.0
    local smoothing = c.smoothing or 0.12
    local sens = c.sensitivity or 5.0
    local pitchLimit = c.pitchLimit or 89.0
    local fov = c.fov or 50.0
    local vel = vector3(0.0, 0.0, 0.0)
    local pos = GetCamCoord(cam)
    local rot = GetCamRot(cam, 2)
    local last = GetGameTimer()

    while on and cam and DoesCamExist(cam) do
        local now = GetGameTimer()
        local dt = (now - last) / 1000.0
        last = now
        if dt > 0.1 then dt = 0.1 end

        DisableAllControlActions(0)
        EnableControlAction(0, 1, true)    -- look x
        EnableControlAction(0, 2, true)    -- look y
        EnableControlAction(0, 245, true)  -- chat key stays blocked by SetTextChatEnabled, harmless here
        HideHudAndRadarThisFrame()

        -- look
        local lx = GetDisabledControlNormal(0, 1)
        local ly = GetDisabledControlNormal(0, 2)
        local pitch = rot.x - ly * sens
        if pitch > pitchLimit then pitch = pitchLimit elseif pitch < -pitchLimit then pitch = -pitchLimit end
        rot = vector3(pitch, 0.0, rot.z - lx * sens)

        -- move
        local fwd = dirFrom(rot)
        local right = rightFrom(rot)
        local up = vector3(0.0, 0.0, 1.0)
        local want = vector3(0.0, 0.0, 0.0)
        if IsDisabledControlPressed(0, 32) then want = want + fwd end
        if IsDisabledControlPressed(0, 33) then want = want - fwd end
        if IsDisabledControlPressed(0, 34) then want = want - right end
        if IsDisabledControlPressed(0, 35) then want = want + right end
        if IsDisabledControlPressed(0, 38) then want = want + up end      -- E
        if IsDisabledControlPressed(0, 44) then want = want - up end      -- Q
        local mult = 1.0
        if IsDisabledControlPressed(0, 21) then mult = c.fast or 4.0 end
        if IsDisabledControlPressed(0, 36) then mult = c.slow or 0.25 end
        local target = want * (speed * mult)
        vel = vel + (target - vel) * smoothing
        pos = pos + vel * dt

        -- zoom
        if IsDisabledControlJustPressed(0, 241) then fov = fov - (c.fovStep or 2.0) end
        if IsDisabledControlJustPressed(0, 242) then fov = fov + (c.fovStep or 2.0) end
        if fov < (c.fovMin or 15.0) then fov = c.fovMin or 15.0 end
        if fov > (c.fovMax or 100.0) then fov = c.fovMax or 100.0 end

        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, fov)

        if Config.MovePedWithCamera and not cache.vehicle then
            local ped = cache.ped
            if ped and DoesEntityExist(ped) then
                SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z - 1.0, false, false, false)
            end
        end

        if IsDisabledControlJustPressed(0, 200) then  -- Esc leaves film mode too
            break
        end
        Wait(0)
    end
    if on then stop() end
end

local function start()
    if on then return end
    local ped = cache.ped
    if not ped or not DoesEntityExist(ped) then return end
    local allowed = lib.callback.await('dps-filmmode:server:allowed', false)
    if not allowed then
        notify('You are not allowed to use film mode.', 'error')
        return
    end

    on = true
    origin = GetEntityCoords(ped)
    originHeading = GetEntityHeading(ped)

    local pos = GetGameplayCamCoord()
    local rot = camRotation()
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, (Config.Camera and Config.Camera.fov) or 50.0, false, 0)
    if not cam or not DoesCamExist(cam) then
        on = false
        notify('Could not create the camera.', 'error')
        return
    end
    RenderScriptCams(true, true, 400, true, true)

    if not cache.vehicle then
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
    end
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)

    hideLayers()
    notify('On. W A S D moves, Q E down and up, Shift fast, Ctrl slow, scroll zooms. Press the key or Esc to stop.')
    CreateThread(loop)
end

RegisterCommand(Config.Command or 'film', function()
    if on then stop() else start() end
end, false)
RegisterKeyMapping(Config.Command or 'film', 'Film mode: hide HUD and free camera', 'keyboard', Config.Key or 'F9')

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then stop() end
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    if on then stop() end
end)
