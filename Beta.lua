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
local ESPEnabled = true
local WalkSpeedEnabled = false
local AimbotEnabled = false

local FlySpeed = 50
local WalkSpeed = 30
local AimbotFOV = 100

local BodyVelocity
local BodyGyro

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
-- ESP
--========================================================--

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CafeinaESP"
ESPFolder.Parent = workspace

local ESPObjects = {}

local function CreateESP(TargetPlayer)
	if TargetPlayer == Player then
		return
	end

	local TargetCharacter = TargetPlayer.Character
	if not TargetCharacter then
		return
	end

	local TargetRoot =
		TargetCharacter:FindFirstChild("HumanoidRootPart")

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
	Highlight.Enabled = ESPEnabled
	Highlight.Parent = ESPFolder

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "ESP_Name"
	Billboard.Adornee = TargetRoot
	Billboard.Size = UDim2.fromOffset(150, 35)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Enabled = ESPEnabled
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

local function SetupESPPlayer(TargetPlayer)
	if TargetPlayer == Player then
		return
	end

	TargetPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)

		RemoveESP(TargetPlayer)
		CreateESP(TargetPlayer)
	end)

	if TargetPlayer.Character then
		CreateESP(TargetPlayer)
	end
end

for _, TargetPlayer in ipairs(Players:GetPlayers()) do
	SetupESPPlayer(TargetPlayer)
end

Players.PlayerAdded:Connect(SetupESPPlayer)
Players.PlayerRemoving:Connect(RemoveESP)

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaRoblox"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--========================================================--
-- MENU
--========================================================--

local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"

-- MENU MENOR
Menu.Size = UDim2.fromOffset(230, 330)

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
CloseButton.Size = UDim2.fromOffset(28, 28)
CloseButton.Position = UDim2.fromOffset(7, 7)

CloseButton.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 19
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
Title.Size = UDim2.new(1, -45, 0, 32)
Title.Position = UDim2.fromOffset(38, 4)

Title.BackgroundTransparency = 1
Title.Text = "CAFEÍNA ROBLOX"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

--========================================================--
-- SCROLL
--========================================================--

local Scroll = Instance.new("ScrollingFrame")

Scroll.Name = "Content"
Scroll.Size = UDim2.new(1, -10, 1, -43)
Scroll.Position = UDim2.fromOffset(5, 38)

Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0

Scroll.CanvasSize =
	UDim2.new(0, 0, 0, 610)

Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 =
	Color3.fromRGB(180, 100, 230)

Scroll.ScrollingDirection =
	Enum.ScrollingDirection.Y

Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center
Layout.SortOrder =
	Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

--========================================================--
-- FUNÇÃO BOTÃO
--========================================================--

local function CreateButton(Text)
	local Button = Instance.new("TextButton")

	Button.Size =
		UDim2.new(1, -10, 0, 38)

	Button.BackgroundColor3 =
		Color3.fromRGB(55, 15, 90)

	Button.Text = Text
	Button.TextColor3 =
		Color3.new(1, 1, 1)

	Button.TextSize = 13
	Button.Font = Enum.Font.GothamBold
	Button.BorderSizePixel = 0

	Button.Parent = Scroll

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	return Button
end

--========================================================--
-- KILL / REGENERAR
--========================================================--

local KillButton = CreateButton("KILL / REGENERAR")

KillButton.BackgroundColor3 =
	Color3.fromRGB(180, 35, 35)

KillButton.Activated:Connect(function()

	if Character and Character.Parent then

		local CurrentHumanoid =
			Character:FindFirstChildOfClass("Humanoid")

		if CurrentHumanoid then
			CurrentHumanoid.Health = 0
		end

	end

end)

--========================================================--
-- FLY
--========================================================--

local FlyButton =
	CreateButton("FLY: OFF")

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
	BodyGyro.CFrame = Root.CFrame
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

local FlySpeedFrame = Instance.new("Frame")

FlySpeedFrame.Size =
	UDim2.new(1, -10, 0, 38)

FlySpeedFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

FlySpeedFrame.BorderSizePixel = 0
FlySpeedFrame.Parent = Scroll

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius =
	UDim.new(0, 8)
FlySpeedCorner.Parent = FlySpeedFrame

local FlyMinus = Instance.new("TextButton")

FlyMinus.Size =
	UDim2.fromOffset(36, 30)

FlyMinus.Position =
	UDim2.fromOffset(4, 4)

FlyMinus.Text = "-"
FlyMinus.TextSize = 18
FlyMinus.Font = Enum.Font.GothamBold
FlyMinus.TextColor3 =
	Color3.new(1, 1, 1)

FlyMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FlyMinus.BorderSizePixel = 0
FlyMinus.Parent = FlySpeedFrame

local FlySpeedLabel = Instance.new("TextLabel")

FlySpeedLabel.Size =
	UDim2.new(1, -88, 1, 0)

