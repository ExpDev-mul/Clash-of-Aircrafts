local tweenService = game:GetService("TweenService");

local cc = Instance.new("ColorCorrectionEffect");
cc.Parent = game:GetService("Lighting")

local activated = false
game:GetService("UserInputService").InputBegan:Connect(function(input, isGpe)
	if isGpe then return end;
	if input.KeyCode == Enum.KeyCode.N then
		activated = not activated
		tweenService:Create(cc, TweenInfo.new(0), {Brightness = (activated and 3 or 0), Contrast = (activated and 5 or 0), TintColor = (activated and Color3.fromRGB(0, 85, 0) or Color3.fromRGB(255, 255, 255))}):Play()
		game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NightVision").Enabled = activated
	end;
end)