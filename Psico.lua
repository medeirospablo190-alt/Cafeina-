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
-- TELEPORT
--   • Lista lateral de todos os jogadores
--   • Aliados verdes / inimigos vermelhos
--   • Clique no nome para teleportar
--   • Teleporte instantâneo em uma única operação
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

-- Bootstrap defensivo: se esta linha aparecer no console, a compilação passou.
print("[CAFEINA] Bootstrap iniciado")


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
local CafeinaEnv = _G
if type(getgenv) == "function" then
    local okEnv, customEnv = pcall(getgenv)
    if okEnv and type(customEnv) == "table" then
        CafeinaEnv = customEnv
    end
end

--========================================================--
-- KEY SYSTEM • CAFEÍNA
-- Chave de acesso: Cafeína
--========================================================--

local function RunCafeinaKeySystem()
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
end

RunCafeinaKeySystem()

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
Gui.DisplayOrder = 999998
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
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
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
    -- Estrutura com altura explícita. Isso evita o comportamento em que o
    -- ScrollingFrame reposicionava a seção e dava a impressão de abrir
    -- para cima em alguns executores/mobile.
    local CLOSED_HEIGHT = 40
    local GAP = 5
    local PAD_Y = 12

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1,-4,0,CLOSED_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.ClipsDescendants = false
    wrapper.Parent = Scroll

    local head = MakeButton(wrapper, (icon or "") .. "  " .. string.upper(title) .. "   ›", CLOSED_HEIGHT)
    head.Position = UDim2.fromOffset(0,0)
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.ZIndex = 2

    local hp = Instance.new("UIPadding")
    hp.PaddingLeft = UDim.new(0,12)
    hp.Parent = head

    local body = Instance.new("Frame")
    body.Position = UDim2.fromOffset(0, CLOSED_HEIGHT + GAP)
    body.Size = UDim2.new(1,0,0,0)
    body.BackgroundColor3 = PANEL
    body.BorderSizePixel = 0
    body.Visible = false
    body.ClipsDescendants = true
    body.Parent = wrapper
    AddCorner(body,9)
    AddStroke(body,0.90)

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0,5)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Parent = body

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,6)
    pad.PaddingBottom = UDim.new(0,6)
    pad.PaddingLeft = UDim.new(0,6)
    pad.PaddingRight = UDim.new(0,6)
    pad.Parent = body

    local expanded = false

    local function contentHeight()
        return math.max(0, bodyLayout.AbsoluteContentSize.Y + PAD_Y)
    end

    local function applyHeight(preserveHeader)
        local oldHeaderY = head.AbsolutePosition.Y
        local oldCanvas = Scroll.CanvasPosition
        local h = expanded and contentHeight() or 0

        body.Size = UDim2.new(1,0,0,h)
        wrapper.Size = UDim2.new(1,-4,0,CLOSED_HEIGHT + (expanded and (GAP + h) or 0))

        -- Força o layout a terminar antes de restaurar a posição visual do
        -- cabeçalho. Assim a expansão sempre ocupa espaço abaixo dele.
        task.defer(function()
            if not wrapper.Parent then return end
            Scroll.CanvasSize = UDim2.new(0,0,0,RootLayout.AbsoluteContentSize.Y + 20)
            if preserveHeader and expanded then
                local delta = head.AbsolutePosition.Y - oldHeaderY
                if math.abs(delta) > 0.5 then
                    local maxY = math.max(0, Scroll.AbsoluteCanvasSize.Y - Scroll.AbsoluteWindowSize.Y)
                    Scroll.CanvasPosition = Vector2.new(oldCanvas.X, math.clamp(oldCanvas.Y + delta, 0, maxY))
                else
                    Scroll.CanvasPosition = oldCanvas
                end
            end
        end)
    end

    local function setExpanded(v)
        expanded = v == true
        body.Visible = expanded
        head.Text = (icon or "") .. "  " .. string.upper(title) .. (expanded and "   ▼" or "   ›")
        applyHeight(true)
    end

    bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if expanded then
            applyHeight(false)
        end
    end)

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

-- TELEPORT • LISTA DE TODOS OS JOGADORES
-- Diferente das outras categorias, TELEPORT não expande uma aba.
-- Tocar nele abre diretamente o painel lateral de jogadores.
-- Verde = aliado, vermelho = inimigo, cinza = time não identificado.
local OpenTeleportListButton = MakeButton(Scroll, "◎  TELEPORT   ›", 40)
OpenTeleportListButton.Size = UDim2.new(1,-4,0,40)
OpenTeleportListButton.TextXAlignment = Enum.TextXAlignment.Left

local TeleportButtonPadding = Instance.new("UIPadding")
TeleportButtonPadding.PaddingLeft = UDim.new(0,12)
TeleportButtonPadding.Parent = OpenTeleportListButton

-- Painel lateral com prioridade visual alta sobre as GUIs do próprio jogo.
local TeleportPanel = Instance.new("Frame")
TeleportPanel.Name = "TeleportPlayerPanel"
TeleportPanel.Size = UDim2.fromOffset(222, 326)
TeleportPanel.Position = UDim2.fromOffset(8, 72)
TeleportPanel.BackgroundColor3 = BG
TeleportPanel.BorderSizePixel = 0
TeleportPanel.Visible = false
TeleportPanel.ZIndex = 200
TeleportPanel.Parent = Gui
AddCorner(TeleportPanel, 13)
local TeleportPanelStroke = AddStroke(TeleportPanel, 0.22)
TeleportPanelStroke.Thickness = 1.2

