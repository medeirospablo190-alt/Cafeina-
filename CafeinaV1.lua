--========================================================--
--                  CAFEÍNA V1.0
--             MOBILE / ROBLOX STUDIO
--========================================================--
-- PRINCIPAL
-- MOVIMENTO
--   ├ NOCLIP
--   ├ FLY
--   ├ FLY SPEED
--   └ WALK SPEED
-- COMBATE
--   ├ AIM ASSIST
--   ├ FOV
--   └ FOV CIRCLE
-- VISUAL
--   ├ ESP
--   ├ NOMES
--   └ CAIXAS
-- JOGADOR
-- SCRIPTS
-- SOBRE
--
-- • MOBILE
-- • SIDEBAR COM SCROLL CORRIGIDO
-- • PÁGINAS COM SCROLL
-- • MENU ARRASTÁVEL
-- • ÍCONE ARRASTÁVEL
-- • MINIMIZAR / RESTAURAR / FECHAR
-- • MODO COMPACTO
-- • SLIDERS POR TOQUE
-- • TOGGLES FUNCIONAIS
-- • RESPAWN
-- • ESP
-- • FLY
-- • NOCLIP
-- • WALK SPEED
-- • AIM ASSIST / FOV
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- LIMPEZA DE INSTÂNCIA ANTERIOR
--========================================================--

local OldGui = PlayerGui:FindFirstChild("CAFEINA_V1")

if OldGui then
    OldGui:Destroy()
end

--========================================================--
-- ESTADOS
--========================================================--

local Character
local Humanoid
local Root

local FlyEnabled = false
local NoclipEnabled = false
local WalkSpeedEnabled = false

local ESPEnabled = false
local ESPNamesEnabled = true
local ESPBoxesEnabled = true

local AimAssistEnabled = false
local FOVCircleEnabled = false

local FlySpeed = 50
local WalkSpeedValue = 30
local AimFOV = 120

local BodyVelocity
local BodyGyro

local FlyConnection
local NoclipConnection
local AimConnection

local NoclipState = {}

local ESPFolder
local ESPObjects = {}
local ESPConnections = {}

local CurrentPage = "Principal"
local CompactMode = false
local IsMinimized = false

local States = {}

--========================================================--
-- CORES
--========================================================--

local RED = Color3.fromRGB(255, 35, 45)
local RED_DARK = Color3.fromRGB(115, 18, 25)

local GREEN = Color3.fromRGB(45, 220, 105)
local GREEN_DARK = Color3.fromRGB(20, 100, 55)

local BACKGROUND = Color3.fromRGB(7, 6, 8)
local PANEL = Color3.fromRGB(14, 11, 14)
local PANEL2 = Color3.fromRGB(22, 18, 22)

local TOGGLE_OFF = Color3.fromRGB(38, 35, 40)
local TOGGLE_OFF_BORDER = Color3.fromRGB(63, 58, 65)

local BORDER = Color3.fromRGB(67, 58, 67)

local WHITE = Color3.fromRGB(248, 248, 248)
local GRAY = Color3.fromRGB(170, 165, 172)

--========================================================--
-- CHARACTER
--========================================================--

local function SetupCharacter(Char)

    if not Char then
        return
    end

    Character = Char

    Humanoid =
        Char:WaitForChild(
            "Humanoid",
            10
        )

    Root =
        Char:WaitForChild(
            "HumanoidRootPart",
            10
        )
end

SetupCharacter(
    Player.Character
    or Player.CharacterAdded:Wait()
)

--========================================================--
-- UTILIDADES
--========================================================--

local function CreateCorner(Object, Radius)

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            Radius or 10
        )

    Corner.Parent = Object

    return Corner
end

local function CreateStroke(
    Object,
    Color,
    Thickness
)

    local Stroke =
        Instance.new("UIStroke")

    Stroke.Color =
        Color or BORDER

    Stroke.Thickness =
        Thickness or 1

    Stroke.ApplyStrokeMode =
        Enum.ApplyStrokeMode.Border

    Stroke.Parent = Object

    return Stroke
end

local function Tween(
    Object,
    Properties,
    Time
)

    if
        not Object
        or not Object.Parent
    then
        return
    end

    TweenService:Create(
        Object,
        TweenInfo.new(
            Time or .18,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        Properties
    ):Play()
end

local function CreateLabel(
    Parent,
    Text,
    Size,
    Color,
    Font
)

    local Label =
        Instance.new("TextLabel")

    Label.BackgroundTransparency = 1

    Label.Text = Text

    Label.TextSize =
        Size or 14

    Label.TextColor3 =
        Color or WHITE

    Label.Font =
        Font or Enum.Font.Gotham

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.TextYAlignment =
        Enum.TextYAlignment.Center

    Label.Parent = Parent

    return Label
end

--========================================================--
-- GUI
--========================================================--

local Gui =
    Instance.new("ScreenGui")

Gui.Name = "CAFEINA_V1"

Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true

Gui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

Gui.Parent = PlayerGui

--========================================================--
-- NOTIFICAÇÃO
--========================================================--

local NotificationHolder =
    Instance.new("Frame")

NotificationHolder.BackgroundTransparency = 1

NotificationHolder.AnchorPoint =
    Vector2.new(1, 0)

NotificationHolder.Position =
    UDim2.new(
        1,
        -10,
        0,
        10
    )

NotificationHolder.Size =
    UDim2.new(
        0,
        270,
        1,
        -20
    )

NotificationHolder.ZIndex = 5000

NotificationHolder.Parent = Gui

local NotificationLayout =
    Instance.new("UIListLayout")

NotificationLayout.Padding =
    UDim.new(0, 7)

NotificationLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Right

NotificationLayout.VerticalAlignment =
    Enum.VerticalAlignment.Top

NotificationLayout.Parent =
    NotificationHolder

local function Notify(
    Title,
    Text
)

    local Box =
        Instance.new("Frame")

    Box.BackgroundColor3 =
        PANEL

    Box.Size =
        UDim2.new(
            1,
            0,
            0,
            60
        )

    Box.ZIndex = 5001
    Box.Parent =
        NotificationHolder

    CreateCorner(Box, 10)
    CreateStroke(Box, RED, 1)

    local TitleLabel =
        CreateLabel(
            Box,
            Title,
            14,
            RED,
            Enum.Font.GothamBold
        )

    TitleLabel.Position =
        UDim2.new(
            0,
            11,
            0,
            4
        )

    TitleLabel.Size =
        UDim2.new(
            1,
            -22,
            0,
            22
        )

    TitleLabel.ZIndex = 5002

    local TextLabel =
        CreateLabel(
            Box,
            Text,
            12,
            GRAY,
            Enum.Font.Gotham
        )

    TextLabel.Position =
        UDim2.new(
            0,
            11,
            0,
            29
        )

    TextLabel.Size =
        UDim2.new(
            1,
            -22,
            0,
            24
        )

    TextLabel.ZIndex = 5002

    task.delay(
        2,
        function()

            if
                not Box
                or not Box.Parent
            then
                return
            end

            Tween(
                Box,
                {
                    BackgroundTransparency = 1
                },
                .2
            )

            task.wait(.22)

            if Box then
                Box:Destroy()
            end
        end
    )
end

--========================================================--
-- MENU
--========================================================--

local Main =
    Instance.new("Frame")

Main.Name = "Main"

Main.AnchorPoint =
    Vector2.new(.5, .5)

Main.Position =
    UDim2.fromScale(
        .5,
        .5
    )

Main.Size =
    UDim2.new(
        .93,
        0,
        .85,
        0
    )

Main.BackgroundColor3 =
    BACKGROUND

Main.BorderSizePixel = 0
Main.ClipsDescendants = true

Main.ZIndex = 10
Main.Parent = Gui

CreateCorner(Main, 18)
CreateStroke(Main, RED, 1.3)

local MainScale =
    Instance.new("UIScale")

MainScale.Scale = 1
MainScale.Parent = Main

--========================================================--
-- HEADER
--========================================================--

local Header =
    Instance.new("Frame")

Header.BackgroundTransparency = 1

Header.Size =
    UDim2.new(
        1,
        0,
        0,
        88
    )

Header.ZIndex = 20
Header.Parent = Main

local Crown =
    CreateLabel(
        Header,
        "♛",
        25,
        RED,
        Enum.Font.GothamBold
    )

Crown.Position =
    UDim2.new(
        0,
        22,
        0,
        3
    )

Crown.Size =
    UDim2.new(
        0,
        42,
        0,
        28
    )

Crown.TextXAlignment =
    Enum.TextXAlignment.Center

local Logo =
    CreateLabel(
        Header,
        "CAFEÍNA",
        29,
        WHITE,
        Enum.Font.GothamBlack
    )

Logo.Position =
    UDim2.new(
        0,
        23,
        0,
        27
    )

Logo.Size =
    UDim2.new(
        0,
        210,
        0,
        37
    )

local Version =
    CreateLabel(
        Header,
        "V1.0",
        16,
        RED,
        Enum.Font.GothamBlack
    )

Version.Position =
    UDim2.new(
        0,
        110,
        0,
        61
    )

Version.Size =
    UDim2.new(
        0,
        65,
        0,
        20
    )

--========================================================--
-- MINIMIZAR
--========================================================--

local Minimize =
    Instance.new("TextButton")

Minimize.Text = "−"
Minimize.TextSize = 24
Minimize.TextColor3 = WHITE
Minimize.Font = Enum.Font.GothamBold

Minimize.BackgroundColor3 =
    PANEL2

Minimize.AutoButtonColor = false

Minimize.Position =
    UDim2.new(
        1,
        -116,
        0,
        17
    )

Minimize.Size =
    UDim2.new(
        0,
        36,
        0,
        36
    )

Minimize.ZIndex = 30
Minimize.Parent = Header

CreateCorner(Minimize, 20)
CreateStroke(Minimize, BORDER, 1)

--========================================================--
-- FECHAR
--========================================================--

local Close =
    Instance.new("TextButton")

Close.Text = "×"
Close.TextSize = 24
Close.TextColor3 = WHITE
Close.Font = Enum.Font.GothamBold

Close.BackgroundColor3 =
    RED_DARK

Close.AutoButtonColor = false

Close.Position =
    UDim2.new(
        1,
        -70,
        0,
        17
    )

Close.Size =
    UDim2.new(
        0,
        36,
        0,
        36
    )

Close.ZIndex = 30
Close.Parent = Header

CreateCorner(Close, 20)
CreateStroke(Close, RED, 1)

--========================================================--
-- BODY
--========================================================--

local Body =
    Instance.new("Frame")

Body.BackgroundTransparency = 1

Body.Position =
    UDim2.new(
        0,
        11,
        0,
        88
    )

Body.Size =
    UDim2.new(
        1,
        -22,
        1,
        -99
    )

Body.ClipsDescendants = true

Body.ZIndex = 11
Body.Parent = Main

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar =
    Instance.new("ScrollingFrame")

Sidebar.Name = "Sidebar"

Sidebar.BackgroundColor3 =
    PANEL

Sidebar.Size =
    UDim2.new(
        0,
        145,
        1,
        0
    )

Sidebar.Position =
    UDim2.fromOffset(
        0,
        0
    )

Sidebar.BorderSizePixel = 0

Sidebar.Active = true

Sidebar.ScrollingEnabled = true

Sidebar.ScrollingDirection =
    Enum.ScrollingDirection.Y

Sidebar.ScrollBarThickness = 5

Sidebar.ScrollBarImageColor3 =
    RED

Sidebar.ScrollBarImageTransparency =
    .1

Sidebar.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        0
    )

