--ScriptingOk.applescript
-- ok=ScriptingOk
-- The returned value "ok" is boolean indicating whether the current application has
-- permission to use scripting to control the computer. 
-- To call this applescript directly from MATLAB:
--
-- [status,ok]=system('osascript ScriptingOk.applescript');
-- 
-- "status" is always zero.
-- "ok" is true when your application has permission to control the computer.
--
-- SEE ALSO: 
-- ScriptingOkShowPermission.
-- Denis Pelli, denis.pelli@nyu.edu, May 28, 2015
on run
	tell application "System Events"
		set ok to UI elements enabled
	end tell
	return ok
end run