local TeleportHeader = Instance.new("Frame")
TeleportHeader.Size = UDim2.new(1,0,0,52)
TeleportHeader.BackgroundTransparency = 1
TeleportHeader.ZIndex = 201
TeleportHeader.Parent = TeleportPanel

local TeleportTitle = Instance.new("TextLabel")
TeleportTitle.Size = UDim2.new(1,-52,0,23)
TeleportTitle.Position = UDim2.fromOffset(12,8)
TeleportTitle.BackgroundTransparency = 1
TeleportTitle.Text = "TELEPORT"
TeleportTitle.TextColor3 = TEXT_PRIMARY
TeleportTitle.TextSize = 15
TeleportTitle.Font = Enum.Font.GothamBlack
TeleportTitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportTitle.ZIndex = 202
TeleportTitle.Parent = TeleportHeader

local TeleportSubtitle = Instance.new("TextLabel")
TeleportSubtitle.Size = UDim2.new(1,-52,0,15)
TeleportSubtitle.Position = UDim2.fromOffset(12,29)
TeleportSubtitle.BackgroundTransparency = 1
TeleportSubtitle.Text = "TOQUE NO NOME PARA IR ATÉ ELE"
TeleportSubtitle.TextColor3 = TEXT_MUTED
TeleportSubtitle.TextSize = 7
TeleportSubtitle.Font = Enum.Font.GothamBold
TeleportSubtitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportSubtitle.ZIndex = 202
TeleportSubtitle.Parent = TeleportHeader

local CloseTeleportButton = Instance.new("TextButton")
CloseTeleportButton.Size = UDim2.fromOffset(32,32)
CloseTeleportButton.Position = UDim2.new(1,-42,0,10)
CloseTeleportButton.BackgroundColor3 = CONTROL_COLOR
CloseTeleportButton.BorderSizePixel = 0
CloseTeleportButton.Text = "×"
CloseTeleportButton.TextColor3 = TEXT_PRIMARY
CloseTeleportButton.TextSize = 19
CloseTeleportButton.Font = Enum.Font.GothamBold
CloseTeleportButton.ZIndex = 203
CloseTeleportButton.Parent = TeleportHeader
AddCorner(CloseTeleportButton,8)
AddStroke(CloseTeleportButton,0.70)

local TeleportLegend = Instance.new("TextLabel")
TeleportLegend.Size = UDim2.new(1,-20,0,20)
TeleportLegend.Position = UDim2.fromOffset(10,51)
TeleportLegend.BackgroundTransparency = 1
TeleportLegend.Text = "● ALIADO     ● INIMIGO"
TeleportLegend.TextColor3 = TEXT_MUTED
TeleportLegend.TextSize = 8
TeleportLegend.Font = Enum.Font.GothamBold
TeleportLegend.TextXAlignment = Enum.TextXAlignment.Left
TeleportLegend.ZIndex = 202
TeleportLegend.Parent = TeleportPanel

local TeleportList = Instance.new("ScrollingFrame")
TeleportList.Name = "Players"
TeleportList.Position = UDim2.fromOffset(8,73)
TeleportList.Size = UDim2.new(1,-16,1,-81)
TeleportList.BackgroundTransparency = 1
TeleportList.BorderSizePixel = 0
TeleportList.ScrollBarThickness = 3
TeleportList.ScrollBarImageColor3 = Color3.fromRGB(235,235,235)
TeleportList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TeleportList.CanvasSize = UDim2.new()
TeleportList.ScrollingDirection = Enum.ScrollingDirection.Y
TeleportList.ZIndex = 201
TeleportList.Parent = TeleportPanel

local TeleportListLayout = Instance.new("UIListLayout")
TeleportListLayout.Padding = UDim.new(0,5)
TeleportListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TeleportListLayout.Parent = TeleportList

local TeleportListPad = Instance.new("UIPadding")
TeleportListPad.PaddingBottom = UDim.new(0,5)
TeleportListPad.Parent = TeleportList

local ALLY_TP_COLOR = Color3.fromRGB(28, 105, 58)
local ENEMY_TP_COLOR = Color3.fromRGB(120, 34, 38)
local NEUTRAL_TP_COLOR = Color3.fromRGB(42, 42, 47)

local TeleportBusyToken = 0
local TeleportPanelOpen = false
local LastTeleportListRefresh = 0

local function PlayerRelation(player)
    if not player or player == LocalPlayer then
        return "Self"
    end
    if LocalPlayer.Team and player.Team then
        return player.Team == LocalPlayer.Team and "Ally" or "Enemy"
    end
    return "Neutral"
end

local function StopCharacterMotion(character)
    if not character then return end
    local root = GetRoot(character)
    if root and root:IsA("BasePart") then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

-- Configuração do acompanhamento do teleporte.
-- O acompanhamento continua enquanto o alvo estiver vivo.
-- Quando o alvo morrer/resetar, o personagem local volta ao ponto onde iniciou o TP.
local TeleportBehindDistance = 7.0

-- Durante o acompanhamento, a câmera também mantém a mira no alvo.
-- 1 = acompanha instantaneamente; valores menores deixam mais suave.
local TeleportAimStrength = 1.0

-- Faz a pose da arma/braço acompanhar verticalmente o alvo durante o TP.
-- O giro horizontal continua sendo feito pelo PivotTo/CFrame.lookAt do personagem.
-- Funciona com R6 e R15 sem depender do nome/modelo específico da arma.
local function GetTeleportAimShoulders(character)
    if not character then
        return nil, nil
    end

    local torso =
        character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")

    if not torso then
        return nil, nil
    end

    local rightShoulder =
        torso:FindFirstChild("RightShoulder")
        or torso:FindFirstChild("Right Shoulder")

    local leftShoulder =
        torso:FindFirstChild("LeftShoulder")
        or torso:FindFirstChild("Left Shoulder")

    return rightShoulder, leftShoulder