Sidebar.AutomaticCanvasSize =
    Enum.AutomaticSize.None

Sidebar.ElasticBehavior =
    Enum.ElasticBehavior.WhenScrollable

Sidebar.ClipsDescendants = true

Sidebar.ZIndex = 12
Sidebar.Parent = Body

CreateCorner(Sidebar, 14)
CreateStroke(Sidebar, BORDER, 1)

local SidePadding =
    Instance.new("UIPadding")

SidePadding.PaddingLeft =
    UDim.new(0, 8)

SidePadding.PaddingRight =
    UDim.new(0, 8)

SidePadding.PaddingTop =
    UDim.new(0, 8)

SidePadding.PaddingBottom =
    UDim.new(0, 18)

SidePadding.Parent =
    Sidebar

local SideLayout =
    Instance.new("UIListLayout")

SideLayout.Padding =
    UDim.new(0, 7)

SideLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

SideLayout.Parent =
    Sidebar

--========================================================--
-- ATUALIZAÇÃO DO SCROLL LATERAL
--========================================================--

local function RefreshSidebar()

    if not Sidebar.Parent then
        return
    end

    task.defer(
        function()

            local ContentHeight =
                SideLayout.AbsoluteContentSize.Y

            Sidebar.CanvasSize =
                UDim2.new(
                    0,
                    0,
                    0,
                    math.max(
                        Sidebar.AbsoluteSize.Y + 1,
                        math.ceil(
                            ContentHeight + 28
                        )
                    )
                )
        end
    )
end

SideLayout:GetPropertyChangedSignal(
    "AbsoluteContentSize"
):Connect(
    RefreshSidebar
)

Sidebar:GetPropertyChangedSignal(
    "AbsoluteSize"
):Connect(
    RefreshSidebar
)

--========================================================--
-- PÁGINAS
--========================================================--

local PagesHolder =
    Instance.new("Frame")

PagesHolder.BackgroundTransparency = 1

PagesHolder.Position =
    UDim2.new(
        0,
        155,
        0,
        0
    )

PagesHolder.Size =
    UDim2.new(
        1,
        -155,
        1,
        0
    )

PagesHolder.ClipsDescendants = true

PagesHolder.ZIndex = 12
PagesHolder.Parent = Body

local Pages = {}
local PageLayouts = {}
local NavigationButtons = {}

--========================================================--
-- CRIAR PÁGINA
--========================================================--

local function RefreshPage(Page)

    if
        not Page
        or not Page.Parent
    then
        return
    end

    local Layout =
        PageLayouts[Page]

    if not Layout then
        return
    end

    task.defer(
        function()

            if not Page.Parent then
                return
            end

            local Content =
                Layout.AbsoluteContentSize.Y

            local ViewHeight =
                Page.AbsoluteSize.Y

            Page.CanvasSize =
                UDim2.new(
                    0,
                    0,
                    0,
                    math.max(
                        ViewHeight + 1,
                        math.ceil(
                            Content + 55
                        )
                    )
                )
        end
    )
end

local function RefreshAllPages()

    for _, Page in pairs(Pages) do
        RefreshPage(Page)
    end

    RefreshSidebar()
end

local function CreatePage(Name)

    local Page =
        Instance.new("ScrollingFrame")

    Page.Name = Name

    Page.BackgroundTransparency = 1

    Page.Size =
        UDim2.fromScale(
            1,
            1
        )

    Page.BorderSizePixel = 0

    Page.Active = true
    Page.ScrollingEnabled = true

    Page.ScrollingDirection =
        Enum.ScrollingDirection.Y

    Page.ScrollBarThickness = 4

    Page.ScrollBarImageColor3 =
        RED

    Page.ScrollBarImageTransparency =
        .05

    Page.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    Page.ElasticBehavior =
        Enum.ElasticBehavior.WhenScrollable

    Page.ClipsDescendants = true

    Page.ZIndex = 13
    Page.Parent = PagesHolder

    local Padding =
        Instance.new("UIPadding")

    Padding.PaddingLeft =
        UDim.new(0, 4)

    Padding.PaddingRight =
        UDim.new(0, 10)

    Padding.PaddingTop =
        UDim.new(0, 5)

    Padding.PaddingBottom =
        UDim.new(0, 45)

    Padding.Parent = Page

    local Layout =
        Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(0, 10)

    Layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    Layout.Parent = Page

    Pages[Name] = Page
    PageLayouts[Page] = Layout

    Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(
        function()
            RefreshPage(Page)
        end
    )

    Page:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(
        function()
            RefreshPage(Page)
        end
    )

    return Page
end

local Principal =
    CreatePage("Principal")

local Movimento =
    CreatePage("Movimento")

local Combate =
    CreatePage("Combate")

local Visual =
    CreatePage("Visual")

local Jogador =
    CreatePage("Jogador")

local Scripts =
    CreatePage("Scripts")

local Sobre =
    CreatePage("Sobre")

--========================================================--
-- CABEÇALHO DAS PÁGINAS
--========================================================--

