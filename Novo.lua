--========================================================--
--                    CAFEÍNA ROBLOX
--========================================================--
-- FLY
-- FLY SPEED
-- WALK SPEED
-- NOCLIP
-- ESP SEM LINHAS
-- KILL / REGENERAR
-- AIMBOT
-- MENU COM SCROLL
-- ÍCONE E MENU COM POSIÇÕES INDEPENDENTES
-- SUPORTE MOBILE
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- ESTADOS
--========================================================--

local Character
local Humanoid
local Root

local FlyEnabled = false
local NoclipEnabled = false
local ESPEnabled = false
local WalkSpeedEnabled = false
local AimbotEnabled = false

local FlySpeed = 50
local WalkSpeed = 30
local DefaultWalkSpeed = 16
local AimbotFOV = 100

local BodyVelocity
local BodyGyro

local StartFlyController
local StopFlyController
local StartAimbot
local StopAimbot

local FlyRenderConnection
local AimbotRenderConnection
local NoclipDescendantConnection
local ESPConnections = {}

--========================================================--
-- CHARACTER
--========================================================--

local function SetupCharacter()
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")

	DefaultWalkSpeed = Humanoid.WalkSpeed
end

SetupCharacter()

--========================================================--
-- ESP
--========================================================--

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CafeinaESP"
ESPFolder.Parent = workspace

local ESPObjects = {}

local function CreateESP(TargetPlayer)
	if TargetPlayer == Player or not ESPEnabled then
		return
	end

	local TargetCharacter = TargetPlayer.Character

	if not TargetCharacter then
		return
	end

	local TargetRoot = TargetCharacter:FindFirstChild("HumanoidRootPart")

	if not TargetRoot then
		return
	end

	if ESPObjects[TargetPlayer] then
		return
	end

	local Highlight = Instance.new("Highlight")

	Highlight.Name = "ESP_Highlight"
	Highlight.Adornee = TargetCharacter
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 0
	Highlight.OutlineColor = Color3.new(1, 1, 1)
	Highlight.Enabled = true
	Highlight.Parent = ESPFolder

	local Billboard = Instance.new("BillboardGui")

	Billboard.Name = "ESP_Name"
	Billboard.Adornee = TargetRoot
	Billboard.Size = UDim2.fromOffset(150, 35)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Enabled = true
	Billboard.Parent = ESPFolder

	local NameLabel = Instance.new("TextLabel")

	NameLabel.Size = UDim2.fromScale(1, 1)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = TargetPlayer.DisplayName
	NameLabel.TextColor3 = Color3.new(1, 1, 1)
	NameLabel.TextStrokeTransparency = 0
	NameLabel.TextSize = 14
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Parent = Billboard

	ESPObjects[TargetPlayer] = {
		Highlight = Highlight,
		Billboard = Billboard
	}
end

local function RemoveESP(TargetPlayer)
	local Data = ESPObjects[TargetPlayer]

	if not Data then
		return
	end

	for _, Object in pairs(Data) do
		if typeof(Object) == "Instance" then
			Object:Destroy()
		end
	end

	ESPObjects[TargetPlayer] = nil
end

local function DisconnectESPConnections()
	for _, Connection in pairs(ESPConnections) do
		if Connection then
			Connection:Disconnect()
		end
	end

	table.clear(ESPConnections)
end

local function DisableESP()
	ESPEnabled = false

	DisconnectESPConnections()

	for TargetPlayer in pairs(ESPObjects) do
		RemoveESP(TargetPlayer)
	end
end

local function EnableESP()
	if ESPEnabled then
		return
	end

	ESPEnabled = true

	for _, TargetPlayer in ipairs(Players:GetPlayers()) do
		if TargetPlayer ~= Player then

			ESPConnections[
				"Character_" .. TargetPlayer.UserId
			] = TargetPlayer.CharacterAdded:Connect(function()

				task.wait(0.5)

				if not ESPEnabled then
					return
				end

				RemoveESP(TargetPlayer)
				CreateESP(TargetPlayer)
			end)

			if TargetPlayer.Character then
				CreateESP(TargetPlayer)
			end
		end
	end

	ESPConnections.PlayerAdded =
		Players.PlayerAdded:Connect(function(TargetPlayer)

			if TargetPlayer == Player then
				return
			end

			ESPConnections[
				"Character_" .. TargetPlayer.UserId
			] = TargetPlayer.CharacterAdded:Connect(function()

				task.wait(0.5)

				if not ESPEnabled then
					return
				end

				RemoveESP(TargetPlayer)
				CreateESP(TargetPlayer)
			end)

			if TargetPlayer.Character then
				CreateESP(TargetPlayer)
			end
		end)

	ESPConnections.PlayerRemoving =
		Players.PlayerRemoving:Connect(function(TargetPlayer)
			RemoveESP(TargetPlayer)
		end)