end

local function HasEquippedTool(character)
    if not character then
        return false
    end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return true
        end
    end

    return false
end

local function ApplyTeleportWeaponAim(character, targetPosition, aimState)
    if not character or typeof(targetPosition) ~= "Vector3" then
        return
    end

    if not HasEquippedTool(character) then
        return
    end

    local root = GetRoot(character)
    if not root then
        return
    end

    local rightShoulder, leftShoulder = GetTeleportAimShoulders(character)
    if not rightShoulder then
        return
    end

    if not aimState.Saved then
        aimState.Saved = true
        aimState.RightShoulder = rightShoulder
        aimState.RightTransform = rightShoulder.Transform

        if leftShoulder then
            aimState.LeftShoulder = leftShoulder
            aimState.LeftTransform = leftShoulder.Transform
        end
    end

    -- Como o Root já está virado horizontalmente para o alvo,
    -- basta calcular a inclinação vertical até Head/Root do jogador.
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local delta = targetPosition - origin

    if delta.Magnitude < 0.05 then
        return
    end

    local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local pitch = math.atan2(delta.Y, math.max(horizontal, 0.001))

    -- Limita a pose para não quebrar visualmente os braços.
    pitch = math.clamp(pitch, math.rad(-70), math.rad(70))

    -- RightShoulder segura a maioria das Tools.
    -- Mantém a animação base e acrescenta apenas a inclinação.
    if rightShoulder.Parent then
        rightShoulder.Transform =
            aimState.RightTransform
            * CFrame.Angles(-pitch, 0, 0)
    end

    -- Uma leve correção no braço esquerdo ajuda armas seguradas com duas mãos,
    -- sem forçar armas que usam somente o braço direito.
    if leftShoulder and leftShoulder.Parent then
        leftShoulder.Transform =
            aimState.LeftTransform
            * CFrame.Angles(-pitch * 0.75, 0, 0)
    end
end

local function RestoreTeleportWeaponAim(aimState)
    if not aimState or not aimState.Saved then
        return
    end

    if aimState.RightShoulder and aimState.RightShoulder.Parent then
        pcall(function()
            aimState.RightShoulder.Transform =
                aimState.RightTransform or CFrame.new()
        end)
    end

    if aimState.LeftShoulder and aimState.LeftShoulder.Parent then
        pcall(function()
            aimState.LeftShoulder.Transform =
                aimState.LeftTransform or CFrame.new()
        end)
    end

    aimState.Saved = false
end

local function TeleportToPlayer(player)
    if not player or player == LocalPlayer then
        return
    end

    local localCharacter = LocalPlayer.Character
    local localHumanoid = GetHumanoid(localCharacter)
    local localRoot = GetRoot(localCharacter)

    local targetCharacter = player.Character
    local targetHumanoid = GetHumanoid(targetCharacter)
    local targetRoot = GetRoot(targetCharacter)

    if not localCharacter or not localHumanoid or localHumanoid.Health <= 0 or not localRoot then
        return
    end

    if not targetCharacter or not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot then
        return
    end

    -- Cada novo TP cancela o acompanhamento anterior.
    TeleportBusyToken = TeleportBusyToken + 1
    local myToken = TeleportBusyToken

    -- Guarda exatamente a posição/orientação antes de iniciar o acompanhamento.
    local originalPivot = localCharacter:GetPivot()
    local originalTargetCharacter = targetCharacter

    -- Guarda a pose dos braços para restaurar quando o acompanhamento terminar.
    local teleportWeaponAimState = {}

    task.spawn(function()
        local shouldReturn = false

        while myToken == TeleportBusyToken do
            local currentCharacter = LocalPlayer.Character
            local currentHumanoid = GetHumanoid(currentCharacter)
            local currentRoot = GetRoot(currentCharacter)

            local currentTargetCharacter = player.Character

            -- Alvo resetou/trocou de Character.
            if currentTargetCharacter ~= originalTargetCharacter then
                shouldReturn = true
                break
            end

            local currentTargetHumanoid = GetHumanoid(currentTargetCharacter)
            local currentTargetRoot = GetRoot(currentTargetCharacter)

            -- Alvo morreu, foi removido ou perdeu as partes necessárias.
            if not currentTargetCharacter
                or not currentTargetCharacter.Parent
                or not currentTargetHumanoid
                or currentTargetHumanoid.Health <= 0
                or not currentTargetRoot
            then
                shouldReturn = true
                break
            end

            -- Se o próprio jogador local morreu/resetou, apenas encerra.
            if not currentCharacter
                or not currentCharacter.Parent
                or not currentHumanoid
                or currentHumanoid.Health <= 0
                or not currentRoot
            then
                shouldReturn = false
                break
            end

            -- +Z local = atrás do alvo.
            local behindPosition =
                (currentTargetRoot.CFrame * CFrame.new(
                    0,
                    0,
                    TeleportBehindDistance
                )).Position

            -- Fica atrás do alvo e sempre olhando para ele.
            local destination = CFrame.lookAt(
                behindPosition,
                currentTargetRoot.Position,
                Vector3.yAxis
            )

            currentRoot.AssemblyLinearVelocity = Vector3.zero
            currentRoot.AssemblyAngularVelocity = Vector3.zero
            currentCharacter:PivotTo(destination)

            -- Mantém a mira/câmera apontada para o jogador acompanhado.
            local currentCamera = Workspace.CurrentCamera
            if currentCamera then
                local cameraPosition = currentCamera.CFrame.Position
                local aimPosition =
                    currentTargetCharacter:FindFirstChild("Head")
                    and currentTargetCharacter.Head.Position
                    or currentTargetRoot.Position

                local desiredCamera = CFrame.lookAt(
                    cameraPosition,
                    aimPosition,
                    Vector3.yAxis
                )

                currentCamera.CFrame = currentCamera.CFrame:Lerp(
                    desiredCamera,
                    math.clamp(TeleportAimStrength, 0.01, 1)
                )
            end

            -- Mantém também a arma/braços apontados para o alvo.
            local weaponAimPosition =
                currentTargetCharacter:FindFirstChild("Head")
                and currentTargetCharacter.Head.Position
                or currentTargetRoot.Position

            ApplyTeleportWeaponAim(
                currentCharacter,
                weaponAimPosition,
                teleportWeaponAimState
            )

            RunService.RenderStepped:Wait()
        end

        -- Restaura a pose normal da arma/braços ao encerrar o acompanhamento.
        RestoreTeleportWeaponAim(teleportWeaponAimState)

        -- Só a instância de TP atualmente válida pode executar o retorno.
        if myToken ~= TeleportBusyToken then
            return
        end

        if shouldReturn then
            local returnCharacter = LocalPlayer.Character
            local returnHumanoid = GetHumanoid(returnCharacter)
            local returnRoot = GetRoot(returnCharacter)

            if returnCharacter
                and returnCharacter.Parent
                and returnHumanoid
                and returnHumanoid.Health > 0
                and returnRoot
            then
                returnRoot.AssemblyLinearVelocity = Vector3.zero
                returnRoot.AssemblyAngularVelocity = Vector3.zero

                -- Retorna em uma única operação para o ponto original.
                returnCharacter:PivotTo(originalPivot)

                local rootAfterReturn = GetRoot(returnCharacter)
                if rootAfterReturn then
                    rootAfterReturn.AssemblyLinearVelocity = Vector3.zero
                    rootAfterReturn.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end)
