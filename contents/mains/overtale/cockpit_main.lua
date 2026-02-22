local basalt = require(".libs.basalt")
local data = require(".libs.data")
local physics = require(".libs.physics")
local sc = require(".libs.simple_commands")

local monitorLeftName = settings.get("monitor_left")
local monitorMiddleName = settings.get("monitor_middle")
local monitorRightName = settings.get("monitor_right")
local monitorTopName = settings.get("monitor_top")

if not (monitorLeftName and monitorMiddleName and monitorRightName and monitorTopName) then
	error(
		"Not all monitors were specified in the settings. " ..
		"Please use 'set monitor_left', -middle, -right and -top " ..
		"to specify the peripheral names of the monitors (e.g. 'monitor_0')."
	)
end

local monitorLeft = peripheral.wrap(monitorLeftName)
local monitorMiddle = peripheral.wrap(monitorMiddleName)
local monitorRight = peripheral.wrap(monitorRightName)
local monitorTop = peripheral.wrap(monitorTopName)
monitorLeft.clear()
monitorMiddle.clear()
monitorRight.clear()
monitorTop.clear()

local frameLeft = basalt.createFrame():setTerm(monitorLeft):setBackground(colors.black)
local frameMiddle = basalt.createFrame():setTerm(monitorMiddle):setBackground(colors.black)
local frameRight = basalt.createFrame():setTerm(monitorRight):setBackground(colors.black)
local frameTop = basalt.createFrame():setTerm(monitorTop):setBackground(colors.black)

local send
peripheral.find("modem",
	function(name, modem)
		if modem.isWireless() then
			send = sc.clientConnect("OvertaleControls", name)
		end
	end)

local isEngineOn = false
local lastFuel = nil
local lastPosition = nil
local speed = 0
local targetPosition = nil
local startPosition = nil

local function formatTime(seconds)
	local value = seconds
	local unit = "s"
	if value > 60 then
		value = value / 60
		unit = "min"
	end
	if value > 60 then
		value = value / 60
		unit = "h"
	end
	return string.format("%d %s", math.floor(value), unit)
end

local function repeatString(string, repeats)
	local final = ""
	for i = 1, repeats do
		final = final .. string
	end
	return final
end

local function setupLeft()
	monitorLeft.setTextScale(0.5)
	frameLeft:addButton()
		:setText("Stabilize")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 5)
		:setPosition(2, 2)
		:onClick(function()
			send("CANCEL")
			send("STABILIZE")
		end)
	frameLeft:addButton()
		:setText("Land")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 5)
		:setPosition(2, 8)
		:onClick(function()
			send("CANCEL")
			send("LAND 1")
		end)
	frameLeft:addButton()
		:setText("STOP")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 5)
		:setPosition(2, 14)
		:onClick(function()
			send("CANCEL")
		end)
	local engineButton = frameLeft:addButton()
		:setText("Engine")
		:setForeground(colors.gray)
		:setBackground(colors.red)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 4)
		:setPosition(2, 20)
	engineButton:onClick(function(self)
		isEngineOn = not isEngineOn
		if isEngineOn then
			engineButton:setForeground(colors.gray)
			engineButton:setBackground(colors.green)
		else
			engineButton:setForeground(colors.gray)
			engineButton:setBackground(colors.red)
		end
		send(isEngineOn and "ON" or "OFF")
	end)
end

local function setupMiddle()
	monitorMiddle.setTextScale(1.0)
	frameMiddle:addLabel()
		:setText("F")
		:setPosition(2, 2)
		:setForeground(colors.white)
	local fuelBar = frameMiddle:addProgressBar()
		:setDirection("up")
		:setProgressColor(colors.lime)
		:setProgress(50)
		:setBackground(colors.gray)
		:setSize(1, 15)
		:setPosition(2, 4)
	basalt.schedule(function()
		while true do
			local fuelLevel = tonumber(data.fetchLatestRecord("fuel")) / tonumber(data.fetchLatestRecord("max_fuel"))
			fuelBar:setProgress(math.ceil(100 * fuelLevel))
			local fuelColors = { colors.red, colors.orange, colors.yellow, colors.lime, colors.green, colors.green }
			fuelBar:setProgressColor(fuelColors[1 + math.floor(fuelLevel * 5)])
			sleep(10)
		end
	end)
	frameMiddle:addLabel()
		:setText("H")
		:setPosition(4, 2)
		:setForeground(colors.white)
	local heightSlider = frameMiddle:addSlider()
		:setMax(15)
		:setStep(15)
		:setHorizontal(false)
		:setBackground(colors.lightBlue)
		:setSliderColor(colors.white)
		:setSize(1, 15)
		:setPosition(4, 4)
		:onChange("step", function(self, value)
			local height = 60 + (15 - value) * 20
			local heightDiff = math.floor(height - physics.getLocation().y)
			sleep(1)
			if heightDiff > 0 then
				send("CANCEL")
				send(string.format("UP %d", heightDiff))
			else
				send("CANCEL")
				send(string.format("DOWN %d", heightDiff))
			end
		end)
	local heightIndicator = frameMiddle:addLabel()
		:setText("o")
		:setPosition(4, 18)
	basalt.schedule(function()
		local shouldSetStep = true
		while true do
			local height = math.ceil(physics.getLocation().y)
			local pos_y = 18 - math.ceil(math.max(math.min((height - 60), 300), 0) * (15 / 300))
			heightIndicator:setPosition(4, pos_y)
			if shouldSetStep then
				heightSlider:setStep(pos_y - 3)
				shouldSetStep = false
			end
			sleep(1)
		end
	end)
	frameMiddle:addLabel()
		:setText("S")
		:setPosition(6, 2)
		:setForeground(colors.white)
	local powerLabel = frameMiddle:addLabel()
		:setPosition(6, 18)
		:setText("0")
		:setForeground(colors.white)
	frameMiddle:addSlider()
		:setMax(15)
		:setStep(15)
		:setHorizontal(false)
		:setBackground(colors.red)
		:setSliderColor(colors.brown)
		:setSize(1, 15)
		:setPosition(6, 4)
		:onChange("step", function(self, value)
			powerLabel:setPosition(6, 3 + value):setText(string.format("%X", 15 - value))
			send("CANCEL")
			send(string.format("SPEED %d", 15 - value))
		end)