end

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")

Gui.Name = "CafeinaRoblox"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--========================================================--
-- MENU PRINCIPAL
--========================================================--

local Menu = Instance.new("Frame")

Menu.Name = "MainMenu"

-- LARGURA MANTIDA / ALTURA REDUZIDA
Menu.Size = UDim2.fromOffset(300, 220)

Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.fromScale(0.5, 0.5)

-- FUNDO PRETO
Menu.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Menu.BorderSizePixel = 0
Menu.Parent = Gui

local MenuStroke = Instance.new("UIStroke")

MenuStroke.Thickness = 1
MenuStroke.Transparency = 0.15
MenuStroke.Color = Color3.fromRGB(235, 235, 235)
MenuStroke.Parent = Menu

local MenuCorner = Instance.new("UICorner")

MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = Menu

--========================================================--
-- FECHAR
--========================================================--

local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.fromOffset(8, 8)

CloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 21
CloseButton.Font = Enum.Font.GothamBold

CloseButton.BorderSizePixel = 0
CloseButton.Parent = Menu

local CloseCorner = Instance.new("UICorner")

CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")

CloseStroke.Thickness = 1
CloseStroke.Transparency = 0.4
CloseStroke.Color = Color3.fromRGB(220, 220, 220)
CloseStroke.Parent = CloseButton

--========================================================--
-- TÍTULO CLÁSSICO
--========================================================--

local Title = Instance.new("TextLabel")

Title.Name = "CafeinaTitle"

Title.Size = UDim2.new(1, -75, 0, 42)
Title.Position = UDim2.fromOffset(42, 2)

Title.BackgroundTransparency = 1

Title.Text = "CAFEÍNA V1"
Title.TextColor3 = Color3.fromRGB(245, 245, 245)

-- FONTE CLÁSSICA
Title.TextSize = 23
Title.Font = Enum.Font.Garamond

Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center

Title.TextStrokeTransparency = 0.85
Title.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)

Title.Parent = Menu

--========================================================--
-- LINHA DO TÍTULO
--========================================================--

local TitleLine = Instance.new("Frame")

TitleLine.Size = UDim2.new(1, -20, 0, 1)
TitleLine.Position = UDim2.new(0, 10, 0, 47)

TitleLine.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
TitleLine.BackgroundTransparency = 0.45

TitleLine.BorderSizePixel = 0
TitleLine.Parent = Menu

--========================================================--
-- SCROLL
--========================================================--

local Scroll = Instance.new("ScrollingFrame")

Scroll.Name = "Content"

Scroll.Size = UDim2.new(1, -18, 1, -54)
Scroll.Position = UDim2.fromOffset(9, 50)

Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0

Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 =
	Color3.fromRGB(220, 220, 220)

Scroll.ScrollingDirection =
	Enum.ScrollingDirection.Y

Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout")

Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")

Padding.PaddingTop = UDim.new(0, 4)
Padding.PaddingBottom = UDim.new(0, 10)

Padding.Parent = Scroll

--========================================================--
-- FUNÇÃO BOTÃO
--========================================================--

local function CreateButton(Text)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1, -10, 0, 38)

	Button.BackgroundColor3 =
		Color3.fromRGB(22, 22, 22)

	Button.Text = Text

	Button.TextColor3 =
		Color3.fromRGB(245, 245, 245)

	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold

	Button.BorderSizePixel = 0

	Button.AutoButtonColor = true

	Button.Parent = Scroll

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0, 8)

	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")

	Stroke.Thickness = 1
	Stroke.Transparency = 0.55

	Stroke.Color =
		Color3.fromRGB(190, 190, 190)

	Stroke.Parent = Button

	return Button
end

--========================================================--
-- SEPARADOR DE GRUPO
--========================================================--

