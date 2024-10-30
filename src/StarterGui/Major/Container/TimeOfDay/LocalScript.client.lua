local lighting = game:GetService("Lighting");
lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	local ct = lighting.ClockTime
	if ct >= 13 then
		script.Parent.Text = tostring(math.floor(ct) - 12).. ":".. tostring(string.sub(lighting.TimeOfDay, 4, 5)) .. " PM"
	else
		script.Parent.Text = tostring(math.floor(ct)).. ":".. tostring(string.sub(lighting.TimeOfDay, 4, 5)).. " AM"
	end;
end)