end

local function setupRight()
	monitorRight.setTextScale(0.5)
	frameRight:addButton()
		:setText("^")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 5)
		:setPosition(2, 2)
		:onClick(function()
			send("CANCEL")
			send("MOVE 300")
		end)
	frameRight:addButton()
		:setText("v")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 5)
		:setPosition(2, 8)
		:onClick(function()
			send("CANCEL")
			send("MOVE -300")
		end)
	frameRight:addButton()
		:setText("<-")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(6, 5)
		:setPosition(2, 14)
		:onClick(function()
			send("CANCEL")
			send("TURN -45")
		end)
	frameRight:addButton()
		:setText("->")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(6, 5)
		:setPosition(9, 14)
	frameRight:addButton()
		:setText("Brake")
		:setForeground(colors.green)
		:setBackground(colors.gray)
		:setForegroundState("clicked", colors.gray)
		:setBackgroundState("clicked", colors.lightGray)
		:setSize(13, 4)
		:setPosition(2, 20)
		:onClick(function()
			send("CANCEL")
			send("TURN 45")
		end)
end

local function setupTop()
	local labelPos = frameTop:addLabel()
		:setForeground(colors.white)
		:setPosition(2, 2)
	basalt.schedule(function()
		while true do
			labelPos:setText(string.format("C: %d/%d", physics.getLocation().x, physics.getLocation().z))
			sleep(0.1)
		end
	end)
	local labelFuel = frameTop:addLabel()
		:setForeground(colors.white)
		:setPosition(19, 2)
	basalt.schedule(function()
		while true do
			labelFuel:setForeground(colors.white)
			if not isEngineOn then
				labelFuel:setText(string.format("F: OFF"))
			else
				local thisFuel = data.fetchAverage("fuel", 48)
				if lastFuel ~= nil then
					local difference = (lastFuel - thisFuel) / 12
					if difference == 0 then
						labelFuel:setText(string.format("F: FULL"))
					elseif difference < 0 then
						local maxFuel = data.fetchLatestRecord("max_fuel")
						local fuelUntilFull = maxFuel - thisFuel
						local secondsUntilFull = fuelUntilFull / -difference
						labelFuel:setText("F: " .. formatTime(secondsUntilFull))
						labelFuel:setForeground(colors.lightGray)
					else
						local secondsUntilEmpty = thisFuel / difference
						labelFuel:setText("F: " .. formatTime(secondsUntilEmpty))
					end
				end
				lastFuel = thisFuel
			end
			sleep(12)
		end
	end)
	local labelSpeed = frameTop:addLabel()
		:setForeground(colors.white)
		:setPosition(32, 2)
	basalt.schedule(function()
		while true do
			local thisPosition = physics.getLocation()
			if lastPosition ~= nil then
				local distance = math.sqrt(math.abs(lastPosition.x - thisPosition.x) ^ 2 +
					math.abs(lastPosition.z - thisPosition.z) ^ 2)
				speed = distance / 0.5
				labelSpeed:setText(string.format("S: %d m/s", speed))
			end
			lastPosition = thisPosition
			sleep(0.5)
		end
	end)
	local labelTarget = frameTop:addLabel()
		:setForeground(colors.white)
		:setPosition(2, 4)
	basalt.schedule(function()
		while true do
			if targetPosition then
				labelTarget:setText(string.format("T: %d/%d", targetPosition.x, targetPosition.z))
			else
				labelTarget:setText("T: -----------")
			end
			sleep(1)
		end
	end)
	local labelProgress = frameTop:addLabel()
		:setForeground(colors.white)
		:setPosition(19, 4)
	basalt.schedule(function()
		while true do
			local charsFilled = 0
			local seconds = 0
			if targetPosition and startPosition then
				local distanceStartTarget = math.sqrt(math.abs(startPosition.x - targetPosition.x) ^ 2 +
					math.abs(startPosition.z - targetPosition.z) ^ 2)
				local distanceStartThis = math.sqrt(math.abs(startPosition.x - thisPosition.x) ^ 2 +
					math.abs(startPosition.z - thisPosition.z) ^ 2)
				charsFilled = math.floor(30 * (distanceStartThis / distanceStartTarget))
				seconds = (distanceStartTarget - distanceStartThis) / speed
			end
			local charsEmpty = 30 - charsFilled
			labelProgress:setText(string.format("[%s%s] (%s)", repeatString("=", charsFilled),
				repeatString(" ", charsEmpty), formatTime(seconds)))
			sleep(1)
		end
	end)
end

setupLeft()
setupMiddle()
setupRight()
setupTop()

basalt.run()