local function PageHeader(
    Page,
    Icon,
    Title,
    Description
)

    local Box =
        Instance.new("Frame")

    Box.BackgroundTransparency = 1

    Box.Size =
        UDim2.new(
            1,
            -10,
            0,
            65
        )

    Box.Parent = Page

    local IconLabel =
        CreateLabel(
            Box,
            Icon,
            25,
            RED,
            Enum.Font.GothamBold
        )

    IconLabel.Position =
        UDim2.new(
            0,
            3,
            0,
            0
        )

    IconLabel.Size =
        UDim2.new(
            0,
            40,
            0,
            31
        )

    IconLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    local TitleLabel =
        CreateLabel(
            Box,
            Title,
            22,
            WHITE,
            Enum.Font.GothamBold
        )

    TitleLabel.Position =
        UDim2.new(
            0,
            48,
            0,
            0
        )

    TitleLabel.Size =
        UDim2.new(
            1,
            -55,
            0,
            32
        )

    local DescriptionLabel =
        CreateLabel(
            Box,
            Description,
            12,
            GRAY,
            Enum.Font.Gotham
        )

    DescriptionLabel.Position =
        UDim2.new(
            0,
            48,
            0,
            32
        )

    DescriptionLabel.Size =
        UDim2.new(
            1,
            -55,
            0,
            22
        )

    return Box
end

--========================================================--
-- TOGGLE GENÉRICO
--========================================================--

local function CreateToggle(
    Parent,
    Name,
    Default,
    Callback
)

    local Row =
        Instance.new("Frame")

    Row.BackgroundColor3 =
        PANEL2

    Row.Size =
        UDim2.new(
            1,
            0,
            0,
            56
        )

    Row.Parent = Parent

    CreateCorner(Row, 11)

    local RowStroke =
        CreateStroke(
            Row,
            TOGGLE_OFF_BORDER,
            1
        )

    local Text =
        CreateLabel(
            Row,
            Name,
            15,
            WHITE,
            Enum.Font.GothamMedium
        )

    Text.Position =
        UDim2.new(
            0,
            14,
            0,
            0
        )

    Text.Size =
        UDim2.new(
            1,
            -88,
            1,
            0
        )

    local Toggle =
        Instance.new("TextButton")

    Toggle.Text = ""

    Toggle.AutoButtonColor = false

    Toggle.BackgroundColor3 =
        Default
        and GREEN
        or TOGGLE_OFF

    Toggle.AnchorPoint =
        Vector2.new(
            1,
            .5
        )

    Toggle.Position =
        UDim2.new(
            1,
            -12,
            .5,
            0
        )

    Toggle.Size =
        UDim2.new(
            0,
            58,
            0,
            30
        )

    Toggle.ZIndex =
        Row.ZIndex + 2

    Toggle.Parent = Row

    CreateCorner(
        Toggle,
        20
    )

    local ToggleStroke =
        CreateStroke(
            Toggle,
            Default
            and GREEN
            or TOGGLE_OFF_BORDER,
            1
        )

    local Knob =
        Instance.new("Frame")

    Knob.BackgroundColor3 =
        WHITE

    Knob.Size =
        UDim2.new(
            0,
            24,
            0,
            24
        )

    Knob.AnchorPoint =
        Vector2.new(
            .5,
            .5
        )

    Knob.Position =
        Default
        and UDim2.new(
            1,
            -15,
            .5,
            0
        )
        or UDim2.new(
            0,
            15,
            .5,
            0
        )

    Knob.ZIndex =
        Toggle.ZIndex + 1

    Knob.Parent = Toggle

    CreateCorner(
        Knob,
        20
    )

    States[Name] = Default

    local function SetState(
        State,
        Silent
    )

        States[Name] = State

        Tween(
            Toggle,
            {
                BackgroundColor3 =
                    State
                    and GREEN
                    or TOGGLE_OFF
            },
            .15
        )

        Tween(
            ToggleStroke,
            {
                Color =
                    State
                    and GREEN
                    or TOGGLE_OFF_BORDER
            },
            .15
        )

        Tween(
            Knob,
            {
                Position =
                    State
                    and UDim2.new(
                        1,
                        -15,
                        .5,
                        0
                    )
                    or UDim2.new(
                        0,
                        15,
                        .5,
                        0
                    )
            },
            .15
        )

        if Callback then
            Callback(State)
        end

        if not Silent then
            Notify(
                Name,
                State
                and "Ativado."
                or "Desativado."
            )
        end
    end

    Toggle.Activated:Connect(
        function()

            SetState(
                not States[Name]
            )
        end
    )

    return Row, SetState
end

--========================================================--
-- SLIDER
--========================================================--

local function CreateSlider(
    Parent,
    Name,
    Minimum,
    Maximum,
    Default,
    Callback
)

    local Box =
        Instance.new("Frame")

    Box.BackgroundColor3 =
        PANEL2

    Box.Size =
        UDim2.new(
            1,
            0,
            0,
            76
        )

    Box.Parent = Parent

    CreateCorner(Box, 11)
    CreateStroke(Box, BORDER, 1)

    local Title =
        CreateLabel(
            Box,
            Name,
            14,
            WHITE,
            Enum.Font.GothamBold
        )

    Title.Position =
        UDim2.new(
            0,
            13,
            0,
            7
        )

    Title.Size =
        UDim2.new(
            .7,
            0,
            0,
            23
        )

    local ValueLabel =
        CreateLabel(
            Box,
            tostring(Default),
            14,
            WHITE,
            Enum.Font.GothamBold
        )

    ValueLabel.Position =
        UDim2.new(
            1,
            -60,
            0,
            7
        )

    ValueLabel.Size =
        UDim2.new(
            0,
            47,
            0,
            23
        )

    ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Right

    local Bar =
        Instance.new("TextButton")

    Bar.Text = ""
    Bar.AutoButtonColor = false

    Bar.BackgroundColor3 =
        Color3.fromRGB(
            52,
            48,
            53
        )

    Bar.Position =
        UDim2.new(
            0,
            13,
            0,
            48
        )

    Bar.Size =
        UDim2.new(
            1,
            -26,
            0,
            7
        )

    Bar.Active = true
    Bar.Parent = Box

    CreateCorner(
        Bar,
        10
    )

    local Range =
        math.max(
            Maximum - Minimum,
            1
        )

    local Ratio =
        math.clamp(
            (
                Default
                - Minimum
            ) / Range,
            0,
            1
        )

    local Fill =
        Instance.new("Frame")

    Fill.BackgroundColor3 =
        RED

    Fill.Size =
        UDim2.new(
            Ratio,
            0,
            1,
            0
        )

    Fill.Parent = Bar

    CreateCorner(
        Fill,
        10
    )

    local Knob =
        Instance.new("Frame")

    Knob.BackgroundColor3 =
        WHITE

    Knob.AnchorPoint =
        Vector2.new(
            .5,
            .5
        )

    Knob.Position =
        UDim2.new(
            Ratio,
            0,
            .5,
            0
        )

    Knob.Size =
        UDim2.new(
            0,
            16,
            0,
            16
        )

    Knob.Parent = Bar

    CreateCorner(
        Knob,
        20
    )

    local CurrentValue =
        Default

    local Dragging = false

    local function SetValue(
        Number
    )

        Number =
            math.clamp(
                math.floor(
                    Number + .5
                ),
                Minimum,
                Maximum
            )

        CurrentValue =
            Number

        local Percent =
            math.clamp(
                (
                    Number
                    - Minimum
                ) / Range,
                0,
                1
            )

        ValueLabel.Text =
            tostring(Number)

        Fill.Size =
            UDim2.new(
                Percent,
                0,
                1,
                0
            )

        Knob.Position =
            UDim2.new(
                Percent,
                0,
                .5,
                0
            )

        if Callback then
            Callback(Number)
        end
    end

    local function UpdateFromInput(
        Input
    )

        local Width =
            Bar.AbsoluteSize.X

        if Width <= 0 then
            return
        end

        local X =
            Input.Position.X
            - Bar.AbsolutePosition.X

        local Percent =
            math.clamp(
                X / Width,
                0,
                1
            )

        SetValue(
            Minimum
            + (
                Maximum
                - Minimum
            )
            * Percent
        )
    end

    Bar.InputBegan:Connect(
        function(Input)

            if
                Input.UserInputType
                == Enum.UserInputType.Touch
                or
                Input.UserInputType
                == Enum.UserInputType.MouseButton1
            then

                Dragging = true

                UpdateFromInput(
                    Input
                )
            end
        end
    )
