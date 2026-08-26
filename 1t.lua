--========================================================--
--                  CAFEÍNA ROBLOX
--========================================================--
-- FLY + FLY SPEED
-- WALK SPEED
-- NOCLIP
-- ESP SEM LINHAS
-- IM BOT + FOV
-- MENU + ÍCONE INDEPENDENTES
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- ESTADO
--========================================================--

local Character
local Humanoid
local Root

local FlyEnabled = false
local NoclipEnabled = false
local ESPEnabled = true
local WalkSpeedEnabled = false
local IMBotEnabled = false

local FlySpeed = 50
local WalkSpeed = 30
local FOV = 40

local BodyVelocity
local BodyGyro

--========================================================--
-- LIMPAR GUI ANTIGA
--========================================================--

local OldGui = PlayerGui:FindFirstChild("CafeinaRoblox")

if OldGui then
	OldGui:Destroy()
end

--========================================================--
-- CHARACTER
--========================================================--

local function SetupCharacter()

	Character = Player.Character or Player.CharacterAdded:Wait()

	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")

	Humanoid.WalkSpeed =
		WalkSpeedEnabled and WalkSpeed or 16

end

SetupCharacter()

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaRoblox"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--========================================================--
-- MENU
--========================================================--

local Menu = Instance.new("Frame")

Menu.Name = "MainMenu"
Menu.Size = UDim2.fromOffset(250, 440)
Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.fromScale(0.5, 0.5)

Menu.BackgroundColor3 =
	Color3.fromRGB(80, 25, 130)

Menu.BorderSizePixel = 0
Menu.Parent = Gui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14)
MenuCorner.Parent = Menu

--========================================================--
-- FECHAR
--========================================================--

local CloseButton = Instance.new("TextButton")

CloseButton.Size =
	UDim2.fromOffset(30, 30)

CloseButton.Position =
	UDim2.fromOffset(7, 7)

CloseButton.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

CloseButton.Text = "×"
CloseButton.TextColor3 =
	Color3.new(1, 1, 1)

CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Menu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

--========================================================--
-- TÍTULO
--========================================================--

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(1, -50, 0, 35)

Title.Position =
	UDim2.fromOffset(42, 3)

Title.BackgroundTransparency = 1

Title.Text = "CAFEÍNA ROBLOX"

Title.TextColor3 =
	Color3.new(1, 1, 1)

Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

--========================================================--
-- FUNÇÃO BOTÃO
--========================================================--

local function CreateButton(Text, Y)

	local Button = Instance.new("TextButton")

	Button.Size =
		UDim2.new(1, -20, 0, 38)

	Button.Position =
		UDim2.fromOffset(10, Y)

	Button.BackgroundColor3 =
		Color3.fromRGB(55, 15, 90)

	Button.Text = Text

	Button.TextColor3 =
		Color3.new(1, 1, 1)

	Button.TextSize = 14
	Button.Font = Enum.Font.GothamBold

	Button.BorderSizePixel = 0
	Button.Parent = Menu

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	return Button

end

--========================================================--
-- FLY
--========================================================--

local FlyButton =
	CreateButton("FLY: OFF", 45)

--========================================================--
-- FLY SPEED
--========================================================--

local FlySpeedFrame = Instance.new("Frame")

FlySpeedFrame.Size =
	UDim2.new(1, -20, 0, 38)

FlySpeedFrame.Position =
	UDim2.fromOffset(10, 89)

FlySpeedFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

FlySpeedFrame.BorderSizePixel = 0
FlySpeedFrame.Parent = Menu

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius = UDim.new(0, 8)
FlySpeedCorner.Parent = FlySpeedFrame

local FlyMinus = Instance.new("TextButton")

FlyMinus.Size =
	UDim2.fromOffset(40, 30)

FlyMinus.Position =
	UDim2.fromOffset(4, 4)

FlyMinus.Text = "-"
FlyMinus.TextSize = 19
FlyMinus.Font = Enum.Font.GothamBold

FlyMinus.TextColor3 =
	Color3.new(1, 1, 1)

FlyMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FlyMinus.BorderSizePixel = 0
FlyMinus.Parent = FlySpeedFrame

local FlyMinusCorner = Instance.new("UICorner")
FlyMinusCorner.CornerRadius = UDim.new(0, 6)
FlyMinusCorner.Parent = FlyMinus

local FlySpeedLabel = Instance.new("TextLabel")

FlySpeedLabel.Size =
	UDim2.fromOffset(130, 38)

FlySpeedLabel.Position =
	UDim2.fromOffset(52, 0)

FlySpeedLabel.BackgroundTransparency = 1