local function CreateSection(Text, Accent)

	local Container = Instance.new("Frame")

	Container.Size =
		UDim2.new(1, -10, 0, 28)

	Container.BackgroundTransparency = 1
	Container.BorderSizePixel = 0

	Container.Parent = Scroll

	local Section = Instance.new("TextLabel")

	Section.Size =
		UDim2.new(1, 0, 1, -4)

	Section.Position =
		UDim2.fromOffset(0, 0)

	Section.BackgroundTransparency = 1

	Section.Text = Text

	Section.TextColor3 =
		Color3.fromRGB(225, 225, 225)

	Section.TextSize = 11
	Section.Font = Enum.Font.Garamond

	Section.TextXAlignment =
		Enum.TextXAlignment.Left

	Section.TextYAlignment =
		Enum.TextYAlignment.Center

	Section.Parent = Container

	local Line = Instance.new("Frame")

	Line.Size =
		UDim2.new(1, 0, 0, 1)

	Line.Position =
		UDim2.new(0, 0, 1, -2)

	Line.BackgroundColor3 =
		Color3.fromRGB(180, 180, 180)

	Line.BackgroundTransparency = 0.4

	Line.BorderSizePixel = 0

	Line.Parent = Container

	return Container
end

--========================================================--
-- PLAYER
--========================================================--

CreateSection(
	"PLAYER",
	Color3.fromRGB(225, 225, 225)
)

local KillButton =
	CreateButton("KILL / REGENERAR")

KillButton.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

local KillStroke =
	KillButton:FindFirstChildOfClass("UIStroke")

if KillStroke then
	KillStroke.Color =
		Color3.fromRGB(235, 235, 235)

	KillStroke.Transparency = 0.25
end

KillButton.Activated:Connect(function()

	if Character and Character.Parent then

		local CurrentHumanoid =
			Character:FindFirstChildOfClass(
				"Humanoid"
			)

		if CurrentHumanoid then
			CurrentHumanoid.Health = 0
		end
	end
end)

--========================================================--
-- FLY + NOCLIP JUNTOS
--========================================================--

CreateSection(
	"FLY / NOCLIP",
	Color3.fromRGB(225, 225, 225)
)

local FlyButton =
	CreateButton("FLY: OFF")

local NoclipButton =
	CreateButton("NOCLIP: OFF")

--========================================================--
-- FLY
--========================================================--

local function StopFly()

	local WasFlying =
		BodyVelocity ~= nil
		or BodyGyro ~= nil
		or (
			Humanoid
			and Humanoid.PlatformStand
		)

	if BodyVelocity then
		BodyVelocity:Destroy()
		BodyVelocity = nil
	end

	if BodyGyro then
		BodyGyro:Destroy()
		BodyGyro = nil
	end

	if Humanoid and WasFlying then
		Humanoid.PlatformStand = false
	end

	if Root and WasFlying then
		Root.AssemblyLinearVelocity =
			Vector3.zero
	end
end

local function StartFly()

	if not Root or not Humanoid then
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
	BodyVelocity.Velocity = Vector3.zero

	BodyVelocity.Parent = Root

	BodyGyro =
		Instance.new("BodyGyro")

	BodyGyro.MaxTorque =
		Vector3.new(
			math.huge,
			math.huge,
			math.huge
		)

	BodyGyro.P = 9000
	BodyGyro.CFrame = Root.CFrame

	BodyGyro.Parent = Root

	Humanoid.PlatformStand = true
end

FlyButton.Activated:Connect(function()

	FlyEnabled = not FlyEnabled

	if FlyEnabled then

		FlyButton.Text = "FLY: ON"

		FlyButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)

		StartFly()
		StartFlyController()

	else

		FlyButton.Text = "FLY: OFF"

		FlyButton.BackgroundColor3 =
			Color3.fromRGB(22, 22, 22)

		StopFly()
		StopFlyController()
	end
end)

--========================================================--
-- FLY SPEED
--========================================================--

local FlySpeedFrame =
	Instance.new("Frame")

FlySpeedFrame.Size =
	UDim2.new(1, -10, 0, 38)

FlySpeedFrame.BackgroundColor3 =
	Color3.fromRGB(22, 22, 22)

FlySpeedFrame.BorderSizePixel = 0

FlySpeedFrame.Parent = Scroll

local FlySpeedCorner =
	Instance.new("UICorner")

FlySpeedCorner.CornerRadius =
	UDim.new(0, 8)

FlySpeedCorner.Parent =
	FlySpeedFrame

local FlyMinus =
	Instance.new("TextButton")

FlyMinus.Size =
	UDim2.fromOffset(32, 30)

