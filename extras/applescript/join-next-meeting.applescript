-- join-next-meeting.applescript
-- Returns the first http(s) link found in the next Calendar event starting
-- within the next 60 minutes (or already in progress). Empty string if none.
on run
	set lookahead to 60 * minutes
	set graceMinutes to 5 * minutes
	set rightNow to current date
	set windowStart to rightNow - graceMinutes
	set horizon to rightNow + lookahead

	set foundEvent to missing value
	set foundStart to missing value

	tell application "Calendar"
		repeat with cal in calendars
			set evts to events of cal
			repeat with e in evts
				try
					set s to start date of e
				on error
					set s to missing value
				end try
				if s is not missing value then
					if s comes after windowStart and s comes before horizon then
						if foundStart is missing value or s comes before foundStart then
							set foundEvent to contents of e
							set foundStart to s
						end if
					end if
				end if
			end repeat
		end repeat

		if foundEvent is missing value then
			return ""
		end if

		set theURL to ""
		try
			set theURL to url of foundEvent
		end try
		if theURL is missing value or theURL is "" then
			set blob to ""
			try
				set blob to (location of foundEvent) & " " & (description of foundEvent)
			end try
			set theURL to my extractURL(blob)
		end if
	end tell

	return theURL
end run

on extractURL(s)
	if s is missing value then return ""
	set AppleScript's text item delimiters to {"http://", "https://"}
	set parts to text items of s
	set AppleScript's text item delimiters to ""
	if (count of parts) < 2 then return ""
	set tail to item 2 of parts
	-- truncate at first whitespace, quote, or close-bracket
	set stops to {space, tab, return, linefeed, "\"", ">", ")", "]", "<"}
	repeat with c in stops
		set i to offset of c in tail
		if i > 0 then set tail to text 1 thru (i - 1) of tail
	end repeat
	return "https://" & tail
end extractURL