FlySpeedLabel.Text =
	"FLY SPEED: 50"

FlySpeedLabel.TextColor3 =
	Color3.new(1, 1, 1)

FlySpeedLabel.TextSize = 11
FlySpeedLabel.Font = Enum.Font.GothamBold
FlySpeedLabel.Parent = FlySpeedFrame

local FlyPlus = Instance.new("TextButton")

FlyPlus.Size =
	UDim2.fromOffset(40, 30)

FlyPlus.Position =
	UDim2.new(1, -44, 0, 4)

FlyPlus.Text = "+"
FlyPlus.TextSize = 19
FlyPlus.Font = Enum.Font.GothamBold

FlyPlus.TextColor3 =
	Color3.new(1, 1, 1)

FlyPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FlyPlus.BorderSizePixel = 0
FlyPlus.Parent = FlySpeedFrame

local FlyPlusCorner = Instance.new("UICorner")
FlyPlusCorner.CornerRadius = UDim.new(0, 6)
FlyPlusCorner.Parent = FlyPlus

--========================================================--
-- WALK SPEED
--========================================================--

local WalkButton =
	CreateButton("WALK SPEED: OFF", 133)

local WalkSpeedFrame = Instance.new("Frame")

WalkSpeedFrame.Size =
	UDim2.new(1, -20, 0, 38)

WalkSpeedFrame.Position =
	UDim2.fromOffset(10, 177)

WalkSpeedFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

WalkSpeedFrame.BorderSizePixel = 0
WalkSpeedFrame.Parent = Menu

local WalkSpeedCorner = Instance.new("UICorner")
WalkSpeedCorner.CornerRadius = UDim.new(0, 8)
WalkSpeedCorner.Parent = WalkSpeedFrame

local WalkMinus = Instance.new("TextButton")

WalkMinus.Size =
	UDim2.fromOffset(40, 30)

WalkMinus.Position =
	UDim2.fromOffset(4, 4)

WalkMinus.Text = "-"
WalkMinus.TextSize = 19
WalkMinus.Font = Enum.Font.GothamBold

WalkMinus.TextColor3 =
	Color3.new(1, 1, 1)

WalkMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

WalkMinus.BorderSizePixel = 0
WalkMinus.Parent = WalkSpeedFrame

local WalkMinusCorner = Instance.new("UICorner")
WalkMinusCorner.CornerRadius = UDim.new(0, 6)
WalkMinusCorner.Parent = WalkMinus

local WalkSpeedLabel = Instance.new("TextLabel")

WalkSpeedLabel.Size =
	UDim2.fromOffset(130, 38)

WalkSpeedLabel.Position =
	UDim2.fromOffset(52, 0)

WalkSpeedLabel.BackgroundTransparency = 1

WalkSpeedLabel.Text =
	"WALK SPEED: 30"

WalkSpeedLabel.TextColor3 =
	Color3.new(1, 1, 1)

WalkSpeedLabel.TextSize = 10
WalkSpeedLabel.Font = Enum.Font.GothamBold
WalkSpeedLabel.Parent = WalkSpeedFrame

local WalkPlus = Instance.new("TextButton")

WalkPlus.Size =
	UDim2.fromOffset(40, 30)

WalkPlus.Position =
	UDim2.new(1, -44, 0, 4)

WalkPlus.Text = "+"
WalkPlus.TextSize = 19
WalkPlus.Font = Enum.Font.GothamBold

WalkPlus.TextColor3 =
	Color3.new(1, 1, 1)

WalkPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

WalkPlus.BorderSizePixel = 0
WalkPlus.Parent = WalkSpeedFrame

local WalkPlusCorner = Instance.new("UICorner")
WalkPlusCorner.CornerRadius = UDim.new(0, 6)
WalkPlusCorner.Parent = WalkPlus

--========================================================--
-- NOCLIP / ESP
--========================================================--

local NoclipButton =
	CreateButton("NOCLIP: OFF", 221)

local ESPButton =
	CreateButton("ESP: ON", 265)

ESPButton.BackgroundColor3 =
	Color3.fromRGB(35, 150, 70)

--========================================================--
-- IM BOT
--========================================================--

local IMBotButton =
	CreateButton("IM BOT: OFF", 309)

--========================================================--
-- FOV CONTROLE
--========================================================--

local FOVFrame = Instance.new("Frame")

FOVFrame.Size =
	UDim2.new(1, -20, 0, 38)

FOVFrame.Position =
	UDim2.fromOffset(10, 353)

FOVFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = Menu

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 8)
FOVCorner.Parent = FOVFrame

local FOVMinus = Instance.new("TextButton")

