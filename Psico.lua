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

local ESPEnabled = true
local ESPSoldiersEnabled = true
local ESPInfoEnabled = true

local AimEnabled = false
local AimSoldiersEnabled = true
local TeamCheckEnabled = true
local VisibleCheckEnabled = true
local AimPartMode = "Head"

local FlySpeed = 50
local WalkSpeed = 30
local AimFOV = 60 -- graus
local AimSmoothness = 0.30

local Connections = {}
local PlayerConnections = {}
local SoldierConnections = {}
local NoclipOriginal = {}
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

local function IsFriendly(entry)
    if not TeamCheckEnabled then
        return false
    end

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
        Humanoid.WalkSpeed = WalkSpeedEnabled and WalkSpeed or 16
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

local COLOR_ENEMY = Color3.fromRGB(255, 70, 70)
local COLOR_ALLY = Color3.fromRGB(70, 255, 140)
local COLOR_PLAYER = Color3.fromRGB(255, 255, 255)
local COLOR_SOLDIER = Color3.fromRGB(255, 190, 70)

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
    highlight.Enabled = ESPEnabled
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(230, 92)
    billboard.StudsOffset = Vector3.new(0, 3.7, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Enabled = ESPEnabled
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

    local friendly = IsFriendly(entry)
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
    local relation = friendly and "ALIADO" or "INIMIGO"

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

local function UpdateESP()
    for key, entry in pairs(ESPEntries) do
        local model = entry.Model
        local humanoid = entry.Humanoid
        local root = entry.Root

        if not model or not model.Parent or not humanoid or not root or not root.Parent then
            DestroyESPEntry(key)
        else
            local showKind = entry.Kind ~= "Soldier" or ESPSoldiersEnabled
            local alive = humanoid.Health > 0
            local enabled = ESPEnabled and showKind and alive

            entry.Highlight.Enabled = enabled
            entry.Billboard.Enabled = enabled

            if enabled then
                local text, friendly = BuildESPText(entry)
                entry.Label.Text = text or model.Name

                local color
                if friendly then
                    color = COLOR_ALLY
                elseif entry.Kind == "Soldier" then
                    color = COLOR_SOLDIER
                else
                    color = COLOR_ENEMY
                end

                entry.Highlight.OutlineColor = color
                entry.Label.TextColor3 = color
            end
        end
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

                    if distance > 0.001 then
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
-- GUI • CAFEÍNA MONOCHROME
-- Mantém exatamente 250 x 360
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name = "CafeinaPsicosenatico"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"
Menu.Size = UDim2.fromOffset(250, 360)
Menu.AnchorPoint = Vector2.new(0.5, 0.5)
Menu.Position = UDim2.fromScale(0.5, 0.5)
Menu.BackgroundColor3 = Color3.fromRGB(6, 6, 7)
Menu.BorderSizePixel = 0
Menu.Parent = Gui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 1.2
MenuStroke.Color = Color3.fromRGB(235, 235, 235)
MenuStroke.Transparency = 0.18
MenuStroke.Parent = Menu

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -12, 0, 46)
Header.Position = UDim2.fromOffset(6, 5)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 11)
Header.BorderSizePixel = 0
Header.Parent = Menu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Thickness = 1
HeaderStroke.Color = Color3.fromRGB(255, 255, 255)
HeaderStroke.Transparency = 0.78
HeaderStroke.Parent = Header

local Brand = Instance.new("TextLabel")
Brand.Size = UDim2.new(1, -48, 0, 24)
Brand.Position = UDim2.fromOffset(11, 3)
Brand.BackgroundTransparency = 1
Brand.Text = "CAFEÍNA  V1"
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.TextColor3 = Color3.fromRGB(255, 255, 255)
Brand.TextSize = 16
Brand.Font = Enum.Font.GothamBlack
Brand.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -48, 0, 15)
Subtitle.Position = UDim2.fromOffset(11, 25)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "CONTROLE  •  PRECISÃO  •  MOBILE"
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextColor3 = Color3.fromRGB(145, 145, 150)
Subtitle.TextSize = 7
Subtitle.Font = Enum.Font.GothamBold
Subtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -37, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
CloseButton.Text = "—"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1
CloseStroke.Color = Color3.fromRGB(255, 255, 255)
CloseStroke.Transparency = 0.68
CloseStroke.Parent = CloseButton

-- O header inteiro funciona como área de arrasto, sem atrapalhar o botão.
local Title = Brand

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Content"
Scroll.Size = UDim2.new(1, -12, 1, -59)
Scroll.Position = UDim2.fromOffset(6, 54)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(230, 230, 230)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 2)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Scroll

