-- set-wallpaper.applescript /path/to/image.{jpg,png,heic}
-- Sets the wallpaper on every desktop.
on run argv
	if (count of argv) = 0 then error "usage: set-wallpaper <path>"
	set imgPath to item 1 of argv
	set imgPosix to (POSIX file imgPath) as alias

	tell application "System Events"
		repeat with d in (every desktop)
			set picture of d to imgPosix
		end repeat
	end tell
	return "wallpaper -> " & imgPath
end run