FlySpeedLabel.Position =
	UDim2.fromOffset(44, 0)

FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text =
	"FLY SPEED: 50"

FlySpeedLabel.TextColor3 =
	Color3.new(1, 1, 1)

FlySpeedLabel.TextSize = 11
FlySpeedLabel.Font =
	Enum.Font.GothamBold

FlySpeedLabel.Parent = FlySpeedFrame

local FlyPlus = Instance.new("TextButton")

FlyPlus.Size =
	UDim2.fromOffset(36, 30)

FlyPlus.Position =
	UDim2.new(1, -40, 0, 4)

FlyPlus.Text = "+"
FlyPlus.TextSize = 18
FlyPlus.Font = Enum.Font.GothamBold
FlyPlus.TextColor3 =
	Color3.new(1, 1, 1)

FlyPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FlyPlus.BorderSizePixel = 0
FlyPlus.Parent = FlySpeedFrame

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

local WalkButton =
	CreateButton("WALK SPEED: OFF")

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

--========================================================--
-- WALK SPEED CONTROLES
--========================================================--

local WalkSpeedFrame = Instance.new("Frame")

WalkSpeedFrame.Size =
	UDim2.new(1, -10, 0, 38)

WalkSpeedFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

WalkSpeedFrame.BorderSizePixel = 0
WalkSpeedFrame.Parent = Scroll

local WalkMinus = Instance.new("TextButton")

WalkMinus.Size =
	UDim2.fromOffset(36, 30)

WalkMinus.Position =
	UDim2.fromOffset(4, 4)

WalkMinus.Text = "-"
WalkMinus.TextSize = 18
WalkMinus.Font = Enum.Font.GothamBold
WalkMinus.TextColor3 =
	Color3.new(1, 1, 1)

WalkMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

WalkMinus.BorderSizePixel = 0
WalkMinus.Parent = WalkSpeedFrame

local WalkSpeedLabel = Instance.new("TextLabel")

WalkSpeedLabel.Size =
	UDim2.new(1, -88, 1, 0)

WalkSpeedLabel.Position =
	UDim2.fromOffset(44, 0)

WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text =
	"WALK SPEED: 30"

WalkSpeedLabel.TextColor3 =
	Color3.new(1, 1, 1)

WalkSpeedLabel.TextSize = 10
WalkSpeedLabel.Font =
	Enum.Font.GothamBold

WalkSpeedLabel.Parent = WalkSpeedFrame

local WalkPlus = Instance.new("TextButton")

WalkPlus.Size =
	UDim2.fromOffset(36, 30)

WalkPlus.Position =
	UDim2.new(1, -40, 0, 4)

WalkPlus.Text = "+"
WalkPlus.TextSize = 18
WalkPlus.Font = Enum.Font.GothamBold
WalkPlus.TextColor3 =
	Color3.new(1, 1, 1)

WalkPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

WalkPlus.BorderSizePixel = 0
WalkPlus.Parent = WalkSpeedFrame

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

local NoclipButton =
	CreateButton("NOCLIP: OFF")

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

RunService.Stepped:Connect(function()

	if not Character then
		return
	end

	for _, Part in ipairs(
		Character:GetDescendants()
	) do

		if Part:IsA("BasePart") then

			Part.CanCollide =
				not NoclipEnabled

		end

	end

end)

--========================================================--
-- ESP
--========================================================--

local ESPButton =
	CreateButton("ESP: ON")

ESPButton.BackgroundColor3 =
	Color3.fromRGB(35, 150, 70)

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

	for _, Data in pairs(
		ESPObjects
	) do

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
-- AIMBOT / FOV
--========================================================--

local AimbotButton =
	CreateButton("AIMBOT: OFF")

--========================================================--
-- CONTROLES DO FOV
--========================================================--

local FOVFrame = Instance.new("Frame")

FOVFrame.Size =
	UDim2.new(1, -10, 0, 38)

FOVFrame.BackgroundColor3 =
	Color3.fromRGB(55, 15, 90)

FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = Scroll

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius =
	UDim.new(0, 8)
FOVCorner.Parent = FOVFrame

local FOVMinus = Instance.new("TextButton")

FOVMinus.Size =
	UDim2.fromOffset(36, 30)

FOVMinus.Position =
	UDim2.fromOffset(4, 4)

FOVMinus.Text = "-"
FOVMinus.TextSize = 18
FOVMinus.Font = Enum.Font.GothamBold
FOVMinus.TextColor3 =
	Color3.new(1, 1, 1)

FOVMinus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FOVMinus.BorderSizePixel = 0
FOVMinus.Parent = FOVFrame

local FOVMinusCorner = Instance.new("UICorner")
FOVMinusCorner.CornerRadius = UDim.new(0, 7)
FOVMinusCorner.Parent = FOVMinus

local FOVLabel = Instance.new("TextLabel")