local OFF_COLOR = Color3.fromRGB(13, 13, 15)
local ON_COLOR = Color3.fromRGB(245, 245, 245)
local CONTROL_COLOR = Color3.fromRGB(28, 28, 31)
local DANGER_COLOR = Color3.fromRGB(18, 18, 20)
local TEXT_PRIMARY = Color3.fromRGB(250, 250, 250)
local TEXT_MUTED = Color3.fromRGB(160, 160, 166)
local BORDER_COLOR = Color3.fromRGB(255, 255, 255)

local function AddStroke(object, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = BORDER_COLOR
    stroke.Transparency = transparency or 0.82
    stroke.Parent = object
    return stroke
end

local function CreateSection(title, subtitle)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, subtitle and 38 or 28)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = Scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 20)
    label.Position = UDim2.fromOffset(4, 2)
    label.BackgroundTransparency = 1
    label.Text = string.upper(title)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = TEXT_PRIMARY
    label.TextSize = 12
    label.Font = Enum.Font.GothamBlack
    label.Parent = frame

    if subtitle then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -8, 0, 14)
        sub.Position = UDim2.fromOffset(4, 20)
        sub.BackgroundTransparency = 1
        sub.Text = subtitle
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.TextColor3 = TEXT_MUTED
        sub.TextSize = 8
        sub.Font = Enum.Font.Gotham
        sub.Parent = frame
    end

    return frame
end

local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 36)
    button.BackgroundColor3 = OFF_COLOR
    button.Text = text
    button.TextColor3 = TEXT_PRIMARY
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    AddStroke(button, 0.82)

    return button
end

local function SetToggleButton(button, label, state)
    button.Text = label .. "   " .. (state and "ON" or "OFF")
    button.BackgroundColor3 = state and ON_COLOR or OFF_COLOR
    button.TextColor3 = state and Color3.fromRGB(8, 8, 9) or TEXT_PRIMARY

    local stroke = button:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Transparency = state and 0.18 or 0.82
        stroke.Color = state and Color3.fromRGB(255, 255, 255) or BORDER_COLOR
    end
end

local function CreateStepper(label, getValue, minusCallback, plusCallback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 38)
    frame.BackgroundColor3 = OFF_COLOR
    frame.BorderSizePixel = 0
    frame.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = frame

    AddStroke(frame, 0.82)

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromOffset(34, 28)
    minus.Position = UDim2.fromOffset(5, 5)
    minus.Text = "−"
    minus.TextSize = 17
    minus.Font = Enum.Font.GothamBold
    minus.TextColor3 = TEXT_PRIMARY
    minus.BackgroundColor3 = CONTROL_COLOR
    minus.BorderSizePixel = 0
    minus.Parent = frame

    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 7)
    minusCorner.Parent = minus

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -86, 1, 0)
    valueLabel.Position = UDim2.fromOffset(43, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = label .. "  " .. tostring(getValue())
    valueLabel.TextColor3 = TEXT_PRIMARY
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.fromOffset(34, 28)
    plus.Position = UDim2.new(1, -39, 0, 5)
    plus.Text = "+"
    plus.TextSize = 17
    plus.Font = Enum.Font.GothamBold
    plus.TextColor3 = TEXT_PRIMARY
    plus.BackgroundColor3 = CONTROL_COLOR
    plus.BorderSizePixel = 0
    plus.Parent = frame

    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 7)
    plusCorner.Parent = plus

    local function refresh()
        valueLabel.Text = label .. "  " .. tostring(getValue())
    end

    minus.Activated:Connect(function()
        minusCallback()
        refresh()
    end)

    plus.Activated:Connect(function()
        plusCallback()
        refresh()
    end)

    return frame, valueLabel, refresh
end

--========================================================--
-- MOVIMENTO
--========================================================--

CreateSection("Movimento", "Controle de movimento e mobilidade.")

local FlyButton = CreateButton("FLY   OFF")
FlyButton.Activated:Connect(function()
    FlyEnabled = not FlyEnabled

    if FlyEnabled then
        if not StartFly() then
            FlyEnabled = false
        end
    else
        StopFly()
    end

    SetToggleButton(FlyButton, "FLY", FlyEnabled)
end)

CreateStepper(
    "FLY SPEED",
    function() return FlySpeed end,
    function() FlySpeed = math.max(10, FlySpeed - 10) end,
    function() FlySpeed = math.min(300, FlySpeed + 10) end
)

