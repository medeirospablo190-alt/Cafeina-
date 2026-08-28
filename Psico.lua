--========================================================--
--              CAFEÍNA ROBLOX • PSICOSENATICO
--========================================================--
-- Base: Beta.lua
-- Atualizações orientadas pelo scan Psicosenatico.json
--
-- MOVIMENTO
--   • Fly mobile/joystick corrigido
--   • Fly Speed
--   • Walk Speed
--   • Noclip com restauração do estado original
--
-- VISUAL
--   • ESP de jogadores
--   • ESP de Workspace.Soldiers
--   • Nome / tipo / time / arma / munição / vida / distância
--   • Cores por aliado/inimigo
--
-- COMBATE
--   • Aim Assist em jogadores e Soldiers
--   • FOV
--   • Team Check
--   • Visible Check (raycast)
--   • Head / Torso
--   • Força regulável e distância máxima
--   • Suavização de câmera
--
-- SEGURANÇA / ESTABILIDADE
--   • Limpeza de GUI/ESP anterior
--   • Conexões controladas
--   • Respawn robusto
--   • Atualização de ESP limitada para mobile
--   • Não depende de RemoteEvent/RemoteFunction inventado
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("CAFEÍNA: LocalPlayer não disponível.")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
    warn("CAFEÍNA: PlayerGui não encontrado.")
    return
end

-- Registro global de limpeza para evitar loops duplicados ao executar
-- a mesma versão novamente no mesmo cliente.
local CafeinaEnv = (getgenv and getgenv()) or _G

--========================================================--
-- KEY SYSTEM • CAFEÍNA
-- Chave de acesso: Cafeína
--========================================================--

local KEY_GUI_NAME = "CafeinaKeySystem"
local ACCESS_KEY = "Cafeína"

local oldKeyGui = PlayerGui:FindFirstChild(KEY_GUI_NAME)
if oldKeyGui then
    oldKeyGui:Destroy()
end

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = KEY_GUI_NAME
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.DisplayOrder = 999999
KeyGui.Parent = PlayerGui

local KeyOverlay = Instance.new("Frame")
KeyOverlay.Name = "Overlay"
KeyOverlay.Size = UDim2.fromScale(1, 1)
KeyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyOverlay.BackgroundTransparency = 0.18
KeyOverlay.BorderSizePixel = 0
KeyOverlay.Parent = KeyGui

local KeyMain = Instance.new("Frame")
KeyMain.Name = "KeyPanel"
KeyMain.Size = UDim2.fromOffset(250, 190)
KeyMain.AnchorPoint = Vector2.new(0.5, 0.5)
KeyMain.Position = UDim2.fromScale(0.5, 0.5)
KeyMain.BackgroundColor3 = Color3.fromRGB(6, 6, 7)
KeyMain.BorderSizePixel = 0
KeyMain.Parent = KeyOverlay

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 14)
KeyCorner.Parent = KeyMain

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 1.2
KeyStroke.Color = Color3.fromRGB(235, 235, 235)
KeyStroke.Transparency = 0.18
KeyStroke.Parent = KeyMain

local KeyBrand = Instance.new("TextLabel")
KeyBrand.Size = UDim2.new(1, -28, 0, 27)
KeyBrand.Position = UDim2.fromOffset(14, 13)
KeyBrand.BackgroundTransparency = 1
KeyBrand.Text = "CAFEÍNA  V1"
KeyBrand.TextXAlignment = Enum.TextXAlignment.Left
KeyBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBrand.TextSize = 17
KeyBrand.Font = Enum.Font.GothamBlack
KeyBrand.Parent = KeyMain

local KeySubtitle = Instance.new("TextLabel")
KeySubtitle.Size = UDim2.new(1, -28, 0, 18)
KeySubtitle.Position = UDim2.fromOffset(14, 39)
KeySubtitle.BackgroundTransparency = 1
KeySubtitle.Text = "ACESSO PROTEGIDO • DIGITE A CHAVE"
KeySubtitle.TextXAlignment = Enum.TextXAlignment.Left
KeySubtitle.TextColor3 = Color3.fromRGB(145, 145, 150)
KeySubtitle.TextSize = 8
KeySubtitle.Font = Enum.Font.GothamBold
KeySubtitle.Parent = KeyMain

local KeyBox = Instance.new("TextBox")
KeyBox.Name = "KeyInput"
KeyBox.Size = UDim2.new(1, -28, 0, 42)
KeyBox.Position = UDim2.fromOffset(14, 69)
KeyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderText = "Digite a chave..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(105, 105, 110)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.TextXAlignment = Enum.TextXAlignment.Left
KeyBox.Parent = KeyMain

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 9)
KeyBoxCorner.Parent = KeyBox

local KeyBoxStroke = Instance.new("UIStroke")
KeyBoxStroke.Thickness = 1
KeyBoxStroke.Color = Color3.fromRGB(255, 255, 255)
KeyBoxStroke.Transparency = 0.78
KeyBoxStroke.Parent = KeyBox

local KeyPadding = Instance.new("UIPadding")
KeyPadding.PaddingLeft = UDim.new(0, 12)
KeyPadding.PaddingRight = UDim.new(0, 12)
KeyPadding.Parent = KeyBox

local KeyButton = Instance.new("TextButton")
KeyButton.Name = "Validate"
KeyButton.Size = UDim2.new(1, -28, 0, 38)
KeyButton.Position = UDim2.fromOffset(14, 120)
KeyButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
KeyButton.BorderSizePixel = 0
KeyButton.Text = "ENTRAR"
KeyButton.TextColor3 = Color3.fromRGB(5, 5, 6)
KeyButton.TextSize = 12
KeyButton.Font = Enum.Font.GothamBold
KeyButton.AutoButtonColor = true
KeyButton.Parent = KeyMain

local KeyButtonCorner = Instance.new("UICorner")
KeyButtonCorner.CornerRadius = UDim.new(0, 9)
KeyButtonCorner.Parent = KeyButton

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -28, 0, 17)
KeyStatus.Position = UDim2.fromOffset(14, 164)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(170, 170, 175)
KeyStatus.TextSize = 10
KeyStatus.Font = Enum.Font.GothamMedium
KeyStatus.TextXAlignment = Enum.TextXAlignment.Center
KeyStatus.Parent = KeyMain

local KeyUnlocked = false
local KeyBusy = false

