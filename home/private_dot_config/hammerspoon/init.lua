
local modules = {
  { name = "debug_tap", enabled = false },
  { name = "f18_mute", enabled = true },
  { name = "vscode_fkeys", enabled = false },
}

hs.fnutils.each(modules, function(entry)
  if entry.enabled == false then return end
  local ok, mod = pcall(require, entry.name)
  if not ok then
    hs.printf("Failed to load %s: %s", entry.name, mod)
    hs.alert.show(("Failed to load %s"):format(entry.name))
    return
  end

  local starter = entry.starter or mod.start
  if type(starter) == "function" then
    starter(entry.opts)
    hs.printf("Started %s", entry.name)
  else
    hs.printf("%s does not expose start()", entry.name)
    hs.alert.show(("%s missing start()"):format(entry.name))
  end
end)