FlyMinus.Position =
	UDim2.fromOffset(4, 4)

FlyMinus.Text = "-"
FlyMinus.TextSize = 18

FlyMinus.Font =
	Enum.Font.GothamBold

FlyMinus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

FlyMinus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

FlyMinus.BorderSizePixel = 0

FlyMinus.Parent =
	FlySpeedFrame

local FlyMinusCorner =
	Instance.new("UICorner")

FlyMinusCorner.CornerRadius =
	UDim.new(0, 7)

FlyMinusCorner.Parent =
	FlyMinus

local FlySpeedLabel =
	Instance.new("TextLabel")

FlySpeedLabel.Size =
	UDim2.new(1, -82, 1, 0)

FlySpeedLabel.Position =
	UDim2.fromOffset(41, 0)

FlySpeedLabel.BackgroundTransparency = 1

FlySpeedLabel.Text =
	"FLY SPEED: 50"

FlySpeedLabel.TextColor3 =
	Color3.fromRGB(245, 245, 245)

FlySpeedLabel.TextSize = 11
FlySpeedLabel.Font =
	Enum.Font.GothamBold

FlySpeedLabel.Parent =
	FlySpeedFrame

local FlyPlus =
	Instance.new("TextButton")

FlyPlus.Size =
	UDim2.fromOffset(32, 30)

FlyPlus.Position =
	UDim2.new(1, -36, 0, 4)

FlyPlus.Text = "+"
FlyPlus.TextSize = 18

FlyPlus.Font =
	Enum.Font.GothamBold

FlyPlus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

FlyPlus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

FlyPlus.BorderSizePixel = 0

FlyPlus.Parent =
	FlySpeedFrame

local FlyPlusCorner =
	Instance.new("UICorner")

FlyPlusCorner.CornerRadius =
	UDim.new(0, 7)

FlyPlusCorner.Parent =
	FlyPlus

FlyMinus.Activated:Connect(function()

	FlySpeed =
		math.max(
			10,
			FlySpeed - 10
		)

	FlySpeedLabel.Text =
		"FLY SPEED: " .. FlySpeed
end)

FlyPlus.Activated:Connect(function()

	FlySpeed =
		math.min(
			300,
			FlySpeed + 10
		)

	FlySpeedLabel.Text =
		"FLY SPEED: " .. FlySpeed
end)

--========================================================--
-- NOCLIP
--========================================================--

local NoclipCollisionState = {}

local function ApplyNoclipToCharacter()

	if not Character then
		return
	end

	for _, Part in ipairs(
		Character:GetDescendants()
	) do

		if Part:IsA("BasePart") then

			if NoclipCollisionState[Part] == nil then

				NoclipCollisionState[Part] =
					Part.CanCollide
			end

			Part.CanCollide = false
		end
	end
end

local function RestoreCharacterCollision()

	for Part, OriginalCanCollide in pairs(
		NoclipCollisionState
	) do

		if Part and Part.Parent then

			Part.CanCollide =
				OriginalCanCollide
		end
	end

	table.clear(
		NoclipCollisionState
	)
end

local function ConnectNoclipWatcher()

	if NoclipDescendantConnection then

		NoclipDescendantConnection:
			Disconnect()
	end

	if not Character then
		return
	end

	NoclipDescendantConnection =
		Character.DescendantAdded:Connect(
			function(Part)

				if not NoclipEnabled
					or not Part:IsA("BasePart") then
					return
				end

				if NoclipCollisionState[Part] == nil then

					NoclipCollisionState[Part] =
						Part.CanCollide
				end

				Part.CanCollide = false
			end
		)
end

NoclipButton.Activated:Connect(function()

	NoclipEnabled =
		not NoclipEnabled

	if NoclipEnabled then

		NoclipButton.Text =
			"NOCLIP: ON"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)

		ApplyNoclipToCharacter()
		ConnectNoclipWatcher()

	else

		NoclipButton.Text =
			"NOCLIP: OFF"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(22, 22, 22)

		if NoclipDescendantConnection then

			NoclipDescendantConnection:
				Disconnect()

			NoclipDescendantConnection = nil
		end

		RestoreCharacterCollision()
	end
end)

--========================================================--
-- WALK SPEED
--========================================================--

CreateSection(
	"WALK SPEED",
	Color3.fromRGB(225, 225, 225)
)

local WalkButton =
	CreateButton("WALK SPEED: OFF")

