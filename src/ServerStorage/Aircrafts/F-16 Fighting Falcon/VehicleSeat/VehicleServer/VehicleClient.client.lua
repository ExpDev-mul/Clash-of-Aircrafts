-- Constants
local range = 2700
local detectionRange = 1700
local minSpeed = -85
local maxSpeed = 450
local acceleration = 20
local takeOffSpeed = 250
local rocketSpeed = 600

-- Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService");

-- Objects
local localPlayer = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local stop = script:WaitForChild("Stop")
local vehicle = script:WaitForChild("Vehicle").Value
local body = vehicle:WaitForChild("Body")
local vehicleSeat = vehicle:WaitForChild("VehicleSeat")
local missileFire = replicatedStorage:WaitForChild("MissileFire")
local targetUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Target");
local targetTrack = targetUI:WaitForChild("Track");
local flamerFire = vehicle:WaitForChild("Flamer"):WaitForChild("Fire")
local innerEngine = vehicle:WaitForChild("InnerEngine")
local bodyGyro = body:WaitForChild("BodyGyro")
local linearVelocity = body:WaitForChild("LinearVelocity")
local bodyForce = body:WaitForChild("BodyForce")
local engines = body:WaitForChild("Engines")
local statsUI = localPlayer.PlayerGui:WaitForChild("Stats");

-- Functions
function Lerp(a, b, t)
	return a + (b - a) * math.min(t, 1)
end

local splash = script:WaitForChild("Splash");
script.Parent = workspace

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {vehicle}
function IsGrounded()
	local p0 = body.Position
	local ray = workspace:Raycast(p0, -Vector3.yAxis * 60, raycastParams)
	if ray and ray.Instance then
		if math.abs((ray.Position - p0).Y) < 10 then
			return true
		end;

		splash.Position = ray.Position
		local rayColor = Color3.fromRGB(0, 0, 0)
		if ray.Instance.Name == "WaterPart" then
			splash:WaitForChild("Water").Enabled = true
			splash.Smoke.Enabled = false
		else
			rayColor = (ray.Instance == workspace.Terrain) and workspace.Terrain:GetMaterialColor(ray.Material) or rayColor
			splash:WaitForChild("Smoke").Enabled = true
			splash:WaitForChild("Water").Enabled = false
		end;


		splash.Smoke.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, rayColor), ColorSequenceKeypoint.new(1.0, rayColor) })
	else
		splash:WaitForChild("Smoke").Enabled = false
		splash:WaitForChild("Water").Enabled = false
	end;


	return (ray ~= nil and ray.Instance ~= nil and math.abs((ray.Position - p0).Y) < 10)
end

function TargetInRange()
	local targets = workspace:WaitForChild("Targets"):GetDescendants();
	
	local minAngle = 0.91
	local minTarget = nil
	for _, item in next, targets do
		if not item:IsA("BasePart") then
			continue
		end;
		
		local dist = (item.Position - body.Position).Magnitude
		local angle = (item.Position - body.Position).Unit:Dot(body.CFrame.RightVector)
		if dist <= detectionRange and angle > minAngle then
			minAngle = angle
			minTarget = item
		end;
	end;
	
	return minTarget
end;

function CalculateTargetVector()
	local targetInRange = TargetInRange()
	if targetInRange then
		return targetInRange
	end;
	
	targetInRange = body.Position + body.CFrame.RightVector * range
	local target = targetInRange
	local ray = workspace:Raycast(target, (target - body.Position).Unit * range, raycastParams)
	local dist = range
	if ray then
		if ray.Position then
			dist = (ray.Position - body.Position).Magnitude
		end
	end
	
	return body.Position + body.CFrame.RightVector * dist
end