FOVMinus.Size =
	UDim2.fromOffset(40, 30)

FOVMinus.Position =
	UDim2.fromOffset(4, 4)

FOVMinus.Text = "-"
FOVMinus.TextSize = 19
FOVMinus.Font = Enum.Font.GothamBold

FOVMinus.TextColor3 =
	Color3.new(1, 1, 1)

FOVMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FOVMinus.BorderSizePixel = 0
FOVMinus.Parent = FOVFrame

local FOVMinusCorner = Instance.new("UICorner")
FOVMinusCorner.CornerRadius = UDim.new(0, 6)
FOVMinusCorner.Parent = FOVMinus

local FOVLabel = Instance.new("TextLabel")

FOVLabel.Size =
	UDim2.fromOffset(130, 38)

FOVLabel.Position =
	UDim2.fromOffset(52, 0)

FOVLabel.BackgroundTransparency = 1

FOVLabel.Text =
	"FOV: 40"

FOVLabel.TextColor3 =
	Color3.new(1, 1, 1)

FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.Parent = FOVFrame

local FOVPlus = Instance.new("TextButton")

FOVPlus.Size =
	UDim2.fromOffset(40, 30)

FOVPlus.Position =
	UDim2.new(1, -44, 0, 4)

FOVPlus.Text = "+"
FOVPlus.TextSize = 19
FOVPlus.Font = Enum.Font.GothamBold

FOVPlus.TextColor3 =
	Color3.new(1, 1, 1)

FOVPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FOVPlus.BorderSizePixel = 0
FOVPlus.Parent = FOVFrame

local FOVPlusCorner = Instance.new("UICorner")
FOVPlusCorner.CornerRadius = UDim.new(0, 6)
FOVPlusCorner.Parent = FOVPlus

--========================================================--
-- CÍRCULO FOV
--========================================================--

local FOVCircle = Instance.new("Frame")

FOVCircle.Name = "FOVCircle"

FOVCircle.AnchorPoint =
	Vector2.new(0.5, 0.5)

FOVCircle.Position =
	UDim2.fromScale(0.5, 0.5)

FOVCircle.Size =
	UDim2.fromOffset(FOV * 2, FOV * 2)

FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 1
FOVCircle.Parent = Gui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")

CircleStroke.Thickness = 2

CircleStroke.Color =
	Color3.fromRGB(128, 0, 128)

CircleStroke.Parent = FOVCircle

--========================================================--
-- ÍCONE
--========================================================--

local OpenButton = Instance.new("ImageButton")

OpenButton.Name = "CafeinaIcon"

OpenButton.Size =
	UDim2.fromOffset(55, 55)

OpenButton.AnchorPoint =
	Vector2.new(0.5, 0.5)

OpenButton.Position =
	UDim2.fromScale(0.5, 0.5)

OpenButton.BackgroundColor3 =
	Color3.fromRGB(80, 25, 130)

OpenButton.BorderSizePixel = 0

OpenButton.Image =
	"rbxassetid://91715286435585"

OpenButton.ScaleType =
	Enum.ScaleType.Fit

OpenButton.Visible = false
OpenButton.ZIndex = 10
OpenButton.Parent = Gui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

--========================================================--
-- DRAG
--========================================================--

local function MakeDraggable(Object)

	local Dragging = false
	local DragStart
	local StartPosition

	Object.InputBegan:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Object.Position

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if not Dragging then
			return
		end

		if Input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or Input.UserInputType ==
			Enum.UserInputType.Touch then

			local Delta =
				Input.Position - DragStart

			Object.Position =
				UDim2.new(
					StartPosition.X.Scale,
					StartPosition.X.Offset + Delta.X,
					StartPosition.Y.Scale,
					StartPosition.Y.Offset + Delta.Y
				)

		end

	end)

	UserInputService.InputEnded:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = false

		end

	end)

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
-- FLY
--========================================================--

local function StopFly()

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

	if Root then
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
	BodyGyro.CFrame =
		Root.CFrame

	BodyGyro.Parent = Root

	Humanoid.PlatformStand = true

end

FlyButton.Activated:Connect(function()

	FlyEnabled = not FlyEnabled

	if FlyEnabled then

		FlyButton.Text = "FLY: ON"

		FlyButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

		StartFly()

	else

		FlyButton.Text = "FLY: OFF"

		FlyButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

		StopFly()

	end

end)

--========================================================--
-- FLY SPEED
--========================================================--

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
-- WALK SPEED
--========================================================--

local function UpdateWalkSpeed()

	if not Humanoid then
		return
	end

	Humanoid.WalkSpeed =
		WalkSpeedEnabled
		and WalkSpeed
		or 16

