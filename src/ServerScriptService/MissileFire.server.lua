local missileFire = game:GetService("ReplicatedStorage"):WaitForChild("MissileFire")
local rocket = script:WaitForChild("Rocket");

local missile = game.ReplicatedStorage:WaitForChild("Missile")

missileFire.OnServerInvoke = function(player, vehicle, index)
	local newRocket = rocket:Clone()
	newRocket.Parent = workspace
	newRocket.Transparency = 1

	newRocket:PivotTo(vehicle:GetPivot() - Vector3.yAxis*(500))
	newRocket:WaitForChild("Flamer").WeldConstraint.Part0 = newRocket.Flamer
	newRocket.Flamer.WeldConstraint.Part1 = newRocket
	
	newRocket:SetNetworkOwner(player)
	local bodyForce = Instance.new("BodyForce", newRocket)
	bodyForce.Force = Vector3.yAxis*newRocket:GetMass()*workspace.Gravity
	local bodyGyro = Instance.new("BodyGyro", newRocket)
	bodyGyro.MaxTorque = Vector3.one*10^5
	
	task.wait(0.1)
	newRocket.Transparency = 0
	return newRocket
end