local WalkSpeedRestoreValue

local function UpdateWalkSpeed()

	if not Humanoid or not WalkSpeedEnabled then
		return
	end

	Humanoid.WalkSpeed =
		WalkSpeed
end

WalkButton.Activated:Connect(function()

	WalkSpeedEnabled =
		not WalkSpeedEnabled

	if WalkSpeedEnabled then

		if Humanoid then
			WalkSpeedRestoreValue =
				Humanoid.WalkSpeed
		end

		WalkButton.Text =
			"WALK SPEED: ON"

		WalkButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)

		UpdateWalkSpeed()

	else

		if Humanoid
			and WalkSpeedRestoreValue ~= nil then

			Humanoid.WalkSpeed =
				WalkSpeedRestoreValue
		end

		WalkSpeedRestoreValue = nil

		WalkButton.Text =
			"WALK SPEED: OFF"

		WalkButton.BackgroundColor3 =
			Color3.fromRGB(22, 22, 22)
	end
end)

local WalkSpeedFrame =
	Instance.new("Frame")

WalkSpeedFrame.Size =
	UDim2.new(1, -10, 0, 38)

WalkSpeedFrame.BackgroundColor3 =
	Color3.fromRGB(22, 22, 22)

WalkSpeedFrame.BorderSizePixel = 0

WalkSpeedFrame.Parent = Scroll

local WalkSpeedCorner =
	Instance.new("UICorner")

WalkSpeedCorner.CornerRadius =
	UDim.new(0, 8)

WalkSpeedCorner.Parent =
	WalkSpeedFrame

local WalkMinus =
	Instance.new("TextButton")

WalkMinus.Size =
	UDim2.fromOffset(32, 30)

WalkMinus.Position =
	UDim2.fromOffset(4, 4)

WalkMinus.Text = "-"
WalkMinus.TextSize = 18

WalkMinus.Font =
	Enum.Font.GothamBold

WalkMinus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

WalkMinus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

WalkMinus.BorderSizePixel = 0

WalkMinus.Parent =
	WalkSpeedFrame

local WalkMinusCorner =
	Instance.new("UICorner")

WalkMinusCorner.CornerRadius =
	UDim.new(0, 7)

WalkMinusCorner.Parent =
	WalkMinus

local WalkSpeedLabel =
	Instance.new("TextLabel")

WalkSpeedLabel.Size =
	UDim2.new(1, -82, 1, 0)

WalkSpeedLabel.Position =
	UDim2.fromOffset(41, 0)

WalkSpeedLabel.BackgroundTransparency = 1

WalkSpeedLabel.Text =
	"WALK SPEED: 30"

WalkSpeedLabel.TextColor3 =
	Color3.fromRGB(245, 245, 245)

WalkSpeedLabel.TextSize = 11
WalkSpeedLabel.Font =
	Enum.Font.GothamBold

WalkSpeedLabel.Parent =
	WalkSpeedFrame

local WalkPlus =
	Instance.new("TextButton")

WalkPlus.Size =
	UDim2.fromOffset(32, 30)

WalkPlus.Position =
	UDim2.new(1, -36, 0, 4)

WalkPlus.Text = "+"
WalkPlus.TextSize = 18

WalkPlus.Font =
	Enum.Font.GothamBold

WalkPlus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

WalkPlus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

WalkPlus.BorderSizePixel = 0

WalkPlus.Parent =
	WalkSpeedFrame

local WalkPlusCorner =
	Instance.new("UICorner")

WalkPlusCorner.CornerRadius =
	UDim.new(0, 7)

WalkPlusCorner.Parent =
	WalkPlus

WalkMinus.Activated:Connect(function()

	WalkSpeed =
		math.max(
			16,
			WalkSpeed - 5
		)

	WalkSpeedLabel.Text =
		"WALK SPEED: " .. WalkSpeed

	if WalkSpeedEnabled then
		UpdateWalkSpeed()
	end
end)

WalkPlus.Activated:Connect(function()

	WalkSpeed =
		math.min(
			200,
			WalkSpeed + 5
		)

	WalkSpeedLabel.Text =
		"WALK SPEED: " .. WalkSpeed

	if WalkSpeedEnabled then
		UpdateWalkSpeed()
	end
end)

--========================================================--
-- ESP
--========================================================--

CreateSection(
	"VISUAL",
	Color3.fromRGB(225, 225, 225)
)

