-- Lua Gauge widget

local translations = {en="DC-Atty", fr="DC-Atty"}


local function name(widget)
    local locale = system.getLocale()
    return translations[locale] or translations["en"]
end

local function create()
    return {
        colorData = lcd.RGB(0xEA, 0x5E, 0x00), 
        colorSky = lcd.RGB(0x55, 0x89, 0xb9), 
        colorGround = lcd.RGB(0x73, 0x49, 0x31),
        colorPlane = lcd.RGB(0xC0, 0xC0, 0xC0),
        sensorPitch = nil, 
        sensorRoll = nil, 
        valuePitch = 0,
        valueRoll = 0
    }
end

local function angleRatio(angle)
    return {
        sin = math.sin(angle), 
        cos = math.cos(angle)
    }
end

local Angle = {}
function Angle:new(angle)
  local obj = {
    angle = angle,
    sin = math.sin(angle),
    cos = math.cos(angle)
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

local function rotate(x, y, ratio) 
    return {
        x = math.floor(ratio.cos * x - ratio.sin * y + 0.5),
        y = math.floor(ratio.sin * x + ratio.cos * y + 0.5)
    }
end

local function angleLine(angle, pointCenter, x1, y1, x2, y2)
    local pointStart = rotate(x1, y1, angle);
    local pointFinish = rotate(x2, y2, angle);
    lcd.drawLine(pointCenter.x + pointStart.x, pointCenter.y + pointStart.y, pointCenter.x + pointFinish.x, pointCenter.y + pointFinish.y)
end

local function paint(widget)
    if widget.sensorPitch == nil or widget.sensorRoll == nil then
        return
    end


    local pitch = Angle:new(widget.sensorPitch:value())
    local roll = Angle:new(widget.sensorRoll:value())

    local screenW, screenH = lcd.getWindowSize()
    
    local pointCenter = {
        x = screenW / 2,
        y = screenH / 2
    }
    
    
    -- Sky
    lcd.color(widget.colorSky)
    lcd.drawFilledRectangle(0, 0, screenW, screenH)

    -- Ground
    lcd.color(widget.colorGround)
    lcd.drawFilledRectangle(0, pointCenter.y - pitch.angle / math.pi * screenH , screenW, screenH)

    -- Airplane

    local wingspanHalf = screenH / 4

    lcd.color(widget.colorPlane)

    angleLine(roll, pointCenter, wingspanHalf * -1, -1, wingspanHalf, -1)
    angleLine(roll, pointCenter, wingspanHalf * -1, 0, wingspanHalf, 0)
    angleLine(roll, pointCenter, wingspanHalf * -1, 1, wingspanHalf, 1)


    angleLine(roll, pointCenter, -2, 0, -1, wingspanHalf * -1)
    angleLine(roll, pointCenter, -1, 0, -1, wingspanHalf * -1)
    angleLine(roll, pointCenter, 0, 0, 0, wingspanHalf * -1)
    angleLine(roll, pointCenter, 1, 0, 1, wingspanHalf * -1)
    angleLine(roll, pointCenter, 2, 0, 1, wingspanHalf * -1)

    -- Data
    lcd.color(widget.colorData)
    lcd.font(FONT_S)
    lcd.drawText(0, 0, widget.sensorPitch:stringValue())
    lcd.drawText(screenW/2, 0, widget.sensorRoll:stringValue())

end

local function wakeup(widget)
    if widget.sensorPitch and widget.sensorRoll then
        local valuePitchNew = widget.sensorPitch:value()
        local valueRollNew = widget.sensorRoll:value()
        if widget.valuePitch ~= valuePitchNew or widget.valueRoll ~= valueRollNew then
            widget.valuePitch = valuePitchNew
            widget.valueRoll = valueRollNew
            lcd.invalidate()
        end
    end
end

local function configure(widget)
    -- Source choice
    line = form.addLine("Pitch")
    form.addSourceField(line, nil, function() return widget.sensorPitch end, function(value) widget.sensorPitch = value end)

    line = form.addLine("Roll")
    form.addSourceField(line, nil, function() return widget.sensorRoll end, function(value) widget.sensorRoll = value end)

    -- Color
    line = form.addLine("Data color")
    form.addColorField(line, nil, function() return widget.colorData end, function(value) widget.colorData = value end)

    line = form.addLine("Sky color")
    form.addColorField(line, nil, function() return widget.colorSky end, function(value) widget.colorSky = value end)

    line = form.addLine("Ground color")
    form.addColorField(line, nil, function() return widget.colorGround end, function(value) widget.colorGround = value end)

    line = form.addLine("Plane color")
    form.addColorField(line, nil, function() return widget.colorPlane end, function(value) widget.colorPlane = value end)

    
end

local function read(widget)
    widget.sensorPitch = storage.read("sensorPitch")
    widget.sensorRoll = storage.read("sensorRoll")
    widget.colorData = storage.read("colorData")
    widget.colorSky = storage.read("colorSky")
    widget.colorGround = storage.read("colorGround")
    widget.colorPlane = storage.read("colorPlane")
end

local function write(widget)
    storage.write("sensorPitch", widget.sensorPitch)
    storage.write("sensorRoll", widget.sensorRoll)
    storage.write("colorData", widget.colorData)
    storage.write("colorSky", widget.colorSky)
    storage.write("colorGround", widget.colorGround)
    storage.write("colorPlane", widget.colorPlane)
end

local function init()
    system.registerWidget({key="dc-atty", name=name, create=create, paint=paint, wakeup=wakeup, configure=configure, read=read, write=write})
end

return {init=init}
