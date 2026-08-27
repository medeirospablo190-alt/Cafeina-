--[[
    CAFEÍNA MOBILE UI • RED TOGGLE STYLE • COMPACT
    Referência visual:
      ON  = trilho vermelho + bolinha branca à direita
      OFF = trilho escuro + bolinha branca à esquerda

    Feito para uso mobile:
      - Menu arrastável
      - Ícone minimizado arrastável
      - Scroll vertical
      - Botões grandes
      - Toggles fáceis de tocar
      - Fecha e limpa conexões/objetos
      - Aimbot / ESP / Hitbox simples
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
-- THEME
--========================================================

local Theme = {
    Background = Color3.fromRGB(14, 10, 12),
    Panel = Color3.fromRGB(22, 15, 18),
    Panel2 = Color3.fromRGB(28, 19, 23),
    Stroke = Color3.fromRGB(72, 35, 43),

    Red = Color3.fromRGB(255, 25, 38),
    RedDark = Color3.fromRGB(120, 17, 28),

    Text = Color3.fromRGB(245, 245, 245),
    TextDim = Color3.fromRGB(170, 160, 165),

    ToggleOff = Color3.fromRGB(35, 28, 31),
    ToggleOffStroke = Color3.fromRGB(95, 82, 87),
    White = Color3.fromRGB(255, 255, 255),
}

--========================================================
-- INTERNAL CLEANUP
--========================================================

local Connections = {}
local Drawings = {}
local HitboxCache = {}
local ESPObjects = {}
local Running = true

local function TrackConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function TrackDrawing(object)
    table.insert(Drawings, object)
    return object
end

--========================================================
-- CHARACTER HELPERS
--========================================================

local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(player)
    local character = GetCharacter(player)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(player)
    local character = GetCharacter(player)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
    local humanoid = GetHumanoid(player)
    return humanoid and humanoid.Health > 0
end

local function SameTeam(player)
    if not LocalPlayer.Team or not player.Team then
        return false
    end
    return LocalPlayer.Team == player.Team
end

local function GetDistance(player)
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(player)

    if not myRoot or not targetRoot then
        return math.huge
    end

    return (myRoot.Position - targetRoot.Position).Magnitude
end

local function GetPlayerColor(player)
    if Config.ESP.TeamColors and player.TeamColor then
        return player.TeamColor.Color
    end
    return Theme.Red
end

--========================================================
-- AIMBOT
--========================================================

local function HasLineOfSight(part)
    if not Config.Aimbot.WallCheck then
        return true
    end

    local character = GetCharacter(LocalPlayer)
    if not character or not part then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function GetAimCenter()
    return Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
end

local function GetBestTarget()
    local bestPart = nil
    local bestDistance = Config.Aimbot.FOV
    local center = GetAimCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if (not Config.Aimbot.TeamCheck) or (not SameTeam(player)) then
                local character = GetCharacter(player)
                local part = character and character:FindFirstChild(Config.Aimbot.TargetPart)

                if part and part:IsA("BasePart") then
                    if GetDistance(player) <= Config.Aimbot.MaxDistance then
                        local projected, onScreen = Camera:WorldToViewportPoint(part.Position)

                        if onScreen and projected.Z > 0 then
                            local screenPoint = Vector2.new(projected.X, projected.Y)
                            local screenDistance = (screenPoint - center).Magnitude

                            if screenDistance < bestDistance and HasLineOfSight(part) then
                                bestDistance = screenDistance
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPart
end

--========================================================
-- DRAWING / TRACERS
--========================================================

local DrawingAvailable =
    type(Drawing) == "table"
    and type(Drawing.new) == "function"

local Tracers = {}

local function RemoveTracer(player)
    local tracer = Tracers[player]
    if tracer then
        pcall(function()
            tracer:Remove()
        end)
        Tracers[player] = nil
    end
end

local function GetTracer(player)
    if not DrawingAvailable then
        return nil
    end

    if not Tracers[player] then
        local line = TrackDrawing(Drawing.new("Line"))
        line.Visible = false
        line.Thickness = 1.5
        line.Transparency = 1
        line.Color = Theme.Red
        Tracers[player] = line
    end

    return Tracers[player]
end

--========================================================
-- ESP
--========================================================

local function CleanupESP(player)
    local character = GetCharacter(player)

    if character then
        local highlight = character:FindFirstChild("CafeinaESPHighlight")
        if highlight then
            highlight:Destroy()
        end

        local head = character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("CafeinaESPName")
            if tag then
                tag:Destroy()
            end
        end
    end

    RemoveTracer(player)
end

local function EnsureHighlight(player, color)
    local character = GetCharacter(player)
    if not character then
        return
    end

    local highlight = character:FindFirstChild("CafeinaESPHighlight")

    if not Config.ESP.Chams then
        if highlight then
            highlight:Destroy()
        end
        return
    end

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "CafeinaESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.68
        highlight.OutlineTransparency = 0.15
        highlight.Parent = character
    end

    highlight.FillColor = color
    highlight.OutlineColor = color
end

local function EnsureNameTag(player, color, distance)
    local character = GetCharacter(player)
    if not character then
        return
    end

    local head = character:FindFirstChild("Head")
    if not head then
        return
    end

    local tag = head:FindFirstChild("CafeinaESPName")

    if not Config.ESP.Names then
        if tag then
            tag:Destroy()
        end
        return
    end

    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = "CafeinaESPName"
        tag.AlwaysOnTop = true
        tag.Size = UDim2.new(0, 220, 0, 48)
        tag.StudsOffset = Vector3.new(0, 3, 0)
        tag.Adornee = head
        tag.Parent = head

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextStrokeTransparency = 0.35
        label.TextColor3 = Theme.White
        label.Parent = tag
    end

    local label = tag:FindFirstChild("Label")
    if label then
        label.TextColor3 = color

        if Config.ESP.Studs then
            label.Text = string.format(
                "%s  [%d]",
                player.Name,
                math.floor(distance + 0.5)
            )
        else
            label.Text = player.Name
        end
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local valid =
                Config.ESP.Enabled
                and IsAlive(player)
                and GetDistance(player) <= Config.ESP.MaxDistance

            if valid then
                local character = GetCharacter(player)
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if root then
                    local color = GetPlayerColor(player)
                    local distance = GetDistance(player)

                    EnsureHighlight(player, color)
                    EnsureNameTag(player, color, distance)

                    if Config.ESP.Tracers and DrawingAvailable then
                        local tracer = GetTracer(player)
                        local projected, onScreen = Camera:WorldToViewportPoint(root.Position)

                        if tracer then
                            if onScreen and projected.Z > 0 then
                                tracer.From = Vector2.new(
                                    Camera.ViewportSize.X / 2,
                                    Camera.ViewportSize.Y
                                )
                                tracer.To = Vector2.new(
                                    projected.X,
                                    projected.Y
                                )
                                tracer.Color = color
                                tracer.Visible = true
                            else
                                tracer.Visible = false
                            end
                        end
                    else
                        RemoveTracer(player)
                    end
                else
                    CleanupESP(player)
                end
            else
                CleanupESP(player)
            end
        end
    end
end

--========================================================
-- HITBOX
--========================================================

local function RestoreHitbox(player)
    local cached = HitboxCache[player]
    if not cached then
        return
    end

    if cached.Part and cached.Part.Parent then
        pcall(function()
            cached.Part.Size = cached.OriginalSize
            cached.Part.Transparency = cached.OriginalTransparency
            cached.Part.CanCollide = cached.OriginalCanCollide
        end)
    end

    HitboxCache[player] = nil
end

local function UpdateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local allowed =
                Config.Hitbox.Enabled
                and IsAlive(player)
                and (
                    (not Config.Hitbox.TeamCheck)
                    or (not SameTeam(player))
                )

            if allowed then
                local character = GetCharacter(player)
                local part = character and character:FindFirstChild(Config.Hitbox.Part)

                if part and part:IsA("BasePart") then
                    if not HitboxCache[player] or HitboxCache[player].Part ~= part then
                        RestoreHitbox(player)

                        HitboxCache[player] = {
                            Part = part,
                            OriginalSize = part.Size,
                            OriginalTransparency = part.Transparency,
                            OriginalCanCollide = part.CanCollide,
                        }
                    end

                    local size = math.max(Config.Hitbox.Size, 1) * 2

                    part.Size = Vector3.new(size, size, size)
                    part.Transparency =
                        math.clamp(Config.Hitbox.Transparency / 100, 0, 1)
                    part.CanCollide = false
                end
            else
                RestoreHitbox(player)
            end
        end
    end
end

--========================================================
-- PARENT GUI
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

local old = ParentGui:FindFirstChild("CafeinaMobileV2")
if old then
    old:Destroy()
end

--========================================================
-- SCREEN GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaMobileV2"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = ParentGui

--========================================================
-- MAIN MENU
--========================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0.5, -125, 0.5, -160)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1.3
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Theme.Stroke
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -82, 0, 24)
Title.Position = UDim2.new(0, 12, 0, 5)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "CAFEÍNA"
Title.TextSize = 15
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -82, 0, 14)
SubTitle.Position = UDim2.new(0, 12, 0, 26)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.Text = "MOBILE V2 • COMPACT"
SubTitle.TextSize = 8
SubTitle.TextColor3 = Theme.Red
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 28)
MinimizeButton.Position = UDim2.new(1, -68, 0, 8)
MinimizeButton.BackgroundColor3 = Theme.Panel2
MinimizeButton.Text = "—"
MinimizeButton.TextSize = 15
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 28)
CloseButton.Position = UDim2.new(1, -34, 0, 8)
CloseButton.BackgroundColor3 = Theme.RedDark
CloseButton.Text = "×"
CloseButton.TextSize = 15
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Theme.White
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseButton

