local runService = game:GetService("RunService");

local camera = workspace.CurrentCamera;

local water = script:WaitForChild("Water");

function LockToGrid(n, grid)
	return math.floor(n/grid)*grid
end;

local lighting = game:GetService("Lighting");
local cc = lighting:WaitForChild("ColorCorrection");

local lastAlp = nil
function SetColor()
	local ct = lighting.ClockTime;
	
	local alp = 0
	if lastAlp == alp then
		return
	end;
	
	lastAlp = alp
	if ct > 8 and ct < 21 then
		alp = 0
	else
		if ct > 21 and ct < 24 then
			alp = (ct - 21)/11
		else
			alp = (3 + ct)/11
		end;
	end;
	

	if alp >= 0.5 then
		alp = 1 - alp
	end;
	
	alp *= 2
		
	for _, child in next, water:GetChildren() do
		child.Color = Color3.fromRGB(0, 170, 255):Lerp(Color3.fromRGB(0, 29, 44), alp)
	end;
	
	lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70):Lerp(Color3.fromRGB(26, 26, 26), alp)
	cc.Contrast = 0.1*alp
end;


local texture = water:WaitForChild("WaterPart"):WaitForChild("Texture");

local offset = 0
runService.RenderStepped:Connect(function(dt)
	water.Parent = workspace
	
	local pos = camera.CFrame.Position * Vector3.new(1, 0, 1)
	
	texture.OffsetStudsU = offset
	texture.OffsetStudsV = offset
	
	pos = Vector3.new(LockToGrid(pos.X, 15), -20, LockToGrid(pos.Z, 15))
	
	
	offset += 3*dt
	--pos -= Vector3.new(size.X/2, 0, size.Z/2)
	water:PivotTo(CFrame.new(pos))
end)

while task.wait(1) do
	SetColor()
end;