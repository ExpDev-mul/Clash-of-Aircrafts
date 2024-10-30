local aircrafts = require(game:GetService("ReplicatedStorage"):WaitForChild("Aircrafts"))

game.ReplicatedStorage:WaitForChild("SpawnAircraft").OnServerEvent:Connect(function(player, name, island)
	local aircraftClone = game:GetService("ServerStorage"):WaitForChild("Aircrafts"):WaitForChild(name):Clone()
	aircraftClone.Parent = workspace
	print(island)
	aircraftClone.PrimaryPart = aircraftClone:WaitForChild("Body")
	aircraftClone:PivotTo(island:FindFirstChild("SpawnSpot").CFrame)
end)