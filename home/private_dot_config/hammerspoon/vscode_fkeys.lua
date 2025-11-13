-- Map media keys → F1..F12 only while VS Code is active.
-- No writes to com.apple.keyboard.fnState, no killall cfprefsd.

local M = {}

local CODE_APP_NAMES = {
  ["Visual Studio Code"] = true,
  ["Code"] = true,
  ["Code - Insiders"] = true,
}

local CODE_BUNDLE_IDS = {
  ["com.microsoft.VSCode"] = true,
  ["com.microsoft.VSCodeInsiders"] = true,
  ["com.visualstudio.code.oss"] = true,
}

local tap, watcher
local active = false

-- Accept both legacy and modern labels for the media keys.
local keymap = {
  BRIGHTNESS_DOWN   = "f1",
  BRIGHTNESS_UP     = "f2",
  MISSION_CONTROL   = "f3",
  LAUNCHPAD         = "f4",
  LAUNCH_PANEL      = "f4",
  ILLUMINATION_DOWN = "f5",
  ILLUMINATION_UP   = "f6",
  ILLUMINATION_TOGGLE = "f6",
  PREVIOUS          = "f7",
  REWIND            = "f7",
  PLAY              = "f8",
  FAST              = "f8",
  NEXT              = "f9",
  SOUND_DOWN        = "f11",
  VOLUME_DOWN       = "f11",
  SOUND_UP          = "f12",
  VOLUME_UP         = "f12",
  MUTE              = "f10",
}

local function ensureTap()
  if tap then return end
  tap = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(e)
    local info = e:systemKey()
    if not info then return false end
    if not active then
      hs.printf("[vscode_fkeys] tap received %s but inactive", info.key)
      return false
    end

    -- Only act on key-down events; ignore repeats to reduce chatter.
    if not info.down or info["repeat"] then return false end

    hs.printf("[vscode_fkeys] event key=%s down=%s repeat=%s", tostring(info.key), tostring(info.down), tostring(info["repeat"]))
    local fk = keymap[info.key]
    if not fk then
      hs.printf("[vscode_fkeys] tap saw %s (unmapped)", info.key)
      return false
    end

    hs.printf("[vscode_fkeys] %s -> %s", info.key, fk)
    hs.eventtap.keyStroke({}, fk, 0)
    return true -- swallow the original media key

  end)
end

local function setActive(on)
  active = on
  if on then
    ensureTap()
    if not tap:isEnabled() then tap:start() end
    hs.printf("[vscode_fkeys] event tap enabled")
  else
    if tap and tap:isEnabled() then tap:stop() end
    hs.printf("[vscode_fkeys] event tap disabled")
  end
end

local function isCodeApp(app)
  if not app then return false end
  local name = app:name()
  local bundle = app:bundleID()
  if name and CODE_APP_NAMES[name] then return true end
  if bundle and CODE_BUNDLE_IDS[bundle] then return true end
  return false
end

local function updateForFrontApp(app)
  if type(app) == "string" then
    app = hs.application.get(app)
  end
  if app == nil then app = hs.application.frontmostApplication() end
  local name = app and app:name() or "nil"
  local bundle = app and app:bundleID() or "nil"
  local shouldEnable = isCodeApp(app)
  hs.printf("[vscode_fkeys] %sactive for app %s (%s)", shouldEnable and "" or "in", name, bundle)
  setActive(shouldEnable)
end

function M.start()
  ensureTap()
  watcher = watcher or hs.application.watcher.new(function(name, event, app)
    if event == hs.application.watcher.activated then
      updateForFrontApp(app or name)
    end
  end)
  watcher:start()

  updateForFrontApp(hs.application.frontmostApplication())

  -- On reload/quit, stop the tap to be safe
  local prev = hs.shutdownCallback
  hs.shutdownCallback = function()
    if tap and tap:isEnabled() then tap:stop() end
    if prev then pcall(prev) end
  end
end

function M.stop()
  if watcher then watcher:stop(); watcher = nil end
  setActive(false)
end

return M
