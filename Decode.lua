--[[
    CAFEINA / BEEF CLEAN REBUILD
    Reconstructed from static analysis of the obfuscated "beef" payload.

    Features:
      - Mobile-friendly draggable UI
      - Aimbot / Aim Assist (camera CFrame:Lerp)
      - Team check
      - Wall check with RaycastParams.Exclude
      - FOV circle (Drawing API when available)
      - ESP names
      - ESP Highlight / Chams
      - Tracers (Drawing API when available)
      - Distance in studs
      - Local hitbox expander with original-size restore
      - Minimize / restore icon

    Notes:
      - This is a clean rewrite, NOT the original source.
      - File/config persistence from the obfuscated payload is intentionally omitted.
]]

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================
-- CONFIG
--========================================================

local Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 120,
        Smoothness = 6,
        MaxDistance = 1000,
        TargetPart = "Head",
        ShowFOV = true,
    },

    ESP = {
        Enabled = false,
        Names = true,
        Chams = true,
        Tracers = true,
        Studs = true,
        TeamColors = true,
        MaxDistance = 2000,
    },

    Hitbox = {
        Enabled = false,
        TeamCheck = true,
        Size = 5,
        Transparency = 50,
        Part = "HumanoidRootPart",
    }
}

--========================================================
-- HELPERS
--========================================================

local function getCharacter(player)
    return player and player.Character
end

local function getHumanoid(player)
    local character = getCharacter(player)
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(player)
    local character = getCharacter(player)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function isAlive(player)
    local hum = getHumanoid(player)
    return hum and hum.Health > 0
end

local function sameTeam(player)
    if not LocalPlayer.Team or not player.Team then
        return false
    end
    return LocalPlayer.Team == player.Team
end

local function getTeamColor(player)
    if player and player.TeamColor then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(255, 70, 70)
end

local function worldDistance(player)
    local myRoot = getRoot(LocalPlayer)
    local targetRoot = getRoot(player)
    if not myRoot or not targetRoot then
        return math.huge
    end
    return (myRoot.Position - targetRoot.Position).Magnitude
end

local function hasLineOfSight(targetPart)
    if not Config.Aimbot.WallCheck then
        return true
    end

    local localCharacter = getCharacter(LocalPlayer)
    if not localCharacter or not targetPart then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {localCharacter}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

--========================================================
-- DRAWING SUPPORT
--========================================================

local DrawingAvailable = type(Drawing) == "table" and type(Drawing.new) == "function"

local FOVCircle
if DrawingAvailable then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Filled = false
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 72
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Color3.fromRGB(255, 70, 70)
end

local Tracers = {}

local function removeTracer(player)
    local line = Tracers[player]
    if line then
        pcall(function() line:Remove() end)
        Tracers[player] = nil
    end
end

local function getTracer(player)
    if not DrawingAvailable then return nil end
    if not Tracers[player] then
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        line.Transparency = 1
        line.Color = Color3.fromRGB(255, 70, 70)
        Tracers[player] = line
    end
    return Tracers[player]
end

--========================================================
-- TARGET SELECTOR
--========================================================

local function getAimReference()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function getBestTarget()
    local bestPlayer
    local bestPart
    local bestScreenDistance = Config.Aimbot.FOV
    local reference = getAimReference()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            if (not Config.Aimbot.TeamCheck) or (not sameTeam(player)) then
                local character = getCharacter(player)
                local part = character and character:FindFirstChild(Config.Aimbot.TargetPart)

                if part and part:IsA("BasePart") then
                    local distance3D = worldDistance(player)

                    if distance3D <= Config.Aimbot.MaxDistance then
                        local projected, onScreen = Camera:WorldToViewportPoint(part.Position)

                        if onScreen and projected.Z > 0 then
                            local point = Vector2.new(projected.X, projected.Y)
                            local screenDistance = (point - reference).Magnitude

                            if screenDistance < bestScreenDistance and hasLineOfSight(part) then
                                bestScreenDistance = screenDistance
                                bestPlayer = player
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart
end

--========================================================
-- ESP
--========================================================

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CafeinaESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function cleanupPlayerESP(player)
    local character = getCharacter(player)
    if character then
        local h = character:FindFirstChild("ESPHighlight")
        if h then h:Destroy() end

        local head = character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("ESPNameTag")
            if tag then tag:Destroy() end
        end
    end

    removeTracer(player)
end

