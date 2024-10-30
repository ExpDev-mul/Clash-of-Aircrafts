local tweenService = game:GetService("TweenService");

local buildingDestroy = game.ReplicatedStorage:WaitForChild("BuildingDestroy");

buildingDestroy.OnServerEvent:Connect(function(player, building)
	player.leaderstats.Dollars.Value += building:GetAttribute("Reward") or 0
	building.Parent = workspace
	buildingDestroy:FireAllClients(building)
	task.delay(4, function()
		building:Destroy()
	end)
end)