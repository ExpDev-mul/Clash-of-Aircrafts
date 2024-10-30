local bombDrop = game:GetService("ReplicatedStorage"):WaitForChild("BombDrop")
local bomb = script:WaitForChild("Bomb");

bombDrop.OnServerInvoke = function(player, vehicle)
	local new = bomb:Clone()
	new.Parent = workspace
	new.Transparency = 1
	
	local bodyForce = Instance.new("BodyForce", new)
	bodyForce.Force = Vector3.yAxis*(new:GetMass()*workspace.Gravity)*(3/9.81)
	
	new:PivotTo(vehicle:GetPivot())

	new:SetNetworkOwner(player)
	task.wait(0.1)
	return new
end