--============================================================--
-- Mine a Mountain - Mobile Patch
-- Base original: DonnieAzoff / 2RanmaChan2
-- Adaptacao mobile: menu touch, fly por joystick/camera,
-- Aim Teleport e Instant Grab por botoes.
--============================================================--

local SOURCE_URL =
	"https://gist.githubusercontent.com/2RanmaChan2/d85484e7ff26eadee63e20f9069d8581/raw/1185a00d955831be354d47d6d8a79349288ba59f/Mine%2520a%2520Mountain%2520by%2520DonnieAzoff"

local function notifyConsole(...)
	print("[Mine a Mountain Mobile]", ...)
end

local function replaceOnce(source, old, new, label)
	local first, last = string.find(source, old, 1, true)
	if not first then
		warn("[Mine a Mountain Mobile] Patch nao encontrado:", label)
		return source, false
	end

	return string.sub(source, 1, first - 1)
		.. new
		.. string.sub(source, last + 1), true
end

local okDownload, source = pcall(function()
	return game:HttpGet(SOURCE_URL .. "?mobile_patch=" .. tostring(os.time()))
end)

if not okDownload or type(source) ~= "string" or #source < 1000 then
	error("Nao foi possivel baixar o script original: " .. tostring(source))
end

notifyConsole("Original baixado:", #source, "bytes")

--============================================================--
-- 1) DETECCAO MOBILE + JANELA RESPONSIVA
--============================================================--

local oldWindow = [[
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
local Window = Library:CreateWindow({
	Title = "Mine a Mountain",
	Footer = "Mine a Mountain",
	AutoShow = true,
	NotifySide = "Right",
	ShowCustomCursor = false,
})
]]

local newWindow = [[
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local IS_MOBILE =
	UserInputService.TouchEnabled
	and not UserInputService.KeyboardEnabled

local cameraForUI = Workspace.CurrentCamera
local viewportForUI =
	cameraForUI and cameraForUI.ViewportSize
	or Vector2.new(800, 600)

local windowSize

if IS_MOBILE then
	windowSize = UDim2.fromOffset(
		math.clamp(viewportForUI.X - 16, 420, 700),
		math.clamp(viewportForUI.Y - 72, 320, 560)
	)

	pcall(function()
		Library:SetDPIScale(90)
	end)
else
	windowSize = UDim2.fromOffset(720, 600)
end

local Window = Library:CreateWindow({
	Title = IS_MOBILE and "Mine a Mountain • Mobile" or "Mine a Mountain",
	Footer = IS_MOBILE and "Mobile Edition" or "Mine a Mountain",
	Size = windowSize,
	AutoShow = true,
	Center = true,
	NotifySide = "Right",
	ShowCustomCursor = false,
	ShowMobileButtons = false,
	MobileButtonsSide = "Right",
	Resizable = not IS_MOBILE,
	EnableCompacting = true,
	SidebarCompacted = IS_MOBILE,
	UnlockMouseWhileOpen = true,
})

--========================================================--
-- CONTROLES MOBILE PERSONALIZADOS
-- Botao "-" no canto do menu + icone flutuante arrastavel
--========================================================--

if IS_MOBILE then
	local mobileGui = Instance.new("ScreenGui")
	mobileGui.Name = "MineMountainMobileControls"
	mobileGui.ResetOnSpawn = false
	mobileGui.IgnoreGuiInset = true
	mobileGui.DisplayOrder = 10000

	local parentOk = false
	pcall(function()
		local targetParent =
			(type(gethui) == "function" and gethui())
			or game:GetService("CoreGui")
		mobileGui.Parent = targetParent
		parentOk = true
	end)

	if not parentOk then
		mobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local restoreButton = Instance.new("TextButton")
	restoreButton.Name = "RestoreIcon"
	restoreButton.Size = UDim2.fromOffset(58, 58)
	restoreButton.Position = UDim2.new(1, -72, 0.5, -29)
	restoreButton.AnchorPoint = Vector2.new(0, 0)
	restoreButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	restoreButton.BorderSizePixel = 0
	restoreButton.Text = "⛰"
	restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	restoreButton.TextSize = 26
	restoreButton.Font = Enum.Font.GothamBold
	restoreButton.AutoButtonColor = true
	restoreButton.Visible = false
	restoreButton.ZIndex = 10002
	restoreButton.Parent = mobileGui

	local restoreCorner = Instance.new("UICorner")
	restoreCorner.CornerRadius = UDim.new(1, 0)
	restoreCorner.Parent = restoreButton

	local restoreStroke = Instance.new("UIStroke")
	restoreStroke.Thickness = 2
	restoreStroke.Color = Color3.fromRGB(125, 85, 255)
	restoreStroke.Transparency = 0.15
	restoreStroke.Parent = restoreButton

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.Size = UDim2.fromOffset(42, 34)
	minimizeButton.AnchorPoint = Vector2.new(1, 0)
	minimizeButton.Position = UDim2.new(1, -8, 0, 7)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Text = "−"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 25
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.AutoButtonColor = true
	minimizeButton.ZIndex = 10001

	if Window and Window.MainFrame then
		minimizeButton.Parent = Window.MainFrame
	else
		minimizeButton.Parent = mobileGui
		minimizeButton.Position = UDim2.new(1, -12, 0, 12)
	end

	local minimizeCorner = Instance.new("UICorner")
	minimizeCorner.CornerRadius = UDim.new(0, 8)
	minimizeCorner.Parent = minimizeButton

	local minimized = false

	local function setMinimized(value)
		minimized = value == true

		pcall(function()
			Window:Toggle(not minimized)
		end)

		restoreButton.Visible = minimized
	end

	minimizeButton.MouseButton1Click:Connect(function()
		setMinimized(true)
	end)

	restoreButton.MouseButton1Click:Connect(function()
		setMinimized(false)
	end)

	-- Arrasto touch/mouse do icone flutuante
	local dragging = false
	local dragStart
	local startPos
	local activeInput

	restoreButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then

			dragging = true
			dragStart = input.Position
			startPos = restoreButton.Position
			activeInput = input

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					activeInput = nil
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local delta = input.Position - dragStart
		local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
			or Vector2.new(800, 600)

		local x = math.clamp(startPos.X.Offset + delta.X, 8, viewport.X - 66)
		local y = math.clamp(startPos.Y.Offset + delta.Y, 8, viewport.Y - 66)

		restoreButton.Position = UDim2.fromOffset(x, y)
	end)

	-- Mantem o icone sincronizado se o menu for aberto por outro metodo
	task.spawn(function()
		while mobileGui.Parent and not Library.Unloaded do
			task.wait(0.25)
			if minimized and Library.Toggled then
				minimized = false
				restoreButton.Visible = false
			end
		end
	end)
end
]]