end

local function ClearTeleportRows()
    for _, child in ipairs(TeleportList:GetChildren()) do
        if child:IsA("GuiObject") and child.Name == "PlayerRow" then
            child:Destroy()
        end
    end
end

local function RefreshTeleportPlayers()
    if not TeleportPanelOpen or not TeleportPanel.Visible then
        return
    end

    ClearTeleportRows()

    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player)
        end
    end
    table.sort(list, function(a,b)
        local ra, rb = PlayerRelation(a), PlayerRelation(b)
        local order = {Ally=1, Enemy=2, Neutral=3, Self=4}
        if order[ra] ~= order[rb] then
            return order[ra] < order[rb]
        end
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)

    if #list == 0 then
        local empty = Instance.new("TextLabel")
        empty.Name = "PlayerRow"
        empty.Size = UDim2.new(1,0,0,42)
        empty.BackgroundColor3 = OFF_COLOR
        empty.BorderSizePixel = 0
        empty.Text = "Nenhum outro jogador"
        empty.TextColor3 = TEXT_MUTED
        empty.TextSize = 10
        empty.Font = Enum.Font.GothamBold
        empty.ZIndex = 202
        empty.Parent = TeleportList
        AddCorner(empty,8)
        return
    end

    for index, player in ipairs(list) do
        local relation = PlayerRelation(player)
        local background = relation == "Ally" and ALLY_TP_COLOR
            or relation == "Enemy" and ENEMY_TP_COLOR
            or NEUTRAL_TP_COLOR

        local row = Instance.new("TextButton")
        row.Name = "PlayerRow"
        row.LayoutOrder = index
        row.Size = UDim2.new(1,0,0,46)
        row.BackgroundColor3 = background
        row.BorderSizePixel = 0
        row.AutoButtonColor = true
        row.Text = ""
        row.ZIndex = 202
        row.Parent = TeleportList
        AddCorner(row,8)
        AddStroke(row,0.78)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1,-14,0,22)
        name.Position = UDim2.fromOffset(9,5)
        name.BackgroundTransparency = 1
        name.Text = player.DisplayName .. "  (@" .. player.Name .. ")"
        name.TextColor3 = Color3.fromRGB(255,255,255)
        name.TextSize = 10
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.ZIndex = 203
        name.Parent = row

        local team = Instance.new("TextLabel")
        team.Size = UDim2.new(1,-14,0,14)
        team.Position = UDim2.fromOffset(9,26)
        team.BackgroundTransparency = 1
        local teamName = player.Team and player.Team.Name or "Sem time"
        team.Text = (relation == "Ally" and "ALIADO" or relation == "Enemy" and "INIMIGO" or "NEUTRO") .. "  •  " .. teamName
        team.TextColor3 = Color3.fromRGB(225,225,225)
        team.TextSize = 7
        team.Font = Enum.Font.GothamBold
        team.TextXAlignment = Enum.TextXAlignment.Left
        team.ZIndex = 203
        team.Parent = row

        row.Activated:Connect(function()
            TeleportToPlayer(player)
        end)
    end
end

local function SetTeleportPanelVisible(value)
    TeleportPanelOpen = value == true
    TeleportPanel.Visible = TeleportPanelOpen
    if TeleportPanelOpen then
        RefreshTeleportPlayers()
    end
end

OpenTeleportListButton.Activated:Connect(function()
    SetTeleportPanelVisible(true)
end)
CloseTeleportButton.Activated:Connect(function()
    SetTeleportPanelVisible(false)
end)

