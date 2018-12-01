function [oldSetting,status]=AutoBrightness(screenNumber,newSetting)
% [oldSetting, status] = AutoBrightness([screenNumber=0][, newSetting])
%
% AUTOBRIGHTNESS Get and set the checkbox called "Automatically adjust
% brightness" on the Mac OS X: System Preferences: Displays panel. The
% first argument select a screen, but has been tested only for screen 0
% (the main screen). The second argument "newSetting" (integer 0 or 1) is
% optional, and, if present, indicates that you want to turn the
% autobrightness feature on (newSetting==1) or off (newSetting==0). If you
% call AutoBrightness without the second argument (or a newSetting value
% other than 0 or 1) then nothing is changed. The current state is always
% reported in the returned oldSetting (0 or 1). The optionally returned
% "status" is always zero unless the applescript failed.
%
% AutoBrightness.m uses the AutoBrightness.applescript to allow you to turn
% off a pesky feature of Apple's liquid crystal displays. In Mac OSX, this
% feature is manually enabled/disabled by the "Automatically adjust
% brightness" checkbox in the System Preferences: Displays panel. While the
% feature is enabled, your Mac slowly adjusts the screen luminance of your
% Apple liquid crystal display, depending the the luminance of the room.
% That's bad for screen calibration, and perhaps also bad for your
% experiments. My AutoBrightness routines allow your programs to read the
% on/off setting of that feature, and enable or disable it.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, May 21, 2015.
% Incorporated into MATLAB adding untested code to specify which screen, by
% Mario Kleiner, June 1. Cast return argument to double by Denis, June 11,
% 2015.
%
% This Psychtoolbox MATLAB function calls my AutoBrightness applescript,
% which allows you to temporarily disable a feature of Apple Macintosh
% laptops that is undesirable for vision experiments and display
% calibration. The applescript is equivalent to manually opening the System
% Preference:Displays panel and clicking to turn on or off the "Automatic
% brightness adjustment" checkbox. I wrote the script to be invoked from
% MATLAB, but you could call in from any application. One important use of
% the script is to prevent changes of brightness in response to the room
% luminance while calibrating a display. The automatic adjustments are
% slow, over many seconds, which could invalidate your display calibration.
% When "Automatically adjust brightness" is checked, the Mac OS uses the
% video camera to sense the room luminance and slowly dims the display if
% the room is dark. It does this by adjusting the "brightness" setting,
% which controls the luminance of the fluorescent light that is behind the
% liquid crystal display. I believe that the "brightness" slider controls
% only the luminance of the source, and does not affect the liquid crystal
% itsef, which is controlled by the color lookup table. The luminance at
% the viewer's eye is presumably the product of the two factors: luminance
% of the source and transmission of the liquid crystal, at each wavelength.
%
% USAGE. I suggest that you turn auto brightness off at the beginning of
% your session and turn it back on when you're done. Trying to save and
% restore the old state may not work while you're debugging because you'll
% often interrupt the program before the restore happens.
%
% BEWARE 30 s DELAY. This uses the "System Preferences: Displays" panel,
% which takes 30 s to open if it isn't already open. I set up the
% AutoBrightness applescript to always leave System Preferences open, so
% you won't waste your observer's time waiting 30 s for System Preferences
% to open every time you call AutoBrightness.
%
% BRIGHTNESS. Psychtoolbox for MATLAB and Macintosh already has a Screen
% call to get and set the brightness, so we don't need applescript for
% that. The Psychtoolbox call is:
% [oldBrightness]=Screen('ConfigureDisplay','Brightness', screenId [,outputId][,brightness]);
%
% APPLE SECURITY. The first time any application (e.g. MATLAB) asks
% AutoBrightness.applescript to change a setting, the request will be
% blocked and an error dialog window will appear saying the application is
% "not allowed assistive access." This means that the application needs an
% administrator's permission to control the computer. A user with admin
% privileges should then click as requested to provide that permission.
% This needs to be done only once (for each application).
%
% MULTIPLE SCREENS: The first argument specifies which screen, but has so
% far only been tested for screen 0. All my computers have only one screen,
% so I couldn't test that feature. 
%
% SYSTEM COMPATIBILITY. It works with Mac OS X 10.9 (Mavericks) and 10.10
% (Yosemite). It may require updating to work with Mac OS X 10.11 (El
% Capitan) and further releases.
%
% LINUX and WINDOWS. Applescript works only under Mac OS X. When running
% under any operating system other that Mac OS X, this program ignores the
% newSetting argument and always returns zero as the oldSetting. It is
% conceivable that Apple's auto brightness feature is implemented on
% Macintoshes running Linux or Windows. If that applies to you, please
% consider enhancing this program to return a correct answer for that case,
% and sharing the result with me and the Psychtoolbox forum.

% See also:
% ScriptingOk.m
% ScriptingOkShowPermission.m
% ScreenProfile.m

% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
%
% Thanks to Mario Kleiner for explaining how Mac OSX "brightness" works.
% Thanks to nick.peatfield@gmail.com for sharing his applescript code for
% dimmer.scpt and brighter.scpt.
if ~IsOSX
    % I believe that Applescript works only within Mac OS X. It is
    % conceivable that Apple's auto brightness feature is implemented on
    % Macintoshes running Linux or Windows, in which case someone might
    % enhance this program to return a correct answer for those cases.
    oldSetting = 0;
    status = 1; % Report failure on this unsupported OS.
    return;
end
scriptPath = which('AutoBrightness.applescript');
command = ['osascript ', scriptPath];
if nargin > 0
    command = [command, ' ', num2str(screenNumber)];
end
if nargin > 1
    command = [command, ' ', num2str(newSetting)];
end
[status,oldSetting] = system(command);
oldSetting = str2num(oldSetting);
end

