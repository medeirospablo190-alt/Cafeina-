--========================================================--
--                    CAFEÍNA ROBLOX
--       FLY + FLY SPEED + WALK SPEED + NOCLIP + ESP
--       MENU + ÍCONE INDEPENDENTES
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

if not Player then
	warn("[CAFEÍNA] LocalPlayer não encontrado.")
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- CONFIG
--========================================================--

local FlyEnabled = false
local NoclipEnabled = false
local ESPEnabled = true
local WalkSpeedEnabled = false

local FlySpeed = 50
local WalkSpeed = 30

local Character
local Humanoid
local Root

local BodyVelocity
local BodyGyro

local CollisionSaved = {}

--========================================================--
-- LIMPAR VERSÃO ANTERIOR
--========================================================--

local OldGui = PlayerGui:FindFirstChild("CafeinaRoblox")

if OldGui then
	OldGui:Destroy()
end

local OldESP = workspace:FindFirstChild("CafeinaESP")

if OldESP then
	OldESP:Destroy()
end

--========================================================--
-- ESP
--========================================================--

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CafeinaESP"
ESPFolder.Parent = workspace

local ESPObjects = {}
local ESPConnections = {}

--========================================================--
-- CHARACTER
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
		Humanoid.AutoRotate = true
	end

	if Root then
		Root.AssemblyLinearVelocity = Vector3.zero
		Root.AssemblyAngularVelocity = Vector3.zero
	end

end

local function SaveCollision()

	table.clear(CollisionSaved)

	if not Character then
		return
	end

	for _, Object in ipairs(Character:GetDescendants()) do

		if Object:IsA("BasePart") then
			CollisionSaved[Object] = Object.CanCollide
		end

	end

end

local function ApplyNoclip()

	if not Character then
		return
	end

	for _, Object in ipairs(Character:GetDescendants()) do

		if Object:IsA("BasePart") then

			if CollisionSaved[Object] == nil then
				CollisionSaved[Object] = Object.CanCollide
			end

			Object.CanCollide = false

		end

	end

end

local function RestoreCollision()

	for Object, Value in pairs(CollisionSaved) do

		if Object and Object.Parent then
			Object.CanCollide = Value
		end

	end

	table.clear(CollisionSaved)

end

local function SetupCharacter(NewCharacter)

	Character = NewCharacter

	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")

	StopFly()
	RestoreCollision()

	FlyEnabled = false
	NoclipEnabled = false

	if WalkSpeedEnabled then
		Humanoid.WalkSpeed = WalkSpeed
	else
		Humanoid.WalkSpeed = 16
	end

end

SetupCharacter(
	Player.Character or Player.CharacterAdded:Wait()
)

Player.CharacterAdded:Connect(function(NewCharacter)

	StopFly()
	RestoreCollision()

	FlyEnabled = false
	NoclipEnabled = false

	task.wait(0.2)

	SetupCharacter(NewCharacter)

end)

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
Menu.Size = UDim2.fromOffset(250, 355)
Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.fromScale(0.5, 0.5)
Menu.BackgroundColor3 = Color3.fromRGB(80, 25, 130)
Menu.BorderSizePixel = 0
Menu.Parent = Gui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14)
MenuCorner.Parent = Menu

--========================================================--
-- FECHAR
--========================================================--

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.fromOffset(7, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(55, 15, 90)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
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
Title.Size = UDim2.new(1, -50, 0, 35)
Title.Position = UDim2.fromOffset(42, 3)
Title.BackgroundTransparency = 1
Title.Text = "CAFEÍNA ROBLOX"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

--========================================================--
-- BOTÃO
--========================================================--

local function CreateButton(Text, Y)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1, -20, 0, 38)
	Button.Position = UDim2.fromOffset(10, Y)
	Button.BackgroundColor3 = Color3.fromRGB(55, 15, 90)
	Button.Text = Text
	Button.TextColor3 = Color3.new(1, 1, 1)
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

local FlyButton = CreateButton("FLY: OFF", 45)

--========================================================--
-- FLY SPEED
--========================================================--

local FlySpeedFrame = Instance.new("Frame")
FlySpeedFrame.Size = UDim2.new(1, -20, 0, 38)
FlySpeedFrame.Position = UDim2.fromOffset(10, 89)
FlySpeedFrame.BackgroundColor3 = Color3.fromRGB(55, 15, 90)
FlySpeedFrame.BorderSizePixel = 0
FlySpeedFrame.Parent = Menu

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius = UDim.new(0, 8)
FlySpeedCorner.Parent = FlySpeedFrame

local FlyMinus = Instance.new("TextButton")
FlyMinus.Size = UDim2.fromOffset(40, 30)
FlyMinus.Position = UDim2.fromOffset(4, 4)
FlyMinus.Text = "-"
FlyMinus.TextSize = 19
FlyMinus.Font = Enum.Font.GothamBold
FlyMinus.TextColor3 = Color3.new(1, 1, 1)
FlyMinus.BackgroundColor3 = Color3.fromRGB(100, 35, 150)
FlyMinus.BorderSizePixel = 0
FlyMinus.Parent = FlySpeedFrame