--========================================================
-- CONTENT SCROLL
--========================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Size = UDim2.new(1, -12, 1, -54)
Scroll.Position = UDim2.new(0, 6, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Theme.Red
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
Scroll.Parent = Main

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 3)
Padding.PaddingRight = UDim.new(0, 3)
Padding.PaddingTop = UDim.new(0, 3)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

--========================================================
-- UI BUILDERS
--========================================================

local function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -6, 0, 22)
    Section.BackgroundTransparency = 1
    Section.Font = Enum.Font.GothamBold
    Section.Text = text
    Section.TextSize = 10
    Section.TextColor3 = Theme.Red
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = Scroll

    return Section
end

local function CreateToggle(text, defaultState, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -6, 0, 42)
    Container.BackgroundColor3 = Theme.Panel
    Container.BorderSizePixel = 0
    Container.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1
    Stroke.Transparency = 0.45
    Stroke.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -76, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = text
    Label.TextSize = 11
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 54, 0, 26)
    ToggleButton.Position = UDim2.new(1, -64, 0.5, -13)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1.2
    ToggleStroke.Parent = ToggleButton

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new(0, 2, 0.5, -11)
    Knob.BackgroundColor3 = Theme.White
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleButton

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = defaultState

    local function Render(animated)
        local targetColor =
            state and Theme.Red or Theme.ToggleOff

        local targetStroke =
            state and Theme.Red or Theme.ToggleOffStroke

        local targetPos =
            state
            and UDim2.new(1, -24, 0.5, -11)
            or UDim2.new(0, 2, 0.5, -11)

        if animated then
            TweenService:Create(
                ToggleButton,
                TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = targetColor}
            ):Play()

            TweenService:Create(
                Knob,
                TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = targetPos}
            ):Play()

            TweenService:Create(
                ToggleStroke,
                TweenInfo.new(0.16),
                {Color = targetStroke}
            ):Play()
        else
            ToggleButton.BackgroundColor3 = targetColor
            ToggleStroke.Color = targetStroke
            Knob.Position = targetPos
        end
    end

    local function Set(value, animated)
        state = value == true
        Render(animated)
        if callback then
            callback(state)
        end
    end

    TrackConnection(ToggleButton.MouseButton1Click:Connect(function()
        Set(not state, true)
    end))

    Render(false)

    return {
        Frame = Container,
        Set = Set,
        Get = function()
            return state
        end
    }
