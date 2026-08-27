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
		math.clamp(viewportForUI.X - 24, 430, 680),
		math.clamp(viewportForUI.Y - 90, 300, 520)
	)

	pcall(function()
		Library:SetDPIScale(85)
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
	ShowMobileButtons = true,
	MobileButtonsSide = "Right",
	Resizable = not IS_MOBILE,
	EnableCompacting = true,
	SidebarCompacted = IS_MOBILE,
	UnlockMouseWhileOpen = true,
})
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
			MenuGroup:AddLabel("Use the floating mobile button to open/close the menu", true)
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
