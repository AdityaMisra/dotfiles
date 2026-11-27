-- toggle-camera.applescript [on|off|toggle]
-- Sends Cmd+Shift+V to Zoom (toggle video) or Cmd+E to Google Meet in Chrome.
on run argv
	set mode to "toggle"
	if (count of argv) > 0 then set mode to item 1 of argv

	if isRunning("zoom.us") then
		tell application "System Events"
			tell process "zoom.us"
				set frontmost to true
				keystroke "v" using {command down, shift down}
			end tell
		end tell
		return "zoom: " & mode
	else if isRunning("Google Chrome") then
		tell application "Google Chrome" to activate
		tell application "System Events"
			keystroke "e" using {command down}
		end tell
		return "meet: " & mode
	else
		return "no call app frontmost"
	end if
end run

on isRunning(appName)
	tell application "System Events" to (name of processes) contains appName
end isRunning