source = select(1, replaceOnce(source, oldWindow, newWindow, "janela mobile"))

--============================================================--
-- 2) FLY MOBILE - JOYSTICK + DIRECAO DA CAMERA
--============================================================--

local oldFlyDirection = [[
			local frame = camera.CFrame
			local direction = Vector3.zero
			if not UserInputService:GetFocusedTextBox() then
				for _, entry in ipairs(FLY_KEYS) do
					if UserInputService:IsKeyDown(entry.key) then
						if entry.axis == "look" then
							direction += frame.LookVector * entry.sign
						elseif entry.axis == "right" then
							direction += frame.RightVector * entry.sign
						else
							direction += Vector3.yAxis * entry.sign
						end
					end
				end
			end
			if direction.Magnitude > 0.1 then
				velocity.Velocity = direction.Unit * flySpeed
			else
				velocity.Velocity = Vector3.zero
			end

			local flat = Vector3.new(frame.LookVector.X, 0, frame.LookVector.Z)
			if flat.Magnitude > 0.05 then
				gyro.CFrame = CFrame.new(root.Position, root.Position + flat)
			end
]]

local newFlyDirection = [[
			local frame = camera.CFrame
			local direction = Vector3.zero

			if not UserInputService:GetFocusedTextBox() then
				-- PC / teclado
				if UserInputService.KeyboardEnabled then
					for _, entry in ipairs(FLY_KEYS) do
						if UserInputService:IsKeyDown(entry.key) then
							if entry.axis == "look" then
								direction += frame.LookVector * entry.sign
							elseif entry.axis == "right" then
								direction += frame.RightVector * entry.sign
							else
								direction += Vector3.yAxis * entry.sign
							end
						end
					end
				end

				-- Mobile / joystick:
				-- andar para frente faz o personagem voar
				-- exatamente para onde a camera esta apontando.
				if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
					local move = humanoid.MoveDirection

					local flatLook = Vector3.new(
						frame.LookVector.X,
						0,
						frame.LookVector.Z
					)

					local flatRight = Vector3.new(
						frame.RightVector.X,
						0,
						frame.RightVector.Z
					)

					if flatLook.Magnitude > 0.001 then
						flatLook = flatLook.Unit
					else
						flatLook = Vector3.new(0, 0, -1)
					end

					if flatRight.Magnitude > 0.001 then
						flatRight = flatRight.Unit
					else
						flatRight = Vector3.xAxis
					end

					local forwardAmount = move:Dot(flatLook)
					local rightAmount = move:Dot(flatRight)

					direction += frame.LookVector * forwardAmount
					direction += frame.RightVector * rightAmount
				end
			end

			if direction.Magnitude > 0.1 then
				velocity.Velocity = direction.Unit * flySpeed
			else
				velocity.Velocity = Vector3.zero
			end

			-- Faz o personagem acompanhar a direcao da camera,
			-- inclusive olhando para cima/baixo.
			if frame.LookVector.Magnitude > 0.05 then
				gyro.CFrame = CFrame.lookAt(
					root.Position,
					root.Position + frame.LookVector,
					Vector3.yAxis
				)
			end
]]

