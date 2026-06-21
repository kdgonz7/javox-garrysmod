---@diagnostic disable: undefined-field
if SERVER then return end

local javoxCalloutMenuIsOpen = false
local jaVoxCalloutOpacity = 0
local targetAlpha = 0
local centerPositions = { x = 0, y = 0 }
local menuRadius = 300
local itemRadius = 40
local openingAnimationPosition = 0
local selectedAngle = 0
local currentItemHovered = nil

local options = {}
local selected = 1

local MenuColors = {
    Background = Color(36, 36, 36, 180),
    OuterRing = Color(65, 105, 225, 200),
    InnerCircle = Color(20, 20, 20, 220),
    Selected = Color(255, 214, 10),
    Text = Color(255, 255, 255),
    Hover = Color(100, 180, 255, 100)
}

local function GetCirclePoint(angle, radius)
    return {
        x = math.cos(math.rad(angle)) * radius,
        y = math.sin(math.rad(angle)) * radius
    }
end

local function Lerp(t, a, b)
    return a + (b - a) * t
end

hook.Add("HUDPaint", "PVox_RadialMenu", function()
    local Us = LocalPlayer()
    if not Us:Alive() then return end

    -- Animate menu alpha
    local approachSpeed = FrameTime() * 6
    jaVoxCalloutOpacity = Lerp(approachSpeed, jaVoxCalloutOpacity, targetAlpha)

    -- Animate opening
    if javoxCalloutMenuIsOpen then
        openingAnimationPosition = Lerp(approachSpeed, openingAnimationPosition, 1)
        targetAlpha = 255
    else
        openingAnimationPosition = Lerp(approachSpeed, openingAnimationPosition, 0)
        targetAlpha = 0
    end

    if jaVoxCalloutOpacity < 1 and not javoxCalloutMenuIsOpen then return end

    local ScreenW, ScreenH = ScrW(), ScrH()
    centerPositions = { x = ScreenW / 2, y = ScreenH / 2 }

    local m = JaVox.vox[Us:GetNWString(JAVOX_PRESET, nil)]
    if not m or not m.callouts or table.IsEmpty(m.callouts) then return end

    -- Prepare callout options
    if table.IsEmpty(options) then
        local callouts_keys = table.GetKeys(m.callouts)
        table.sort(callouts_keys)
        options = callouts_keys
        table.insert(options, "Cancel")
    end

    -- Draw outer circle
    local outerRingColor = ColorAlpha(MenuColors.OuterRing, jaVoxCalloutOpacity)
    local scaledRadius = menuRadius * openingAnimationPosition

    -- Draw blur under the menu
    draw.BlurredCircle(centerPositions.x, centerPositions.y, scaledRadius + 30,
        ColorAlpha(MenuColors.Background, jaVoxCalloutOpacity * 0.5))

    -- Draw outer ring with glow
    surface.SetDrawColor(outerRingColor)
    local segments = 64
    for i = 1, segments do
        local angle1 = (i - 1) * 360 / segments
        local angle2 = i * 360 / segments

        local p1 = GetCirclePoint(angle1, scaledRadius)
        local p2 = GetCirclePoint(angle2, scaledRadius)

        surface.DrawLine(
            centerPositions.x + p1.x, centerPositions.y + p1.y,
            centerPositions.x + p2.x, centerPositions.y + p2.y
        )
    end

    -- Draw inner circle
    draw.Circle(centerPositions.x, centerPositions.y, scaledRadius * 0.3,
        ColorAlpha(MenuColors.InnerCircle, jaVoxCalloutOpacity))

    -- Draw menu items in a circle
    local itemCount = #options
    local angleStep = 360 / itemCount

    -- Get mouse angle for hover detection
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local mouseVec = Vector(mouseX - centerPositions.x, mouseY - centerPositions.y, 0)
    local mouseAngle = math.deg(math.atan2(mouseVec.y, mouseVec.x))
    if mouseAngle < 0 then mouseAngle = mouseAngle + 360 end

    -- Get mouse distance for hover detection
    local mouseDist = mouseVec:Length()
    currentItemHovered = nil

    if javoxCalloutMenuIsOpen and mouseDist < scaledRadius + itemRadius and mouseDist > scaledRadius * 0.4 then
        -- Find hovered item based on angle
        for i = 1, itemCount do
            local itemAngle = (i - 1) * angleStep
            local angleDiff = math.abs(((mouseAngle - itemAngle + 180) % 360) - 180)

            if angleDiff < angleStep / 2 then
                currentItemHovered = i
                break
            end
        end
    end

    -- Animate selected angle
    local targetAngle = (selected - 1) * angleStep
    selectedAngle = Lerp(approachSpeed * 2, selectedAngle, targetAngle)

    for i = 1, itemCount do
        local angle = (i - 1) * angleStep
        local isSelected = (selected == i)
        local isHovered = (currentItemHovered == i)

        -- Calculate item position
        local scaleFactor = isSelected and 1.2 or (isHovered and 1.1 or 1)
        local itemPos = GetCirclePoint(angle, scaledRadius * openingAnimationPosition)
        local x, y = centerPositions.x + itemPos.x, centerPositions.y + itemPos.y

        -- Draw connecting line from center
        surface.SetDrawColor(ColorAlpha(isSelected and MenuColors.Selected or MenuColors.OuterRing,
            jaVoxCalloutOpacity * 0.5))
        surface.DrawLine(centerPositions.x, centerPositions.y, x, y)

        -- Draw item circle
        local itemColor = isSelected and MenuColors.Selected or (isHovered and MenuColors.Hover or MenuColors.Background)
        draw.Circle(x, y, itemRadius * scaleFactor * openingAnimationPosition, ColorAlpha(itemColor, jaVoxCalloutOpacity))

        -- Draw item text
        local text = options[i]
        if i == itemCount then text = "✕ " .. text end

        draw.SimpleTextOutlined(
            text,
            "Trebuchet24",
            x,
            y,
            ColorAlpha(isSelected and MenuColors.Selected or MenuColors.Text, jaVoxCalloutOpacity),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            1,
            ColorAlpha(Color(0, 0, 0), jaVoxCalloutOpacity)
        )

        -- Draw selection indicator
        if isSelected then
            draw.Circle(x, y, itemRadius * 1.3 * openingAnimationPosition,
                ColorAlpha(MenuColors.Selected, jaVoxCalloutOpacity * 0.3))
        end
    end



    local selPos = GetCirclePoint(selectedAngle, scaledRadius + 20)
    draw.SimpleTextOutlined(
        "▶",
        "Trebuchet24",
        centerPositions.x + selPos.x,
        centerPositions.y + selPos.y,
        ColorAlpha(MenuColors.Selected, jaVoxCalloutOpacity),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        ColorAlpha(Color(0, 0, 0), jaVoxCalloutOpacity)
    )
end)

