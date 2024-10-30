local item = script:WaitForChild("Item");

local replicatedStorage = game:GetService("ReplicatedStorage");

local aircrafts = require(replicatedStorage:WaitForChild("Aircrafts"));

local spawnAircraft = replicatedStorage:WaitForChild("SpawnAircraft");
for _, aircraft in ipairs(aircrafts) do
	local itemClone = item:Clone()
	itemClone.Title.Text = aircraft.Name
	itemClone.Desc.Text = aircraft.Description
	itemClone.Cost.Text = aircraft.Price == 0 and "FREE" or tostring(aircraft.Price)
	itemClone.Flag.Text = aircraft.Flag
	itemClone.Parent = script.Parent
	itemClone:WaitForChild("Spawn").MouseButton1Down:Connect(function()
		script.Parent.Parent.Parent.Visible = false
		spawnAircraft:FireServer(aircraft.Name, workspace["Runway Island"])
	end)
end;

script.Parent.Parent:WaitForChild("Close").MouseButton1Down:Connect(function()
	script.Parent.Parent.Parent.Visible = false
end)

replicatedStorage:WaitForChild("OpenSpawner").OnClientEvent:Connect(function()
	script.Parent.Parent.Parent.Visible = true
end)