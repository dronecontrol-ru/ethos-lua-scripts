-- Lua Gauge widget

local translations = {en="AF-Atty", fr="AF-Atty"}


local function name(widget)
    local locale = system.getLocale()
    return translations[locale] or translations["en"]
end

local function create()
    return {
        colorData = lcd.RGB(0xEA, 0x5E, 0x00), 
        colorSky = lcd.RGB(0x55, 0x89, 0xc9), 
        colorGround = lcd.RGB(0x73, 0x49, 0x31),
        colorPlane = lcd.RGB(0xC0, 0xC0, 0xC0),
        pitch = 0,
        roll = 0
    }
end

local function wakeup(widget)
    if widget.sensorPitch == nil then
        widget.sensorPitch = system.getSource("Pitch")
    end
    if widget.sensorRoll == nil then
        widget.sensorRoll = system.getSource("Roll")
    end

    if widget.sensorPitch and widget.sensorRoll then
        local pitch = widget.sensorPitch:value()
        local roll = widget.sensorRoll:value()
        if widget.pitch ~= pitch or widget.roll ~= roll then
            widget.pitch = pitch
            widget.roll = roll
            lcd.invalidate()
        end
    end
end

local function rotateX(cX, pX, deg)
    return cX + (pX - cX) * math.cos(math.rad(deg))
end

local function rotateY(cY, pY, deg)
    return cY + (pY - cY) * math.sin(math.rad(deg))
end

local function paint(widget)
    if widget.sensorPitch == nil or widget.sensorRoll == nil then
        return
    end

    
    -- local p = widget.sensorPitch:value()
    -- local r = widget.sensorRoll:value()

    local p = widget.pitch
    local r = widget.roll

    print("Atty: ", p, r, "\n")

    local w, h = lcd.getWindowSize()
    local l = h / 2
    
    
    -- Sky
    lcd.color(widget.colorSky);
    lcd.drawFilledRectangle(0, 0, w, h)

    -- Ground
    lcd.color(widget.colorGround)
    lcd.drawFilledRectangle(0, h / 2 + h / 2 * math.sin(math.rad(-1 * p)) , w, h)

    -- Airplane

    lcd.color(widget.colorPlane)
    lcd.drawLine(rotateX(w/2, w/2-l/2, r), rotateY(h/2, h/2-l/2, r), rotateX(w/2, w/2 + l/2, r), rotateY(h/2, h/2 + l/2, r))
    lcd.drawLine(w/2, h/2, rotateX(w/2, w/2 + l/3, r - 90), rotateY(h/2, h/2 + l/3, r - 90))

    -- Data
    -- lcd.color(widget.colorData)
    -- lcd.font(FONT_S)
    -- lcd.drawText(0, 0, widget.sensorPitch:stringValue())
    -- lcd.drawText(screenW/2, 0, widget.sensorRoll:stringValue())

end



local function configure(widget)
    -- Color
    line = form.addLine("Text color")
    form.addColorField(line, nil, function() return widget.colorData end, function(value) widget.colorData = value end)

    line = form.addLine("Sky color")
    form.addColorField(line, nil, function() return widget.colorSky end, function(value) widget.colorSky = value end)

    line = form.addLine("Ground color")
    form.addColorField(line, nil, function() return widget.colorGround end, function(value) widget.colorGround = value end)

    line = form.addLine("Plane color")
    form.addColorField(line, nil, function() return widget.colorPlane end, function(value) widget.colorPlane = value end)

    
end

local function read(widget)
    widget.colorData = storage.read("colorData")
    widget.colorSky = storage.read("colorSky")
    widget.colorGround = storage.read("colorGround")
    widget.colorPlane = storage.read("colorPlane")
end

local function write(widget)
    storage.write("colorData", widget.colorData)
    storage.write("colorSky", widget.colorSky)
    storage.write("colorGround", widget.colorGround)
    storage.write("colorPlane", widget.colorPlane)
end

local function init()
    system.registerWidget({key="af-atty", name=name, create=create, paint=paint, wakeup=wakeup, configure=configure, read=read, write=write})
end

return {init=init}
