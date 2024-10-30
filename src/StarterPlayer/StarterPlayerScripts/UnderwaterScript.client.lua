local runService = game:GetService("RunService");
local lighting = game:GetService("Lighting");

local blur = Instance.new("BlurEffect", lighting)
blur.Size = 0

local cc = Instance.new("ColorCorrectionEffect", lighting)

local camera = workspace.CurrentCamera

function Lerp(a, b, t)
	return a + (b - a) * t
end

runService.RenderStepped:Connect(function(dt)
	if camera.CFrame.Position.Y < -0.5 then
		blur.Size = Lerp(blur.Size, 50, dt*15)
		cc.TintColor = cc.TintColor:Lerp(Color3.fromRGB(0, 170, 255), dt*15)
		cc.Brightness = Lerp(cc.Brightness, 0.3, dt*15)
	else
		blur.Size = Lerp(blur.Size, 0, dt*15)
		cc.TintColor = cc.TintColor:Lerp(Color3.fromRGB(255, 255, 255), dt*15)
		cc.Brightness = Lerp(cc.Brightness, 0, dt*15)
	end;
end)