TrackConnection(Players.PlayerAdded:Connect(function()
    if TeleportPanelOpen then task.defer(RefreshTeleportPlayers) end
end))
TrackConnection(Players.PlayerRemoving:Connect(function()
    if TeleportPanelOpen then task.defer(RefreshTeleportPlayers) end
end))
TrackConnection(RunService.Heartbeat:Connect(function()
    if TeleportPanelOpen and os.clock() - LastTeleportListRefresh >= 1 then
        LastTeleportListRefresh = os.clock()
        RefreshTeleportPlayers()
    end
end))


-- COLETA / COMPRAS
local function SetupEconomyPanel()
-- Adaptado à estrutura observada no scan Psicosenatico:
-- Workspace.Tycoons.<tycoon>.CoreBuild.Collector.Collect
-- Workspace.Tycoons.<tycoon>.Buttons.<compra>.Touch
-- Os Models de compra usam atributos como Owner, Price, Name,
-- Dependency, Gamepass e NonPurchase.

local OpenEconomyPanelButton = MakeButton(Scroll, "$  COLETA / COMPRAS   ›", 40)
OpenEconomyPanelButton.Size = UDim2.new(1,-4,0,40)
OpenEconomyPanelButton.TextXAlignment = Enum.TextXAlignment.Left

local EconomyButtonPadding = Instance.new("UIPadding")
EconomyButtonPadding.PaddingLeft = UDim.new(0,12)
EconomyButtonPadding.Parent = OpenEconomyPanelButton

local EconomyPanel = Instance.new("Frame")
EconomyPanel.Name = "EconomyPanel"
EconomyPanel.Size = UDim2.fromOffset(222,326)
EconomyPanel.Position = UDim2.fromOffset(8,72)
EconomyPanel.BackgroundColor3 = BG
EconomyPanel.BorderSizePixel = 0
EconomyPanel.Visible = false
EconomyPanel.ZIndex = 220
EconomyPanel.Parent = Gui
AddCorner(EconomyPanel,13)
local EconomyPanelStroke = AddStroke(EconomyPanel,0.22)
EconomyPanelStroke.Thickness = 1.2

local EconomyHeader = Instance.new("Frame")
EconomyHeader.Size = UDim2.new(1,0,0,52)
EconomyHeader.BackgroundTransparency = 1
EconomyHeader.ZIndex = 221
EconomyHeader.Parent = EconomyPanel

local EconomyTitle = Instance.new("TextLabel")
EconomyTitle.Size = UDim2.new(1,-52,0,23)
EconomyTitle.Position = UDim2.fromOffset(12,8)
EconomyTitle.BackgroundTransparency = 1
EconomyTitle.Text = "COLETA / COMPRAS"
EconomyTitle.TextColor3 = TEXT_PRIMARY
EconomyTitle.TextSize = 14
EconomyTitle.Font = Enum.Font.GothamBlack
EconomyTitle.TextXAlignment = Enum.TextXAlignment.Left
EconomyTitle.ZIndex = 222
EconomyTitle.Parent = EconomyHeader

local EconomySubtitle = Instance.new("TextLabel")
EconomySubtitle.Size = UDim2.new(1,-52,0,15)
EconomySubtitle.Position = UDim2.fromOffset(12,29)
EconomySubtitle.BackgroundTransparency = 1
EconomySubtitle.Text = "SEU TYCOON • SOMENTE MOEDA DO JOGO"
EconomySubtitle.TextColor3 = TEXT_MUTED
EconomySubtitle.TextSize = 7
EconomySubtitle.Font = Enum.Font.GothamBold
EconomySubtitle.TextXAlignment = Enum.TextXAlignment.Left
EconomySubtitle.ZIndex = 222
EconomySubtitle.Parent = EconomyHeader

local CloseEconomyButton = Instance.new("TextButton")
CloseEconomyButton.Size = UDim2.fromOffset(32,32)
CloseEconomyButton.Position = UDim2.new(1,-42,0,10)
CloseEconomyButton.BackgroundColor3 = CONTROL_COLOR
CloseEconomyButton.BorderSizePixel = 0
CloseEconomyButton.Text = "×"
CloseEconomyButton.TextColor3 = TEXT_PRIMARY
CloseEconomyButton.TextSize = 19
CloseEconomyButton.Font = Enum.Font.GothamBold
CloseEconomyButton.ZIndex = 223
CloseEconomyButton.Parent = EconomyHeader
AddCorner(CloseEconomyButton,8)
AddStroke(CloseEconomyButton,0.70)

local EconomyBody = Instance.new("Frame")
EconomyBody.Position = UDim2.fromOffset(8,58)
EconomyBody.Size = UDim2.new(1,-16,1,-66)
EconomyBody.BackgroundTransparency = 1
EconomyBody.ZIndex = 221
EconomyBody.Parent = EconomyPanel

local EconomyBodyLayout = Instance.new("UIListLayout")
EconomyBodyLayout.Padding = UDim.new(0,7)
EconomyBodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
EconomyBodyLayout.Parent = EconomyBody

local EconomyStatusCard = Instance.new("Frame")
EconomyStatusCard.LayoutOrder = 1
EconomyStatusCard.Size = UDim2.new(1,0,0,68)
EconomyStatusCard.BackgroundColor3 = CONTROL_COLOR
EconomyStatusCard.BorderSizePixel = 0
EconomyStatusCard.ZIndex = 222
EconomyStatusCard.Parent = EconomyBody
AddCorner(EconomyStatusCard,9)
AddStroke(EconomyStatusCard,0.78)