local function TrimKey(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function ValidateCafeinaKey()
    if KeyBusy or KeyUnlocked then
        return
    end

    KeyBusy = true

    if TrimKey(KeyBox.Text) == ACCESS_KEY then
        KeyUnlocked = true
        KeyStatus.Text = "✓ ACESSO LIBERADO"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyButton.Text = "LIBERADO"
        KeyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

        task.wait(0.35)
        if KeyGui then
            KeyGui:Destroy()
        end
    else
        KeyStatus.Text = "✕ CHAVE INCORRETA"
        KeyStatus.TextColor3 = Color3.fromRGB(210, 210, 215)
        KeyBox.Text = ""
        KeyBox:CaptureFocus()

        local originalPosition = KeyMain.Position
        for _ = 1, 2 do
            KeyMain.Position = originalPosition + UDim2.fromOffset(-5, 0)
            task.wait(0.035)
            KeyMain.Position = originalPosition + UDim2.fromOffset(5, 0)
            task.wait(0.035)
        end
        KeyMain.Position = originalPosition
        KeyBusy = false
    end
end

KeyButton.MouseButton1Click:Connect(ValidateCafeinaKey)
KeyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        ValidateCafeinaKey()
    end
end)

-- O restante do menu só é criado após a chave correta.
while not KeyUnlocked do
    task.wait(0.05)
end

if CafeinaEnv and type(CafeinaEnv.CAFEINA_V1_UNLOAD) == "function" then
    pcall(CafeinaEnv.CAFEINA_V1_UNLOAD)
    CafeinaEnv.CAFEINA_V1_UNLOAD = nil
end

--========================================================--
-- LIMPEZA DE INSTÂNCIAS ANTERIORES
--========================================================--

local OLD_GUI_NAMES = {
    "CafeinaRoblox",
    "CAFEINA_V1",
    "CafeinaPsicosenatico"
}

for _, guiName in ipairs(OLD_GUI_NAMES) do
    local old = PlayerGui:FindFirstChild(guiName)
    if old then
        old:Destroy()
    end
end

local oldESP = Workspace:FindFirstChild("CafeinaESP")
if oldESP then
    oldESP:Destroy()
end

--========================================================--
-- ESTADOS
--========================================================--

local Character
local Humanoid
local Root

local FlyEnabled = false
local WalkSpeedEnabled = false
local NoclipEnabled = false

local InfiniteJumpEnabled = false

-- Todas as opções começam DESATIVADAS.
local ESPEnabled = false
local ESPSoldiersEnabled = false
local ESPInfoEnabled = false
local WallBoxEnabled = false
local HitboxEnabled = false

local AimEnabled = false
local AimSoldiersEnabled = false
local TeamCheckEnabled = false
local VisibleCheckEnabled = false
local AimPartMode = "Head"

local FlySpeed = 50
local WalkSpeed = 30
local OriginalWalkSpeed = 16
local HitboxSize = 6
local AimFOV = 60 -- graus
local AimStrength = 0.30
local AimMaxDistance = 500

local Connections = {}
local PlayerConnections = {}
local SoldierConnections = {}
local NoclipOriginal = {}
local HitboxOriginal = {}
local ESPEntries = {}

local BodyVelocity
local BodyGyro

local ESP_UPDATE_INTERVAL = 0.12
local LastESPUpdate = 0

--========================================================--
-- UTILIDADES
--========================================================--

local function TrackConnection(connection)
    if connection then
        table.insert(Connections, connection)
    end
    return connection
end

local function DisconnectConnection(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function SafeAttr(instance, name)
    if not instance then
        return nil
    end

    local ok, value = pcall(function()
        return instance:GetAttribute(name)
    end)

    if ok then
        return value
    end

    return nil
end

local function GetHumanoid(model)
    if not model then
        return nil
    end
    return model:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(model)
    if not model then
        return nil
    end

    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function GetAimPart(model)
    if not model then
        return nil
    end

    if AimPartMode == "Head" then
        return model:FindFirstChild("Head") or GetRoot(model)
    end

    return model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or GetRoot(model)
end

local function GetTool(model)
    if not model then
        return nil
    end

    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end

    return nil
end

local function FormatNumber(value, decimals)
    value = tonumber(value)
    if not value then
        return "?"
    end

    decimals = decimals or 0
    local pow = 10 ^ decimals
    return tostring(math.floor(value * pow + 0.5) / pow)
end

local function GetWeaponData(model)
    local tool = GetTool(model)

    if tool then
        local ammo = SafeAttr(tool, "_ammo")
        local mag = SafeAttr(tool, "magazineSize")

        return {
            Name = tool.Name,
            Ammo = ammo,
            Magazine = mag,
            Damage = SafeAttr(tool, "damage"),
            Range = SafeAttr(tool, "range"),
            FireMode = SafeAttr(tool, "fireMode"),
            RateOfFire = SafeAttr(tool, "rateOfFire"),
            Spread = SafeAttr(tool, "spread"),
            Scope = SafeAttr(tool, "scope"),
            AimZoom = SafeAttr(tool, "aimZoom")
        }
    end

    -- Soldiers do scan expõem Gun/MagSize no próprio Model.
    local gun = SafeAttr(model, "Gun")
    if gun then
        return {
            Name = tostring(gun),
            Ammo = nil,
            Magazine = SafeAttr(model, "MagSize"),
            Damage = nil,
            Range = SafeAttr(model, "Range"),
            FireMode = nil,
            RateOfFire = SafeAttr(model, "FireRate"),
            Spread = nil,
            Scope = nil,
            AimZoom = nil
        }
    end

    return nil
end

local function GetLocalTeamName()
    if LocalPlayer.Team then
        return LocalPlayer.Team.Name
    end

    local teamAttr = SafeAttr(Character, "Team")
    if teamAttr then
        return tostring(teamAttr)
    end

    return nil
end

local function GetEntityTeam(entry)
    if entry.Kind == "Player" then
        local targetPlayer = entry.Player
        if targetPlayer and targetPlayer.Team then
            return targetPlayer.Team.Name
        end
        return nil
    end

    local team = SafeAttr(entry.Model, "Team")
    if team ~= nil then
        return tostring(team)
    end

    return nil
end

local function IsSameTeam(entry)
    if entry.Kind == "Player" then
        local targetPlayer = entry.Player
        return targetPlayer
            and LocalPlayer.Team ~= nil
            and targetPlayer.Team ~= nil
            and targetPlayer.Team == LocalPlayer.Team
    end

    local localTeam = GetLocalTeamName()
    local targetTeam = GetEntityTeam(entry)
    if localTeam and targetTeam then
        return string.lower(localTeam) == string.lower(targetTeam)
    end
    return false
end

local function IsFriendly(entry)
    return TeamCheckEnabled and IsSameTeam(entry)
end

local function IsAlive(model)
    local humanoid = GetHumanoid(model)
    return humanoid ~= nil and humanoid.Health > 0
end

local function DistanceToLocal(rootPart)
    if not rootPart or not Root then
        return math.huge
    end
    return (rootPart.Position - Root.Position).Magnitude
end

local function IsVisible(targetPart, targetModel)
    if not VisibleCheckEnabled then
        return true
    end

    local camera = Workspace.CurrentCamera
    if not camera or not targetPart then
        return false
    end

    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin

    if direction.Magnitude <= 0.001 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ignore = {}
    if Character then
        table.insert(ignore, Character)
    end
    if camera then
        table.insert(ignore, camera)
    end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return targetModel and result.Instance:IsDescendantOf(targetModel)
end

--========================================================--
-- CHARACTER / RESPAWN
--========================================================--

local function RestoreNoclip()
    for part, oldState in pairs(NoclipOriginal) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = oldState
            end)
        end
    end
    table.clear(NoclipOriginal)
