-- Settings
local module = {}
module.timeFrame = 0.2
module.debug = false

-- Modal hotkey for Touch-cursor mode
local touchCursor = hs.hotkey.modal.new()

local function notify(msg) 
  if module.debug then hs.alert(msg) end
end

function onCountDown()
  notify("Timer expired")
  module.countDownTimer = nil
  module.shouldSendSpace = false 
end

function pressedSpace()
    touchCursor:enter()
    module.shouldSendSpace = true
    module.countDownTimer = hs.timer.doAfter(module.timeFrame, onCountDown)
    notify("TouchCursor ON")
end

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
  --notify("Holding Space")
end

function send(modifier, key)
  --notify("send {" .. table.concat(modifier, ", ") .. "} " .. key)
  hs.eventtap.keyStroke(modifier, key)
end

function map(modifierFrom, keyFrom, modifierTo, keyTo)
  touchCursor:bind(modifierFrom, keyFrom, function() send(modifierTo, keyTo) end, nil, function() send(modifierTo, keyTo) end)
end

function mapFull(keyFrom, keyTo)
  map({}, keyFrom, {}, keyTo)

  map({"shift"}, keyFrom, {"shift"}, keyTo)
  map({"alt"}, keyFrom, {"alt"}, keyTo)
  map({"cmd"}, keyFrom, {"cmd"}, keyTo)
  map({"shift, alt"}, keyFrom, {"shift", "alt"}, keyTo)
  map({"shift", "cmd"}, keyFrom, {"shift", "cmd"}, keyTo)
end

enterTC = hs.hotkey.bind({}, "space", pressedSpace, releasedSpace, holdingSpace)

mapFull('N', 'Left')
mapFull('U', 'Up')
mapFull('E', 'Down')
mapFull('I', 'Right')

map({}, 'H', {}, 'pageup')
map({"shift"}, 'H', {"shift"}, 'pageup')
map({}, 'K', {}, 'pagedown')
map({"shift"}, 'K', {"shift"}, 'pagedown')
map({}, 'L', {"cmd"}, 'Left')
map({}, 'Y', {"cmd"}, 'Right')

map({}, 33, {}, 'escape') -- Ö
map({}, 'M', {}, 'forwarddelete')

return module