source = select(1, replaceOnce(source, oldFlyDirection, newFlyDirection, "fly mobile"))

--============================================================--
-- 3) AIM TELEPORT - BOTAO TOUCH
--============================================================--

local oldAimPicker = [[
		TeleportBox:AddLabel("Aim Teleport"):AddKeyPicker("AimTeleportKey", {
			Default = "F",
			NoUI = false,
			Text = "Aim Teleport",
			Mode = "Always",
		})

		TeleportBox:AddDivider()
]]

local newAimPicker = [[
		if IS_MOBILE then
			TeleportBox:AddButton("Aim Teleport Now", function()
				if not aimTpEnabled then
					Library:Notify("Enable Aim Teleport first", 2)
					return
				end

				local ok, err = pcall(aimTeleport)
				if not ok then
					reportError("mobileAimTeleport", err)
				end
			end)
		else
			TeleportBox:AddLabel("Aim Teleport"):AddKeyPicker("AimTeleportKey", {
				Default = "F",
				NoUI = false,
				Text = "Aim Teleport",
				Mode = "Always",
			})
		end

		TeleportBox:AddDivider()
]]

source = select(1, replaceOnce(source, oldAimPicker, newAimPicker, "aim teleport touch"))

--============================================================--
-- 4) INSTANT PROMPT - BOTAO TOUCH
--============================================================--

local oldInstantPrompt = [[
		PickupBox:AddToggle("InstantPrompt", {
			Text = "Instant Prompt",
			Default = false,
			Callback = setInstantPrompt,
		})

		PickupBox:AddToggle("AutoRunePickup", {
]]

local newInstantPrompt = [[
		PickupBox:AddToggle("InstantPrompt", {
			Text = "Instant Prompt",
			Default = false,
			Callback = setInstantPrompt,
		})

		if IS_MOBILE then
			PickupBox:AddButton("Instant Grab Now", function()
				if not instantPromptActive then
					Library:Notify("Enable Instant Prompt first", 2)
					return
				end

				local ok, err = pcall(instantGrab)
				if not ok then
					reportError("mobileInstantGrab", err)
				end
			end)
		end

		PickupBox:AddToggle("AutoRunePickup", {
]]

source = select(1, replaceOnce(source, oldInstantPrompt, newInstantPrompt, "instant grab touch"))

--============================================================--
-- 5) MENU SETTINGS MOBILE
-- Mantem RightControl no PC; no mobile o botao flutuante da
-- Obsidian fica responsavel por abrir/fechar.
--============================================================--

local oldMenuSettings = [[
		local MenuGroup = SettingsTab:AddRightGroupbox("Menu", "wrench")
		MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
			Default = "RightControl",
			NoUI = true,
			Text = "Menu keybind",
		})

		MenuGroup:AddButton("Unload", function()
]]

local newMenuSettings = [[
		local MenuGroup = SettingsTab:AddRightGroupbox("Menu", "wrench")

		if IS_MOBILE then
			MenuGroup:AddLabel("Use − para minimizar e o icone flutuante para restaurar.", true)
		else
			MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
				Default = "RightControl",
				NoUI = true,
				Text = "Menu keybind",
			})
		end

		MenuGroup:AddButton("Unload", function()
]]

source = select(1, replaceOnce(source, oldMenuSettings, newMenuSettings, "menu mobile"))

-- A linha abaixo dependia obrigatoriamente de MenuKeybind.
-- Em mobile a opcao nao existe, entao atribuimos somente no PC.
local oldToggleBind = [[
Library.ToggleKeybind = Library.Options.MenuKeybind
ThemeManager:ApplyToTab(SettingsTab)
]]

local newToggleBind = [[
if not IS_MOBILE then
	Library.ToggleKeybind = Library.Options.MenuKeybind
end
ThemeManager:ApplyToTab(SettingsTab)
]]

source = select(1, replaceOnce(source, oldToggleBind, newToggleBind, "toggle keybind mobile"))

--============================================================--
-- 6) COMPILE / EXECUTE
--============================================================--

notifyConsole("Patches aplicados. Compilando...")

local compiled, compileErr = loadstring(source)

if not compiled then
	error(
		"Erro ao compilar a versao mobile:\n"
		.. tostring(compileErr)
	)
end

local okRun, runtimeErr = pcall(compiled)

if not okRun then
	error(
		"Erro durante a execucao da versao mobile:\n"
		.. tostring(runtimeErr)
	)
end

notifyConsole("Versao mobile executada.")
