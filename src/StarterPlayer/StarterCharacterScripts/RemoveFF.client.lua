local ff = script.Parent:FindFirstChildOfClass("ForceField")
if ff then
	print("Removed forcefield from character.")
	ff:Destroy()
end;

script:Destroy()