end

local function StopFly()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    if Humanoid and Humanoid.Parent then
        Humanoid.PlatformStand = false
        Humanoid.AutoRotate = true
    end

    if Root and Root.Parent then
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function StartFly()
    if not Root or not Root.Parent or not Humanoid or Humanoid.Health <= 0 then
        return false
    end

    StopFly()

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "CafeinaFlyVelocity"
    BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    BodyVelocity.P = 15000
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = Root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "CafeinaFlyGyro"
    BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    BodyGyro.P = 15000
    BodyGyro.D = 500
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root

    Humanoid.PlatformStand = true
    Humanoid.AutoRotate = false
    return true
end

local function ApplyWalkSpeed()
    if Humanoid and Humanoid.Parent then
        Humanoid.WalkSpeed = WalkSpeedEnabled and WalkSpeed or OriginalWalkSpeed
    end
end

local function SetupCharacter(character)
    Character = character or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 10)
    Root = Character:WaitForChild("HumanoidRootPart", 10)

    if not Humanoid or not Root then
        warn("CAFEÍNA: personagem incompleto.")
        return
    end

    OriginalWalkSpeed = Humanoid.WalkSpeed
    RestoreNoclip()
    StopFly()
    ApplyWalkSpeed()
end

SetupCharacter(LocalPlayer.Character)

--========================================================--
-- ESP
--========================================================--

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "CafeinaESP"
ESPFolder.Parent = Workspace

local COLOR_ENEMY = Color3.fromRGB(255, 75, 75)
local COLOR_ALLY = Color3.fromRGB(80, 255, 145)
local COLOR_NEUTRAL = Color3.fromRGB(255, 215, 85)

local function DestroyESPEntry(key)
    local entry = ESPEntries[key]
    if not entry then
        return
    end

    if entry.Highlight then
        entry.Highlight:Destroy()
    end
    if entry.Billboard then
        entry.Billboard:Destroy()
    end

    ESPEntries[key] = nil
end

local function CreateESPEntry(key, model, kind, targetPlayer)
    if not model or not model.Parent then
        return nil
    end

    local root = GetRoot(model)
    local humanoid = GetHumanoid(model)

    if not root or not humanoid then
        return nil
    end

    DestroyESPEntry(key)

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(230, 92)
    billboard.StudsOffset = Vector3.new(0, 3.7, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextWrapped = false
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.15
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    local entry = {
        Key = key,
        Model = model,
        Root = root,
        Humanoid = humanoid,
        Kind = kind,
        Player = targetPlayer,
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }

    ESPEntries[key] = entry
    return entry
end

local function RegisterPlayerESP(targetPlayer)
    if targetPlayer == LocalPlayer then
        return
    end

    if PlayerConnections[targetPlayer] then
        for _, c in ipairs(PlayerConnections[targetPlayer]) do
            DisconnectConnection(c)
        end
    end

    PlayerConnections[targetPlayer] = {}

    local function refresh(character)
        task.defer(function()
            if character then
                character:WaitForChild("HumanoidRootPart", 5)
                character:WaitForChild("Humanoid", 5)
            end
            CreateESPEntry(targetPlayer, character, "Player", targetPlayer)
        end)
    end

    table.insert(PlayerConnections[targetPlayer], targetPlayer.CharacterAdded:Connect(refresh))
    table.insert(PlayerConnections[targetPlayer], targetPlayer.CharacterRemoving:Connect(function()
        DestroyESPEntry(targetPlayer)
    end))

    if targetPlayer.Character then
        refresh(targetPlayer.Character)
    end
end

local function UnregisterPlayerESP(targetPlayer)
    DestroyESPEntry(targetPlayer)

    local list = PlayerConnections[targetPlayer]
    if list then
        for _, c in ipairs(list) do
            DisconnectConnection(c)
        end
    end
    PlayerConnections[targetPlayer] = nil
end

local SoldiersFolder = Workspace:FindFirstChild("Soldiers")

local function IsValidSoldier(model)
    return model
        and model:IsA("Model")
        and GetHumanoid(model) ~= nil
        and GetRoot(model) ~= nil
end

local function RegisterSoldier(model)
    if not IsValidSoldier(model) then
        return
    end

    CreateESPEntry(model, model, "Soldier", nil)

    if SoldierConnections[model] then
        DisconnectConnection(SoldierConnections[model])
    end

    SoldierConnections[model] = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            DestroyESPEntry(model)
            DisconnectConnection(SoldierConnections[model])
            SoldierConnections[model] = nil
        end
    end)
end

local function ScanSoldiers()
    SoldiersFolder = Workspace:FindFirstChild("Soldiers")
    if not SoldiersFolder then
        return
    end

    for _, model in ipairs(SoldiersFolder:GetChildren()) do
        RegisterSoldier(model)
    end
end

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    RegisterPlayerESP(targetPlayer)
end

TrackConnection(Players.PlayerAdded:Connect(RegisterPlayerESP))
TrackConnection(Players.PlayerRemoving:Connect(UnregisterPlayerESP))

ScanSoldiers()

if SoldiersFolder then
    TrackConnection(SoldiersFolder.ChildAdded:Connect(function(child)
        task.wait(0.1)
        RegisterSoldier(child)
    end))

    TrackConnection(SoldiersFolder.ChildRemoved:Connect(function(child)
        DestroyESPEntry(child)
    end))
