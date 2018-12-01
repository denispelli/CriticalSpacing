--ScriptingOkShowPermission.applescript
-- ok=ScriptingOkShowPermission.applescript
-- The returned value "ok" is boolean indicating whether the current application
-- has permission to use scripting to control the computer.
-- If not ok, the Preferences Privacy panel is brought forward.
-- To call this applescript directly from MATLAB:
--
-- [status,ok]=system('osascript ScriptingOkShowPermission.applescript');
-- 
-- "status" is always zero.
-- "ok" is true when your application has permission to control the computer.
--
-- SEE ALSO: 
-- ScriptingOk
-- Denis Pelli, denis.pelli@nyu.edu, May 28, 2015
on run
	set show to 1
	tell application "System Events"
		set ok to UI elements enabled
		set applicationName to item 1 of (get name of processes whose frontmost is true)
	end tell
	if not ok and show > 0 then
		tell application "System Preferences"
			activate
			reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
			if show > 1 then
				display alert applicationName & " needs your permission to control this computer.  Please check the appropriate box to allow this."
			end if
		end tell
	end if
	return ok
end run