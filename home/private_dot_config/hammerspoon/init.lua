
-- Minimal key sniffer (toggle it off by restarting Hammerspoon)
-- if _G.__tap then _G.__tap:stop() end
-- _G.__tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
--   local code = e:getKeyCode()
--   local name = hs.keycodes.map[code]
--   hs.alert.show(("keyCode=%s  name=%s"):format(code, tostring(name)))
--   print("keyDown:", code, name)
--   return false
-- end):start()

-- === App-aware F18 mute ===
local app = require("hs.application")

local function stroke(mods, key) -- quick key press
  hs.eventtap.keyStroke(mods, key, 0)
end

local function routeMute()
  local front = app.frontmostApplication()
  if not front then return end
  local bundle = front:bundleID() or ""

  if bundle == "com.microsoft.teams2" or bundle == "com.microsoft.teams" then
    stroke({"cmd","shift"}, "m")         -- Teams
    hs.notify.new({title="Mute", informativeText="Teams ⌘⇧M"}):send()
    return
  end

  if bundle == "com.google.Chrome" then  -- Google Meet in Chrome (title heuristic)
    local win = hs.window.frontmostWindow()
    if win and (win:title() or ""):find("Meet") then
      stroke({"cmd"}, "d")               -- Meet
      hs.notify.new({title="Mute", informativeText="Google Meet ⌘D"}):send()
      return
    end
  end

  hs.notify.new({title="Mute", informativeText="F18 pressed (no rule)"}):send()
end

-- Simple tap: press F18 to toggle mute based on app
hs.hotkey.bind({}, "f18", routeMute)
