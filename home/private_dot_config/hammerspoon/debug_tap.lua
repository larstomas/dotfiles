-- Minimal key sniffer (toggle it off by restarting Hammerspoon)
local M = {}
local tap

local function ensureTap()
  if tap then return end
  tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local code = e:getKeyCode()
    local name = hs.keycodes.map[code]
    hs.alert.show(("keyCode=%s  name=%s"):format(code, tostring(name)))
    print("keyDown:", code, name)
    return false
  end)
end

local function announceFrontApp()
  local frontApp = hs.application.frontmostApplication()
  if frontApp then
    local bundleID = frontApp:bundleID()
    hs.alert.show("Frontmost app bundle ID: " .. tostring(bundleID))
    print("Frontmost app bundle ID:", bundleID)
  else
    hs.alert.show("No frontmost application found.")
    print("No frontmost application found.")
  end
end

function M.start()
  ensureTap()
  if not tap:isEnabled() then tap:start() end
  announceFrontApp()
end

function M.stop()
  if tap and tap:isEnabled() then tap:stop() end
end

return M