\n    -- Touch direto no próprio slider (mais confiável em celular).\n    Bar.InputChanged:Connect(\n        function(Input)\n\n            if not Dragging then\n                return\n            end\n\n            if Input.UserInputType == Enum.UserInputType.Touch\n                or Input.UserInputType == Enum.UserInputType.MouseMovement then\n                UpdateFromInput(Input)\n            end\n        end\n    )\n
    UIS.InputChanged:Connect(
        function(Input)

            if not Dragging then
                return
            end

            if
                Input.UserInputType
                == Enum.UserInputType.Touch
                or
                Input.UserInputType
                == Enum.UserInputType.MouseMovement
            then

                UpdateFromInput(
                    Input
                )
            end
        end
    )

    UIS.InputEnded:Connect(
        function(Input)

            if
                Input.UserInputType
                == Enum.UserInputType.Touch
                or
                Input.UserInputType
                == Enum.UserInputType.MouseButton1
            then

                Dragging = false
            end
        end
    )

    return Box, SetValue
end

--========================================================--
-- MOVIMENTO: FUNÇÕES
--========================================================--

local function StopFly()

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

local function StartFly()

    if
        not Root
        or not Humanoid
    then
        return
    end

    StopFly()

    BodyVelocity =
        Instance.new("BodyVelocity")

    BodyVelocity.MaxForce =
        Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )

    BodyVelocity.P = 9000
    BodyVelocity.Velocity =
        Vector3.zero

    BodyVelocity.Parent =
        Root

    BodyGyro =
        Instance.new("BodyGyro")

    BodyGyro.MaxTorque =
        Vector3.new(
            math.huge,
            math.huge,
            math.huge
        )

    BodyGyro.P = 9000

    BodyGyro.CFrame =
        Root.CFrame

    BodyGyro.Parent =
        Root

    Humanoid.PlatformStand = true

    FlyConnection =
        RunService.RenderStepped:
        Connect(
            function()

                if
                    not FlyEnabled
                    or not Root
                    or not BodyVelocity
                    or not BodyGyro
                then
                    return
                end

                local Camera =
                    workspace.CurrentCamera

                if not Camera then
                    return
                end

                local Move =
                    Humanoid.MoveDirection

                local Velocity =
                    Vector3.zero

                if
                    Move.Magnitude
                    > .05
                then

                    local Direction =
                        Move

                    if
                        Direction.Magnitude
                        > .05
                    then

                        Velocity =
                            Direction.Unit
                            * FlySpeed
                    end
                end

                BodyVelocity.Velocity =
                    Velocity

                BodyGyro.CFrame =
                    CFrame.lookAt(
                        Root.Position,
                        Root.Position
                        + Camera.CFrame.LookVector
                    )
            end
        )
end

--========================================================--
-- NOCLIP
--========================================================--

local function ApplyNoclip()

    if not Character then
        return
    end

    for _, Part in ipairs(
        Character:GetDescendants()
    ) do

        if Part:IsA("BasePart") then

            if
                NoclipState[Part]
                == nil
            then

                NoclipState[Part] =
                    Part.CanCollide
            end

            Part.CanCollide = false
        end
    end
end

local function RestoreNoclip()

    for Part, Original in pairs(
        NoclipState
    ) do

        if
            Part
            and Part.Parent
        then

            Part.CanCollide =
                Original
        end
    end

    table.clear(
        NoclipState
    )
end

local function StartNoclip()

    ApplyNoclip()

    if NoclipConnection then
        NoclipConnection:Disconnect()
    end

    NoclipConnection =
        RunService.Stepped:
        Connect(
            function()

                if NoclipEnabled then
                    ApplyNoclip()
                end
            end
        )
end

local function StopNoclip()

    if NoclipConnection then

        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    RestoreNoclip()
end

--========================================================--
-- WALK SPEED
--========================================================--

local function ApplyWalkSpeed()

    if not Humanoid then
        return
    end

    if WalkSpeedEnabled then

        Humanoid.WalkSpeed =
            WalkSpeedValue

    else

        Humanoid.WalkSpeed = 16
    end
end

--========================================================--
-- ESP
--========================================================--

ESPFolder =
    Instance.new("Folder")

ESPFolder.Name =
    "CafeinaESP"

ESPFolder.Parent =
    Gui

local function RemoveESP(
    Target
)

    local Data =
        ESPObjects[Target]

    if not Data then
        return
    end

    for _, Object in pairs(
        Data
    ) do

        if Object then
            Object:Destroy()
        end
    end

    ESPObjects[Target] = nil
end

local function CreateESP(
    Target
)

    if
        Target == Player
        or not ESPEnabled
    then
        return
    end

    local TargetCharacter =
        Target.Character

    if not TargetCharacter then
        return
    end

    local TargetRoot =
        TargetCharacter:
        FindFirstChild(
            "HumanoidRootPart"
        )

    if not TargetRoot then
        return
    end

    if ESPObjects[Target] then
        return
    end

    local Data = {}

    if ESPBoxesEnabled then

        local Highlight =
            Instance.new("Highlight")

        Highlight.Name =
            "ESP_Highlight"

        Highlight.Adornee =
            TargetCharacter

        Highlight.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop

        Highlight.FillTransparency = 1
        Highlight.OutlineTransparency = 0

        Highlight.OutlineColor =
            Color3.new(
                1,
                1,
                1
            )

        Highlight.Parent =
            ESPFolder

        Data.Highlight =
            Highlight
    end

    if ESPNamesEnabled then

        local Billboard =
            Instance.new("BillboardGui")

        Billboard.Name =
            "ESP_Name"

        Billboard.Adornee =
            TargetRoot

        Billboard.Size =
            UDim2.fromOffset(
                150,
                35
            )

        Billboard.StudsOffset =
            Vector3.new(
                0,
                3,
                0
            )

        Billboard.AlwaysOnTop = true
        Billboard.Parent =
            ESPFolder

        local Label =
            Instance.new("TextLabel")

        Label.Size =
            UDim2.fromScale(
                1,
                1
            )

        Label.BackgroundTransparency = 1

        Label.Text =
            Target.DisplayName

        Label.TextColor3 =
            Color3.new(
                1,
                1,
                1
            )

        Label.TextStrokeTransparency = 0
        Label.TextSize = 14

        Label.Font =
            Enum.Font.GothamBold

        Label.Parent =
            Billboard

        Data.Billboard =
            Billboard
    end

    ESPObjects[Target] =
        Data
end

local function ClearESPConnections()

    for _, Connection in pairs(
        ESPConnections
    ) do

        if Connection then
            Connection:Disconnect()
        end
    end

    table.clear(
        ESPConnections
    )
end

local function DisableESP()

    ESPEnabled = false

    ClearESPConnections()

    for Target in pairs(
        ESPObjects
    ) do

        RemoveESP(Target)
    end
end

local function WatchPlayer(
    Target
)

    if Target == Player then
        return
    end

    local Key =
        "Character_"
        .. Target.UserId

    if ESPConnections[Key] then

        ESPConnections[Key]:
            Disconnect()
    end

    ESPConnections[Key] =
        Target.CharacterAdded:
        Connect(
            function()

                task.wait(.25)

                if ESPEnabled then

                    RemoveESP(
                        Target
                    )

                    CreateESP(
                        Target
                    )
                end
            end
        )

    if ESPEnabled then
        CreateESP(Target)
    end
end

local function EnableESP()

    ESPEnabled = true

    ClearESPConnections()

    for _, Target in ipairs(
        Players:GetPlayers()
    ) do

        WatchPlayer(
            Target
        )
    end

    ESPConnections.PlayerAdded =
        Players.PlayerAdded:
        Connect(
            function(Target)

                if Target ~= Player then
                    WatchPlayer(Target)
                end
            end
        )

    ESPConnections.PlayerRemoving =
        Players.PlayerRemoving:
        Connect(
            function(Target)

                RemoveESP(Target)
            end
        )
end

local function RefreshESP()

    if not ESPEnabled then
        return
    end

    for Target in pairs(
        ESPObjects
    ) do

        RemoveESP(Target)
    end

    for _, Target in ipairs(
        Players:GetPlayers()
    ) do

        if Target ~= Player then
            CreateESP(Target)
        end
    end
end

--========================================================--
-- AIM ASSIST
--========================================================--