else
    -- Caso a pasta seja criada depois do script.
    TrackConnection(Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Soldiers" and child:IsA("Folder") then
            SoldiersFolder = child
            ScanSoldiers()
            TrackConnection(child.ChildAdded:Connect(function(soldier)
                task.wait(0.1)
                RegisterSoldier(soldier)
            end))
            TrackConnection(child.ChildRemoved:Connect(function(soldier)
                DestroyESPEntry(soldier)
            end))
        end
    end))
end

local function BuildESPText(entry)
    local model = entry.Model
    local humanoid = entry.Humanoid
    local root = entry.Root

    if not model or not model.Parent or not humanoid or not root then
        return nil
    end

    local friendly = IsSameTeam(entry)
    local team = GetEntityTeam(entry)
    local weapon = GetWeaponData(model)
    local distance = DistanceToLocal(root)

    local displayName
    if entry.Kind == "Player" and entry.Player then
        displayName = entry.Player.DisplayName
        if entry.Player.Name ~= entry.Player.DisplayName then
            displayName = displayName .. " (@" .. entry.Player.Name .. ")"
        end
    else
        displayName = model.Name
    end

    local kindLabel = entry.Kind == "Soldier" and "SOLDADO" or "PLAYER"
    local relation = friendly and "ALIADO" or (team and "INIMIGO" or "NEUTRO")

    local first = string.format("%s  [%s • %s]", displayName, kindLabel, relation)

    if not ESPInfoEnabled then
        return first, friendly
    end

    local hp = math.max(0, humanoid.Health)
    local maxHp = math.max(1, humanoid.MaxHealth)
    local second = string.format("HP %s/%s  •  %.0f studs", FormatNumber(hp, 0), FormatNumber(maxHp, 0), distance)

    if team then
        second = second .. "  •  " .. tostring(team)
    end

    local third = "Arma: desarmado"
    local fourth = nil

    if weapon then
        third = "Arma: " .. tostring(weapon.Name)

        if weapon.Ammo ~= nil or weapon.Magazine ~= nil then
            third = third .. "  •  " .. tostring(weapon.Ammo ~= nil and weapon.Ammo or "?")
                .. "/" .. tostring(weapon.Magazine ~= nil and weapon.Magazine or "?")
        end

        local details = {}
        if weapon.Damage ~= nil then
            table.insert(details, "DMG " .. FormatNumber(weapon.Damage, 1))
        end
        if weapon.FireMode ~= nil then
            table.insert(details, tostring(weapon.FireMode))
        end
        if weapon.Range ~= nil then
            table.insert(details, "R " .. FormatNumber(weapon.Range, 0))
        end
        if weapon.RateOfFire ~= nil then
            table.insert(details, "RPM " .. FormatNumber(weapon.RateOfFire, 0))
        end

        if #details > 0 then
            fourth = table.concat(details, "  •  ")
        end
    elseif entry.Kind == "Soldier" then
        local dps = SafeAttr(model, "DamagePerSecond")
        local range = SafeAttr(model, "Range")
        if dps ~= nil or range ~= nil then
            local details = {}
            if dps ~= nil then
                table.insert(details, "DPS " .. FormatNumber(dps, 1))
            end
            if range ~= nil then
                table.insert(details, "Range " .. FormatNumber(range, 0))
            end
            fourth = table.concat(details, "  •  ")
        end
    end

    local result = first .. "\n" .. second .. "\n" .. third
    if fourth then
        result = result .. "\n" .. fourth
    end

    return result, friendly
end

local function RestoreHitboxes()
    for part, original in pairs(HitboxOriginal) do
        if part and part.Parent then
            pcall(function()
                part.Size = original.Size
                part.Transparency = original.Transparency
                part.CanCollide = original.CanCollide
            end)
        end
    end
    table.clear(HitboxOriginal)
end

local function ApplyHitbox(entry)
    if not HitboxEnabled or IsSameTeam(entry) then
        return
    end

    local part = entry.Model and entry.Model:FindFirstChild("HumanoidRootPart")
    if not part or not part:IsA("BasePart") then
        return
    end

    if not HitboxOriginal[part] then
        HitboxOriginal[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            CanCollide = part.CanCollide
        }
    end

    part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    part.Transparency = 0.70
    part.CanCollide = false
end

local function UpdateESP()
    -- Reaplica as hitboxes a partir do estado original. Assim, ao mudar time,
    -- morrer, ocultar Soldiers ou trocar o tamanho, não ficam partes ampliadas.
    if HitboxEnabled then
        RestoreHitboxes()
    end

    for key, entry in pairs(ESPEntries) do
        local model = entry.Model
        local humanoid = entry.Humanoid
        local root = entry.Root

        if not model or not model.Parent or not humanoid or not root or not root.Parent then
            DestroyESPEntry(key)
        else
            local showKind = entry.Kind ~= "Soldier" or ESPSoldiersEnabled
            local alive = humanoid.Health > 0
            local baseVisible = showKind and alive

            -- Caixa/Highlight pode ser usada separadamente do texto do ESP.
            entry.Highlight.Enabled = WallBoxEnabled and baseVisible
            entry.Billboard.Enabled = ESPEnabled and baseVisible

            local sameTeam = IsSameTeam(entry)
            local teamKnown = GetEntityTeam(entry) ~= nil and GetLocalTeamName() ~= nil
            local color = sameTeam and COLOR_ALLY or (teamKnown and COLOR_ENEMY or COLOR_NEUTRAL)

            entry.Highlight.OutlineColor = color
            entry.Highlight.FillColor = color
            entry.Highlight.FillTransparency = 0.82
            entry.Label.TextColor3 = color

            if entry.Billboard.Enabled then
                local text = BuildESPText(entry)
                entry.Label.Text = text or model.Name
            end

            if HitboxEnabled and baseVisible then
                ApplyHitbox(entry)
            end
        end
    end

    if not HitboxEnabled then
        RestoreHitboxes()
    end
end

--========================================================--
-- AIM TARGET • BASEADO NO ÂNGULO DA CÂMERA
--========================================================--