-- Event connections
stop:GetPropertyChangedSignal("Value"):Connect(function()
	if stop.Value then
		runService.RenderStepped:Wait()
		camera.CameraType = Enum.CameraType.Custom
		camera.FieldOfView = 70
		userInputService.MouseBehavior = Enum.MouseBehavior.Default
		targetUI.Enabled = false
		userInputService.MouseIconEnabled = true
		statsUI.Enabled = false
		script:Destroy()
	end
end)

local wheelsOn = true
function UpdateWheelsState()
	wheelsOn = not wheelsOn
	if wheelsOn then
		tweenService:Create(vehicle.F.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, 1.1, 0)
		}):Play()
		
		tweenService:Create(vehicle.BR.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, 0.53, 0)
		}):Play()
		
		tweenService:Create(vehicle.BL.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, 0.53, 0)
		}):Play()
	else
		tweenService:Create(vehicle.F.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0.51, 1.1, 0) * CFrame.Angles(0, 0, math.pi/2)
		}):Play()
		
		tweenService:Create(vehicle.BL.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, 0.53, -0.29) * CFrame.Angles(math.pi/2, 0, 0)
		}):Play()
		
		tweenService:Create(vehicle.BR.Inner.Weld, TweenInfo.new(2, Enum.EasingStyle.Quint), {
			C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, 0.55, 0.29) * CFrame.Angles(-math.pi/2, 0, 0)
		}):Play()
	end;
end;

local zoom = 55

targetUI.Enabled = true
local speed = 0;
local rot = Vector3.zero
local rotLerp = rot
local targetPosLerp = UDim2.fromScale(targetTrack.Position.X.Scale, targetTrack.Position.Y.Scale)

local cameraFixDt = 0
statsUI.Enabled = true

local windL = vehicle:WaitForChild("WindL"):WaitForChild("Trail");
local windR = vehicle:WaitForChild("WindR"):WaitForChild("Trail");

local cameraRoll = 0

local verticalMode = false

local lastPos = body.Position
local lastVelocityUpdate = 0

local isInFPS = false

-- local fuelProp = statsUI:WaitForChild("Container"):WaitForChild("Fuel"):WaitForChild("Proportion");

local fuel = vehicle:WaitForChild("Fuel");
local maxFuel = vehicle:WaitForChild("MaxFuel");


local fuelPerMinute = vehicle:WaitForChild("FuelPerMinute");

local total = 9
local ds = maxSpeed/(total + 1)
for i = 1, total do
	local currS =  math.round(ds*i/10)*10
	statsUI:WaitForChild("Container"):WaitForChild("Speed"):WaitForChild(tostring(i)).Text = tostring(currS)
end;

local sonic = vehicle:WaitForChild("Sonic");