hook.Add("PlayerBindPress", "JaVox_RadControls", function(ply, bind, pressed)
    if not javoxCalloutMenuIsOpen then return end
    if not pressed then return end

    if bind == "invnext" then
        selected = selected % #options + 1
        return true
    elseif bind == "invprev" then
        selected = selected - 1
        if selected < 1 then selected = #options end
        return true
    end
end)

hook.Add("Think", "JaVox_Sounds", function()
    if not javoxCalloutMenuIsOpen then return end

    if currentItemHovered and input.IsMouseDown(MOUSE_LEFT) then
        if selected ~= currentItemHovered then
            surface.PlaySound("ui/buttonclick.wav")
        end

        selected = currentItemHovered
    end
end)

function draw.Circle(x, y, radius, color)
    local segments = 32
    local poly = {}

    for i = 0, segments do
        local angle = math.rad((i / segments) * -360)
        poly[i + 1] = {
            x = x + math.sin(angle) * radius,
            y = y + math.cos(angle) * radius
        }
    end

    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(poly)
end

-- Blurred circle for background effect
function draw.BlurredCircle(x, y, radius, color)
    render.SetScissorRect(x - radius, y - radius, x + radius, y + radius, true)
    surface.SetDrawColor(color)
    render.SetScissorRect(0, 0, 0, 0, false)

    draw.Circle(x, y, radius, color)
end

concommand.Add("+java_callout", function()
    options = {}

    javoxCalloutMenuIsOpen = true
    gui.EnableScreenClicker(true)

    -- start on the cancel instead of the first element
    selected = #options
end)

concommand.Add("-java_callout", function()
    javoxCalloutMenuIsOpen = false
    gui.EnableScreenClicker(false)

    if options[selected] and selected <= #options then
        net.Start("JaVox_EmitCallout")
        net.WriteString(options[selected])
        net.SendToServer()
    end

    selected = 1
    options = {}
end)