local function GetClosestCharacter()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local Center =
        Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )

    local Closest = nil

    local Distance =
        AimFOV

    for _, Target in ipairs(
        Players:GetPlayers()
    ) do

        if Target ~= Player then

            local Char =
                Target.Character

            if Char then

                local TargetHumanoid =
                    Char:FindFirstChildOfClass(
                        "Humanoid"
                    )

                local Head =
                    Char:FindFirstChild(
                        "Head"
                    )

                if
                    TargetHumanoid
                    and TargetHumanoid.Health > 0
                    and Head
                then

                    local Position,
                        OnScreen =
                        Camera:
                        WorldToViewportPoint(
                            Head.Position
                        )

                    if OnScreen then

                        local CurrentDistance =
                            (
                                Vector2.new(
                                    Position.X,
                                    Position.Y
                                )
                                - Center
                            ).Magnitude

                        if
                            CurrentDistance
                            < Distance
                        then

                            Distance =
                                CurrentDistance

                            Closest =
                                Head
                        end
                    end
                end
            end
        end
    end

    return Closest
end

local FOVCircle =
    Instance.new("Frame")

FOVCircle.Name = "FOV"

FOVCircle.Size =
    UDim2.fromOffset(
        AimFOV * 2,
        AimFOV * 2
    )

FOVCircle.AnchorPoint =
    Vector2.new(
        .5,
        .5
    )

FOVCircle.Position =
    UDim2.fromScale(
        .5,
        .5
    )

FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0

FOVCircle.Visible = false

FOVCircle.ZIndex = 4
FOVCircle.Parent = Gui

CreateCorner(
    FOVCircle,
    999
)

local FOVStroke =
    CreateStroke(
        FOVCircle,
        WHITE,
        1
    )

FOVStroke.Transparency = .4

local function StopAim()

    AimAssistEnabled = false
    FOVCircle.Visible = false

    if AimConnection then

        AimConnection:Disconnect()
        AimConnection = nil
    end
end

local function StartAim()

    if AimConnection then
        AimConnection:Disconnect()
    end

    AimConnection =
        RunService.RenderStepped:
        Connect(
            function()

                if not AimAssistEnabled then
                    return
                end

                local Camera =
                    workspace.CurrentCamera

                if not Camera then
                    return
                end

                local Target =
                    GetClosestCharacter()

                if Target then

                    local Current =
                        Camera.CFrame

                    local Desired =
                        CFrame.lookAt(
                            Current.Position,
                            Target.Position
                        )

                    Camera.CFrame =
                        Current:Lerp(
                            Desired,
                            .12
                        )
                end
            end
        )
end

--========================================================--
-- PRINCIPAL
--========================================================--

PageHeader(
    Principal,
    "♛",
    "Principal",
    "Controle total em suas mãos."
)

local Welcome =
    Instance.new("Frame")

Welcome.BackgroundColor3 =
    PANEL

Welcome.Size =
    UDim2.new(
        1,
        -10,
        0,
        285
    )

Welcome.Parent =
    Principal

CreateCorner(
    Welcome,
    14
)

CreateStroke(
    Welcome,
    RED_DARK,
    1
)

local BigLogo =
    CreateLabel(
        Welcome,
        "CAFEÍNA",
        32,
        WHITE,
        Enum.Font.GothamBlack
    )

BigLogo.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

BigLogo.Position =
    UDim2.new(
        .5,
        0,
        0,
        17
    )

BigLogo.Size =
    UDim2.new(
        1,
        -20,
        0,
        40
    )

BigLogo.TextXAlignment =
    Enum.TextXAlignment.Center

local BigVersion =
    CreateLabel(
        Welcome,
        "V1.0",
        18,
        RED,
        Enum.Font.GothamBlack
    )

BigVersion.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

BigVersion.Position =
    UDim2.new(
        .5,
        0,
        0,
        55
    )

BigVersion.Size =
    UDim2.new(
        0,
        70,
        0,
        25
    )

BigVersion.TextXAlignment =
    Enum.TextXAlignment.Center

local Motto =
    CreateLabel(
        Welcome,
        "FORÇA  •  CONTROLE  •  SUPREMACIA",
        12,
        GRAY,
        Enum.Font.GothamMedium
    )

Motto.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

Motto.Position =
    UDim2.new(
        .5,
        0,
        0,
        84
    )

Motto.Size =
    UDim2.new(
        1,
        -20,
        0,
        25
    )

Motto.TextXAlignment =
    Enum.TextXAlignment.Center

local EnterButton =
    Instance.new("TextButton")

EnterButton.Text =
    "ENTRAR NO MOVIMENTO"

EnterButton.TextSize = 15
EnterButton.TextColor3 =
    WHITE

EnterButton.Font =
    Enum.Font.GothamBold

EnterButton.BackgroundColor3 =
    RED_DARK

EnterButton.AutoButtonColor = false

EnterButton.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

EnterButton.Position =
    UDim2.new(
        .5,
        0,
        0,
        120
    )

EnterButton.Size =
    UDim2.new(
        1,
        -60,
        0,
        48
    )

EnterButton.Parent =
    Welcome

CreateCorner(
    EnterButton,
    11
)

CreateStroke(
    EnterButton,
    RED,
    1
)

local CompactCard =
    Instance.new("Frame")

CompactCard.BackgroundColor3 =
    Color3.fromRGB(
        22,
        13,
        17
    )

CompactCard.Position =
    UDim2.new(
        0,
        20,
        0,
        185
    )

CompactCard.Size =
    UDim2.new(
        1,
        -40,
        0,
        78
    )

CompactCard.Parent =
    Welcome

CreateCorner(
    CompactCard,
    12
)

CreateStroke(
    CompactCard,
    RED_DARK,
    1
)

local CompactTitle =
    CreateLabel(
        CompactCard,
        "MODO COMPACTO",
        15,
        WHITE,
        Enum.Font.GothamBold
    )

CompactTitle.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

CompactTitle.Position =
    UDim2.new(
        .5,
        0,
        0,
        6
    )

CompactTitle.Size =
    UDim2.new(
        1,
        -80,
        0,
        22
    )

CompactTitle.TextXAlignment =
    Enum.TextXAlignment.Center

local CompactDescription =
    CreateLabel(
        CompactCard,
        "Reduz o tamanho mantendo a interface funcional.",
        11,
        GRAY,
        Enum.Font.Gotham
    )

CompactDescription.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

CompactDescription.Position =
    UDim2.new(
        .5,
        0,
        0,
        30
    )

CompactDescription.Size =
    UDim2.new(
        1,
        -80,
        0,
        20
    )

CompactDescription.TextXAlignment =
    Enum.TextXAlignment.Center

local CompactToggle =
    Instance.new("TextButton")

CompactToggle.Text = ""

CompactToggle.BackgroundColor3 =
    TOGGLE_OFF

CompactToggle.AutoButtonColor = false

CompactToggle.AnchorPoint =
    Vector2.new(
        .5,
        0
    )

CompactToggle.Position =
    UDim2.new(
        .5,
        0,
        0,
        53
    )

CompactToggle.Size =
    UDim2.new(
        0,
        58,
        0,
        30
    )

CompactToggle.Parent =
    CompactCard

CreateCorner(
    CompactToggle,
    20
)

local CompactStroke =
    CreateStroke(
        CompactToggle,
        TOGGLE_OFF_BORDER,
        1
    )

local CompactKnob =
    Instance.new("Frame")

CompactKnob.BackgroundColor3 =
    WHITE

CompactKnob.Size =
    UDim2.new(
        0,
        24,
        0,
        24
    )

CompactKnob.AnchorPoint =
    Vector2.new(
        .5,
        .5
    )

CompactKnob.Position =
    UDim2.new(
        0,
        15,
        .5,
        0
    )

CompactKnob.Parent =
    CompactToggle

CreateCorner(
    CompactKnob,
    20
)

--========================================================--
-- MOVIMENTO
--========================================================--

PageHeader(
    Movimento,
    "♟",
    "Movimento",
    "Controles de movimento organizados."
)

local MovementCard =
    Instance.new("Frame")

MovementCard.BackgroundColor3 =
    PANEL

MovementCard.Size =
    UDim2.new(
        1,
        -10,
        0,
        430
    )

MovementCard.Parent =
    Movimento

CreateCorner(
    MovementCard,
    14
)

CreateStroke(
    MovementCard,
    RED_DARK,
    1
)

local MovementPadding =
    Instance.new("UIPadding")

