-- Brightness.applescript
-- Denis G. Pelli, denis.pelli@nyu.edu
-- June 25, 2017. 
--
-- HISTORY
-- June 25, 2017. First version. Based on my AutoBrightness.applescript
--
-- COMPATIBILITY
-- Works on Mavericks, Yosemite, and El Capitan (Mac OS X 10.9 to 10.11).
-- Not yet tested on earlier versions of Mac OS X (< 10.9).
-- I hope this will work internationally, with Macs running under Mac OS X
-- localized for any language, not just English. That is why we select
-- the Display/Colors panel by the internal name "displaysDisplayTab" 
-- instead using the localized name "Display". 
--
-- INTRODUCTION
-- This applescript allows you read and set the "Brightness" of Apple 
-- Macintosh liquid crystal displays. This applescript is equivalent to manually opening
-- the System Preference:Displays and adjusting the 16-position "brightnes" slider. 
-- I wrote this script to be invoked from
-- MATLAB, but you could call it from any application running under Mac OS X.
-- The "brightness" setting controls the luminance of the fluorescent light that is behind the
-- liquid crystal display. I believe that this "brightness" setting controls only the
-- luminance of the source, and does not affect the liquid crystal display,
-- which is controlled by the color lookup table. The screen luminance is 
-- presumably the product of the two factors: luminance of the source 
-- and transmission of the liquid crystal, at each wavelength.
--
-- BEWARE DELAY: This script uses the "System Preferences: Displays" panel,
-- which takes 30 s to open, if it isn't already open.  You should either
-- open System Preferences in advance, or be prepared to wait 30 s when you
-- call this script. If System Preferences was already open, then this script 
-- leaves it open. If it was not already open, there is an option in the code,
-- "leaveSystemPrefsRunning", which I set to true, so you don't waste the
-- observer's time waiting 30 s for System Preferences to open every time
-- you call AutoBrightness.
--
-- Brightness screenNumber level
-- The parameter "level" (float 0.0 to 1.0) sets the brightness level, 
-- which I think is quantized by the control panel to 16 levels.
-- If  the newLevel argument is omitted
-- then nothing is changed, and the current level is reported in the
-- returned value (0.0 to 1.0). However, the returned value is -99 if your 
-- application (e.g. MATLAB) does not have permission to control your computer 
-- (see APPLE SECURITY below).
--
-- In MATLAB, use the corresponding MATLAB Psychtoolbox function, which calls 
-- this script:
--
-- oldLevel=Brightness(level);
--
-- To call this directly from MATLAB, 
-- [status,oldLevel]=system(['osascript Brightness.applescript ' num2str(level)]); % to set
-- system(['osascript Brightness.applescript ' num2str(oldAuto)]); % to restore
-- Use from any other language is very similar.
-- Ignore the returned "status", which seems to always be zero.
-- The string argument to system() is passed without processing by MATLAB.
-- It appears that MATLAB's path is not used in finding the script,
-- "Autobrightness.applescript". When I don't specify a path for the
-- applescript file, it appears that system() assumes
-- that it's in /User/denispelli/Documents/MATLAB/
-- I succeeded in using my applescript from an arbitrary location by
-- specifying its full path. (See AutoBrightness.m.) 
--
-- BEWARE OF DELAY: This script uses the "System Preferences: Displays" panel,
-- which takes 30 s to open, if it isn't already open.  You should either
-- open System Preferences in advance, or be prepared to wait 30 s when you
-- call this script. Whether or not System Preferences was already open, this script 
-- leaves it open, so you don't waste the observer's time waiting 30 s for System 
-- Preferences to open every time you call AutoBrightness. 
--
-- APPLE SECURITY. Unless the application (e.g. MATLAB) calling this script
-- has permission to control the computer, attempts to changes settings will be blocked.
-- In that case the appropriate Security and Privacy System Preference panel is opened 
-- and an error dialog window asks the user to provide the permission. A user with 
-- admin privileges should then click as requested to provide that permission. 
-- This needs to be done only once for each application that calls this script. 
-- The permission is remembered forever. Once permission has been granted, 
-- subsequent calls of this script will work. Note that a user lacking admin access 
-- is unable to grant the permission; in that case every time you call this 
-- script, you'll get the error dialog window.
-- 
-- SCRIPTING CONTROL ALLOWED? 
-- You can call Denis Pelli's innocuous script "ScriptingAllowed.applescript" to find out
-- whether scripting permission has been granted. http://psych.nyu.edu/pelli/software.html
--
-- MULTIPLE SCREENS: All my computers have only one screen, so 
-- I haven't yet tested it with values of screenNumber other than zero.
--
-- BRIGHTNESS: 
-- The Psychtoolbox for MATLAB
-- and Macintosh already has a Screen call to get and set the brightness, but it 
-- seems to be unreliable in macOS Sierra. It always runs without raising an error, 
-- but doesn't always do the job.

