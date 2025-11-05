try
	tell application "Firefox"
		try
			activate
			delay 0.1
			tell application "System Events"
				try
					keystroke "l" using command down
					delay 0.1
					keystroke "c" using command down
					delay 0.1
					keystroke tab
				on error errMsg
					return "ERROR: System Events failed: " & errMsg
				end try
			end tell
			delay 0.1
			return (the clipboard as text)
		on error errMsg
			return "ERROR: Firefox activation failed: " & errMsg
		end try
	end tell
on error errMsg
	return "ERROR: Firefox application not available: " & errMsg
end try 
