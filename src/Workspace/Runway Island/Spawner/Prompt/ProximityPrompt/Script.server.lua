script.Parent.Triggered:Connect(function(player)
	game:GetService("ReplicatedStorage"):WaitForChild("OpenSpawner"):FireClient(player)
end)