local EconomyStatusTitle = Instance.new("TextLabel")
EconomyStatusTitle.Size = UDim2.new(1,-16,0,20)
EconomyStatusTitle.Position = UDim2.fromOffset(8,7)
EconomyStatusTitle.BackgroundTransparency = 1
EconomyStatusTitle.Text = "STATUS"
EconomyStatusTitle.TextColor3 = TEXT_MUTED
EconomyStatusTitle.TextSize = 8
EconomyStatusTitle.Font = Enum.Font.GothamBold
EconomyStatusTitle.TextXAlignment = Enum.TextXAlignment.Left
EconomyStatusTitle.ZIndex = 223
EconomyStatusTitle.Parent = EconomyStatusCard

local EconomyStatus = Instance.new("TextLabel")
EconomyStatus.Size = UDim2.new(1,-16,0,32)
EconomyStatus.Position = UDim2.fromOffset(8,26)
EconomyStatus.BackgroundTransparency = 1
EconomyStatus.Text = "Pronto"
EconomyStatus.TextColor3 = TEXT_PRIMARY
EconomyStatus.TextSize = 10
EconomyStatus.Font = Enum.Font.GothamBold
EconomyStatus.TextWrapped = true
EconomyStatus.TextXAlignment = Enum.TextXAlignment.Left
EconomyStatus.TextYAlignment = Enum.TextYAlignment.Top
EconomyStatus.ZIndex = 223
EconomyStatus.Parent = EconomyStatusCard

local CollectMoneyButton = Instance.new("TextButton")
CollectMoneyButton.LayoutOrder = 2
CollectMoneyButton.Size = UDim2.new(1,0,0,52)
CollectMoneyButton.BackgroundColor3 = ON_COLOR
CollectMoneyButton.BorderSizePixel = 0
CollectMoneyButton.Text = "$  COLETAR DINHEIRO"
CollectMoneyButton.TextColor3 = Color3.fromRGB(12,12,12)
CollectMoneyButton.TextSize = 10
CollectMoneyButton.Font = Enum.Font.GothamBlack
CollectMoneyButton.ZIndex = 222
CollectMoneyButton.Parent = EconomyBody
AddCorner(CollectMoneyButton,9)

local BuyAllButton = Instance.new("TextButton")
BuyAllButton.LayoutOrder = 3
BuyAllButton.Size = UDim2.new(1,0,0,52)
BuyAllButton.BackgroundColor3 = ON_COLOR
BuyAllButton.BorderSizePixel = 0
BuyAllButton.Text = "▣  COMPRAR TUDO POSSÍVEL"
BuyAllButton.TextColor3 = Color3.fromRGB(12,12,12)
BuyAllButton.TextSize = 9
BuyAllButton.Font = Enum.Font.GothamBlack
BuyAllButton.ZIndex = 222
BuyAllButton.Parent = EconomyBody
AddCorner(BuyAllButton,9)

local StopBuyingButton = Instance.new("TextButton")
StopBuyingButton.LayoutOrder = 4
StopBuyingButton.Size = UDim2.new(1,0,0,38)
StopBuyingButton.BackgroundColor3 = OFF_COLOR
StopBuyingButton.BorderSizePixel = 0
StopBuyingButton.Text = "PARAR COMPRAS"
StopBuyingButton.TextColor3 = TEXT_PRIMARY
StopBuyingButton.TextSize = 9
StopBuyingButton.Font = Enum.Font.GothamBold
StopBuyingButton.Visible = false
StopBuyingButton.ZIndex = 222
StopBuyingButton.Parent = EconomyBody
AddCorner(StopBuyingButton,9)
AddStroke(StopBuyingButton,0.78)

local EconomyHint = Instance.new("TextLabel")
EconomyHint.LayoutOrder = 5
EconomyHint.Size = UDim2.new(1,0,0,40)
EconomyHint.BackgroundTransparency = 1
EconomyHint.Text = "Compra somente itens com Price em moeda do jogo. Gamepasses, Robux e compras especiais são ignorados."
EconomyHint.TextColor3 = TEXT_MUTED
EconomyHint.TextSize = 7
EconomyHint.Font = Enum.Font.Gotham
EconomyHint.TextWrapped = true
EconomyHint.TextXAlignment = Enum.TextXAlignment.Left
EconomyHint.TextYAlignment = Enum.TextYAlignment.Top
EconomyHint.ZIndex = 222
EconomyHint.Parent = EconomyBody

local EconomyPanelOpen = false
local AutoBuying = false
local AutoBuyToken = 0

local function SetEconomyStatus(message)
    EconomyStatus.Text = tostring(message or "")
end

local function FindOwnedTycoon()
    local tycoons = Workspace:FindFirstChild("Tycoons")
    if not tycoons then
        return nil
    end

    local playerName = LocalPlayer.Name

    -- O Collector do scan possui o atributo Owner.
    for _, tycoon in ipairs(tycoons:GetChildren()) do
        local core = tycoon:FindFirstChild("CoreBuild")
        local collector = core and core:FindFirstChild("Collector")
        if collector and tostring(collector:GetAttribute("Owner") or "") == playerName then
            return tycoon
        end
    end

    -- Fallback: os Models em Buttons também carregam Owner.
    for _, tycoon in ipairs(tycoons:GetChildren()) do
        local buttons = tycoon:FindFirstChild("Buttons")
        if buttons then
            for _, button in ipairs(buttons:GetChildren()) do
                if tostring(button:GetAttribute("Owner") or "") == playerName then
                    return tycoon
                end
            end
        end
    end

    return nil
end

local function GetTouchPart(model)
    if not model then
        return nil
    end

    local touch = model:FindFirstChild("Touch")
    if touch and touch:IsA("BasePart") then
        return touch
    end

    if model:IsA("BasePart") then
        return model
    end

    return model:FindFirstChildWhichIsA("BasePart")