local FlyMinusCorner = Instance.new("UICorner")
FlyMinusCorner.CornerRadius = UDim.new(0, 6)
FlyMinusCorner.Parent = FlyMinus

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.fromOffset(130, 38)
FlySpeedLabel.Position = UDim2.fromOffset(52, 0)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "FLY SPEED: 50"
FlySpeedLabel.TextColor3 = Color3.new(1, 1, 1)
FlySpeedLabel.TextSize = 11
FlySpeedLabel.Font = Enum.Font.GothamBold
FlySpeedLabel.Parent = FlySpeedFrame

local FlyPlus = Instance.new("TextButton")
FlyPlus.Size = UDim2.fromOffset(40, 30)
FlyPlus.Position = UDim2.new(1, -44, 0, 4)
FlyPlus.Text = "+"
FlyPlus.TextSize = 19
FlyPlus.Font = Enum.Font.GothamBold
FlyPlus.TextColor3 = Color3.new(1, 1, 1)
FlyPlus.BackgroundColor3 = Color3.fromRGB(100, 35, 150)
FlyPlus.BorderSizePixel = 0
FlyPlus.Parent = FlySpeedFrame

local FlyPlusCorner = Instance.new("UICorner")
FlyPlusCorner.CornerRadius = UDim.new(0, 6)
FlyPlusCorner.Parent = FlyPlus

--========================================================--
-- WALK SPEED
--========================================================--

local WalkButton = CreateButton("WALK SPEED: OFF", 133)

local WalkSpeedFrame = Instance.new("Frame")
WalkSpeedFrame.Size = UDim2.new(1, -20, 0, 38)
WalkSpeedFrame.Position = UDim2.fromOffset(10, 177)
WalkSpeedFrame.BackgroundColor3 = Color3.fromRGB(55, 15, 90)
WalkSpeedFrame.BorderSizePixel = 0
WalkSpeedFrame.Parent = Menu

local WalkSpeedCorner = Instance.new("UICorner")
WalkSpeedCorner.CornerRadius = UDim.new(0, 8)
WalkSpeedCorner.Parent = WalkSpeedFrame

local WalkMinus = Instance.new("TextButton")
WalkMinus.Size = UDim2.fromOffset(40, 30)
WalkMinus.Position = UDim2.fromOffset(4, 4)
WalkMinus.Text = "-"
WalkMinus.TextSize = 19
WalkMinus.Font = Enum.Font.GothamBold
WalkMinus.TextColor3 = Color3.new(1, 1, 1)
WalkMinus.BackgroundColor3 = Color3.fromRGB(100, 35, 150)
WalkMinus.BorderSizePixel = 0
WalkMinus.Parent = WalkSpeedFrame

local WalkMinusCorner = Instance.new("UICorner")
WalkMinusCorner.CornerRadius = UDim.new(0, 6)
WalkMinusCorner.Parent = WalkMinus

local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Size = UDim2.fromOffset(130, 38)
WalkSpeedLabel.Position = UDim2.fromOffset(52, 0)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text = "WALK SPEED: 30"
WalkSpeedLabel.TextColor3 = Color3.new(1, 1, 1)
WalkSpeedLabel.TextSize = 10
WalkSpeedLabel.Font = Enum.Font.GothamBold
WalkSpeedLabel.Parent = WalkSpeedFrame

local WalkPlus = Instance.new("TextButton")
WalkPlus.Size = UDim2.fromOffset(40, 30)
WalkPlus.Position = UDim2.new(1, -44, 0, 4)
WalkPlus.Text = "+"
WalkPlus.TextSize = 19
WalkPlus.Font = Enum.Font.GothamBold
WalkPlus.TextColor3 = Color3.new(1, 1, 1)
WalkPlus.BackgroundColor3 = Color3.fromRGB(100, 35, 150)
WalkPlus.BorderSizePixel = 0
WalkPlus.Parent = WalkSpeedFrame

local WalkPlusCorner = Instance.new("UICorner")
WalkPlusCorner.CornerRadius = UDim.new(0, 6)
WalkPlusCorner.Parent = WalkPlus

--========================================================--
-- NOCLIP / ESP
--========================================================--

local NoclipButton = CreateButton("NOCLIP: OFF", 221)

local ESPButton = CreateButton("ESP: ON", 265)

ESPButton.BackgroundColor3 =
	Color3.fromRGB(35, 150, 70)

--========================================================--
-- ÍCONE
--========================================================--

local OpenButton = Instance.new("ImageButton")

OpenButton.Name = "CafeinaIcon"
OpenButton.Size = UDim2.fromOffset(55, 55)
OpenButton.AnchorPoint = Vector2.new(0.5, 0.5)
OpenButton.Position = UDim2.fromScale(0.5, 0.5)

OpenButton.BackgroundColor3 =
	Color3.fromRGB(80, 25, 130)