MovementPadding.PaddingLeft =
    UDim.new(0, 11)

MovementPadding.PaddingRight =
    UDim.new(0, 11)

MovementPadding.PaddingTop =
    UDim.new(0, 11)

MovementPadding.PaddingBottom =
    UDim.new(0, 15)

MovementPadding.Parent =
    MovementCard

local MovementLayout =
    Instance.new("UIListLayout")

MovementLayout.Padding =
    UDim.new(0, 8)

MovementLayout.Parent =
    MovementCard

local _, SetNoclip =
    CreateToggle(
        MovementCard,
        "NOCLIP",
        false,
        function(State)

            NoclipEnabled =
                State

            if State then
                StartNoclip()
            else
                StopNoclip()
            end
        end
    )

local MovementColumns =
    Instance.new("Frame")

MovementColumns.BackgroundTransparency = 1

MovementColumns.Size =
    UDim2.new(
        1,
        0,
        0,
        335
    )

MovementColumns.Parent =
    MovementCard

local FlyColumn =
    Instance.new("Frame")

FlyColumn.BackgroundColor3 =
    Color3.fromRGB(
        25,
        13,
        17
    )

FlyColumn.Position =
    UDim2.new(
        0,
        0,
        0,
        0
    )

FlyColumn.Size =
    UDim2.new(
        .5,
        -4,
        1,
        0
    )

FlyColumn.Parent =
    MovementColumns

CreateCorner(
    FlyColumn,
    12
)

CreateStroke(
    FlyColumn,
    RED_DARK,
    1
)

local WalkColumn =
    Instance.new("Frame")

WalkColumn.BackgroundColor3 =
    Color3.fromRGB(
        25,
        13,
        17
    )

WalkColumn.Position =
    UDim2.new(
        .5,
        4,
        0,
        0
    )

WalkColumn.Size =
    UDim2.new(
        .5,
        -4,
        1,
        0
    )

WalkColumn.Parent =
    MovementColumns

CreateCorner(
    WalkColumn,
    12
)

CreateStroke(
    WalkColumn,
    RED_DARK,
    1
)

local FlyTitle =
    CreateLabel(
        FlyColumn,
        "FLY",
        18,
        RED,
        Enum.Font.GothamBlack
    )

FlyTitle.Position =
    UDim2.new(
        0,
        12,
        0,
        10
    )

FlyTitle.Size =
    UDim2.new(
        1,
        -24,
        0,
        27
    )

local FlyDesc =
    CreateLabel(
        FlyColumn,
        "MOVIMENTO AÉREO",
        10,
        GRAY,
        Enum.Font.GothamMedium
    )

FlyDesc.Position =
    UDim2.new(
        0,
        12,
        0,
        37
    )

FlyDesc.Size =
    UDim2.new(
        1,
        -24,
        0,
        20
    )

local FlyRow,
    SetFly =
    CreateToggle(
        FlyColumn,
        "Ativar Fly",
        false,
        function(State)

            FlyEnabled =
                State

            if State then
                StartFly()
            else
                StopFly()
            end
        end
    )

FlyRow.Position =
    UDim2.new(
        0,
        8,
        0,
        64
    )

FlyRow.Size =
    UDim2.new(
        1,
        -16,
        0,
        50
    )

local FlySlider =
    CreateSlider(
        FlyColumn,
        "FLY SPEED",
        10,
        300,
        50,
        function(Value)

            FlySpeed =
                Value
        end
    )

FlySlider.Position =
    UDim2.new(
        0,
        8,
        0,
        123
    )

FlySlider.Size =
    UDim2.new(
        1,
        -16,
        0,
        76
    )

local WalkTitle =
    CreateLabel(
        WalkColumn,
        "WALK SPEED",
        17,
        RED,
        Enum.Font.GothamBlack
    )

WalkTitle.Position =
    UDim2.new(
        0,
        12,
        0,
        10
    )

WalkTitle.Size =
    UDim2.new(
        1,
        -24,
        0,
        27
    )

local WalkDesc =
    CreateLabel(
        WalkColumn,
        "VELOCIDADE DO JOGADOR",
        10,
        GRAY,
        Enum.Font.GothamMedium
    )

WalkDesc.Position =
    UDim2.new(
        0,
        12,
        0,
        37
    )

WalkDesc.Size =
    UDim2.new(
        1,
        -24,
        0,
        20
    )

local WalkRow,
    SetWalk =
    CreateToggle(
        WalkColumn,
        "Ativar",
        false,
        function(State)

            WalkSpeedEnabled =
                State

            ApplyWalkSpeed()
        end
    )

WalkRow.Position =
    UDim2.new(
        0,
        8,
        0,
        64
    )

WalkRow.Size =
    UDim2.new(
        1,
        -16,
        0,
        50
    )

local WalkSlider =
    CreateSlider(
        WalkColumn,
        "WALK SPEED",
        16,
        200,
        30,
        function(Value)

            WalkSpeedValue =
                Value

            ApplyWalkSpeed()
        end
    )

WalkSlider.Position =
    UDim2.new(
        0,
        8,
        0,
        123
    )

WalkSlider.Size =
    UDim2.new(
        1,
        -16,
        0,
        76
    )

--========================================================--
-- COMBATE
--========================================================--

PageHeader(
    Combate,
    "◎",
    "Combate",
    "Precisão e configurações de combate."
)

local CombatCard =
    Instance.new("Frame")

CombatCard.BackgroundColor3 =
    PANEL

CombatCard.Size =
    UDim2.new(
        1,
        -10,
        0,
        370
    )

CombatCard.Parent =
    Combate

CreateCorner(
    CombatCard,
    14
)

CreateStroke(
    CombatCard,
    RED_DARK,
    1
)

local CombatPadding =
    Instance.new("UIPadding")

CombatPadding.PaddingLeft =
    UDim.new(0, 11)

CombatPadding.PaddingRight =
    UDim.new(0, 11)

CombatPadding.PaddingTop =
    UDim.new(0, 11)

CombatPadding.PaddingBottom =
    UDim.new(0, 20)

CombatPadding.Parent =
    CombatCard

local CombatLayout =
    Instance.new("UIListLayout")

CombatLayout.Padding =
    UDim.new(0, 8)

CombatLayout.Parent =
    CombatCard

CreateToggle(
    CombatCard,
    "Aimbot / Aim Assist",
    false,
    function(State)

        AimAssistEnabled =
            State

        if State then
            StartAim()
        else
            StopAim()
        end

        FOVCircle.Visible =
            AimAssistEnabled
            and FOVCircleEnabled
    end
)

CreateSlider(
    CombatCard,
    "FOV",
    20,
    300,
    120,
    function(Value)

        AimFOV =
            Value

        FOVCircle.Size =
            UDim2.fromOffset(
                AimFOV * 2,
                AimFOV * 2
            )
    end
)

CreateToggle(
    CombatCard,
    "FOV Circle",
    false,
    function(State)

        FOVCircleEnabled =
            State

        FOVCircle.Visible =
            State
            and AimAssistEnabled
    end
)

CreateToggle(
    CombatCard,
    "Precisão automática",
    false
)

CreateToggle(
    CombatCard,
    "Modo de combate",
    false
)

--========================================================--
-- VISUAL
--========================================================--

PageHeader(
    Visual,
    "◉",
    "Visual",
    "Controles visuais."
)

local VisualCard =
    Instance.new("Frame")

VisualCard.BackgroundColor3 =
    PANEL

VisualCard.Size =
    UDim2.new(
        1,
        -10,
        0,
        390
    )

VisualCard.Parent =
    Visual

CreateCorner(
    VisualCard,
    14
)

CreateStroke(
    VisualCard,
    RED_DARK,
    1
)

local VisualPadding =
    Instance.new("UIPadding")

VisualPadding.PaddingLeft =
    UDim.new(0, 11)

VisualPadding.PaddingRight =
    UDim.new(0, 11)

VisualPadding.PaddingTop =
    UDim.new(0, 11)

VisualPadding.PaddingBottom =
    UDim.new(0, 20)

VisualPadding.Parent =
    VisualCard

local VisualLayout =
    Instance.new("UIListLayout")

VisualLayout.Padding =
    UDim.new(0, 8)

VisualLayout.Parent =
    VisualCard

CreateToggle(
    VisualCard,
    "ESP",
    false,
    function(State)

        if State then
            EnableESP()
        else
            DisableESP()
        end
    end
)

