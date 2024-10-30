-->> Services
local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local marketPlaceService = game:GetService("MarketplaceService");

-->> Modules
local dataStore2 = require(script:WaitForChild("DataStore2"));
local dataStoreService = game:GetService("DataStoreService");

-->> Functions & Events
local dataTemplate = {
	["Dollars"] = 0,
}

function PlayerAdded(player)
	local isVIP = false
	pcall(function()
		-- isVIP = marketPlaceService:UserOwnsGamePassAsync(player.UserId, 130722711)
	end)
	
	player:SetAttribute("VIP", isVIP)
	local statsDataStore = dataStore2("StatsDataStore", player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local dollars = Instance.new("IntValue")
	dollars.Name = "Dollars"
	dollars.Parent = leaderstats
	
	local data = statsDataStore:Get() or dataTemplate
	for stat, value in pairs(data) do
		leaderstats:FindFirstChild(stat).Value = value
	end;
end;

players.PlayerAdded:Connect(PlayerAdded)

function PlayerRemoving(player)
	local statsDataStore = dataStore2("StatsDataStore", player)
	local data = dataTemplate
	for _, stat in next, player.leaderstats:GetChildren() do
		data[stat.Name] = stat.Value
	end;
	
	statsDataStore:Set(data)
end;

players.PlayerRemoving:Connect(PlayerRemoving)

game:BindToClose(function()
	for _, player in next, players:GetChildren() do
		coroutine.wrap(function()
			PlayerRemoving(player)
		end)()
	end;
end)