end

local function CreateStepper(text, value, minValue, maxValue, step, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -6, 0, 44)
    Container.BackgroundColor3 = Theme.Panel
    Container.BorderSizePixel = 0
    Container.Parent = Scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1
    Stroke.Transparency = 0.45
    Stroke.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -96, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 10
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Minus = Instance.new("TextButton")
    Minus.Size = UDim2.new(0, 30, 0, 28)
    Minus.Position = UDim2.new(1, -68, 0.5, -14)
    Minus.BackgroundColor3 = Theme.Panel2
    Minus.Text = "−"
    Minus.TextSize = 14
    Minus.Font = Enum.Font.GothamBold
    Minus.TextColor3 = Theme.Text
    Minus.AutoButtonColor = false
    Minus.Parent = Container

    local Plus = Instance.new("TextButton")
    Plus.Size = UDim2.new(0, 30, 0, 28)
    Plus.Position = UDim2.new(1, -34, 0.5, -14)
    Plus.BackgroundColor3 = Theme.RedDark
    Plus.Text = "+"
    Plus.TextSize = 14
    Plus.Font = Enum.Font.GothamBold
    Plus.TextColor3 = Theme.Text
    Plus.AutoButtonColor = false
    Plus.Parent = Container

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 7)
    c1.Parent = Minus

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 7)
    c2.Parent = Plus

    local current = value

    local function Update()
        Label.Text = string.format("%s: %s", text, tostring(current))

        if callback then
            callback(current)
        end
    end

    TrackConnection(Minus.MouseButton1Click:Connect(function()
        current = math.max(minValue, current - step)
        Update()
    end))

    TrackConnection(Plus.MouseButton1Click:Connect(function()
        current = math.min(maxValue, current + step)
        Update()
    end))

    Update()

    return Container