local ESPButton =
	CreateButton("ESP: OFF")

ESPButton.Activated:Connect(function()

	if ESPEnabled then

		DisableESP()

		ESPButton.Text =
			"ESP: OFF"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(22, 22, 22)

	else

		EnableESP()

		ESPButton.Text =
			"ESP: ON"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)
	end
end)

--========================================================--
-- AIMBOT
--========================================================--

CreateSection(
	"AIMBOT / FOV",
	Color3.fromRGB(225, 225, 225)
)

local AimbotButton =
	CreateButton("AIMBOT: OFF")

local FOVGui =
	Instance.new("Frame")

FOVGui.Name =
	"AimbotFOV"

FOVGui.Size =
	UDim2.fromOffset(
		AimbotFOV * 2,
		AimbotFOV * 2
	)

FOVGui.AnchorPoint =
	Vector2.new(0.5, 0.5)

FOVGui.Position =
	UDim2.fromScale(0.5, 0.5)

FOVGui.BackgroundTransparency = 1
FOVGui.BorderSizePixel = 0

FOVGui.Visible = false
FOVGui.ZIndex = 10

FOVGui.Parent = Gui

local FOVCorner =
	Instance.new("UICorner")

FOVCorner.CornerRadius =
	UDim.new(1, 0)

FOVCorner.Parent =
	FOVGui

local FOVStroke =
	Instance.new("UIStroke")

FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.4

FOVStroke.Color =
	Color3.fromRGB(255, 255, 255)

FOVStroke.Parent =
	FOVGui

--========================================================--
-- AIMBOT TARGET
--========================================================--

local function GetClosestTarget()

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

	local ClosestHead = nil
	local ClosestDistance = AimbotFOV

	for _, TargetPlayer in ipairs(
		Players:GetPlayers()
	) do

		if TargetPlayer ~= Player then

			local TargetCharacter =
				TargetPlayer.Character

			if TargetCharacter then

				local TargetHumanoid =
					TargetCharacter:
					FindFirstChildOfClass(
						"Humanoid"
					)

				local Head =
					TargetCharacter:
					FindFirstChild("Head")

				if TargetHumanoid
					and TargetHumanoid.Health > 0
					and Head then

					local ScreenPosition, OnScreen =
						Camera:WorldToViewportPoint(
							Head.Position
						)

					if OnScreen then

						local Distance =
							(
								Vector2.new(
									ScreenPosition.X,
									ScreenPosition.Y
								) - Center
							).Magnitude

						if Distance <
							ClosestDistance then

							ClosestDistance =
								Distance

							ClosestHead =
								Head
						end
					end
				end
			end
		end
	end

	return ClosestHead
end

--========================================================--
-- FOV CONTROLES
--========================================================--

local FOVFrame =
	Instance.new("Frame")

FOVFrame.Size =
	UDim2.new(1, -10, 0, 38)

FOVFrame.BackgroundColor3 =
	Color3.fromRGB(22, 22, 22)

FOVFrame.BorderSizePixel = 0

FOVFrame.Parent = Scroll

local FOVCorner2 =
	Instance.new("UICorner")

FOVCorner2.CornerRadius =
	UDim.new(0, 8)

FOVCorner2.Parent =
	FOVFrame

local FOVMinus =
	Instance.new("TextButton")

FOVMinus.Size =
	UDim2.fromOffset(32, 30)

FOVMinus.Position =
	UDim2.fromOffset(4, 4)

FOVMinus.Text = "-"
FOVMinus.TextSize = 18

FOVMinus.Font =
	Enum.Font.GothamBold

FOVMinus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

FOVMinus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

FOVMinus.BorderSizePixel = 0

FOVMinus.Parent =
	FOVFrame

local FOVMinusCorner =
	Instance.new("UICorner")

FOVMinusCorner.CornerRadius =
	UDim.new(0, 7)

FOVMinusCorner.Parent =
	FOVMinus

local FOVLabel =
	Instance.new("TextLabel")

FOVLabel.Size =
	UDim2.new(1, -82, 1, 0)

FOVLabel.Position =
	UDim2.fromOffset(41, 0)

FOVLabel.BackgroundTransparency = 1

FOVLabel.Text =
	"AIMBOT FOV: " .. AimbotFOV

FOVLabel.TextColor3 =
	Color3.fromRGB(245, 245, 245)

FOVLabel.TextSize = 11
FOVLabel.Font =
	Enum.Font.GothamBold

