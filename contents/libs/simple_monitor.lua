Monitor = { monitor = nil }
Monitor.__index = Monitor

function Monitor:new(monitor, scale)
    setmetatable({}, Monitor)
    self.monitor = monitor
    self.scale = scale or 1.0
    return self
end

function Monitor:print(text, textColor, backgroundColor)
    self.monitor.setTextColor(textColor or colors.white)
    self.monitor.setBackgroundColor(backgroundColor or colors.black)
    self.monitor.write(text or "")
end

function Monitor:println(text, textColor, backgroundColor)
    self:print(text, textColor, backgroundColor)
    local _, y = self.monitor.getCursorPos()
    self.monitor.setCursorPos(1, y + 1)
end

function Monitor:clear()
    self.monitor.clear()
    self.monitor.setCursorPos(1, 1)
end

return {
    Monitor = Monitor,
}
