-- Mic / camera toggles. Calls AppleScripts in the repo.
local hyper = require("modules.hyper")

local REPO = os.getenv("HOME") .. "/.dotfiles"
local AS = REPO .. "/applescript"

local function runScript(path, label)
  return function()
    local ok, out = hs.osascript.applescriptFromFile(path)
    if ok then
      hs.alert.show(label .. ": " .. tostring(out or "ok"))
    else
      hs.alert.show(label .. " failed")
    end
  end
end

hyper.bind("M", runScript(AS .. "/mute-mic.applescript",       "Mic"))
hyper.bind("V", runScript(AS .. "/toggle-camera.applescript",  "Camera"))
hyper.bind("D", runScript(AS .. "/slack-snooze.applescript",   "Slack DND"))
hyper.bind("J", runScript(AS .. "/join-next-meeting.applescript", "Meeting"))
