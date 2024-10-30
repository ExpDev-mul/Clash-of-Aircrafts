local lighting = script.Parent;

local dayPeriod = 13
local nightPeriod = 24 - dayPeriod

local dayStep = dayPeriod/(60*6); -- 6 minutes
local nightStep = nightPeriod/(60*4); -- 4 minutes

function IsDay()
	return lighting.ClockTime > 8 and lighting.ClockTime < 8 + dayPeriod
end;


while true do
	local dt = task.wait(0.5)
	lighting.ClockTime = lighting.ClockTime + (IsDay() and dayStep*dt or nightStep*dt)
end;