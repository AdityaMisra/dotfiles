-- slack-snooze.applescript [on|off]
-- Toggles Slack DND via the menu (Preferences > Notifications > Pause).
on run argv
	set mode to "on"
	if (count of argv) > 0 then set mode to item 1 of argv

	if not isRunning("Slack") then return "slack not running"

	tell application "Slack" to activate
	delay 0.2
	tell application "System Events"
		tell process "Slack"
			-- Cmd+Shift+Y in Slack toggles "Pause notifications"
			keystroke "y" using {command down, shift down}
		end tell
	end tell
	return "slack dnd: " & mode
end run

on isRunning(appName)
	tell application "System Events" to (name of processes) contains appName
end isRunning