local function ensureHighlight(player, color)
    if not Config.ESP.Chams then
        local character = getCharacter(player)
        local old = character and character:FindFirstChild("ESPHighlight")
        if old then old:Destroy() end
        return
    end

    local character = getCharacter(player)
    if not character then return end

    local highlight = character:FindFirstChild("ESPHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.65
        highlight.OutlineTransparency = 0.5
        highlight.Parent = character
    end

    highlight.FillColor = color
    highlight.OutlineColor = color
end

local function ensureNameTag(player, color, distance)
    local character = getCharacter(player)
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    if not Config.ESP.Names then
        local old = head:FindFirstChild("ESPNameTag")
        if old then old:Destroy() end
        return
    end

    local tag = head:FindFirstChild("ESPNameTag")
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = "ESPNameTag"
        tag.AlwaysOnTop = true
        tag.Size = UDim2.new(0, 200, 0, 50)
        tag.StudsOffset = Vector3.new(0, 3, 0)
        tag.Adornee = head
        tag.Parent = head

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextStrokeTransparency = 0.35
        label.Parent = tag
    end

    local label = tag:FindFirstChild("Text")
    if label then
        label.TextColor3 = color
        if Config.ESP.Studs then
            label.Text = string.format("%s  [%d]", player.Name, math.floor(distance + 0.5))
        else
            label.Text = player.Name
        end
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Config.ESP.Enabled and isAlive(player) then
                local character = getCharacter(player)
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if root then
                    local distance = worldDistance(player)

                    if distance <= Config.ESP.MaxDistance then
                        local color = Config.ESP.TeamColors and getTeamColor(player)
                            or Color3.fromRGB(255, 70, 70)

                        ensureHighlight(player, color)
                        ensureNameTag(player, color, distance)

                        if Config.ESP.Tracers and DrawingAvailable then
                            local line = getTracer(player)
                            local projected, onScreen = Camera:WorldToViewportPoint(root.Position)

                            if onScreen and projected.Z > 0 then
                                line.From = Vector2.new(
                                    Camera.ViewportSize.X / 2,
                                    Camera.ViewportSize.Y
                                )
                                line.To = Vector2.new(projected.X, projected.Y)
                                line.Color = color
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        else
                            removeTracer(player)
                        end
                    else
                        cleanupPlayerESP(player)
                    end
                else
                    cleanupPlayerESP(player)
                end
            else
                cleanupPlayerESP(player)
            end
        end
    end
end

--========================================================
-- HITBOX
--========================================================

local HitboxCache = {}

local function restoreHitbox(player)
    local data = HitboxCache[player]
    if not data then return end

    local part = data.Part
    if part and part.Parent and data.OrigSize then
        pcall(function()
            part.Size = data.OrigSize
            part.Transparency = data.OrigTransparency or 0
        end)
    end

    HitboxCache[player] = nil
end

local function updateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local allowed = Config.Hitbox.Enabled
                and isAlive(player)
                and ((not Config.Hitbox.TeamCheck) or (not sameTeam(player)))

            if allowed then
                local character = getCharacter(player)
                local part = character and character:FindFirstChild(Config.Hitbox.Part)

                if part and part:IsA("BasePart") then
                    local cached = HitboxCache[player]

                    if not cached or cached.Part ~= part then
                        restoreHitbox(player)
                        HitboxCache[player] = {
                            Part = part,
                            OrigSize = part.Size,
                            OrigTransparency = part.Transparency,
                        }
                    end

                    local size = math.max(1, Config.Hitbox.Size) * 2
                    part.Size = Vector3.new(size, size, size)
                    part.Transparency = math.clamp(Config.Hitbox.Transparency / 100, 0, 1)
                    part.CanCollide = false
                end
            else
                restoreHitbox(player)
            end
        end
    end
end

--========================================================
-- UI
--========================================================

local ParentGui
pcall(function()
    if type(gethui) == "function" then
        ParentGui = gethui()
    end
end)

if not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local Existing = ParentGui:FindFirstChild("CafeinaBeefClean")
if Existing then
    Existing:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaBeefClean"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = ParentGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 330, 0, 430)
Main.Position = UDim2.new(0.5, -165, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 32, 45)
stroke.Thickness = 1.2
stroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "CAFEÍNA • BEEF CLEAN"
Title.TextSize = 17
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 38, 0, 34)
MinBtn.Position = UDim2.new(1, -84, 0, 9)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
MinBtn.Text = "−"
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(110, 24, 34)
CloseBtn.Text = "×"
CloseBtn.TextSize = 19
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -18, 1, -62)
Scroll.Position = UDim2.new(0, 9, 0, 56)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Scroll

local Pad = Instance.new("UIPadding")
Pad.PaddingBottom = UDim.new(0, 12)
Pad.Parent = Scroll

local function section(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -12, 0, 28)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = 13
    l.TextColor3 = Color3.fromRGB(235, 82, 92)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = Scroll
end

local function toggle(text, initial, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(29, 29, 35)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.AutoButtonColor = false
    b.Parent = Scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)

    local state = initial

    local function redraw()
        b.Text = string.format("%s     [%s]", text, state and "ON" or "OFF")
        b.BackgroundColor3 = state
            and Color3.fromRGB(92, 30, 39)
            or Color3.fromRGB(29, 29, 35)
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        redraw()
        callback(state)
    end)

    redraw()
    return b
end