end

--========================================================
-- BUILD OPTIONS
--========================================================

CreateSection("AIMBOT")

CreateToggle(
    "Aimbot",
    Config.Aimbot.Enabled,
    function(v)
        Config.Aimbot.Enabled = v
    end
)

CreateToggle(
    "Team Check",
    Config.Aimbot.TeamCheck,
    function(v)
        Config.Aimbot.TeamCheck = v
    end
)

CreateToggle(
    "Wall Check",
    Config.Aimbot.WallCheck,
    function(v)
        Config.Aimbot.WallCheck = v
    end
)

CreateStepper(
    "FOV",
    Config.Aimbot.FOV,
    30,
    500,
    10,
    function(v)
        Config.Aimbot.FOV = v
    end
)

CreateStepper(
    "Suavidade",
    Config.Aimbot.Smoothness,
    1,
    20,
    1,
    function(v)
        Config.Aimbot.Smoothness = v
    end
)

CreateStepper(
    "Distância Máxima",
    Config.Aimbot.MaxDistance,
    100,
    5000,
    100,
    function(v)
        Config.Aimbot.MaxDistance = v
    end
)

CreateSection("ESP")

CreateToggle(
    "ESP",
    Config.ESP.Enabled,
    function(v)
        Config.ESP.Enabled = v
    end
)

CreateToggle(
    "Nomes",
    Config.ESP.Names,
    function(v)
        Config.ESP.Names = v
    end
)

CreateToggle(
    "Chams",
    Config.ESP.Chams,
    function(v)
        Config.ESP.Chams = v
    end
)

CreateToggle(
    "Tracers",
    Config.ESP.Tracers,
    function(v)
        Config.ESP.Tracers = v
    end
)

CreateToggle(
    "Distância em Studs",
    Config.ESP.Studs,
    function(v)
        Config.ESP.Studs = v
    end
)

CreateToggle(
    "Cores por Time",
    Config.ESP.TeamColors,
    function(v)
        Config.ESP.TeamColors = v
    end
)

CreateSection("HITBOX")

CreateToggle(
    "Hitbox",
    Config.Hitbox.Enabled,
    function(v)
        Config.Hitbox.Enabled = v
    end
)

CreateToggle(
    "Team Check Hitbox",
    Config.Hitbox.TeamCheck,
    function(v)
        Config.Hitbox.TeamCheck = v
    end
)

