local t0 = tick() -- Seed for localized points randomization

local tweenService = game:GetService("TweenService");

local radius = 4000
local cloudsPerGrid = 6
local gridSize = Vector3.new(3000, 0, 3000)

local camera = workspace.CurrentCamera;

local currentClouds = {}

function LockToGrid(n, grid)
	return math.round(n/grid)*grid
end;

function TrackLocalizedClouds(pivot)
	local points = {}
	for n = 1, cloudsPerGrid do
		math.randomseed(t0 + n + pivot.Magnitude)
		local angle = math.rad(math.random(0, 360))
		local cf = CFrame.new(pivot) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, math.random(0, radius))
		table.insert(points, cf.Position)
	end;
	
	return points
end;

local cloudsFolder = workspace:WaitForChild("Clouds");
local cloudMesh = script:WaitForChild("Cloud");
while task.wait(0.5) do
	local gridPoint = Vector3.new(LockToGrid(camera.CFrame.Position.X, gridSize.X), 0, LockToGrid(camera.CFrame.Position.Z, gridSize.Z))
	local localizedClouds = TrackLocalizedClouds(gridPoint)
	
	for _, point in pairs(localizedClouds) do
		if currentClouds[point] == nil then
			local newCloud = cloudMesh:Clone()
			local tra0 = newCloud.Transparency
			newCloud.Transparency = 1
			newCloud.Position = point + Vector3.new(0, 3500, 0)
			local xs = math.random(100, 600)
			newCloud.Size = Vector3.new(xs, math.random(1, 10)/10, xs*math.random(0.8*100, 1.2*100)/100)
			newCloud.Orientation = Vector3.new(0, math.random(0, 360), 0)
			newCloud.Parent = cloudsFolder
			currentClouds[point] = newCloud
			tweenService:Create(newCloud, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Transparency = tra0}):Play()
		end;
	end
	
	for _, existingCloud in pairs(currentClouds) do
		if (existingCloud.Position*Vector3.new(1, 0, 1) - camera.CFrame.Position*Vector3.new(1, 0, 1)).Magnitude > radius*2 then
			existingCloud:Destroy()
		end;
	end;
end;