end

local function TriggerTycoonTouch(part)
    if not part or not part:IsA("BasePart") or not part.Parent then
        return false
    end

    local character = LocalPlayer.Character
    local root = GetRoot(character)
    local humanoid = GetHumanoid(character)

    if not character or not root or not humanoid or humanoid.Health <= 0 then
        return false
    end

    -- Primeiro tenta o TouchTransmitter diretamente quando o ambiente oferece
    -- firetouchinterest. Faz duas sequências para tolerar perda de evento.
    local touchFn = rawget(_G, "firetouchinterest")
    if type(touchFn) ~= "function" and getgenv then
        local okEnv, env = pcall(getgenv)
        if okEnv and type(env) == "table" then
            touchFn = rawget(env, "firetouchinterest")
        end
    end

    if type(touchFn) == "function" then
        local ok = pcall(function()
            touchFn(root, part, 0)
            task.wait(0.08)
            touchFn(root, part, 1)
            task.wait(0.08)
            touchFn(root, part, 0)
            task.wait(0.08)
            touchFn(root, part, 1)
        end)

        if ok then
            return true
        end
    end

    -- Fallback universal: encosta o HumanoidRootPart de verdade na peça,
    -- mantém por alguns frames e depois volta.
    local originalPivot = character:GetPivot()

    local ok = pcall(function()
        local y = part.Position.Y + math.max(1.5, part.Size.Y * 0.5 + 1.5)
        local destination = CFrame.new(part.Position.X, y, part.Position.Z)

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        character:PivotTo(destination)

        for _ = 1, 6 do
            RunService.Heartbeat:Wait()
        end
    end)

    if character.Parent and humanoid.Parent and humanoid.Health > 0 then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            character:PivotTo(originalPivot)
        end)
    end

    return ok
end

local function CollectTycoonMoney()
    local tycoon = FindOwnedTycoon()
    if not tycoon then
        SetEconomyStatus("Seu Tycoon não foi encontrado.")
        return false
    end

    local core = tycoon:FindFirstChild("CoreBuild")
    local collector = core and core:FindFirstChild("Collector")
    local collect = collector and collector:FindFirstChild("Collect")

    if not collect or not collect:IsA("BasePart") then
        SetEconomyStatus("Coletor de dinheiro não encontrado.")
        return false
    end

    SetEconomyStatus("Coletando dinheiro...")
    local ok = TriggerTycoonTouch(collect)

    if ok then
        SetEconomyStatus("Coleta acionada.")
    else
        SetEconomyStatus("Não foi possível acionar o coletor.")
    end

    return ok
end

local function PurchaseExists(tycoon, purchaseName)
    if not tycoon or not purchaseName or purchaseName == "" then
        return false
    end

    local purchases = tycoon:FindFirstChild("Purchases")
    return purchases ~= nil and purchases:FindFirstChild(purchaseName) ~= nil
end

local function IsDependencySatisfied(tycoon, button)
    local dependency = tostring(button:GetAttribute("Dependency") or "")
    if dependency == "" then
        return true
    end

    return PurchaseExists(tycoon, dependency)
end

local ROBUX_ATTRIBUTE_NAMES = {
    "Gamepass",
    "GamePass",
    "GamePassId",
    "GamepassId",
    "ProductId",
    "DeveloperProductId",
    "DevProductId",
    "Robux",
    "RobuxPrice",
    "MarketplaceId",
    "AssetId",
}

local function HasRobuxPurchaseMarker(button)
    for _, attributeName in ipairs(ROBUX_ATTRIBUTE_NAMES) do
        local value = button:GetAttribute(attributeName)
        if value ~= nil and value ~= false and value ~= "" then
            return true
        end
    end

    local combinedName = string.lower(
        tostring(button.Name) .. " "
        .. tostring(button:GetAttribute("Name") or "")
    )

    -- Fallback conservador para nomenclaturas explícitas.
    if string.find(combinedName, "robux", 1, true)
        or string.find(combinedName, "gamepass", 1, true)
        or string.find(combinedName, "developer product", 1, true)
    then
        return true
    end

    return false
end

local function IsNormalPurchaseButton(tycoon, button, playerName)
    if not button or not button:IsA("Model") then
        return false
    end

    if tostring(button:GetAttribute("Owner") or "") ~= playerName then
        return false
    end

    -- REGRA PRINCIPAL:
    -- só entra no Auto Buy se existir um Price numérico em moeda do jogo.
    local rawPrice = button:GetAttribute("Price")
    local price = tonumber(rawPrice)
    if rawPrice == nil or not price or price < 0 then
        return false
    end

    -- Qualquer marcador de Marketplace/Robux exclui o botão, mesmo que
    -- por algum motivo também exista um atributo Price.
    if HasRobuxPurchaseMarker(button) then
        return false
    end

    if button:GetAttribute("NonPurchase") == true then
        return false
    end

    local touch = button:FindFirstChild("Touch")
    if not touch or not touch:IsA("BasePart") or touch.CanTouch == false then
        return false
    end

    if not IsDependencySatisfied(tycoon, button) then
        return false
    end

    -- Se a compra já existe em Purchases, não tenta novamente.
    if PurchaseExists(tycoon, button.Name) then
        return false
    end

    return true
end