CreateToggle(
    VisualCard,
    "Mostrar Nomes",
    true,
    function(State)

        ESPNamesEnabled =
            State

        RefreshESP()
    end
)

CreateToggle(
    VisualCard,
    "Mostrar Caixas",
    true,
    function(State)

        ESPBoxesEnabled =
            State

        RefreshESP()
    end
)

CreateToggle(
    VisualCard,
    "Mostrar Tracers",
    false
)

CreateToggle(
    VisualCard,
    "Indicadores",
    false
)

--========================================================--
-- JOGADOR
--========================================================--

PageHeader(
    Jogador,
    "♙",
    "Jogador",
    "Configurações do jogador."
)

local PlayerCard =
    Instance.new("Frame")

PlayerCard.BackgroundColor3 =
    PANEL

PlayerCard.Size =
    UDim2.new(
        1,
        -10,
        0,
        280
    )

PlayerCard.Parent =
    Jogador

CreateCorner(
    PlayerCard,
    14
)

CreateStroke(
    PlayerCard,
    RED_DARK,
    1
)

local PlayerPadding =
    Instance.new("UIPadding")

PlayerPadding.PaddingLeft =
    UDim.new(0, 11)

PlayerPadding.PaddingRight =
    UDim.new(0, 11)

PlayerPadding.PaddingTop =
    UDim.new(0, 11)

PlayerPadding.PaddingBottom =
    UDim.new(0, 20)

PlayerPadding.Parent =
    PlayerCard

local PlayerLayout =
    Instance.new("UIListLayout")

PlayerLayout.Padding =
    UDim.new(0, 8)

PlayerLayout.Parent =
    PlayerCard

local Respawn =
    Instance.new("TextButton")

Respawn.Text =
    "KILL / REGENERAR"

Respawn.TextSize = 15
Respawn.TextColor3 = WHITE
Respawn.Font =
    Enum.Font.GothamBold

Respawn.BackgroundColor3 =
    RED_DARK

Respawn.AutoButtonColor = false

Respawn.Size =
    UDim2.new(
        1,
        0,
        0,
        56
    )

Respawn.Parent =
    PlayerCard

CreateCorner(
    Respawn,
    11
)

CreateStroke(
    Respawn,
    RED,
    1
)

Respawn.Activated:Connect(
    function()

        if Humanoid then
            Humanoid.Health = 0
        end
    end
)

CreateToggle(
    PlayerCard,
    "Modo jogador",
    false
)

CreateToggle(
    PlayerCard,
    "Proteção",
    false
)

CreateToggle(
    PlayerCard,
    "Interface rápida",
    true
)

--========================================================--
-- SCRIPTS
--========================================================--

PageHeader(
    Scripts,
    "⌘",
    "Scripts",
    "Área organizada para scripts autorizados."
)

local ScriptInfo =
    Instance.new("Frame")

ScriptInfo.BackgroundColor3 =
    PANEL

ScriptInfo.Size =
    UDim2.new(
        1,
        -10,
        0,
        125
    )

ScriptInfo.Parent =
    Scripts

CreateCorner(
    ScriptInfo,
    14
)

CreateStroke(
    ScriptInfo,
    RED_DARK,
    1
)

local ScriptTitle =
    CreateLabel(
        ScriptInfo,
        "SCRIPTS",
        19,
        RED,
        Enum.Font.GothamBlack
    )

ScriptTitle.Position =
    UDim2.new(
        0,
        15,
        0,
        12
    )

ScriptTitle.Size =
    UDim2.new(
        1,
        -30,
        0,
        28
    )

local ScriptDescription =
    CreateLabel(
        ScriptInfo,
        "Área preparada para scripts de teste autorizados.\nNenhum código externo é executado automaticamente.",
        12,
        GRAY,
        Enum.Font.Gotham
    )

ScriptDescription.Position =
    UDim2.new(
        0,
        15,
        0,
        45
    )

ScriptDescription.Size =
    UDim2.new(
        1,
        -30,
        0,
        55
    )

ScriptDescription.TextWrapped = true

local ScriptList =
    Instance.new("Frame")

ScriptList.BackgroundColor3 =
    PANEL

ScriptList.Size =
    UDim2.new(
        1,
        -10,
        0,
        260
    )

ScriptList.Parent =
    Scripts

CreateCorner(
    ScriptList,
    14
)

CreateStroke(
    ScriptList,
    RED_DARK,
    1
)

local ScriptPadding =
    Instance.new("UIPadding")

ScriptPadding.PaddingLeft =
    UDim.new(0, 11)

ScriptPadding.PaddingRight =
    UDim.new(0, 11)

ScriptPadding.PaddingTop =
    UDim.new(0, 11)

ScriptPadding.PaddingBottom =
    UDim.new(0, 15)

ScriptPadding.Parent =
    ScriptList

local ScriptLayout =
    Instance.new("UIListLayout")

ScriptLayout.Padding =
    UDim.new(0, 8)

ScriptLayout.Parent =
    ScriptList

CreateToggle(
    ScriptList,
    "Script 01",
    false
)

CreateToggle(
    ScriptList,
    "Script 02",
    false
)

CreateToggle(
    ScriptList,
    "Script 03",
    false
)

--========================================================--
-- SOBRE
--========================================================--

PageHeader(
    Sobre,
    "ⓘ",
    "Sobre",
    "Informações do CAFEÍNA."
)

local About =
    Instance.new("Frame")

About.BackgroundColor3 =
    PANEL

About.Size =
    UDim2.new(
        1,
        -10,
        0,
        245
    )

About.Parent =
    Sobre

CreateCorner(
    About,
    14
)

CreateStroke(
    About,
    RED_DARK,
    1
)

local AboutTitle =
    CreateLabel(
        About,
        "CAFEÍNA V1.0",
        26,
        WHITE,
        Enum.Font.GothamBlack
    )

AboutTitle.Position =
    UDim2.new(
        0,
        17,
        0,
        17
    )

AboutTitle.Size =
    UDim2.new(
        1,
        -34,
        0,
        38
    )

local AboutText =
    CreateLabel(
        About,
        "Interface mobile responsiva.\n\n"
        .. "Menu organizado por áreas,\n"
        .. "controles funcionais,\n"
        .. "scroll automático e modo compacto.\n\n"
        .. "FORÇA  •  CONTROLE  •  SUPREMACIA",
        13,
        GRAY,
        Enum.Font.Gotham
    )

AboutText.Position =
    UDim2.new(
        0,
        17,
        0,
        62
    )

AboutText.Size =
    UDim2.new(
        1,
        -34,
        0,
        165
    )

AboutText.TextWrapped = true

--========================================================--
-- NAVEGAÇÃO
--========================================================--

local Navigation = {
    {"Principal", "⌂"},
    {"Movimento", "♟"},
    {"Combate", "◎"},
    {"Visual", "◉"},
    {"Jogador", "♙"},
    {"Scripts", "⌘"},
    {"Sobre", "ⓘ"}
}

local function SelectPage(
    Name
)

    if not Pages[Name] then
        return
    end

    CurrentPage =
        Name

    for PageName, Page in pairs(
        Pages
    ) do

        Page.Visible =
            PageName == Name

        if PageName == Name then

            Page.CanvasPosition =
                Vector2.new(
                    0,
                    0
                )

            RefreshPage(Page)
        end
    end

    for PageName, Button in pairs(
        NavigationButtons
    ) do

        Tween(
            Button,
            {
                BackgroundColor3 =
                    PageName == Name
                    and RED_DARK
                    or PANEL2
            },
            .12
        )

        local Stroke =
            Button:FindFirstChildOfClass(
                "UIStroke"
            )

        if Stroke then

            Tween(
                Stroke,
                {
                    Color =
                        PageName == Name
                        and RED
                        or BORDER
                },
                .12
            )
        end
    end
end

for Index, Data in ipairs(
    Navigation
) do

    local Name =
        Data[1]

    local Icon =
        Data[2]

    local Button =
        Instance.new("TextButton")

    Button.Text =
        Icon
        .. "   "
        .. Name

    Button.TextSize = 13
    Button.TextColor3 = WHITE
    Button.Font =
        Enum.Font.GothamMedium

    Button.BackgroundColor3 =
        PANEL2

    Button.AutoButtonColor = false

    Button.Size =
        UDim2.new(
            1,
            -2,
            0,
            44
        )

    Button.LayoutOrder =
        Index

    Button.ZIndex = 15
    Button.Parent =
        Sidebar

    CreateCorner(
        Button,
        10
    )

    CreateStroke(
        Button,
        BORDER,
        1
    )

    NavigationButtons[Name] =
        Button

    Button.Activated:Connect(
        function()

            SelectPage(
                Name
            )
        end
    )
