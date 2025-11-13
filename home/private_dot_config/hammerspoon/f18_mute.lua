-- === App-aware F18 mute ===
local app = require("hs.application")

local M = {}
local hotkey

local function stroke(mods, key) -- quick key press
  hs.eventtap.keyStroke(mods, key, 0)
end

local function routeMute()
  local front = app.frontmostApplication()
  if not front then return end
  local bundle = front:bundleID() or ""

  -- Mute microphone in Teams
  if bundle == "com.microsoft.teams2" or bundle == "com.microsoft.teams" then
    stroke({"cmd","shift"}, "m")         -- Teams
    hs.notify.new({title="Mute", informativeText="Teams ⌘⇧M"}):send()
    return
  end

  hs.notify.new({title="Mute", informativeText="F18 pressed (no rule)"}):send()
end

local function ensureHotkey()
  if hotkey then return end
  hotkey = hs.hotkey.new({}, "f18", routeMute)
end

function M.start()
  ensureHotkey()
  hotkey:enable()
end

function M.stop()
  if hotkey then hotkey:disable() end
end

return M
