-- Services
local tweenService = game:GetService("TweenService")

-- Objects
local vehicleSeat = script.Parent
local proximityPrompt = vehicleSeat:WaitForChild("ProximityPrompt")
local vehicleClient = script:WaitForChild("VehicleClient")

-- Functions
function SetCharacter(player, isMassless, invisible)
	if not player then
		return
	end;
	
	for _, basePart in ipairs(player.Character:GetDescendants()) do
		if basePart:IsA("BasePart") then
			basePart.Massless = isMassless
			if basePart.Name ~= "HumanoidRootPart" then
				basePart.Transparency = invisible and 1 or 0
			end
		end

		if basePart:IsA("Decal") then
			basePart.Transparency = invisible and 1 or 0
		end
	end
end

function EngineState(on)
	local engines = vehicleSeat.Parent:WaitForChild("Body"):WaitForChild("Engines")

	if on then
		engines:Play()
	else
		task.delay(3, function()
			if not engines.IsPlaying then
				engines:Stop()
			end
		end)
	end

	tweenService:Create(engines, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Volume = on and 0.7 or 0}):Play()
end

-- Properties and Events
local currentPlayer = nil
local currentVehicleClientScript = nil

function Start()
	EngineState(true)
	proximityPrompt.Enabled = false
end

local linearVelocity;
function Stop()
	EngineState(false)
	proximityPrompt.Enabled = true
	SetCharacter(currentPlayer, false, false)
	linearVelocity.VectorVelocity = Vector3.yAxis*(-20)
	currentPlayer = nil

	if currentVehicleClientScript then
		currentVehicleClientScript:WaitForChild("Stop").Value = true
		task.wait(2)
		currentVehicleClientScript:Destroy()
	end
end


vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if not vehicleSeat.Occupant then
		Stop()
	end
end)

proximityPrompt.Triggered:Connect(function(player)
	if not vehicleSeat.Occupant then
		if player.Character and player.Character.Humanoid.Health > 0 then
			currentPlayer = player
			SetCharacter(player, true, true)

			local clone = vehicleClient:Clone()
			clone:WaitForChild("Vehicle").Value = vehicleSeat.Parent
			clone.Parent = currentPlayer:WaitForChild("Backpack")
			currentVehicleClientScript = clone

			vehicleSeat:Sit(player.Character.Humanoid)
			Start()
		end
	end
end)

-- Create physics objects
local bodyGyro = Instance.new("BodyGyro", vehicleSeat.Parent:WaitForChild("Body"))
bodyGyro.MaxTorque = Vector3.one*10^5

linearVelocity = Instance.new("LinearVelocity", vehicleSeat.Parent.Body)
linearVelocity.VectorVelocity = Vector3.yAxis*(-20)
linearVelocity.Attachment0 = vehicleSeat.Parent.Body:WaitForChild("Attachment")
linearVelocity.MaxForce = 10^7
linearVelocity.RelativeTo = "World"

local bodyForce = Instance.new("BodyForce", vehicleSeat.Parent.Body)
bodyForce.Force = Vector3.zero
