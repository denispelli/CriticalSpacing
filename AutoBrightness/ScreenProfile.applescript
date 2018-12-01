-- oldProfileName=ScreenProfile(screenNumber,newProfileName)
-- oldProfileName and newProfileName are profile names, e.g. "Apple RGB", as seen in the Displays 
--     pref panel, not their aliases.
-- screenNumber is an integer. The main screen is zero, the next is 1, etc.
-- Both arguments are optional. If omitted, screenNumber is assumed to be 0. If newProfileName is omitted, 
-- the profile selection is unchanged.
-- In MATLAB, use the corresponding MATLAB wrapper function, which calls 
-- this script:
--
-- oldProfileName=ScreenProfile(screenNumber,newProfileName)
--
-- To call this applescript directly from MATLAB:
--
-- [status,oldProfileName]=system('osascript ScreenProfile.applescript'); % get name of main screen profile
-- [status,oldProfileName]=system(['osascript ScreenProfile.applescript ' num2str(screenNumber) newProfileName]); 
--
-- Denis Pelli, denis.pelli@nyu.edu, May 29, 2015. June 1, 2015. Polished the comments.
-- Sources: http://macscripter.net/viewtopic.php?pid=133504#p133504
-- https://discussions.apple.com/thread/5203905
--
-- BEWARE OF DELAY: This script uses the "System Preferences: Displays" panel,
-- which takes 30 s to open, if it isn't already open.  You should either
-- open System Preferences in advance, or be prepared to wait 30 s when you
-- call this script. Whether or not System Preferences was already open, this script 
-- leaves it open, so you don't waste the observer's time waiting 30 s for System 
-- Preferences to open every time you call AutoBrightness. 
--
-- SCRIPTING CONTROL ALLOWED? You can call the innocuous script "ScriptingAllowed.applescript" 
-- to find out whether permission has been granted for the running application (e.g. MATLAB)
-- to control your computer by scripting. That script comes in three flavors:
-- 1. ScriptingAllowed returns immediately with the answer.
-- 2. ScriptingShowPreferences returns immediately if the answer is yes, but if the 
-- answer is no, it opens the Displays preferences panel before returning. Note that, if 
-- the panel was not open, opening it takes about 30 s.
-- 3. ScriptingShowDialog performs like ScriptingShowPreferences, but, if the answer is 
-- no, also displays a dialog window that pauses the application until the user clicks Ok.
--
-- SEE ALSO:
-- ScreenProfile.m
-- ScriptingAllowed.applescript, ScriptingAllowedShowPermission.applescript
-- ScriptingAllowedShowDialog.applescript
-- AutoBrightness.applescript, AutoBrightness.m

on run argv
	tell application "System Events"
		set ok to UI elements enabled
	end tell
	if not ok then
		tell application "System Preferences"
			activate
			-- denis pelli updated for Mavericks, to select the right pane and anchor.
			reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
			display alert "Scripting of preferences must be enabled by a user with admin privileges. After unlocking this pane, please check the box that allows the application, e.g. MATLAB, to control your computer."
		end tell
		return
	end if
	try
		set newProfileName to item 2 of argv as text
	on error
		set newProfileName to ""
	end try
	try
		set screenNumber to item 1 of argv as integer
	on error
		set screenNumber to 0 -- Default is the main screen.
	end try
	set windowNumber to screenNumber + 1 -- Has been tested only for screenNumber==0
	tell application "System Preferences"
		set current pane to pane id "com.apple.preference.displays"
		reveal (first anchor of current pane whose name is "displaysColorTab")
	end tell
	tell application "System Events"
		tell process "System Preferences"
			tell tab group 1 of window windowNumber
				tell table 1 of scroll area 1
					set oldProfileName to static text's name of (first UI element whose selected is true)
					if length of newProfileName > 0 then
						select (first row where its first static text's name is newProfileName)
					end if
				end tell
			end tell
		end tell
	end tell
	--quit application "System Preferences"	
	return oldProfileName
end run
