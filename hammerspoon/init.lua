-- ~/.hammerspoon/init.lua (symlink to <repo>/hammerspoon/init.lua)
-- Loads each module from hammerspoon/modules/. Order matters only for hyper
-- (other modules consume the `hyper` global it defines).

hs.window.animationDuration = 0  -- snappier tiling

local function reload(files)
  for _, file in ipairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end

require("modules.hyper")
require("modules.tiling")
require("modules.launchers")
require("modules.mediakeys")
require("modules.reload")

hs.alert.show("Hammerspoon \u2713")