FOVLabel.Size =
	UDim2.new(1, -88, 1, 0)

FOVLabel.Position =
	UDim2.fromOffset(44, 0)

FOVLabel.BackgroundTransparency = 1
FOVLabel.Text =
	"FOV: " .. AimbotFOV

FOVLabel.TextColor3 =
	Color3.new(1, 1, 1)

FOVLabel.TextSize = 11
FOVLabel.Font =
	Enum.Font.GothamBold

FOVLabel.Parent = FOVFrame

local FOVPlus = Instance.new("TextButton")

FOVPlus.Size =
	UDim2.fromOffset(36, 30)

FOVPlus.Position =
	UDim2.new(1, -40, 0, 4)

FOVPlus.Text = "+"
FOVPlus.TextSize = 18
FOVPlus.Font = Enum.Font.GothamBold
FOVPlus.TextColor3 =
	Color3.new(1, 1, 1)

FOVPlus.BackgroundColor3 =
	Color3.fromRGB(100, 35, 150)

FOVPlus.BorderSizePixel = 0
FOVPlus.Parent = FOVFrame

local FOVPlusCorner = Instance.new("UICorner")
FOVPlusCorner.CornerRadius = UDim.new(0, 7)
FOVPlusCorner.Parent = FOVPlus

local function UpdateFOVSize()
	FOVGui.Size =
		UDim2.fromOffset(
			AimbotFOV * 2,
			AimbotFOV * 2
		)

	FOVLabel.Text =
		"FOV: " .. AimbotFOV
end

FOVMinus.Activated:Connect(function()
	AimbotFOV =
		math.max(
			20,
			AimbotFOV - 10
		)

	UpdateFOVSize()
end)

FOVPlus.Activated:Connect(function()
	AimbotFOV =
		math.min(
			300,
			AimbotFOV + 10
		)

	UpdateFOVSize()
end)

-- Círculo de FOV usando UI normal
local FOVGui = Instance.new("Frame")

FOVGui.Name = "AimbotFOV"
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

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius =
	UDim.new(1, 0)
FOVCorner.Parent = FOVGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.4
FOVStroke.Color =
	Color3.fromRGB(255, 255, 0)
FOVStroke.Parent = FOVGui

UpdateFOVSize()

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
					TargetCharacter:FindFirstChildOfClass(
						"Humanoid"
					)

				local Head =
					TargetCharacter:FindFirstChild("Head")

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

						if Distance < ClosestDistance then

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
-- AIMBOT BUTTON
--========================================================--

AimbotButton.Activated:Connect(function()

	AimbotEnabled =
		not AimbotEnabled

	FOVGui.Visible =
		AimbotEnabled

	if AimbotEnabled then

		AimbotButton.Text =
			"AIMBOT: ON"

		AimbotButton.BackgroundColor3 =
			Color3.fromRGB(35, 150, 70)

	else

		AimbotButton.Text =
			"AIMBOT: OFF"

		AimbotButton.BackgroundColor3 =
			Color3.fromRGB(55, 15, 90)

	end

end)

--========================================================--
-- AIMBOT
--========================================================--

RunService.RenderStepped:Connect(function()

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

end)

--========================================================--
-- FLY / JOYSTICK
--========================================================--

RunService.RenderStepped:Connect(function()

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
			Root.Position + LookDirection
		)

end)

--========================================================--
-- ÍCONE
--========================================================--

local OpenButton =
	Instance.new("ImageButton")

OpenButton.Name =
	"CafeinaIcon"

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
OpenButton.ZIndex = 20
OpenButton.Parent = Gui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(0, 12)

OpenCorner.Parent =
	OpenButton

--========================================================--
-- ARRASTAR MENU / ÍCONE
--========================================================--

local function MakeDraggable(Object)

	local Dragging = false
	local DragStart
	local StartPosition

	Object.InputBegan:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.Touch
			or Input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

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

	end)

	UserInputService.InputEnded:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.Touch
			or Input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

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
-- ATUALIZA SCROLL AUTOMATICAMENTE
--========================================================--

Layout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(function()

	Scroll.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			Layout.AbsoluteContentSize.Y + 15
		)

end)

--========================================================--
-- RESPAWN
--========================================================--

Player.CharacterAdded:Connect(function(NewCharacter)

	Character = NewCharacter

	Humanoid =
		NewCharacter:WaitForChild(
			"Humanoid"
		)

	Root =
		NewCharacter:WaitForChild(
			"HumanoidRootPart"
		)

	StopFly()

	FlyEnabled = false

	FlyButton.Text =
		"FLY: OFF"

	FlyButton.BackgroundColor3 =
		Color3.fromRGB(55, 15, 90)

	UpdateWalkSpeed()

	if NoclipEnabled then

		for _, Part in ipairs(
			NewCharacter:GetDescendants()
		) do

			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end

		end

	end

end)

--========================================================--
-- FIM
--========================================================--
