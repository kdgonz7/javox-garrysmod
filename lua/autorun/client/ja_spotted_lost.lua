local SpottedHUDState = {
    isGoingUp = false,
    animationTextState = 1,
    tooltipTextState = 0,
    lastLostTime = 0,
    isSpotted = false,
    windPlayed = false,
    lastSeenPosition = Vector(0, 0, 0)
}

local SpottedHUDSettings = {
    AnimationDuration = CreateClientConVar("javox_spotted_lost_animation_duration", "5", true, false),
    EnableTooltipText = CreateClientConVar("javox_spotted_lost_enable_tooltip_text", "1", true, false),
    TooltipTextDuration = CreateClientConVar("javox_spotted_lost_tooltip_text_duration", "5", true, false),
    PlayWindSound = CreateClientConVar("javox_spotted_lost_wind_sound", "1", true, false),
    ShowText = CreateClientConVar("javox_spotted_lost_show_text", "1", true, false),
    ShowPings = CreateClientConVar("javox_spotted_lost_show_pings", "1", true, false)
}

net.Receive("JaVox_EntLost", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    -- Handle the lost entity (e.g., remove from UI, play sound, etc.)
    SpottedHUDState.lastLostTime = CurTime()
    SpottedHUDState.isGoingUp = true
    SpottedHUDState.isSpotted = false

    if SpottedHUDSettings.PlayWindSound:GetBool() then
        if not SpottedHUDState.windPlayed then
            surface.PlaySound("ambient/wind/windgust.wav")
            SpottedHUDState.windPlayed = true
        end
    end
end)

net.Receive("JaVox_EntSpotted", function()
    if not SpottedHUDSettings.ShowText:GetBool() then return end
    local ent = net.ReadEntity()
    if not IsValid(ent) then return print("ent not valid") end

    -- Handle the spotted entity (e.g., add to UI, play sound, etc.)
    SpottedHUDState.lastLostTime = CurTime()
    SpottedHUDState.isGoingUp = true
    SpottedHUDState.isSpotted = true
    SpottedHUDState.windPlayed = false

    -- TODO: send vector directly from server instead of using ent:GetPos()
    SpottedHUDState.lastSeenPosition = ent:GetPos()
end)

hook.Add("HUDPaint", "JaVox_SpottedHUD", function()
    if not SpottedHUDSettings.ShowText:GetBool() then return end

    local ply = LocalPlayer()
    if ! ply:IsValid() or ! ply:Alive() then
        -- reset states
        SpottedHUDState.isGoingUp = false
        SpottedHUDState.isSpotted = false
        SpottedHUDState.windPlayed = false
        SpottedHUDState.lastSeenPosition = Vector(0, 0, 0)
        return
    end

    if CurTime() - SpottedHUDState.lastLostTime > SpottedHUDSettings.AnimationDuration:GetFloat() then
        SpottedHUDState.isGoingUp = false
        SpottedHUDState.windPlayed = false
    end

    -- lerp the animation text state
    if SpottedHUDState.isGoingUp then
        SpottedHUDState.animationTextState = Lerp(0.02, SpottedHUDState.animationTextState, 1)
    else
        SpottedHUDState.animationTextState = Lerp(0.02, SpottedHUDState.animationTextState, 0)
    end


    -- lerp the tooltip text state
    if SpottedHUDState.animationTextState > 0.9 and ! SpottedHUDState.isSpotted then
        SpottedHUDState.tooltipTextState = Lerp(0.02, SpottedHUDState.tooltipTextState, 1)
    else
        SpottedHUDState.tooltipTextState = Lerp(0.02, SpottedHUDState.tooltipTextState, 0)
    end

    if SpottedHUDState.animationTextState > 0.001 then
        draw.SimpleText("Entity " .. (SpottedHUDState.isSpotted and "Spotted" or "Lost"), "ShareTech", ScrW() * 0.5,
            ScrH() * 0.7 - SpottedHUDState.animationTextState * 10,
            Color(255, 255, 255, 255 * SpottedHUDState.animationTextState),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText("try going to the area you last saw it.", "ShareTechSmaller", ScrW() * 0.5,
            ScrH() * 0.7 - SpottedHUDState.animationTextState * 10 + 20,
            Color(255, 255, 255, 255 * SpottedHUDState.tooltipTextState),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        if not SpottedHUDState.isGoingUp then
            SpottedHUDState.windPlayed = false
        end
    end
end)

-- render a visual indicator for the last seen position
hook.Add("PostDrawTranslucentRenderables", "JaVox_SpottedIndicator", function()
    if not SpottedHUDSettings.ShowPings:GetBool() then return end

    if ! SpottedHUDState.lastSeenPosition then return end
    if SpottedHUDState.animationTextState > 0.001 then
        local pos = SpottedHUDState.lastSeenPosition + Vector(0, 0, 45) -- float it up slightly
        local plyAng = LocalPlayer():EyeAngles()
        plyAng:RotateAroundAxis(plyAng:Up(), -90)
        plyAng:RotateAroundAxis(plyAng:Forward(), 90)

        local uiText = "Last Seen Position"
        local uiColor = SpottedHUDState.isSpotted and Color(255, 140, 0, 255 * SpottedHUDState.animationTextState) or
            Color(255, 0, 0, 255 * SpottedHUDState.animationTextState)

        cam.Start3D2D(pos, plyAng, 0.2)

        cam.IgnoreZ(true)

        draw.Circle(0, 70, 60, uiColor)
        draw.SimpleText(uiText, "ShareTech", 0, 0, uiColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        cam.IgnoreZ(false)
        cam.End3D2D()
    end
end)