local function GetClosestTarget()
    local camera = Workspace.CurrentCamera
    if not camera then
        return nil
    end

    local cameraPosition = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector

    local closestPart = nil
    local smallestAngle = AimFOV

    for _, entry in pairs(ESPEntries) do
        local model = entry.Model
        local humanoid = entry.Humanoid

        if model and humanoid and humanoid.Health > 0 then
            local allowedKind = entry.Kind == "Player"
                or (entry.Kind == "Soldier" and AimSoldiersEnabled)

            local friendly = IsFriendly(entry)

            if allowedKind and (not TeamCheckEnabled or not friendly) then
                local targetPart = GetAimPart(model)

                if targetPart and targetPart:IsA("BasePart") then
                    local offset = targetPart.Position - cameraPosition
                    local distance = offset.Magnitude

                    if distance > 0.001 and distance <= AimMaxDistance then
                        local direction = offset / distance

                        -- Evita erros raros do acos por imprecisão de ponto flutuante.
                        local dot = math.clamp(cameraLook:Dot(direction), -1, 1)
                        local angle = math.deg(math.acos(dot))

                        if angle < smallestAngle then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)

                            if onScreen and screenPos.Z > 0 and IsVisible(targetPart, model) then
                                smallestAngle = angle
                                closestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPart
end

--========================================================--
-- GUI • CAFEÍNA V1 • COMPACTO / ACCORDION
-- Mantém 250 x 360 e usa seções expansíveis.
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaPsicosenatico"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local BG = Color3.fromRGB(6, 6, 7)
local PANEL = Color3.fromRGB(12, 12, 14)
local CONTROL_COLOR = Color3.fromRGB(18, 18, 21)
local OFF_COLOR = Color3.fromRGB(14, 14, 16)
local ON_COLOR = Color3.fromRGB(245, 245, 245)
local TEXT_PRIMARY = Color3.fromRGB(245, 245, 245)
local TEXT_MUTED = Color3.fromRGB(145, 145, 150)
local DANGER_COLOR = Color3.fromRGB(70, 18, 18)

local function AddCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 9)
    c.Parent = obj
    return c
end

local function AddStroke(obj, transparency)
    local st = Instance.new("UIStroke")
    st.Thickness = 1
    st.Color = Color3.fromRGB(255,255,255)
    st.Transparency = transparency or 0.78
    st.Parent = obj
    return st
end

local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"
Menu.Size = UDim2.fromOffset(250, 360)
Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.fromScale(0.5, 0.5)
Menu.BackgroundColor3 = BG
Menu.BorderSizePixel = 0
Menu.Parent = Gui
AddCorner(Menu, 14)
AddStroke(Menu, 0.28)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = Menu

local Brand = Instance.new("TextLabel")
Brand.Size = UDim2.new(1, -54, 0, 24)
Brand.Position = UDim2.fromOffset(14, 9)
Brand.BackgroundTransparency = 1
Brand.Text = "CAFEÍNA V1"
Brand.TextColor3 = TEXT_PRIMARY
Brand.TextSize = 17
Brand.Font = Enum.Font.GothamBlack
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -54, 0, 14)
Sub.Position = UDim2.fromOffset(14, 31)
Sub.BackgroundTransparency = 1
Sub.Text = "MOBILE • CONTROLE • PRECISÃO"
Sub.TextColor3 = TEXT_MUTED
Sub.TextSize = 8
Sub.Font = Enum.Font.GothamBold
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30,30)
CloseButton.Position = UDim2.new(1,-39,0,11)
CloseButton.BackgroundColor3 = CONTROL_COLOR
CloseButton.BorderSizePixel = 0
CloseButton.Text = "—"
CloseButton.TextColor3 = TEXT_PRIMARY
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header
AddCorner(CloseButton, 8)
AddStroke(CloseButton, 0.72)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Content"
Scroll.Position = UDim2.fromOffset(8, 54)
Scroll.Size = UDim2.new(1, -16, 1, -62)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(225,225,225)
Scroll.CanvasSize = UDim2.new()
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = Menu

local RootLayout = Instance.new("UIListLayout")
RootLayout.Padding = UDim.new(0, 6)
RootLayout.SortOrder = Enum.SortOrder.LayoutOrder
RootLayout.Parent = Scroll

local RootPad = Instance.new("UIPadding")
RootPad.PaddingBottom = UDim.new(0,8)
RootPad.Parent = Scroll

local function SetToggleButton(button, label, state)
    button.Text = label .. (state and "   ON" or "   OFF")
    button.BackgroundColor3 = state and ON_COLOR or OFF_COLOR
    button.TextColor3 = state and Color3.fromRGB(5,5,6) or TEXT_PRIMARY
end

local function MakeButton(parent, text, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,height or 36)
    b.BackgroundColor3 = OFF_COLOR
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = TEXT_PRIMARY
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = parent
    AddCorner(b,8)
    AddStroke(b,0.84)
    return b
end

local function MakeStepper(parent, label, getValue, minusCallback, plusCallback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,38)
    frame.BackgroundColor3 = OFF_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = parent
    AddCorner(frame,8)
    AddStroke(frame,0.86)

    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(1,-82,1,0)
    value.Position = UDim2.fromOffset(8,0)
    value.BackgroundTransparency = 1
    value.TextColor3 = TEXT_PRIMARY
    value.TextSize = 10
    value.Font = Enum.Font.GothamBold
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.Parent = frame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromOffset(32,28)
    minus.Position = UDim2.new(1,-72,0,5)
    minus.BackgroundColor3 = CONTROL_COLOR
    minus.BorderSizePixel = 0
    minus.Text = "−"
    minus.TextColor3 = TEXT_PRIMARY
    minus.TextSize = 17
    minus.Font = Enum.Font.GothamBold
    minus.Parent = frame
    AddCorner(minus,7)

    local plus = minus:Clone()
    plus.Position = UDim2.new(1,-36,0,5)
    plus.Text = "+"
    plus.Parent = frame

    local function refresh()
        value.Text = label .. "   " .. tostring(getValue())
    end
    refresh()
    minus.Activated:Connect(function() minusCallback(); refresh() end)
    plus.Activated:Connect(function() plusCallback(); refresh() end)
    return frame, value, refresh
end

local function MakeAccordion(title, icon)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1,-4,0,44)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = Scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,5)
    layout.Parent = wrapper

    local head = MakeButton(wrapper, (icon or "") .. "  " .. string.upper(title) .. "   ›", 40)
    head.TextXAlignment = Enum.TextXAlignment.Left
    local hp = Instance.new("UIPadding")
    hp.PaddingLeft = UDim.new(0,12)
    hp.Parent = head

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,0,0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundColor3 = PANEL
    body.BorderSizePixel = 0
    body.Visible = false
    body.Parent = wrapper
    AddCorner(body,9)
    AddStroke(body,0.90)

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0,5)
    bodyLayout.Parent = body
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,6)
    pad.PaddingBottom = UDim.new(0,6)
    pad.PaddingLeft = UDim.new(0,6)
    pad.PaddingRight = UDim.new(0,6)
    pad.Parent = body

    local expanded = false
    local function setExpanded(v)
        expanded = v
        body.Visible = expanded
        head.Text = (icon or "") .. "  " .. string.upper(title) .. (expanded and "   ▼" or "   ›")
    end
    head.Activated:Connect(function()
        setExpanded(not expanded)
    end)
    return body, setExpanded