local function GetAvailablePurchaseButtons(tycoon)
    local buttonsFolder = tycoon and tycoon:FindFirstChild("Buttons")
    if not buttonsFolder then
        return {}
    end

    local result = {}
    local playerName = LocalPlayer.Name

    for _, button in ipairs(buttonsFolder:GetChildren()) do
        if IsNormalPurchaseButton(tycoon, button, playerName) then
            table.insert(result, button)
        end
    end

    table.sort(result, function(a,b)
        local pa = tonumber(a:GetAttribute("Price")) or math.huge
        local pb = tonumber(b:GetAttribute("Price")) or math.huge

        if pa == pb then
            return tostring(a:GetAttribute("Name") or a.Name)
                < tostring(b:GetAttribute("Name") or b.Name)
        end

        return pa < pb
    end)

    return result
end

local function DidPurchaseComplete(tycoon, button, originalName, originalParent)
    -- O scan mostra que compras concluídas aparecem em Tycoon.Purchases.
    if PurchaseExists(tycoon, originalName) then
        return true
    end

    if not button or button.Parent == nil then
        return true
    end

    if originalParent and button.Parent ~= originalParent then
        return true
    end

    local touch = button:FindFirstChild("Touch")
    if not touch or not touch:IsA("BasePart") then
        return true
    end

    return false
end

local function StopAutoBuy(status)
    AutoBuying = false
    AutoBuyToken = AutoBuyToken + 1
    StopBuyingButton.Visible = false
    BuyAllButton.Text = "▣  COMPRAR TUDO POSSÍVEL"

    if status then
        SetEconomyStatus(status)
    end
end

local function StartAutoBuy()
    if AutoBuying then
        return
    end

    local tycoon = FindOwnedTycoon()
    if not tycoon then
        SetEconomyStatus("Seu Tycoon não foi encontrado.")
        return
    end

    AutoBuying = true
    AutoBuyToken = AutoBuyToken + 1
    local myToken = AutoBuyToken

    StopBuyingButton.Visible = true
    BuyAllButton.Text = "COMPRANDO..."
    SetEconomyStatus("Procurando compras com moeda do jogo...")

    task.spawn(function()
        local purchasedCount = 0
        local passCount = 0
        local maxPurchases = 250

        while AutoBuying and myToken == AutoBuyToken and purchasedCount < maxPurchases do
            if not tycoon.Parent then
                StopAutoBuy("Seu Tycoon não está mais disponível.")
                return
            end

            local candidates = GetAvailablePurchaseButtons(tycoon)

            if #candidates == 0 then
                StopAutoBuy(
                    purchasedCount > 0
                    and ("Finalizado: " .. purchasedCount .. " compra(s).")
                    or "Nenhuma compra com moeda do jogo disponível."
                )
                return
            end

            passCount = passCount + 1
            local boughtThisPass = 0

            for _, button in ipairs(candidates) do
                if not AutoBuying or myToken ~= AutoBuyToken then
                    return
                end

                if purchasedCount >= maxPurchases then
                    break
                end

                if button.Parent and IsNormalPurchaseButton(tycoon, button, LocalPlayer.Name) then
                    local price = tonumber(button:GetAttribute("Price")) or 0
                    local displayName = tostring(button:GetAttribute("Name") or button.Name)
                    local touch = GetTouchPart(button)
                    local oldParent = button.Parent
                    local originalName = button.Name

                    SetEconomyStatus(
                        "Tentando: " .. displayName .. "  $" .. tostring(math.floor(price))
                    )

                    if touch then
                        TriggerTycoonTouch(touch)
                        task.wait(0.70)

                        if DidPurchaseComplete(tycoon, button, originalName, oldParent) then
                            purchasedCount = purchasedCount + 1
                            boughtThisPass = boughtThisPass + 1
                            SetEconomyStatus(
                                "Comprado: " .. displayName
                                .. "\nTotal: " .. purchasedCount
                            )

                            -- Pequena pausa para o servidor atualizar novos botões/dependências.
                            task.wait(0.30)
                        end
                    end
                end
            end

            -- Uma passagem inteira sem conseguir comprar nada significa que
            -- nenhum botão disponível foi aceito (normalmente saldo insuficiente
            -- ou dependência ainda não satisfeita). Nesse ponto ele para.
            if boughtThisPass == 0 then
                StopAutoBuy(
                    purchasedCount > 0
                    and ("Parou: sem dinheiro/compra disponível. Total: " .. purchasedCount)
                    or "Parou: nenhuma compra pôde ser concluída."
                )
                return
            end

            task.wait(0.25)
        end

        if AutoBuying and myToken == AutoBuyToken then
            StopAutoBuy("Auto compra finalizada. Total: " .. purchasedCount)
        end
    end)
end

local function SetEconomyPanelVisible(value)
    EconomyPanelOpen = value == true
    EconomyPanel.Visible = EconomyPanelOpen

    if EconomyPanelOpen then
        SetTeleportPanelVisible(false)

        local tycoon = FindOwnedTycoon()
        if tycoon then
            SetEconomyStatus("Tycoon encontrado • pronto")
        else
            SetEconomyStatus("Aguardando seu Tycoon...")
        end
    end
end

OpenEconomyPanelButton.Activated:Connect(function()
    SetEconomyPanelVisible(true)
end)

CloseEconomyButton.Activated:Connect(function()
    if AutoBuying then
        StopAutoBuy("Compras interrompidas.")
    end
    SetEconomyPanelVisible(false)
end)

CollectMoneyButton.Activated:Connect(function()
    CollectTycoonMoney()
end)

BuyAllButton.Activated:Connect(function()
    StartAutoBuy()
end)

StopBuyingButton.Activated:Connect(function()
    StopAutoBuy("Compras interrompidas.")
end)

end

SetupEconomyPanel()

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
        if table.clear then
            table.clear(Connections)
        else
            for i = #Connections, 1, -1 do
                Connections[i] = nil
            end
        end

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