end

WalkButton.Activated:Connect(function()

	WalkSpeedEnabled =
		not WalkSpeedEnabled

	if WalkSpeedEnabled then

		WalkButton.Text =
			"WALK SPEED: ON"

		WalkButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

	else

		WalkButton.Text =
			"WALK SPEED: OFF"

		WalkButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

	end

	UpdateWalkSpeed()

end)

WalkMinus.Activated:Connect(function()

	WalkSpeed =
		math.max(
			16,
			WalkSpeed - 5
		)

	WalkSpeedLabel.Text =
		"WALK SPEED: " .. WalkSpeed

	UpdateWalkSpeed()

end)

WalkPlus.Activated:Connect(function()

	WalkSpeed =
		math.min(
			200,
			WalkSpeed + 5
		)

	WalkSpeedLabel.Text =
		"WALK SPEED: " .. WalkSpeed

	UpdateWalkSpeed()

end)

--========================================================--
-- NOCLIP
--========================================================--

NoclipButton.Activated:Connect(function()

	NoclipEnabled =
		not NoclipEnabled

	if NoclipEnabled then

		NoclipButton.Text =
			"NOCLIP: ON"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

	else

		NoclipButton.Text =
			"NOCLIP: OFF"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

	end

end)

--========================================================--
-- ESP
--========================================================--

local ESPFolder = Instance.new("Folder")

ESPFolder.Name =
	"CafeinaESP"

ESPFolder.Parent =
	workspace

local ESPObjects = {}

local function RemoveESP(TargetPlayer)

	local Data =
		ESPObjects[TargetPlayer]

	if not Data then
		return
	end

	if Data.Highlight then
		Data.Highlight:Destroy()
	end

	if Data.Billboard then
		Data.Billboard:Destroy()
	end

	ESPObjects[TargetPlayer] = nil

end

local function CreateESP(TargetPlayer)

	if TargetPlayer == Player then
		return
	end

	if not ESPEnabled then
		return
	end

	local TargetCharacter =
		TargetPlayer.Character

	if not TargetCharacter then
		return
	end

	local TargetRoot =
		TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not TargetRoot then
		return
	end

	RemoveESP(TargetPlayer)

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
		Color3.fromRGB(255, 255, 255)

	Highlight.Parent =
		ESPFolder

	local Billboard =
		Instance.new("BillboardGui")

	Billboard.Name =
		"ESP_Name"

	Billboard.Adornee =
		TargetRoot

	Billboard.Size =
		UDim2.fromOffset(150, 35)

	Billboard.StudsOffset =
		Vector3.new(0, 3, 0)

	Billboard.AlwaysOnTop = true
	Billboard.Parent = ESPFolder

	local NameLabel =
		Instance.new("TextLabel")

	NameLabel.Size =
		UDim2.fromScale(1, 1)

	NameLabel.BackgroundTransparency = 1

	NameLabel.Text =
		TargetPlayer.DisplayName

	NameLabel.TextColor3 =
		Color3.new(1, 1, 1)

	NameLabel.TextStrokeTransparency = 0
	NameLabel.TextSize = 14
	NameLabel.Font =
		Enum.Font.GothamBold

	NameLabel.Parent =
		Billboard

	ESPObjects[TargetPlayer] = {
		Highlight = Highlight,
		Billboard = Billboard
	}

end

local function SetupESPPlayer(TargetPlayer)

	if TargetPlayer == Player then
		return
	end

	TargetPlayer.CharacterAdded:Connect(function()

		task.wait(0.5)

		if ESPEnabled then
			CreateESP(TargetPlayer)
		end

	end)

	if TargetPlayer.Character then
		CreateESP(TargetPlayer)
	end

end

for _, TargetPlayer in
	ipairs(Players:GetPlayers()) do

	SetupESPPlayer(TargetPlayer)

end

Players.PlayerAdded:Connect(
	SetupESPPlayer
)

Players.PlayerRemoving:Connect(
	RemoveESP
)

ESPButton.Activated:Connect(function()

	ESPEnabled =
		not ESPEnabled

	if ESPEnabled then

		ESPButton.Text =
			"ESP: ON"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

		for _, TargetPlayer in
			ipairs(Players:GetPlayers()) do

			if TargetPlayer ~= Player then
				CreateESP(TargetPlayer)
			end

		end

	else

		ESPButton.Text =
			"ESP: OFF"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

		for TargetPlayer in
			pairs(ESPObjects) do

			RemoveESP(TargetPlayer)

		end

	end

end)

--========================================================--
-- FOV
--========================================================--

loca