end

-- MOVIMENTO
local MovementBody = MakeAccordion("Movimento", "↗")
local NoclipButton = MakeButton(MovementBody, "NOCLIP   OFF")
local FlyButton = MakeButton(MovementBody, "FLY   OFF")
MakeStepper(MovementBody, "FLY SPEED", function() return FlySpeed end,
    function() FlySpeed = math.max(10, FlySpeed-10) end,
    function() FlySpeed = math.min(300, FlySpeed+10) end)
local WalkButton = MakeButton(MovementBody, "WALK SPEED   OFF")
MakeStepper(MovementBody, "WALK SPEED", function() return WalkSpeed end,
    function() WalkSpeed = math.max(16, WalkSpeed-5); ApplyWalkSpeed() end,
    function() WalkSpeed = math.min(200, WalkSpeed+5); ApplyWalkSpeed() end)
local InfiniteJumpButton = MakeButton(MovementBody, "INFINITE JUMP   OFF")

NoclipButton.Activated:Connect(function()
    NoclipEnabled = not NoclipEnabled
    if not NoclipEnabled then RestoreNoclip() end
    SetToggleButton(NoclipButton,"NOCLIP",NoclipEnabled)
end)
FlyButton.Activated:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then if not StartFly() then FlyEnabled=false end else StopFly() end
    SetToggleButton(FlyButton,"FLY",FlyEnabled)
end)
WalkButton.Activated:Connect(function()
    WalkSpeedEnabled = not WalkSpeedEnabled
    ApplyWalkSpeed()
    SetToggleButton(WalkButton,"WALK SPEED",WalkSpeedEnabled)
end)
InfiniteJumpButton.Activated:Connect(function()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    SetToggleButton(InfiniteJumpButton,"INFINITE JUMP",InfiniteJumpEnabled)
end)

-- VISUAL
local VisualBody = MakeAccordion("Visual", "◉")
local ESPButton = MakeButton(VisualBody,"ESP   OFF")
local ESPInfoButton = MakeButton(VisualBody,"ESP INFO   OFF")
local ESPSoldiersButton = MakeButton(VisualBody,"ESP SOLDADOS   OFF")
local WallBoxButton = MakeButton(VisualBody,"CAIXA ATRAVÉS DA PAREDE   OFF")
local HitboxButton = MakeButton(VisualBody,"HITBOX   OFF")
MakeStepper(VisualBody,"HITBOX SIZE",function() return HitboxSize end,
    function() HitboxSize=math.max(3,HitboxSize-1); if HitboxEnabled then RestoreHitboxes(); UpdateESP() end end,
    function() HitboxSize=math.min(20,HitboxSize+1); if HitboxEnabled then RestoreHitboxes(); UpdateESP() end end)

ESPButton.Activated:Connect(function() ESPEnabled=not ESPEnabled; SetToggleButton(ESPButton,"ESP",ESPEnabled); UpdateESP() end)
ESPInfoButton.Activated:Connect(function() ESPInfoEnabled=not ESPInfoEnabled; SetToggleButton(ESPInfoButton,"ESP INFO",ESPInfoEnabled); UpdateESP() end)
ESPSoldiersButton.Activated:Connect(function() ESPSoldiersEnabled=not ESPSoldiersEnabled; SetToggleButton(ESPSoldiersButton,"ESP SOLDADOS",ESPSoldiersEnabled); UpdateESP() end)
WallBoxButton.Activated:Connect(function() WallBoxEnabled=not WallBoxEnabled; SetToggleButton(WallBoxButton,"CAIXA ATRAVÉS DA PAREDE",WallBoxEnabled); UpdateESP() end)
HitboxButton.Activated:Connect(function() HitboxEnabled=not HitboxEnabled; if not HitboxEnabled then RestoreHitboxes() end; SetToggleButton(HitboxButton,"HITBOX",HitboxEnabled); UpdateESP() end)

local Legend = Instance.new("TextLabel")
Legend.Size = UDim2.new(1,0,0,34)
Legend.BackgroundTransparency = 1
Legend.Text = "ALIADO = VERDE  •  INIMIGO = VERMELHO\nNEUTRO = AMARELO"
Legend.TextColor3 = TEXT_MUTED
Legend.TextSize = 8
Legend.Font = Enum.Font.GothamBold
Legend.Parent = VisualBody

-- COMBATE
local CombatBody = MakeAccordion("Combate", "⌖")
local AimButton = MakeButton(CombatBody,"AIMBOT   OFF")
local AimSoldiersButton = MakeButton(CombatBody,"AIM SOLDADOS   OFF")
local TeamCheckButton = MakeButton(CombatBody,"TEAM CHECK   OFF")
local VisibleCheckButton = MakeButton(CombatBody,"VISIBLE CHECK   OFF")
local AimPartButton = MakeButton(CombatBody,"ALVO   HEAD")

local FOVGui = Instance.new("Frame")
FOVGui.Name = "AimbotFOV"
FOVGui.AnchorPoint = Vector2.new(0.5,0.5)
FOVGui.Position = UDim2.fromScale(0.5,0.5)
FOVGui.BackgroundTransparency = 1
FOVGui.BorderSizePixel = 0
FOVGui.Visible = false
FOVGui.ZIndex = 10
FOVGui.Parent = Gui
AddCorner(FOVGui,999)
local FOVStroke = AddStroke(FOVGui,0.30)
FOVStroke.Thickness=1.2

local function UpdateFOVCircle()
    local camera=Workspace.CurrentCamera
    if not camera then return end
    local viewport=camera.ViewportSize
    local radius=(AimFOV/120)*math.min(viewport.X,viewport.Y)*0.80
    radius=math.clamp(radius,30,400)
    FOVGui.Size=UDim2.fromOffset(radius*2,radius*2)
end

MakeStepper(CombatBody,"FOV °",function() return AimFOV end,
    function() AimFOV=math.max(10,AimFOV-5); UpdateFOVCircle() end,
    function() AimFOV=math.min(120,AimFOV+5); UpdateFOVCircle() end)
