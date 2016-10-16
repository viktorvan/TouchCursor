-- Helper method for sending a keystroke
function send(modifier, key)
  --notify("send {" .. table.concat(modifier, ", ") .. "} " .. key)
  if not isVirtualMachine() then 
    --notify('in send ' .. table.concat(modifier, ', ') .. ' ' .. key)
    hs.eventtap.keyStroke(modifier, key) 
  end
end

function isVirtualMachine()
  local app = hs.application.frontmostApplication()
  --notify(app:name())
  return app:name() == "Parallels Desktop"
end

-- Helper method for mapping one keystroke to another one
function map(hotkey, modifierFrom, keyFrom, modifierTo, keyTo)
  hotkey:bind(modifierFrom, keyFrom, function() send(modifierTo, keyTo) end, nil, function() send(modifierTo, keyTo) end)
end

--[[  Helper method that performs all necessary mappings for arrow-keys functionality, 
      i.e. adds mapping for all suitable modifiers.
]]--
function mapFull(hotkey, keyFrom, keyTo)
  map(hotkey, {}, keyFrom, {}, keyTo)

  map(hotkey, {"shift"}, keyFrom, {"shift"}, keyTo)
  map(hotkey, {"alt"}, keyFrom, {"alt"}, keyTo)
  map(hotkey, {"cmd"}, keyFrom, {"cmd"}, keyTo)
  map(hotkey, {"shift, alt"}, keyFrom, {"shift", "alt"}, keyTo)
  map(hotkey, {"shift", "cmd"}, keyFrom, {"shift", "cmd"}, keyTo)
end