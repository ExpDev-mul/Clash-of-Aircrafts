local buildingDestroy = game:GetService("ReplicatedStorage"):WaitForChild("BuildingDestroy");
local blastArea = script:WaitForChild("BlastArea")


local bomb = {}
bomb.__index = bomb

function bomb.new(object: Instance)
	local self = {}
	self.Object = object
	return setmetatable(self, bomb)
end;

function bomb:Drop(vehicle, filter)
	self.Object.Transparency = 0
	self.Object.Velocity = vehicle:WaitForChild("Body").Velocity
	self.Object:PivotTo(vehicle:GetPivot())
	
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
			print(hit)
			if hit.Name == self.Object.Name then return end;
			if hit:GetAttribute("IsABuilding") then
				buildingDestroy:FireServer(hit)
			end;

			Explode()
		end
	end)
end;


return bomb
