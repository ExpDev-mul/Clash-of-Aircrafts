-->> Services
local runService = game:GetService("RunService");
local players = game:GetService("Players");

-->> References
local mapFrame = script.Parent;
local map = mapFrame:WaitForChild("Map");
local arrow = mapFrame:WaitForChild("Arrow");

local localPlayer = players.LocalPlayer;
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait();
local localMouse = localPlayer:GetMouse();

local camera = workspace.CurrentCamera;

-->> Functions & Events
local mapBoundaries = workspace:WaitForChild("MapBoundaries");

local cf, size = mapBoundaries:GetBoundingBox()

local origin = cf.Position
local xSize = size.X;
local zSize = size.Z;

local xOffset = 90
local zOffset = -60

local maximized = false;
local zoom = 1;
local mark = nil;
function Update(dt)
	map.Size = UDim2.fromScale(zoom,  zoom)
	
	local off = (localCharacter.HumanoidRootPart.Position + Vector3.new(xOffset, 0, zOffset) - origin)
	local x = (xSize/2 - off.X)/xSize;
	local z = (zSize/2 - off.Z)/zSize;
	map.Position = UDim2.fromScale(x + (x - 0.5)*(zoom - 1), z + (z - 0.5)*(zoom - 1))
	local pitch, yaw, roll = localCharacter.HumanoidRootPart.CFrame:ToEulerAnglesYXZ();
	arrow.Rotation = -45 - yaw*180/math.pi
end;

runService.RenderStepped:Connect(Update)