FOVLabel.Parent =
	FOVFrame

local FOVPlus =
	Instance.new("TextButton")

FOVPlus.Size =
	UDim2.fromOffset(32, 30)

FOVPlus.Position =
	UDim2.new(1, -36, 0, 4)

FOVPlus.Text = "+"
FOVPlus.TextSize = 18

FOVPlus.Font =
	Enum.Font.GothamBold

FOVPlus.TextColor3 =
	Color3.fromRGB(255, 255, 255)

FOVPlus.BackgroundColor3 =
	Color3.fromRGB(35, 35, 35)

FOVPlus.BorderSizePixel = 0

FOVPlus.Parent =
	FOVFrame

local FOVPlusCorner =
	Instance.new("UICorner")

FOVPlusCorner.CornerRadius =
	UDim.new(0, 7)

FOVPlusCorner.Parent =
	FOVPlus

local function UpdateAimbotFOV()

	AimbotFOV =
		math.clamp(
			AimbotFOV,
			20,
			300
		)

	FOVLabel.Text =
		"AIMBOT FOV: " ..
		AimbotFOV

	FOVGui.Size =
		UDim2.fromOffset(
			AimbotFOV * 2,
			AimbotFOV * 2
		)
end

FOVMinus.Activated:Connect(function()

	AimbotFOV =
		math.max(
			20,
			AimbotFOV - 10
		)

	UpdateAimbotFOV()
end)

FOVPlus.Activated:Connect(function()

	AimbotFOV =
		math.min(
			300,
			AimbotFOV + 10
		)

	UpdateAimbotFOV()
end)

--========================================================--
-- AIMBOT
--========================================================--

AimbotButton.Activated:Connect(function()

	AimbotEnabled =
		not AimbotEnabled

	FOVGui.Visible =
		AimbotEnabled

	if AimbotEnabled then

		StartAimbot()

		AimbotButton.Text =
			"AIMBOT: ON"

		AimbotButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)

	else

		StopAimbot()

		AimbotButton.Text =
			"AIMBOT: OFF"

		AimbotButton.BackgroundColor3 =
			Color3.fromRGB(22, 22, 22)
	end
end)

--========================================================--
-- AIMBOT LOOP
--========================================================--

StartAimbot = function()

	if AimbotRenderConnection then
		return
	end

	AimbotRenderConnection =
		RunService.RenderStepped:Connect(
			function()

				if not AimbotEnabled then
					return
				end

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				local Target =
					GetClosestTarget()

				if Target then

					Camera.CFrame =
						CFrame.lookAt(
							Camera.CFrame.Position,
							Target.Position
						)
				end
			end
		)
end

StopAimbot = function()

	if AimbotRenderConnection then

		AimbotRenderConnection:
			Disconnect()

		AimbotRenderConnection = nil
	end
end

--========================================================--
-- FLY / JOYSTICK
--========================================================--

StartFlyController = function()

	if FlyRenderConnection then
		return
	end

	FlyRenderConnection =
		RunService.RenderStepped:Connect(
			function()

				if not FlyEnabled then
					return
				end

				if not Root
					or not Humanoid
					or not BodyVelocity
					or not BodyGyro then
					return
				end

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				local MoveDirection =
					Humanoid.MoveDirection

				local Velocity =
					Vector3.zero

				if MoveDirection.Magnitude > 0.05 then

					local InputX =
						MoveDirection:Dot(
							Camera.CFrame.RightVector
						)

					local InputZ =
						MoveDirection:Dot(
							Camera.CFrame.LookVector
						)

					local Look =
						Camera.CFrame.LookVector

					local Right =
						Camera.CFrame.RightVector

					Velocity =
						Right * InputX +
						Look * InputZ

					if Velocity.Magnitude > 0.05 then

						Velocity =
							Velocity.Unit *
							FlySpeed
					end
				end

				BodyVelocity.Velocity =
					Velocity

				local LookDirection =
					Camera.CFrame.LookVector

				BodyGyro.CFrame =
					CFrame.lookAt(
						Root.Position,
						Root.Position +
							LookDirection
					)
			end
		)
end

StopFlyController = function()

	if FlyRenderConnection then

		FlyRenderConnection:
			Disconnect()

		FlyRenderConnection = nil
	end
end

--========================================================--
-- ÍCONE
--========================================================--

local OpenButton =
	Instance.new("ImageButton")