runService.RenderStepped:Connect(function(dt)
	if stop.Value then
		return
	end

	cameraFixDt += dt
	local f = vehicleSeat.Throttle
	local s = vehicleSeat.Steer
	local u = userInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0
	u = u - (userInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0)
	local r = userInputService:IsKeyDown(Enum.KeyCode.C) and 1 or 0
	r = r - (userInputService:IsKeyDown(Enum.KeyCode.Z) and 1 or 0)
	
	if localPlayer.Character then
		if localPlayer.Character:FindFirstChild("Humanoid").Health == 0 then
			stop.Value = true
			return
		end;
	end;

	userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	local delta = userInputService:GetMouseDelta()
	rot = rot + Vector3.new((-delta.Y / camera.ViewportSize.Y) * 2 * math.pi, (-delta.X / camera.ViewportSize.X) * 2 * math.pi, 0)
	
	cameraFixDt = 0

	rotLerp = rotLerp:Lerp(rot, dt*20) * Vector3.new(1, 1, 0) + Vector3.zAxis*(rotLerp.Z)

	if not IsGrounded() then
		bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, 0, u * math.pi / 2 * dt) * CFrame.Angles(s * math.pi / 2 * dt, 0, 0) * CFrame.Angles(0, -math.pi / 5 * dt * r, 0)
		-- rotLerp = rotLerp * Vector3.new(1, 1, 0) + Lerp(rotLerp.Z, 0, dt*2)*Vector3.zAxis
	else
		bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, -math.pi / 5 * dt * s, 0) * CFrame.Angles(0, 0, u * math.pi / 2 * dt)
		speed += -math.sign(speed)*acceleration/3*dt
		rotLerp = rotLerp * Vector3.new(1, 1, 0) + Vector3.zAxis * Lerp(rotLerp.Z, math.sin(tick()*15)*math.pi/35*(speed/maxSpeed), dt*10)
	end

	bodyForce.Force = Vector3.yAxis * (body:GetMass() * workspace.Gravity)
	engines.PlaybackSpeed = Lerp(engines.PlaybackSpeed, f > 0 and 1.9 or 0.5, dt * 2)
	flamerFire.Enabled = f > 0 and fuel.Value > 0
	
	if (f == 0) then
		speed -= (speed/5)^2/(2*maxSpeed)*dt
	end
	
	if fuel.Value <= 0 then
		f = math.min(f, 0)
	end;
	
	speed = math.clamp(speed + f*acceleration*dt, minSpeed, maxSpeed)
	
	innerEngine.Color = innerEngine.Color:Lerp((f > 0 and fuel.Value > 0) and Color3.fromRGB(246, 196, 255) or Color3.fromRGB(0, 0, 0), dt * 25)
	
	if verticalMode then
		linearVelocity.VectorVelocity = ((body.CFrame * CFrame.Angles(0, 0, -math.pi/3)).UpVector)*speed/4
	else
		linearVelocity.VectorVelocity = body.CFrame.RightVector*speed + Vector3.yAxis*(-20)
	end;
	
	camera.CameraType = Enum.CameraType.Scriptable
	
	local c0 = body.CFrame
	if isInFPS then
		camera.CFrame = vehicle:WaitForChild("Glass").CFrame * CFrame.Angles(0, -math.pi / 2, 0) * CFrame.Angles(0, rotLerp.Y, 0) * CFrame.Angles(rotLerp.X, 0, 0) * CFrame.Angles(0, 0, rotLerp.Z)
	else
		camera.CFrame = body.CFrame * CFrame.Angles(0, -math.pi / 2, 0) * CFrame.Angles(0, rotLerp.Y, 0) * CFrame.Angles(rotLerp.X, 0, 0) * CFrame.Angles(0, 0, rotLerp.Z)  * CFrame.new(0, 0, zoom) * CFrame.new(0, 7, 0)
	end;
	
	camera.FieldOfView = 90
	
	userInputService.MouseIconEnabled = false
	
	local target = CalculateTargetVector()
	if typeof(target) == typeof(Vector3.zero) then
		for _, sect in next, targetTrack:GetChildren() do
			if sect.Name == "SectionFrame" then
				if sect.BackgroundColor3 == Color3.fromRGB(255, 255, 255) then
					break
				end;
				
				sect.BackgroundColor3 = sect.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), dt*15)
			end;
			
			targetTrack.DistanceText.Text = ""
		end;
	else
		target = target.Position
		for _, sect in next, targetTrack:GetChildren() do
			if sect.Name == "SectionFrame" then
				if sect.BackgroundColor3 == Color3.fromRGB(255, 0, 0) then
					break
				end;
				
				sect.BackgroundColor3 = sect.BackgroundColor3:Lerp(Color3.fromRGB(255, 0, 0), dt*15)
			end;
		end;
		
		targetTrack.DistanceText.Text = math.floor((target - body.Position).Magnitude).. "m"
	end;
	
	if userInputService:IsKeyDown(Enum.KeyCode.V) or cameraFixDt >= 1.35 then
		rot = rot:Lerp(Vector3.zero, dt*5)
	end;
	
	local convPos, inCamera = camera:WorldToScreenPoint(target)
	targetUI.Enabled = inCamera

	targetPosLerp = targetPosLerp:Lerp(UDim2.fromScale(convPos.X/targetTrack.Parent.AbsoluteSize.X, convPos.Y/targetTrack.Parent.AbsoluteSize.Y), dt*15)
	targetTrack.Position = targetPosLerp
	
	lastVelocityUpdate += dt
	if lastVelocityUpdate >= 0.05 then
		lastVelocityUpdate = 0
		
		local alpha = speed/maxSpeed
		statsUI.Container.Speed.Rotor.Rotation = alpha*360
		statsUI.Container.Speed.Rotor.Position = UDim2.fromScale(0.5 + math.cos(2*math.pi*alpha - math.pi/2)*0.1, 0.5 + math.sin(2*math.pi*alpha - math.pi/2)*0.1)
	end;

	lastPos = body.Position
	
	local alpha = body.Position.Y/5000
	statsUI.Container.Alt.Rotor.Rotation = alpha*360
	statsUI.Container.Alt.Rotor.Position = UDim2.fromScale(0.5 + math.cos(2*math.pi*alpha - math.pi/2)*0.2, 0.5 + math.sin(2*math.pi*alpha - math.pi/2)*0.2)
	
	local currentSpeed = speed
	if verticalMode then
		currentSpeed /= 3
	end;
	
	windL.Enabled = currentSpeed >= 225
	windR.Enabled = currentSpeed >= 225
	
	
	
	fuel.Value = math.max(fuel.Value - fuelPerMinute.Value/60*dt*(math.abs(speed/maxSpeed)), 0)
	-- fuelProp.Size = UDim2.fromScale(fuel.Value/maxFuel.Value, 1)
	
	sonic:WaitForChild("Effect").Enabled = (speed > 660 and speed < 660 + 50)
