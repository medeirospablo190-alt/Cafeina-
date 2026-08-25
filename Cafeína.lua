--========================================================--
-- CAFEÍNA ROBLOX
-- GOD MODE - SERVIDOR
-- Coloque este Script em ServerScriptService
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:FindFirstChild("CafeinaGodMode")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "CafeinaGodMode"
	Remote.Parent = ReplicatedStorage
end

local GodModePlayers = {}

local function ApplyGodMode(Player, Enabled)
	GodModePlayers[Player] = Enabled

	local Character = Player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return
	end

	Humanoid:SetAttribute("CafeinaGodMode", Enabled)

	if Enabled then
		Humanoid.Health = Humanoid.MaxHealth
	end
end

Remote.OnServerEvent:Connect(function(Player, Enabled)

	if typeof(Enabled) ~= "boolean" then
		return
	end

	ApplyGodMode(Player, Enabled)

end)

local function SetupPlayer(Player)

	Player.CharacterAdded:Connect(function(Character)

		local Humanoid =
			Character:WaitForChild("Humanoid")

		task.wait(0.2)

		if GodModePlayers[Player] then
			Humanoid:SetAttribute(
				"CafeinaGodMode",
				true
			)

			Humanoid.Health =
				Humanoid.MaxHealth
		end

		Humanoid.HealthChanged:Connect(function()

			if Humanoid:GetAttribute(
				"CafeinaGodMode"
			) then

				if Humanoid.Health <
					Humanoid.MaxHealth then

					Humanoid.Health =
						Humanoid.MaxHealth

				end

			end

		end)

	end)

end

for _, Player in ipairs(Players:GetPlayers()) do
	SetupPlayer(Player)
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(Player)
	GodModePlayers[Player] = nil
end)
