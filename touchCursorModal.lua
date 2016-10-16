local module = {}

-- Settings
--[[  module.timeFrame [seconds]
      If the spacebar is released within this time it will count as a real key-stroke.
      If released after this time it will not trigger a space key-stroke
      module.debug
      Set to true to enable alerts
]]--
module.timeFrame = 0.2
module.debug = false

-- Modal hotkey for Touch-cursor mode
local touchCursor = hs.hotkey.modal.new()

-- Publishes an alert if in debug mode
local function notify(msg) 
  if module.debug then hs.alert(msg) end
end

-- When spacebar has been held down long enough
function onCountDown()
  notify("Timer expired")
  module.countDownTimer = nil
  module.shouldSendSpace = false 
end

-- Pressing space starts a timer and enters touch-cursor mode
function pressedSpace()
    touchCursor:enter()
    module.shouldSendSpace = true
    module.countDownTimer = hs.timer.doAfter(module.timeFrame, onCountDown)
    notify("TouchCursor ON")
end

--[[  exits touch-cursor mode and stops timer. If spacebar has not been held down longer than 
      module.timeframe then a "real" space key-stroke is sent.
]]--
function releasedSpace()
  notify("releasedSpace")
  touchCursor:exit()
  if module.countDownTimer then module.countDownTimer:stop() end
  module.countDownTimer = nil
  if module.shouldSendSpace then 
    notify("sending space")
    enterTC:disable()
    hs.eventtap.keyStroke({}, 'space') 
    enterTC:enable()
  end
  notify("TouchCursor OFF")
end 

function holdingSpace()
  --Do nothing here 
  --notify("Holding Space")
end

-- Helper method for sending a keystroke
function send(modifier, key)
  --notify("send {" .. table.concat(modifier, ", ") .. "} " .. key)
  hs.eventtap.keyStroke(modifier, key)
end

-- Helper method for mapping one keystroke to another one
function map(modifierFrom, keyFrom, modifierTo, keyTo)
  touchCursor:bind(modifierFrom, keyFrom, function() send(modifierTo, keyTo) end, nil, function() send(modifierTo, keyTo) end)
end

--[[  Helper method that performs all necessary mappings for arrow-keys functionality, 
      i.e. adds mapping for all suitable modifiers.
]]--
function mapFull(keyFrom, keyTo)
  map({}, keyFrom, {}, keyTo)

  map({"shift"}, keyFrom, {"shift"}, keyTo)
  map({"alt"}, keyFrom, {"alt"}, keyTo)
  map({"cmd"}, keyFrom, {"cmd"}, keyTo)
  map({"shift, alt"}, keyFrom, {"shift", "alt"}, keyTo)
  map({"shift", "cmd"}, keyFrom, {"shift", "cmd"}, keyTo)
end

-- Setup space as hotkey for TouchCursor mode
enterTC = hs.hotkey.bind({}, "space", pressedSpace, releasedSpace, holdingSpace)

-- Setup arrow key navigation
mapFull('N', 'Left')
mapFull('U', 'Up')
mapFull('E', 'Down')
mapFull('I', 'Right')

-- Setup additional navigation keys
map({}, 'H', {}, 'pageup')
map({"shift"}, 'H', {"shift"}, 'pageup')
map({}, 'K', {}, 'pagedown')
map({"shift"}, 'K', {"shift"}, 'pagedown')
map({}, 'L', {"cmd"}, 'Left')
map({}, 'Y', {"cmd"}, 'Right')

-- Setup other useful keys
map({}, 33, {}, 'escape') -- Ö
map({}, 'M', {}, 'forwarddelete')

return module