local WalkButton = CreateButton("WALK SPEED   OFF")
WalkButton.Activated:Connect(function()
    WalkSpeedEnabled = not WalkSpeedEnabled
    ApplyWalkSpeed()
    SetToggleButton(WalkButton, "WALK SPEED", WalkSpeedEnabled)
end)

CreateStepper(
    "WALK SPEED",
    function() return WalkSpeed end,
    function()
        WalkSpeed = math.max(16, WalkSpeed - 5)
        ApplyWalkSpeed()
    end,
    function()
        WalkSpeed = math.min(200, WalkSpeed + 5)
        ApplyWalkSpeed()
    end
)

local NoclipButton = CreateButton("NOCLIP   OFF")
NoclipButton.Activated:Connect(function()
    NoclipEnabled = not NoclipEnabled

    if not NoclipEnabled then
        RestoreNoclip()
    end

    SetToggleButton(NoclipButton, "NOCLIP", NoclipEnabled)
end)

--========================================================--
-- VISUAL
--========================================================--

CreateSection("Visual", "ESP otimizado para jogadores e soldados.")

local ESPButton = CreateButton("ESP   ON")
SetToggleButton(ESPButton, "ESP", ESPEnabled)
ESPButton.Activated:Connect(function()
    ESPEnabled = not ESPEnabled
    SetToggleButton(ESPButton, "ESP", ESPEnabled)
    UpdateESP()
end)

local ESPSoldiersButton = CreateButton("ESP SOLDADOS   ON")
SetToggleButton(ESPSoldiersButton, "ESP SOLDADOS", ESPSoldiersEnabled)
ESPSoldiersButton.Activated:Connect(function()
    ESPSoldiersEnabled = not ESPSoldiersEnabled
    SetToggleButton(ESPSoldiersButton, "ESP SOLDADOS", ESPSoldiersEnabled)
    UpdateESP()
end)

local ESPInfoButton = CreateButton("ESP INFO   ON")
SetToggleButton(ESPInfoButton, "ESP INFO", ESPInfoEnabled)
ESPInfoButton.Activated:Connect(function()
    ESPInfoEnabled = not ESPInfoEnabled
    SetToggleButton(ESPInfoButton, "ESP INFO", ESPInfoEnabled)
    UpdateESP()
end)

--========================================================--
-- COMBATE
--========================================================--

CreateSection("Combate", "Aimbot automático baseado no ângulo da câmera.")

local AimButton = CreateButton("AIMBOT   OFF")
local AimSoldiersButton = CreateButton("AIM SOLDADOS   ON")
local TeamCheckButton = CreateButton("TEAM CHECK   ON")
local VisibleCheckButton = CreateButton("VISIBLE CHECK   ON")
local AimPartButton = CreateButton("ALVO   HEAD")

SetToggleButton(AimSoldiersButton, "AIM SOLDADOS", AimSoldiersEnabled)
SetToggleButton(TeamCheckButton, "TEAM CHECK", TeamCheckEnabled)
SetToggleButton(VisibleCheckButton, "VISIBLE CHECK", VisibleCheckEnabled)

-- Círculo visual: FOV configurado em graus, convertido para um raio de tela.
local FOVGui = Instance.new("Frame")
FOVGui.Name = "AimbotFOV"
FOVGui.Size = UDim2.fromOffset(120, 120)
FOVGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGui.Position = UDim2.fromScale(0.5, 0.5)
FOVGui.BackgroundTransparency = 1
FOVGui.BorderSizePixel = 0
FOVGui.Visible = false
FOVGui.ZIndex = 10
FOVGui.Parent = Gui

local FOVCircleCorner = Instance.new("UICorner")
FOVCircleCorner.CornerRadius = UDim.new(1, 0)
FOVCircleCorner.Parent = FOVGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.2
FOVStroke.Transparency = 0.28
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVGui

local function UpdateFOVCircle()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local radius = (AimFOV / 120) * math.min(viewport.X, viewport.Y) * 0.80
    radius = math.clamp(radius, 30, 400)
    FOVGui.Size = UDim2.fromOffset(radius * 2, radius * 2)
    FOVGui.Position = UDim2.fromScale(0.5, 0.5)
end

local _, _, RefreshFOV = CreateStepper(
    "FOV °",
    function() return AimFOV end,
    function()
        AimFOV = math.max(10, AimFOV - 5)
        UpdateFOVCircle()
    end,
    function()
        AimFOV = math.min(120, AimFOV + 5)
        UpdateFOVCircle()
    end
)

CreateStepper(
    "SMOOTH x100",
    function() return math.floor(AimSmoothness * 100 + 0.5) end,
    function() AimSmoothness = math.max(0.05, AimSmoothness - 0.05) end,
    function() AimSmoothness = math.min(1, AimSmoothness + 0.05) end
)