CreateStepper(
    "Tamanho Hitbox",
    Config.Hitbox.Size,
    1,
    30,
    1,
    function(v)
        Config.Hitbox.Size = v
    end
)

CreateStepper(
    "Transparência",
    Config.Hitbox.Transparency,
    0,
    100,
    5,
    function(v)
        Config.Hitbox.Transparency = v
    end
)

--========================================================
-- MENU DRAG • MOBILE + MOUSE
--========================================================

local Dragging = false
local DragInput = nil
local DragStart = nil
local StartPosition = nil

TrackConnection(Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
        DragInput = input
    end
end))

TrackConnection(Header.InputEnded:Connect(function(input)
    if input == DragInput then
        Dragging = false
        DragInput = nil
    end
end))

TrackConnection(UserInputService.InputChanged:Connect(function(input)
    if not Dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + delta.Y
    )
end))

--========================================================
-- MINIMIZED ICON
--========================================================

local Icon = Instance.new("TextButton")
Icon.Name = "RestoreIcon"
Icon.Size = UDim2.new(0, 44, 0, 44)
Icon.Position = UDim2.new(0.5, -22, 0.5, -22)
Icon.BackgroundColor3 = Theme.Red
Icon.BorderSizePixel = 0
Icon.Text = "C"
Icon.TextSize = 17
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Theme.White
Icon.AutoButtonColor = false
Icon.Visible = false
Icon.Parent = Gui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = Icon

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Color3.fromRGB(255, 100, 110)
IconStroke.Thickness = 1.4
IconStroke.Parent = Icon

local IconDragging = false
local IconMoved = false
local IconDragStart = nil
local IconStartPosition = nil

TrackConnection(Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        IconDragging = true
        IconMoved = false
        IconDragStart = input.Position
        IconStartPosition = Icon.Position
    end
end))

TrackConnection(Icon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        IconDragging = false
    end
end))

TrackConnection(UserInputService.InputChanged:Connect(function(input)
    if not IconDragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - IconDragStart

    if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
        IconMoved = true
    end

    Icon.Position = UDim2.new(
        IconStartPosition.X.Scale,
        IconStartPosition.X.Offset + delta.X,
        IconStartPosition.Y.Scale,
        IconStartPosition.Y.Offset + delta.Y
    )
end))

TrackConnection(MinimizeButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    Icon.Visible = true
end))

TrackConnection(Icon.MouseButton1Click:Connect(function()
    if IconMoved then
        return
    end

    Icon.Visible = false
    Main.Visible = true
end))

--========================================================
-- MAIN LOOP
--========================================================

local MainLoop

MainLoop = TrackConnection(
    RunService.RenderStepped:Connect(function()
        if not Running then
            return
        end

        Camera = workspace.CurrentCamera

        if Config.Aimbot.Enabled then
            local targetPart = GetBestTarget()

            if targetPart then
                local current = Camera.CFrame
                local desired = CFrame.new(
                    current.Position,
                    targetPart.Position
                )

                local alpha = math.clamp(
                    1 / (Config.Aimbot.Smoothness * 2),
                    0.01,
                    1
                )

                Camera.CFrame = current:Lerp(desired, alpha)
            end
        end

        UpdateESP()
        UpdateHitboxes()
    end)
)

--========================================================
-- PLAYER REMOVING
--========================================================

TrackConnection(Players.PlayerRemoving:Connect(function(player)
    CleanupESP(player)
    RestoreHitbox(player)
end))

--========================================================
-- SHUTDOWN
--========================================================

local function Shutdown()
    if not Running then
        return
    end

    Running = false

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for player in pairs(Tracers) do
        RemoveTracer(player)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        CleanupESP(player)
        RestoreHitbox(player)
    end

    for _, drawing in ipairs(Drawings) do
        pcall(function()
            drawing:Remove()
        end)
    end

    pcall(function()
        Gui:Destroy()
    end)
end

TrackConnection(CloseButton.MouseButton1Click:Connect(Shutdown))

--========================================================
-- END
--========================================================