local function numberControl(text, value, minVal, maxVal, step, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(29,29,35)
    row.Parent = Scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235,235,235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 34, 0, 30)
    minus.Position = UDim2.new(1, -76, 0.5, -15)
    minus.BackgroundColor3 = Color3.fromRGB(45,45,52)
    minus.Text = "−"
    minus.TextColor3 = Color3.new(1,1,1)
    minus.Font = Enum.Font.GothamBold
    minus.Parent = row
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0,7)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 34, 0, 30)
    plus.Position = UDim2.new(1, -38, 0.5, -15)
    plus.BackgroundColor3 = Color3.fromRGB(82,31,39)
    plus.Text = "+"
    plus.TextColor3 = Color3.new(1,1,1)
    plus.Font = Enum.Font.GothamBold
    plus.Parent = row
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0,7)

    local current = value

    local function redraw()
        label.Text = string.format("%s: %s", text, tostring(current))
    end

    minus.MouseButton1Click:Connect(function()
        current = math.max(minVal, current - step)
        redraw()
        callback(current)
    end)

    plus.MouseButton1Click:Connect(function()
        current = math.min(maxVal, current + step)
        redraw()
        callback(current)
    end)

    redraw()
end

section("AIMBOT")
toggle("Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
toggle("Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
toggle("Wall Check", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
toggle("Mostrar FOV", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
numberControl("FOV", Config.Aimbot.FOV, 30, 500, 10, function(v)
    Config.Aimbot.FOV = v
end)
numberControl("Suavidade", Config.Aimbot.Smoothness, 1, 20, 1, function(v)
    Config.Aimbot.Smoothness = v
end)
numberControl("Distância Máx.", Config.Aimbot.MaxDistance, 100, 5000, 100, function(v)
    Config.Aimbot.MaxDistance = v
end)

section("ESP")
toggle("ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
toggle("Nomes", Config.ESP.Names, function(v) Config.ESP.Names = v end)
toggle("Chams", Config.ESP.Chams, function(v) Config.ESP.Chams = v end)
toggle("Tracers", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end)
toggle("Distância", Config.ESP.Studs, function(v) Config.ESP.Studs = v end)
toggle("Cores por Time", Config.ESP.TeamColors, function(v) Config.ESP.TeamColors = v end)

section("HITBOX")
toggle("Hitbox", Config.Hitbox.Enabled, function(v) Config.Hitbox.Enabled = v end)
toggle("Team Check Hitbox", Config.Hitbox.TeamCheck, function(v) Config.Hitbox.TeamCheck = v end)
numberControl("Hitbox Size", Config.Hitbox.Size, 1, 30, 1, function(v)
    Config.Hitbox.Size = v
end)
numberControl("Transparência", Config.Hitbox.Transparency, 0, 100, 5, function(v)
    Config.Hitbox.Transparency = v
end)

--========================================================
-- DRAG SUPPORT (MOUSE + TOUCH)
--========================================================

local dragging = false
local dragInput
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--========================================================
-- MINIMIZED ICON
--========================================================

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 54, 0, 54)
Icon.Position = UDim2.new(0.5, -27, 0.5, -27)
Icon.BackgroundColor3 = Color3.fromRGB(95, 25, 35)
Icon.Text = "C"
Icon.TextColor3 = Color3.new(1,1,1)
Icon.TextSize = 21
Icon.Font = Enum.Font.GothamBold
Icon.Visible = false
Icon.Parent = Gui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local iconDragging = false
local iconStart
local iconPos

Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconStart = input.Position
        iconPos = Icon.Position
    end
end)

Icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if iconDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - iconStart
        Icon.Position = UDim2.new(
            iconPos.X.Scale,
            iconPos.X.Offset + delta.X,
            iconPos.Y.Scale,
            iconPos.Y.Offset + delta.Y
        )
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    Icon.Visible = true
end)

Icon.MouseButton1Click:Connect(function()
    if not iconDragging then
        Main.Visible = true
        Icon.Visible = false
    end
end)

--========================================================
-- MAIN LOOP
--========================================================

local running = true

local Connection = RunService.RenderStepped:Connect(function()
    if not running then return end
    Camera = workspace.CurrentCamera

    if FOVCircle then
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Position = getAimReference()
        FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
    end

    if Config.Aimbot.Enabled then
        local _, targetPart = getBestTarget()

        if targetPart then
            local current = Camera.CFrame
            local desired = CFrame.new(current.Position, targetPart.Position)
            local alpha = math.clamp(1 / (Config.Aimbot.Smoothness * 2), 0.01, 1)
            Camera.CFrame = current:Lerp(desired, alpha)
        end
    end

    updateESP()
    updateHitboxes()
end)

--========================================================
-- CLEANUP
--========================================================

local function shutdown()
    if not running then return end
    running = false

    if Connection then
        Connection:Disconnect()
    end

    if FOVCircle then
        pcall(function() FOVCircle:Remove() end)
        FOVCircle = nil
    end

    for player in pairs(Tracers) do
        removeTracer(player)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        cleanupPlayerESP(player)
        restoreHitbox(player)
    end

    pcall(function() ESPFolder:Destroy() end)
    pcall(function() Gui:Destroy() end)
end

CloseBtn.MouseButton1Click:Connect(shutdown)

Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerESP(player)
    restoreHitbox(player)
end)