-- AUTOBRIGHTNESS. If you use Brightness, then you probably will also want to call 
-- AutoBrightness, to disable the Mac's auto brightness control.
--
-- THANKS. Thanks to Mario Kleiner for explaining how Mac OSX "brightness" works.
-- Thanks to nick.peatfield@gmail.com for sharing his applescript code for dimmer.scpt 
-- and brighter.scpt.
-- 
-- SEE ALSO:
-- ScriptingAllowed.applescript (http://psych.nyu.edu/pelli/software.html)
-- The Psychtoolbox call to get and set the Macintosh brightness:
-- [oldBrightness]=Screen('ConfigureDisplay','Brightness', screenId [,outputId][,brightness]);
-- http://www.manpagez.com/man/1/osascript/
-- https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
-- https://discussions.apple.com/thread/6418291

on run argv
	--Input arguments: screenNumber newLevel
	--Output argument: oldLevel
	-- integer screenNumber. Zero for main screen. Default is zero.
	-- real newLevel: 0.0 to 1.0 value of brightness slider.
	-- Default is to leave the level unchanged.
	--Returns oldLevel, 0.0 to 1.0 value of brightness slider.
	try
		set newLevel to item 2 of argv as real
	on error
		set newLevel to -1.0 -- Unspecified value, so don't change the setting.
	end try
	try
		set screenNumber to item 1 of argv as integer
	on error
		set screenNumber to 0 -- Default is the main screen.
	end try
	set windowNumber to screenNumber + 1 -- Has been tested only for screenNumber==0
	set leaveSystemPrefsRunning to true -- This could be made a third argument.
	tell application "System Preferences"
		set wasRunning to running
		--set the current pane to pane id "com.apple.preference.displays"
		--reveal (first anchor of current pane whose name is "displaysDisplayTab")
		reveal anchor "displaysDisplayTab" of pane "com.apple.preference.displays"
	end tell
	tell application "System Events"
		if not UI elements enabled then
			set applicationName to item 1 of (get name of processes whose frontmost is true)
			tell application "System Preferences"
				activate
				reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
				display alert "To set Displays preferences, " & applicationName & " needs your permission to control this computer.  BEFORE you click OK below, please unlock the Privacy panel and click the box that allows the app to control your computer. THEN click OK."
				delay 1
			end tell
			return -99
		end if
		tell process "System Preferences"
				tell tab group 1 of window windowNumber
				try
				    set ok to false
					tell group 2 -- works sometimes on Mac OS X 10.10, and always on later versions.
						set oldLevel to slider 1's value -- Get brightness
						if newLevel > -1 then
							set slider 1's value to newLevel -- Set brightness
						end if
					end tell
				    set ok to true
				on error
					try
						tell group 1 -- works on Mac OS X 10.9 and sometimes 10.10.
							set oldLevel to slider 1's value -- Get brightness
							if newLevel > -1 then
								set slider 1's value to newLevel -- Set brightness
							end if
						end tell
					    set ok to true
                    on error
						set oldLevel to -1.0
					end try
				end try
			end tell
		end tell
	end tell
	if wasRunning or leaveSystemPrefsRunning then
		-- Leave it running.
	else
		quit application "System Preferences"
	end if
	if not ok then
		tell application "Finder" to activate
		display alert "Applescript error in reading or setting Brightness."
		delay 1
		return -99
	end if
	return oldLevel
end run
