local money = game:GetService("Players").LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Dollars");

--[[
function Suffix(n)
	if n < 1000 then
		return tostring(n)
	end;
	
	local suffixes = {"K", "M", "B"}
	for i = 1, #suffixes do
		if n < 1000^(i + 1)   then
			return string.format("%.2f", n/(1000^i)).. suffixes[i]
		end;
	end;
	
	return string.format("%.2f", n/(1000^#suffixes)).. suffixes[#suffixes]
end;
]]

function CommaSeparate(n)
	n = tostring(n)
	local new = ""
	local iterations = 0
	for i = #n, 1, -1 do
		new = new.. string.sub(n, i, i)
		iterations += 1
		if iterations == 3 and i ~= 1 then
			new = new.. ","
			iterations = 0
		end;
	end;
	
	return string.reverse(new)
end;

function Update()
	script.Parent:WaitForChild("TextLabel").Text = CommaSeparate(money.Value)
end;

money:GetPropertyChangedSignal("Value"):Connect(Update)
Update()