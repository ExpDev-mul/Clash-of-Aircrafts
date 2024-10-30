local tweenService = game:GetService("TweenService");

local buildingDestroy = game:GetService("ReplicatedStorage"):WaitForChild("BuildingDestroy");

buildingDestroy.OnClientEvent:Connect(function(building)
	tweenService:Create(building, TweenInfo.new(4, Enum.EasingStyle.Sine), {
		Position = building.Position - Vector3.yAxis*building.Size.Y/2,
		Transparency = 1,
		Orientation = building.Orientation + Vector3.one*20
	}):Play()
end)