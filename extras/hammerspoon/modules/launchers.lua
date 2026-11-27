-- App launcher hotkeys. hyper+<letter> -> focus or launch the named app.
local hyper = require("modules.hyper")

local function focusOrLaunch(name)
  return function()
    hs.application.launchOrFocus(name)
  end
end

hyper.bind("t", focusOrLaunch("Ghostty"))
hyper.bind("b", focusOrLaunch("Google Chrome"))
hyper.bind("e", focusOrLaunch("Cursor"))
hyper.bind("s", focusOrLaunch("Slack"))
hyper.bind("z", focusOrLaunch("zoom.us"))
hyper.bind("o", focusOrLaunch("Obsidian"))
