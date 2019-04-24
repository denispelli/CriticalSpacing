function [oldSetting,failed] = AutoBrightness(screenNumber,newSetting)
% [oldSetting,failed] = AutoBrightness([screenNumber=0][, newSetting])
%
% AUTOBRIGHTNESS Get and set the checkbox called "Automatically adjust
% brightness" on the macOS: System Preferences: Displays panel. The first
% argument selects a screen, but has been tested only for screen 0 (the
% main screen). The second argument "newSetting" (integer 0 or 1) is
% optional, and, if present, indicates that you want to turn the
% autobrightness feature on (newSetting==1) or off (newSetting==0). If you
% call AutoBrightness without the newSetting argument (or a value other
% than 0 or 1) then nothing is changed. The current state is always
% reported in the returned oldSetting (0 or 1). The optionally returned
% "failed" is always zero unless the applescript failed.
%
% AutoBrightness.m uses the AutoBrightness.applescript to allow you to turn
% off a pesky feature of Apple's liquid crystal displays. In macOS, this
% feature is manually enabled/disabled by the "Automatically adjust
% brightness" checkbox in the System Preferences:Displays panel. While the
% feature is enabled, your Mac slowly adjusts the screen luminance of your
% Apple liquid crystal display, tracking the luminance of the room. That
% instability is bad for screen calibration, and may also be bad for your
% experiments. My AutoBrightness routines allow your programs to read the
% on/off setting of that feature, and set it on or off.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, May 21, 2015.
% Incorporated into MATLAB adding untested code to specify which screen, by
% Mario Kleiner, June 1. Convert return argument from string to double by
% Denis, June 11, 2015.
%
% This Psychtoolbox MATLAB function calls our AutoBrightness applescript,
% which allows you to temporarily disable a feature of Apple Macintosh
% laptops that is undesirable for vision experiments and display
% calibration. The applescript is equivalent to manually opening the System
% Preference:Displays panel and clicking to turn on or off the "Automatic
% brightness adjustment" checkbox. I wrote the script to be invoked from
% MATLAB, but you could call in from any application. One important use of
% the script is to prevent changes of brightness in response to the room
% luminance while calibrating a display. The automatic adjustments are
% slow, over many seconds, which could invalidate your display calibration.
% When "Automatically adjust brightness" is checked, the macOS uses the
% video camera to sense the room luminance and slowly dims the display if
% the room is dark. It does this by adjusting the "brightness" setting,
% which controls the luminance of the fluorescent light that is behind the
% liquid crystal display. I believe that the "brightness" slider controls
% only the luminance of the source, and does not affect the liquid crystal
% itsef, which is controlled by the color lookup table. The luminance at
% the viewer's eye is presumably the product of the two factors: luminance
% of the source and transmission of the liquid crystal, at each wavelength.
%
% USAGE. We suggest that you turn auto brightness off at the beginning of
% your session and turn it back on when you're done. Trying to save and
% restore the old state may not work while you're debugging because you'll
% often interrupt the program before the restore happens.
%
% BEWARE 30 s DELAY. This uses the "System Preferences: Displays" panel,
% which takes 30 s to open, if it isn't already open. We set up the
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
% privileges should then click as requested to provide that permission in
% System Preferences:Security & Privacy:Accessibility. This needs to be
% done only once (for each application).
%
% If needed, our AutoBrightness applescript will put up a helpful alert and
% wait for you to enable control. If necessary, it will close any SCREEN
% windows that you have open, to allow the user to see the alert. The user
% should grant permission in Prefence panel, before hitting Ok to the
% alert. After your ok, if AutoBrightness closed your windows, then it
% throws an error before returning. The error message invites you to run
% your program again, now with permission already granted.
%
% MULTIPLE SCREENS. The first argument specifies which screen, but has so
% far only been tested for screen 0. All my computers have only one screen,
% so I couldn't test that feature. If you specify nonexitent
% screenNumber~=0, on a one-screen system, it returns normally and always
% says autobrightness is off.
%
% SYSTEM COMPATIBILITY. It works with macOS 10.9 (Mavericks) through 10.13
% (High Sierra), and seems likely work with future releases.
%
% LINUX and WINDOWS. Applescript works only under macOS. When running under
% any operating system other that macOS, this program ignores the
% newSetting argument and always returns zero as the oldSetting. It is
% conceivable that Apple's auto brightness feature is implemented on
% Macintoshes running Linux or Windows. If that applies to you, please
% consider enhancing this program to return a correct answer for that case,
% and sharing the result with me and the Psychtoolbox forum.
%
% See also:
% ScriptingOk.m
% ScriptingOkShowPermission.m
% ScreenProfile.m

% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
%
% Thanks to Mario Kleiner for explaining how macOS "brightness" works.
% Thanks to nick.peatfield@gmail.com for sharing his applescript code for
% dimmer.scpt and brighter.scpt.

if ~IsOSX
    % I believe that Applescript works only within macOS. However, it is
    % conceivable that Apple's auto brightness feature is implemented on
    % Macintoshes running Linux or Windows, in which case someone might
    % enhance this MATLAB program to return a correct answer for those
    % cases.
    oldSetting = 0;
    failed = true; % Report failure on this unsupported OS.
    return;
end
if nargin < 1
    screenNumber=0;
end
if nargin <2
    newSetting=-1; % Indicates missing argument.
end
scriptPath = which('AutoBrightness.applescript');
forcedToClose=false;
if newSetting==-1
    s=sprintf('You called AutoBrightness(%d).',screenNumber);
else
    s=sprintf('You called AutoBrightness(%d,%d).',screenNumber,newSetting);
end
windowIsOpen=~isempty(Screen('Windows'));
% if ~ismember(screenNumber,Screen('Windows'))
%     warning(sprintf('%s There is no window with screenNumber %d in the Screen(''Windows'') list.\n',s,screenNumber));
% end
command = ['osascript ', scriptPath ...
    ' ', num2str(screenNumber),...
    ' ', num2str(newSetting), ...
    ' ', num2str(windowIsOpen)];
for i=1:3
    oldSetting=''; % Default in case not set by function.
    [failed,oldSetting] = system(command);
    % Occasionally oldSetting is empty, possibly because that's how we
    % initialized it. I don't know why or what that means.
    if failed
        msg=sprintf('%s The osascript failed with the following error, trying again.\n%s'...
            ,s,oldSetting);
        warning(msg);
        continue
    end
    if isempty(oldSetting)
        msg=sprintf('%s It returned empty oldSetting.\n',s);
        warning(msg);
        continue
    end
    oldSetting=str2num(oldSetting);
    if ~isempty(oldSetting) && oldSetting==-999 && windowIsOpen
        forcedToClose=true;
        sca;
    end
    if ismember(oldSetting,0:1)
        break
    end
end
if forcedToClose
    error('Screen window was closed to allow user to grant permission. Please run your MATLAB program again.');
end
end
