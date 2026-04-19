-- join-next-meeting.applescript
-- Returns the first http(s) link found in the next Calendar event starting
-- within the next 60 minutes (or already in progress). Empty string if none.
on run
	set lookahead to 60 * minutes
	set now to current date
	set horizon to now + lookahead

	tell application "Calendar"
		set foundEvent to missing value
		repeat with cal in calendars
			set evts to (every event of cal whose start date \u2265 (now - 5 * minutes) and start date \u2264 horizon)
			repeat with e in evts
				if foundEvent is missing value then
					set foundEvent to e
				else if (start date of e) < (start date of foundEvent) then
					set foundEvent to e
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
			set theURL to extractURL(blob)
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
