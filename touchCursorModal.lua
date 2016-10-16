local keyStroke = require("keyStrokeMapper")

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
function notify(msg) 
  if module.debug then 
    hs.alert(msg) 
    hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
  end
end

-- When spacebar has been held down long enough
function onCountDown() 
  --notify("Timer expired")
  module.countDownTimer = nil
  shouldSendSpace = false 
end

-- Pressing space starts a timer and enters touch-cursor mode
function pressedSpace()
    touchCursor:enter()
    shouldSendSpace = true
    module.countDownTimer = hs.timer.doAfter(module.timeFrame, onCountDown)
    --notify("TouchCursor ON")
end

--[[  exits touch-cursor mode and stops timer. If spacebar has not been held down longer than 
      module.timeframe then a "real" space key-stroke is sent.
]]--
function releasedSpace()
  --notify("releasedSpace")
  touchCursor:exit()
  if module.countDownTimer then module.countDownTimer:stop() end
  module.countDownTimer = nil
  if shouldSendSpace then 
    --notify("sending space")
    disableTC()
    hs.eventtap.keyStroke({}, 'space') 
    enableTC()
  end
  --notify("TouchCursor OFF")
end 

function holdingSpace()
  --Do nothing here 
  --notify("Holding Space")
end

function enableTC()
  enterTC:enable()
  enterTC2:enable()
  enterTC3:enable()
  enterTC4:enable()
end

function disableTC()
  enterTC:disable()
  enterTC2:disable()
  enterTC3:disable()
  enterTC4:disable()
end

function onAppEvent(appName, event, app)
  if appName == 'Parallels Desktop' then
    if event == hs.application.watcher.activated then
      --notify("Disabling TC")
      disableTC()
    elseif event == hs.application.watcher.deactivated then
      --notify("Enabling TC")
      enableTC()
    end
  end
end 

-- Setup space as hotkey for TouchCursor mode
  enterTC = hs.hotkey.bind({}, "space", pressedSpace, releasedSpace, holdingSpace)
  enterTC2 = hs.hotkey.bind({"shift"}, "space", pressedSpace, releasedSpace, holdingSpace)
  enterTC3 = hs.hotkey.bind({"alt"}, "space", pressedSpace, releasedSpace, holdingSpace)
  enterTC4 = hs.hotkey.bind({"shift", "alt"}, "space", pressedSpace, releasedSpace, holdingSpace)  

-- Disable TouchCursor in Parallels Desktop
appWatcher = hs.application.watcher.new(onAppEvent):start()

-- Setup arrow key navigation
mapFull(touchCursor, 'N', 'Left')
mapFull(touchCursor, 'U', 'Up')
mapFull(touchCursor, 'E', 'Down')
mapFull(touchCursor, 'I', 'Right')

-- Setup additional navigation keys
map(touchCursor, {}, 'H', {}, 'pageup')
map(touchCursor, {"shift"}, 'H', {"shift"}, 'pageup')
map(touchCursor, {}, 'K', {}, 'pagedown')
map(touchCursor, {"shift"}, 'K', {"shift"}, 'pagedown')
map(touchCursor, {}, 'L', {"cmd"}, 'Left')
map(touchCursor, {"shift"}, 'L', {"shift", "cmd"}, 'Left')
map(touchCursor, {}, 'Y', {"cmd"}, 'Right')
map(touchCursor, {"shift"}, 'Y', {"shift", "cmd"}, 'Right')

-- Setup other useful keys
map(touchCursor, {}, 33, {}, 'escape') -- Ö
map(touchCursor, {}, 'M', {}, 'forwarddelete')

return module