AimButton.Activated:Connect(function()
    AimEnabled = not AimEnabled
    FOVGui.Visible = AimEnabled
    SetToggleButton(AimButton, "AIMBOT", AimEnabled)
    UpdateFOVCircle()
end)

AimSoldiersButton.Activated:Connect(function()
    AimSoldiersEnabled = not AimSoldiersEnabled
    SetToggleButton(AimSoldiersButton, "AIM SOLDADOS", AimSoldiersEnabled)
end)

TeamCheckButton.Activated:Connect(function()
    TeamCheckEnabled = not TeamCheckEnabled
    SetToggleButton(TeamCheckButton, "TEAM CHECK", TeamCheckEnabled)
    UpdateESP()
end)

VisibleCheckButton.Activated:Connect(function()
    VisibleCheckEnabled = not VisibleCheckEnabled
    SetToggleButton(VisibleCheckButton, "VISIBLE CHECK", VisibleCheckEnabled)
end)

AimPartButton.Activated:Connect(function()
    AimPartMode = AimPartMode == "Head" and "Torso" or "Head"
    AimPartButton.Text = "ALVO   " .. string.upper(AimPartMode)
end)

--========================================================--
-- JOGADOR
--========================================================--

CreateSection("Jogador", "Ações locais do personagem.")

local KillButton = CreateButton("REGENERAR PERSONAGEM")
KillButton.BackgroundColor3 = DANGER_COLOR
KillButton.Activated:Connect(function()
    if Humanoid and Humanoid.Parent then
        Humanoid.Health = 0
    end
end)

CreateSection("Arma", "Informações do equipamento atual.")

--========================================================--
-- INFO DA ARMA LOCAL
--========================================================--

local WeaponInfo = Instance.new("TextLabel")
WeaponInfo.Size = UDim2.new(1, -8, 0, 62)
WeaponInfo.BackgroundColor3 = OFF_COLOR
WeaponInfo.BorderSizePixel = 0
WeaponInfo.TextColor3 = Color3.new(1, 1, 1)
WeaponInfo.TextStrokeTransparency = 0.5
WeaponInfo.TextSize = 10
WeaponInfo.TextWrapped = true
WeaponInfo.Font = Enum.Font.GothamBold
WeaponInfo.Text = "ARMA: nenhuma equipada"
WeaponInfo.Parent = Scroll

local WeaponInfoCorner = Instance.new("UICorner")
WeaponInfoCorner.CornerRadius = UDim.new(0, 9)
WeaponInfoCorner.Parent = WeaponInfo
AddStroke(WeaponInfo, 0.82)

local function UpdateLocalWeaponInfo()
    local weapon = GetWeaponData(Character)

    if not weapon then
        WeaponInfo.Text = "ARMA: nenhuma equipada"
        return
    end

    local line1 = "ARMA: " .. tostring(weapon.Name)
    if weapon.Ammo ~= nil or weapon.Magazine ~= nil then
        line1 = line1 .. "  |  " .. tostring(weapon.Ammo ~= nil and weapon.Ammo or "?")
            .. "/" .. tostring(weapon.Magazine ~= nil and weapon.Magazine or "?")
    end

    local details = {}
    if weapon.Damage ~= nil then table.insert(details, "DMG " .. FormatNumber(weapon.Damage, 1)) end
    if weapon.FireMode ~= nil then table.insert(details, tostring(weapon.FireMode)) end
    if weapon.Range ~= nil then table.insert(details, "R " .. FormatNumber(weapon.Range, 0)) end
    if weapon.RateOfFire ~= nil then table.insert(details, "RPM " .. FormatNumber(weapon.RateOfFire, 0)) end
    if weapon.Spread ~= nil then table.insert(details, "Spread " .. FormatNumber(weapon.Spread, 1)) end
    if weapon.Scope == true then table.insert(details, "Scope") end

    WeaponInfo.Text = line1
    if #details > 0 then
        WeaponInfo.Text = WeaponInfo.Text .. "\n" .. table.concat(details, "  •  ")
    end
end

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
            camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(AimSmoothness, 0.05, 1))
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

MakeDraggable(Title, Menu)
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
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshCanvas)
task.defer(RefreshCanvas)

--========================================================--
-- RESPAWN
--========================================================--

TrackConnection(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    RestoreNoclip()
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
-- INICIALIZAÇÃO FINAL
--========================================================--

RefreshFOV()
UpdateFOVCircle()
UpdateESP()
UpdateLocalWeaponInfo()

print("CAFEÍNA • Psicosenatico carregado.")