end)

local fireIndex = 1
local missile = require(replicatedStorage:WaitForChild("Missile"))

userInputService.InputChanged:Connect(function(input, gpe)
	if not gpe then
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local dir = input.Position.Z
			zoom = math.clamp(zoom - dir*10, 55, 190)
		end;
	end;
end)

local bombDrop = replicatedStorage:WaitForChild("BombDrop");

local bomb = require(replicatedStorage:WaitForChild("Bomb"));

userInputService.InputBegan:Connect(function(input, gpe)
	if not gpe then
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local model = missileFire:InvokeServer(vehicle, fireIndex)
			fireIndex = fireIndex + 1
			if fireIndex > 2 then
				fireIndex = 1
			end
			
			local obj = missile.new(model)
			local target = CalculateTargetVector()
			obj:Thrust(target, {vehicle, localPlayer.Character}, vehicle:FindFirstChild("Rocket".. fireIndex))
		end
		
		if input.KeyCode == Enum.KeyCode.G then
			if not IsGrounded() then
				UpdateWheelsState()
			end;
		end;
		
		if input.KeyCode == Enum.KeyCode.X then
			isInFPS = not isInFPS
		end;
		
		if input.KeyCode == Enum.KeyCode.H then
			local currentSpeed = speed
			if verticalMode then
				currentSpeed /= 3
			end;
			
			if currentSpeed < 25 then
				verticalMode = not verticalMode
				tweenService:Create(vehicle.Engine.Weld, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					C0 = verticalMode and CFrame.new(0, -0.5, 0) * CFrame.new(-1.6, 0, 0) * CFrame.Angles(0, math.pi, -math.pi/4) or CFrame.new(1.65, 0.2, 0) * CFrame.new(-4, 0, 0) * CFrame.Angles(0, math.pi, 0)
				}):Play()
			end;
		end;
		
		if input.KeyCode == Enum.KeyCode.B then
			local bombInst = bombDrop:InvokeServer(vehicle)
			local bombObj = bomb.new(bombInst)
			bombObj:Drop(vehicle, {vehicle, localPlayer.Character})
		end;
	end
end)