end

--========================================================--
-- BOTÃO PRINCIPAL
--========================================================--

EnterButton.Activated:Connect(
    function()

        SelectPage(
            "Movimento"
        )
    end
)

--========================================================--
-- MODO COMPACTO
--========================================================--

CompactToggle.Activated:Connect(
    function()

        CompactMode =
            not CompactMode

        Tween(
            CompactToggle,
            {
                BackgroundColor3 =
                    CompactMode
                    and GREEN
                    or TOGGLE_OFF
            },
            .18
        )

        Tween(
            CompactStroke,
            {
                Color =
                    CompactMode
                    and GREEN
                    or TOGGLE_OFF_BORDER
            },
            .18
        )

        Tween(
            CompactKnob,
            {
                Position =
                    CompactMode
                    and UDim2.new(
                        1,
                        -15,
                        .5,
                        0
                    )
                    or UDim2.new(
                        0,
                        15,
                        .5,
                        0
                    )
            },
            .18
        )

        Tween(
            MainScale,
            {
                Scale =
                    CompactMode
                    and .78
                    or 1
            },
            .22
        )

        task.delay(
            .25,
            RefreshAllPages
        )

        Notify(
            "MODO COMPACTO",
            CompactMode
            and "Ativado."
            or "Desativado."
        )
    end
)

--========================================================--
-- ÍCONE MINIMIZADO
--========================================================--

local Mini =
    Instance.new("TextButton")

Mini.Name =
    "CafeinaMini"

Mini.Text = "☕"
Mini.TextSize = 25
Mini.TextColor3 = WHITE

Mini.Font =
    Enum.Font.GothamBold

Mini.BackgroundColor3 =
    PANEL

Mini.AutoButtonColor = false

Mini.AnchorPoint =
    Vector2.new(
        .5,
        .5
    )

Mini.Position =
    UDim2.fromScale(
        .5,
        .5
    )

Mini.Size =
    UDim2.new(
        0,
        58,
        0,
        58
    )

Mini.Visible = false
Mini.ZIndex = 9999
Mini.Parent = Gui

CreateCorner(
    Mini,
    30
)

CreateStroke(
    Mini,
    RED,
    2
)

--========================================================--
-- DRAG GENÉRICO
--========================================================--

local function MakeDraggable(
    Object,
    DragArea
)

    local Dragging = false
    local DragStart
    local StartPosition

    DragArea.InputBegan:
        Connect(
            function(Input)

                if
                    Input.UserInputType
                    == Enum.UserInputType.Touch
                    or
                    Input.UserInputType
                    == Enum.UserInputType.MouseButton1
                then

                    Dragging = true

                    DragStart =
                        Input.Position

                    StartPosition =
                        Object.Position
                end
            end
        )

    UIS.InputChanged:
        Connect(
            function(Input)

                if not Dragging then
                    return
                end

                if
                    Input.UserInputType
                    ~= Enum.UserInputType.Touch
                    and
                    Input.UserInputType
                    ~= Enum.UserInputType.MouseMovement
                then
                    return
                end

                local Delta =
                    Input.Position
                    - DragStart

                Object.Position =
                    UDim2.new(
                        StartPosition.X.Scale,
                        StartPosition.X.Offset
                        + Delta.X,

                        StartPosition.Y.Scale,
                        StartPosition.Y.Offset
                        + Delta.Y
                    )
            end
        )

    UIS.InputEnded:
        Connect(
            function(Input)

                if
                    Input.UserInputType
                    == Enum.UserInputType.Touch
                    or
                    Input.UserInputType
                    == Enum.UserInputType.MouseButton1
                then

                    Dragging = false
                end
            end
        )
end

-- Somente header arrasta o menu.
MakeDraggable(
    Main,
    Header
)

--========================================================--
-- ÍCONE ARRASTÁVEL
--========================================================--

MakeDraggable(
    Mini,
    Mini
)

--========================================================--
-- MINIMIZAR
--========================================================--

Minimize.Activated:Connect(
    function()

        IsMinimized = true

        Tween(
            MainScale,
            {
                Scale = 0
            },
            .2
        )

        task.wait(.22)

        if not Gui.Parent then
            return
        end

        Main.Visible = false

        Mini.Visible = true
    end
)

--========================================================--
-- RESTAURAR
--========================================================--

Mini.Activated:Connect(
    function()

        IsMinimized = false

        Mini.Visible = false
        Main.Visible = true

        MainScale.Scale = 0

        Tween(
            MainScale,
            {
                Scale =
                    CompactMode
                    and .78
                    or 1
            },
            .22
        )

        task.delay(
            .25,
            function()

                local Page =
                    Pages[CurrentPage]

                if Page then

                    RefreshPage(
                        Page
                    )
                end

                RefreshSidebar()
            end
        )
    end
)

--========================================================--
-- FECHAR
--========================================================--

Close.Activated:Connect(
    function()

        Tween(
            MainScale,
            {
                Scale = 0
            },
            .18
        )

        task.wait(.2)

        if Gui then
            Gui:Destroy()
        end
    end
)

--========================================================--
-- RESPONSIVIDADE
--========================================================--

local function Responsive()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    local View =
        Camera.ViewportSize

    if View.X < 600 then

        Main.Size =
            UDim2.new(
                .95,
                0,
                .88,
                0
            )

        Sidebar.Size =
            UDim2.new(
                0,
                140,
                1,
                0
            )

        PagesHolder.Position =
            UDim2.new(
                0,
                150,
                0,
                0
            )

        PagesHolder.Size =
            UDim2.new(
                1,
                -150,
                1,
                0
            )

        Logo.TextSize = 26

    else

        Main.Size =
            UDim2.new(
                .90,
                0,
                .82,
                0
            )

        Sidebar.Size =
            UDim2.new(
                0,
                145,
                1,
                0
            )

        PagesHolder.Position =
            UDim2.new(
                0,
                155,
                0,
                0
            )

        PagesHolder.Size =
            UDim2.new(
                1,
                -155,
                1,
                0
            )

        Logo.TextSize = 29
    end

    task.defer(
        RefreshAllPages
    )
end

if workspace.CurrentCamera then

    workspace.CurrentCamera:
        GetPropertyChangedSignal(
            "ViewportSize"
        ):
        Connect(
            Responsive
        )
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local Camera = workspace.CurrentCamera
    if Camera then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Responsive)
        task.defer(Responsive)
    end
end)

--========================================================--
-- RESPAWN
--========================================================--

Player.CharacterAdded:
    Connect(
        function(
            NewCharacter
        )

            StopFly()
            StopNoclip()

            if WalkSpeedEnabled then
                WalkSpeedEnabled = false
            end

            Character =
                NewCharacter

            Humanoid =
                NewCharacter:
                WaitForChild(
                    "Humanoid"
                )

            Root =
                NewCharacter:
                WaitForChild(
                    "HumanoidRootPart"
                )

            FlyEnabled = false
            NoclipEnabled = false

            SetFly(
                false,
                true
            )

            SetNoclip(
                false,
                true
            )

            SetWalk(
                false,
                true
            )

            FOVCircle.Visible =
                false

            Notify(
                "CAFEÍNA",
                "Personagem atualizado."
            )
        end
    )

--========================================================--
-- LIMPEZA
--========================================================--

Gui.Destroying:
    Connect(
        function()

            StopFly()
            StopNoclip()
            StopAim()

            DisableESP()

            RestoreNoclip()

            if Humanoid then
                Humanoid.PlatformStand =
                    false
            end
        end
    )

--========================================================--
-- INICIALIZAÇÃO
--========================================================--

for _, Page in pairs(
    Pages
) do

    Page.Visible = false
end

SelectPage(
    "Principal"
)

Responsive()

RefreshAllPages()

Notify(
    "CAFEÍNA V1.0",
    "Interface carregada."
)

print(
    "======================================"
)

print(
    "           CAFEÍNA V1.0"
)

print(
    "       MOBILE UI CARREGADA"
)

print(
    "======================================"
)





SetFly(false, true)
SetNoclip(false, true)
SetWalk(false, true)
