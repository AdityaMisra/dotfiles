-- Auto-reload Hammerspoon when any .lua file in the repo changes.
local function shouldReload(files)
  for _, file in ipairs(files) do
    if file:sub(-4) == ".lua" then return true end
  end
  return false
end

local watchPath = os.getenv("HOME") .. "/.hammerspoon/"
configWatcher = hs.pathwatcher.new(watchPath, function(files)
  if shouldReload(files) then
    hs.reload()
  end
end):start()