OpenButton.BorderSizePixel = 0
OpenButton.Image = "rbxassetid://91715286435585"
OpenButton.ScaleType = Enum.ScaleType.Fit

OpenButton.Visible = false
OpenButton.Parent = Gui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

--========================================================--
-- ARRASTAR
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

			Object.Position = UDim2.new(
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
-- START FLY
--========================================================--

local function StartFly()

	if not Character
		or not Humanoid
		or not Root then
		return
	end

	StopFly()

	BodyVelocity = Instance.new("BodyVelocity")

	BodyVelocity.MaxForce =
		Vector3.new(
			math.huge,
			math.huge,
			math.huge
		)

	BodyVelocity.P = 9000
	BodyVelocity.Velocity = Vector3.zero
	BodyVelocity.Parent = Root

	BodyGyro = Instance.new("BodyGyro")

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
	Humanoid.AutoRotate = false

end

--========================================================--
-- FLY BUTTON
--========================================================--

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
		math.max(10, FlySpeed - 10)

	FlySpeedLabel.Text =
		"FLY SPEED: " .. FlySpeed

end)

FlyPlus.Activated:Connect(function()

	FlySpeed =
		math.min(300, FlySpeed + 10)

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

	if WalkSpeedEnabled then
		Humanoid.WalkSpeed = WalkSpeed
	else
		Humanoid.WalkSpeed = 16
	end

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
		math.max(16, WalkSpeed - 5)

	WalkSpeedLabel.Text =
		"WALK SPEED: " .. WalkSpeed

	UpdateWalkSpeed()

end)

WalkPlus.Activated:Connect(function()

	WalkSpeed =
		math.min(200, WalkSpeed + 5)

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

		SaveCollision()
		ApplyNoclip()

	else

		NoclipButton.Text =
			"NOCLIP: OFF"

		NoclipButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

		RestoreCollision()

	end

end)

--========================================================--
-- ESP
--========================================================--

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

	RemoveESP(TargetPlayer)

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

	Highlight.Enabled =
		ESPEnabled

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
	Billboard.Enabled = ESPEnabled
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

	if ESPConnections[TargetPlayer] then

		ESPConnections[TargetPlayer]:Disconnect()

	end

	ESPConnections[TargetPlayer] =
		TargetPlayer.CharacterAdded:Connect(function()

			RemoveESP(TargetPlayer)

			task.wait(0.4)

			if TargetPlayer.Parent then
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

Players.PlayerRemoving:Connect(function(TargetPlayer)

	RemoveESP(TargetPlayer)

	if ESPConnections[TargetPlayer] then

		ESPConnections[TargetPlayer]:Disconnect()
		ESPConnections[TargetPlayer] = nil

	end

end)

--========================================================--
-- ESP ON / OFF
--========================================================--

ESPButton.Activated:Connect(function()

	ESPEnabled =
		not ESPEnabled

	if ESPEnabled then

		ESPButton.Text =
			"ESP: ON"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

	else

		ESPButton.Text =
			"ESP: OFF"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

	end

	for _, Data in
		pairs(ESPObjects) do

		if Data.Highlight then
			Data.Highlight.Enabled =
				ESPEnabled
		end

		if Data.Billboard then
			Data.Billboard.Enabled =
				ESPEnabled
		end

	end

end)

--========================================================--
-- LOOP
--========================================================--

RunService.RenderStepped:Connect(function()

	-- WALK SPEED
	if WalkSpeedEnabled
		and Humanoid
		and Humanoid.Parent then

		if Humanoid.WalkSpeed ~= WalkSpeed then
			Humanoid.WalkSpeed = WalkSpeed
		end

	end

	-- NOCLIP
	if NoclipEnabled
		and Character
		and Character.Parent then

		ApplyNoclip()

	end

	-- FLY
	if not FlyEnabled then
		return
	end

	if not Root
		or not Humanoid
		or not BodyVelocity
		or not BodyGyro then
		return
	end

	if Humanoid.Health <= 0 then
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

		local Right =
			Camera.CFrame.RightVector

		local Look =
			Camera.CFrame.LookVector

		Right =
			Vector3.new(
				Right.X,
				0,
				Right.Z
			)

		Look =
			Vector3.new(
				Look.X,
				0,
				Look.Z
			)

		if Right.Magnitude > 0 then
			Right = Right.Unit
		end

		if Look.Magnitude > 0 then
			Look = Look.Unit
		end

		local X =
			MoveDirection:Dot(Right)

		local Z =
			MoveDirection:Dot(Look)

		Velocity =
			Right * X +
			Look * Z

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

	local Horizontal =
		Vector3.new(
			LookDirection.X,
			0,
			LookDirection.Z
		)

	if Horizontal.Magnitude > 0.05 then

		Horizontal =
			Horizontal.Unit

		BodyGyro.CFrame =
			CFrame.lookAt(
				Root.Position,
				Root.Position + Horizontal
			)

	end

end)

--========================================================--
-- PRONTO
--========================================================--

print("[CAFEÍNA] Menu iniciado com sucesso.")
