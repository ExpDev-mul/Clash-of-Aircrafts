local cent = workspace:WaitForChild("cent").Position

local parts = 100
local radius = 380

local height = 20

local da = 360/parts
for i = da, 360, da do
	local po = CFrame.new(cent) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, -radius)
	local prt = Instance.new("Part", workspace)
	
	prt.Anchored = true
	prt.CanCollide = true
	prt.CFrame = po
	prt.Parent = workspace
	prt.Size = Vector3.new(20, height + 6, 2)
	prt.Color = Color3.fromRGB(39, 39, 39)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {prt}
	local ray = workspace:Raycast(po.Position, -Vector3.yAxis*100, params)
	if ray and ray.Position then
		prt.Position = Vector3.new(1,0,1)*prt.Position + ray.Position*Vector3.new(0, 1, 0) + Vector3.yAxis*(height/2 - 3) 
	end;
	
	local inner = Instance.new("Part", prt)
	inner.Size = Vector3.new(20, 2, 6)
	inner.CFrame = prt.CFrame * CFrame.new(0, prt.Size.Y/2, 0)
	inner.Color = Color3.fromRGB(0,0,0)
	inner.Anchored = true
end;