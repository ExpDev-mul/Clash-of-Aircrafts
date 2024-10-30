local targets = workspace:WaitForChild("Targets");

local targetsTable = {}

for _, targetsContainer in pairs(targets:GetDescendants()) do
	if targetsContainer:IsA("Model") then
		local parent = targetsContainer.Parent
		targetsContainer.Parent = script
		
		local function Clone()
			local clone = targetsContainer:Clone()
			clone.Parent = parent
			clone.ChildRemoved:Connect(function()
				if #clone:GetChildren() == 0 then
					clone:Destroy()
					task.delay(60, function()
						Clone()
					end)
				end;
			end)
		end;
		
		Clone()
	end;
end;


function Respawn()
	for _, data in next, targetsTable do
		local clone =  data.Object:Clone()
		clone.Parent = data.Parent
	end;
end;

