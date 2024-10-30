-- Services
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")

-- Objects
local blastArea = script:WaitForChild("BlastArea")
local buildingDestroy = game:GetService("ReplicatedStorage"):WaitForChild("BuildingDestroy");

-- Define missile class
local missile = {}
missile.__index = missile

-- Constructor for missile objects
function missile.new(object)
	local self = {}
	self.Object = object
	return setmetatable(self, missile)
end

-- Method to thrust the missile towards a target
local index = 0
function missile:Thrust(target, filterDescendants, p0Inst, rocketSpeed)
	print(target)
	index += 1
	local filter = {}
	for _, item in pairs(filterDescendants) do
		for _, desc in next, item:GetDescendants() do
			table.insert(filter, desc)
		end;
	end
	
	local bodyGyro = self.Object:FindFirstChild("BodyGyro")

	-- Function to handle explosion
	local alreadyExploded = false
	local function Explode()
		if alreadyExploded then
			return
		end
		
		alreadyExploded = true
		local explosionPosition = self.Object.Position
		self.Object:Destroy()

		-- Create blast area effect
		local blastAreaClone = blastArea:Clone()
		blastAreaClone.Parent = workspace
		blastAreaClone.Anchored = true
		blastAreaClone.Position = explosionPosition
		blastAreaClone.Fire:Emit(200)
		blastAreaClone.Smoke:Emit(200)

		-- Destroy blast area after duration
		task.wait(blastAreaClone:WaitForChild("Fire").Lifetime.Max)
		blastAreaClone:Destroy()
	end

	-- Event handler for missile collisions
	local collided = false
	self.Object.Touched:Connect(function(hit)
		if table.find(filter, hit) then
			return
		end

		if not hit:IsDescendantOf(self.Object) then
			if hit:GetAttribute("IsABuilding") then
				buildingDestroy:FireServer(hit)
			end;
			
			Explode()
		end
	end)

	-- Function to update missile behavior
	local function UpdateBehavior()
		self.Object:PivotTo(p0Inst.CFrame)
		local currentTime = 0
		while not collided do
			local dt = runService.Heartbeat:Wait()
			currentTime += dt

			-- Update target position
			local targetPosition = typeof(target) == "Vector3" and target or target.Position

			-- Adjust body gyro and linear velocity
			bodyGyro.CFrame = CFrame.lookAt(self.Object.Position, targetPosition) * CFrame.Angles(0, math.pi/2, 0)
			self.Object.Velocity = self.Object.CFrame.RightVector * (rocketSpeed) -- + math.sin(currentTime)*50)
		end
	end

	-- Schedule explosion if not collided within a certain time
	task.delay(7, function()
		if not collided then
			collided = true
			Explode()
		end
	end)

	-- Start updating behavior
	UpdateBehavior()
end

-- Return missile class
return missile