OpenButton.Name =
	"CafeinaIcon"

OpenButton.Size =
	UDim2.fromOffset(56, 56)

OpenButton.AnchorPoint =
	Vector2.new(0.5, 0.5)

OpenButton.Position =
	UDim2.fromScale(0.5, 0.5)

OpenButton.BackgroundColor3 =
	Color3.fromRGB(15, 15, 15)

OpenButton.BorderSizePixel = 0

OpenButton.Image =
	"rbxassetid://91715286435585"

OpenButton.ScaleType =
	Enum.ScaleType.Fit

OpenButton.Visible = false

OpenButton.ZIndex = 20

OpenButton.Parent = Gui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(0, 12)

OpenCorner.Parent =
	OpenButton

local OpenStroke = Instance.new("UIStroke")

OpenStroke.Thickness = 1
OpenStroke.Transparency = 0.25
OpenStroke.Color =
	Color3.fromRGB(230, 230, 230)

OpenStroke.Parent = OpenButton

--========================================================--
-- ARRASTAR MENU / ÍCONE
--========================================================--

local function MakeDraggable(Object)

	local Dragging = false
	local DragStart
	local StartPosition

	Object.InputBegan:Connect(
		function(Input)

			if Input.UserInputType ==
				Enum.UserInputType.Touch
				or Input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				Dragging = true

				DragStart =
					Input.Position

				StartPosition =
					Object.Position
			end
		end
	)

	UserInputService.InputChanged:Connect(
		function(Input)

			if not Dragging then
				return
			end

			if Input.UserInputType ==
				Enum.UserInputType.Touch
				or Input.UserInputType ==
				Enum.UserInputType.MouseMovement then

				local Delta =
					Input.Position -
					DragStart

				Object.Position =
					UDim2.new(
						StartPosition.X.Scale,
						StartPosition.X.Offset +
							Delta.X,

						StartPosition.Y.Scale,
						StartPosition.Y.Offset +
							Delta.Y
					)
			end
		end
	)

	UserInputService.InputEnded:Connect(
		function(Input)

			if Input.UserInputType ==
				Enum.UserInputType.Touch
				or Input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				Dragging = false
			end
		end
	)
end

MakeDraggable(Menu)
MakeDraggable(OpenButton)

--========================================================--
-- ABRIR / FECHAR
--========================================================--

CloseButton.Activated:Connect(function()

	Menu.Visible = false
	OpenButton.Visible = true
end)

OpenButton.Activated:Connect(function()

	OpenButton.Visible = false
	Menu.Visible = true
end)

--========================================================--
-- ATUALIZA SCROLL
--========================================================--

Layout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(function()

	Scroll.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			Layout.AbsoluteContentSize.Y + 14
		)
end)

task.defer(function()

	Scroll.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			Layout.AbsoluteContentSize.Y + 14
		)
end)

--========================================================--
-- RESPAWN
--========================================================--

Player.CharacterAdded:Connect(
	function(NewCharacter)

		StopFlyController()
		StopFly()
		StopAimbot()

		if NoclipDescendantConnection then

			NoclipDescendantConnection:
				Disconnect()

			NoclipDescendantConnection = nil
		end

		table.clear(
			NoclipCollisionState
		)

		Character = NewCharacter

		Humanoid =
			NewCharacter:WaitForChild(
				"Humanoid"
			)

		Root =
			NewCharacter:WaitForChild(
				"HumanoidRootPart"
			)

		DefaultWalkSpeed =
			Humanoid.WalkSpeed

		WalkSpeedRestoreValue = nil

		FlyEnabled = false
		AimbotEnabled = false
		NoclipEnabled = false
		WalkSpeedEnabled = false

		FlyButton.Text =
			"FLY: OFF"

		FlyButton.BackgroundColor3 =
			Color3.fromRGB(
				22,
				22,
				22
			)

		AimbotButton.Text =
			"AIMBOT: OFF"

		AimbotButton.BackgroundColor3 =
			Color3.fromRGB(
				22,
				22,
				22
			)

		FOVGui.Visible = false

		NoclipButton.Text =
			"NOCLIP: OFF"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(
				22,
				22,
				22
			)

		WalkButton.Text =
			"WALK SPEED: OFF"

		WalkButton.BackgroundColor3 =
			Color3.fromRGB(
				22,
				22,
				22
			)
	end
)

--========================================================--
-- FIM
--========================================================--