MakeStepper(CombatBody,"FORÇA %",function() return math.floor(AimStrength*100+0.5) end,
    function() AimStrength=math.max(0.05,AimStrength-0.05) end,
    function() AimStrength=math.min(1,AimStrength+0.05) end)
MakeStepper(CombatBody,"DISTÂNCIA",function() return AimMaxDistance end,
    function() AimMaxDistance=math.max(50,AimMaxDistance-50) end,
    function() AimMaxDistance=math.min(3000,AimMaxDistance+50) end)

AimButton.Activated:Connect(function() AimEnabled=not AimEnabled; FOVGui.Visible=AimEnabled; SetToggleButton(AimButton,"AIMBOT",AimEnabled); UpdateFOVCircle() end)
AimSoldiersButton.Activated:Connect(function() AimSoldiersEnabled=not AimSoldiersEnabled; SetToggleButton(AimSoldiersButton,"AIM SOLDADOS",AimSoldiersEnabled) end)
TeamCheckButton.Activated:Connect(function() TeamCheckEnabled=not TeamCheckEnabled; SetToggleButton(TeamCheckButton,"TEAM CHECK",TeamCheckEnabled) end)
VisibleCheckButton.Activated:Connect(function() VisibleCheckEnabled=not VisibleCheckEnabled; SetToggleButton(VisibleCheckButton,"VISIBLE CHECK",VisibleCheckEnabled) end)
AimPartButton.Activated:Connect(function() AimPartMode=AimPartMode=="Head" and "Torso" or "Head"; AimPartButton.Text="ALVO   "..string.upper(AimPartMode) end)

-- TELEPORT PARA ALIADO
local TeleportBody = MakeAccordion("Teleport aliado", "◎")
local AllyLabel = Instance.new("TextLabel")
AllyLabel.Size = UDim2.new(1,0,0,32)
AllyLabel.BackgroundColor3 = OFF_COLOR
AllyLabel.BorderSizePixel = 0
AllyLabel.TextColor3 = TEXT_PRIMARY
AllyLabel.TextSize = 10
AllyLabel.Font = Enum.Font.GothamBold
AllyLabel.Text = "ALIADO: nenhum"
AllyLabel.Parent = TeleportBody
AddCorner(AllyLabel,8)

local AllyRow = Instance.new("Frame")
AllyRow.Size=UDim2.new(1,0,0,36)
AllyRow.BackgroundTransparency=1
AllyRow.Parent=TeleportBody
local prev=MakeButton(AllyRow,"‹",36); prev.Size=UDim2.new(0.22,-3,1,0); prev.Position=UDim2.fromScale(0,0)
local tp=MakeButton(AllyRow,"TELEPORTAR",36); tp.Size=UDim2.new(0.56,-4,1,0); tp.Position=UDim2.new(0.22,3,0,0)
local nextb=MakeButton(AllyRow,"›",36); nextb.Size=UDim2.new(0.22,-3,1,0); nextb.Position=UDim2.new(0.78,3,0,0)
local allyIndex=1
local function GetAllies()
    local list={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and LocalPlayer.Team and plr.Team and plr.Team==LocalPlayer.Team then table.insert(list,plr) end
    end
    table.sort(list,function(a,b) return a.Name<b.Name end)
    return list
end
local function RefreshAlly()
    local allies=GetAllies()
    if #allies==0 then allyIndex=1; AllyLabel.Text="ALIADO: nenhum"; return nil end
    allyIndex=math.clamp(allyIndex,1,#allies)
    local plr=allies[allyIndex]
    AllyLabel.Text="ALIADO: "..plr.DisplayName.."  (@"..plr.Name..")"
    return plr
end
prev.Activated:Connect(function() local a=GetAllies(); if #a>0 then allyIndex=allyIndex-1; if allyIndex<1 then allyIndex=#a end end; RefreshAlly() end)
nextb.Activated:Connect(function() local a=GetAllies(); if #a>0 then allyIndex=allyIndex+1; if allyIndex>#a then allyIndex=1 end end; RefreshAlly() end)
tp.Activated:Connect(function()
    local ally=RefreshAlly()
    if not ally or not Root then return end
    local ch=ally.Character
    local ar=ch and GetRoot(ch)
    local ah=ch and GetHumanoid(ch)
    if ar and ah and ah.Health>0 then
        -- Pequeno deslocamento lateral para não sobrepor os dois personagens.
        Root.CFrame=ar.CFrame*CFrame.new(3,0,0)
    end
end)
TrackConnection(Players.PlayerAdded:Connect(function() task.defer(RefreshAlly) end))
TrackConnection(Players.PlayerRemoving:Connect(function() task.defer(RefreshAlly) end))
RefreshAlly()

-- JOGADOR / INFO
local PlayerBody = MakeAccordion("Jogador", "◇")
local KillButton = MakeButton(PlayerBody,"REGENERAR PERSONAGEM")
KillButton.BackgroundColor3=DANGER_COLOR
KillButton.Activated:Connect(function() if Humanoid and Humanoid.Parent then Humanoid.Health=0 end end)

local WeaponInfo = Instance.new("TextLabel")
WeaponInfo.Size = UDim2.new(1,0,0,58)
WeaponInfo.BackgroundColor3 = OFF_COLOR
WeaponInfo.BorderSizePixel = 0
WeaponInfo.TextColor3 = TEXT_PRIMARY
WeaponInfo.TextSize = 9
WeaponInfo.TextWrapped = true
WeaponInfo.Font = Enum.Font.GothamBold
WeaponInfo.Text = "ARMA: nenhuma equipada"
WeaponInfo.Parent = PlayerBody
AddCorner(WeaponInfo,8)

local function UpdateLocalWeaponInfo()
    local weapon=GetWeaponData(Character)
    if not weapon then WeaponInfo.Text="ARMA: nenhuma equipada"; return end
    local line="ARMA: "..tostring(weapon.Name)
    if weapon.Ammo~=nil or weapon.Magazine~=nil then line=line.."  |  "..tostring(weapon.Ammo or "?").."/"..tostring(weapon.Magazine or "?") end
    local d={}
    if weapon.Damage~=nil then table.insert(d,"DMG "..FormatNumber(weapon.Damage,1)) end
    if weapon.FireMode~=nil then table.insert(d,tostring(weapon.FireMode)) end
    if weapon.Range~=nil then table.insert(d,"R "..FormatNumber(weapon.Range,0)) end
    if weapon.RateOfFire~=nil then table.insert(d,"RPM "..FormatNumber(weapon.RateOfFire,0)) end
    WeaponInfo.Text=line..(#d>0 and "\n"..table.concat(d," • ") or "")
end

-- Infinite Jump: uma única conexão, controlada pelo toggle.
TrackConnection(UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled or not Humanoid or Humanoid.Health<=0 then return end
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end))

--========================================================--
-- LOOPS CONTROLADOS
--========================================================--

TrackConnection(RunService.Stepped:Connect(function()
    if not NoclipEnabled or not Character then
        return
    end

    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if NoclipOriginal[part] == nil then
                NoclipOriginal[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end))

TrackConnection(RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera

    if AimEnabled then
        UpdateFOVCircle()
    end

    -- Fly: usa direção de movimento do Humanoid e adiciona pitch da câmera
    -- quando o jogador está realmente avançando/recuando. Isso evita o bug
    -- clássico do joystick em que só "frente" funcionava corretamente.
    if FlyEnabled and Root and Humanoid and BodyVelocity and BodyGyro and camera then
        if Humanoid.Health <= 0 or not Root.Parent then
            FlyEnabled = false
            StopFly()
            SetToggleButton(FlyButton, "FLY", false)
        else
            local move = Humanoid.MoveDirection
            local velocity = Vector3.zero

            if move.Magnitude > 0.05 then
                local flatMove = Vector3.new(move.X, 0, move.Z)
                if flatMove.Magnitude > 0.05 then
                    flatMove = flatMove.Unit
                end

                local look = camera.CFrame.LookVector
                local flatLook = Vector3.new(look.X, 0, look.Z)
                if flatLook.Magnitude < 0.001 then
                    flatLook = Vector3.new(0, 0, -1)
                else
                    flatLook = flatLook.Unit
                end

                -- Quanto mais o input aponta para frente/trás da câmera,
                -- mais o pitch da câmera participa do voo.
                local forwardAmount = flatMove:Dot(flatLook)
                local vertical = look.Y * forwardAmount
                local direction = Vector3.new(flatMove.X, vertical, flatMove.Z)

                if direction.Magnitude > 0.05 then
                    velocity = direction.Unit * FlySpeed
                end
            end

            BodyVelocity.Velocity = velocity

            local lookDirection = camera.CFrame.LookVector
            if lookDirection.Magnitude > 0.001 then
                BodyGyro.CFrame = CFrame.lookAt(Root.Position, Root.Position + lookDirection)
            end
        end
    end

    if AimEnabled and camera then
        local target = GetClosestTarget()
        if target then
            local desired = CFrame.lookAt(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(AimStrength, 0.05, 1))
        end
    end
end))

TrackConnection(RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - LastESPUpdate >= ESP_UPDATE_INTERVAL then
        LastESPUpdate = now
        UpdateESP()
        UpdateLocalWeaponInfo()
    end
end))

--========================================================--
-- ÍCONE / DRAG MOBILE
--========================================================--

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "CafeinaIcon"
OpenButton.Size = UDim2.fromOffset(55, 55)
OpenButton.AnchorPoint = Vector2.new(0.5, 0.5)
OpenButton.Position = UDim2.fromScale(0.5, 0.5)
OpenButton.BackgroundColor3 = Color3.fromRGB(8, 8, 9)
OpenButton.BorderSizePixel = 0
OpenButton.Image = "rbxassetid://91715286435585"
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.Visible = false
OpenButton.ZIndex = 20
OpenButton.Parent = Gui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton
AddStroke(OpenButton, 0.45)

local function MakeDraggable(handle, object)
    local dragging = false
    local dragStart
    local startPosition
    local activeInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = object.Position
            activeInput = input
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragStart or not startPosition then
            return
        end

        if input == activeInput
            or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseMovement
                and input.UserInputType == Enum.UserInputType.MouseMovement) then

            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))

    TrackConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            activeInput = nil
        end
    end))
