local camera = workspace.Camera;

local originp = workspace:WaitForChild("Origin")
local xSize = originp.Size.X;
local zSize = originp.Size.Z;
local alpha = camera.FieldOfView;
local y = (math.max(xSize, zSize)/2)/math.tan(alpha/2/180*math.pi)
while task.wait() do
	local origin = originp.Position
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(originp + Vector3.new(0, y, 0), originp) * CFrame.new(math.pi/2, 0, 0)
end;