end

MakeDraggable(Header, Menu)
MakeDraggable(OpenButton, OpenButton)

CloseButton.Activated:Connect(function()
    Menu.Visible = false
    OpenButton.Visible = true
end)

OpenButton.Activated:Connect(function()
    OpenButton.Visible = false
    Menu.Visible = true
end)

--========================================================--
-- SCROLL AUTOMÁTICO
--========================================================--

local function RefreshCanvas()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, RootLayout.AbsoluteContentSize.Y + 20)
end

RootLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshCanvas)
task.defer(RefreshCanvas)

--========================================================--
-- RESPAWN
--========================================================--

TrackConnection(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    RestoreNoclip()
    RestoreHitboxes()
    StopFly()

    FlyEnabled = false
    SetToggleButton(FlyButton, "FLY", false)

    SetupCharacter(newCharacter)
    ApplyWalkSpeed()

    if NoclipEnabled then
        task.defer(function()
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if NoclipOriginal[part] == nil then
                            NoclipOriginal[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end))

--========================================================--
-- UNLOAD / REEXECUÇÃO SEGURA
--========================================================--

if CafeinaEnv then
    CafeinaEnv.CAFEINA_V1_UNLOAD = function()
        FlyEnabled = false
        WalkSpeedEnabled = false
        NoclipEnabled = false
        InfiniteJumpEnabled = false
        ESPEnabled = false
        ESPSoldiersEnabled = false
        ESPInfoEnabled = false
        WallBoxEnabled = false
        HitboxEnabled = false
        AimEnabled = false

        pcall(RestoreNoclip)
        pcall(RestoreHitboxes)
        pcall(StopFly)
        pcall(ApplyWalkSpeed)

        for _, connection in ipairs(Connections) do
            DisconnectConnection(connection)
        end
        table.clear(Connections)

        for player, list in pairs(PlayerConnections) do
            for _, connection in ipairs(list) do
                DisconnectConnection(connection)
            end
            PlayerConnections[player] = nil
        end

        for soldier, connection in pairs(SoldierConnections) do
            DisconnectConnection(connection)
            SoldierConnections[soldier] = nil
        end

        if ESPFolder and ESPFolder.Parent then
            ESPFolder:Destroy()
        end
        if Gui and Gui.Parent then
            Gui:Destroy()
        end
    end
end

--========================================================--
-- INICIALIZAÇÃO FINAL
--========================================================--

UpdateFOVCircle()
UpdateESP()
UpdateLocalWeaponInfo()

print("CAFEÍNA • Psicosenatico carregado.")
