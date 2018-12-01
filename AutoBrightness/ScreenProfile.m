function [oldProfileName,status]=ScreenProfile(screenNumber,newProfileName)
%SCREENPROFILE Get and set the name of the color profile used on one
% screen. oldProfileName and newProfileName are profile names as seen in
% the Displays pref panel, not their aliases. screenNumber is an integer.
% The main screen is zero, the next is 1, etc. Both input arguments are
% optional. If omitted, screenNumber is assumed to be 0. If newProfileName
% is omitted, the profile selection is unchanged. The optionally returned
% "status" is always zero unless the applescript failed.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, May 29, 2015.
%
% INSTALLATION. To work with MATLAB, please put both files (ScreenProfile.m
% and ScreenProfile.applescript) anywhere in MATLAB's path. I hope they
% will be added to the Psychtoolbox.
%
% BEWARE DELAY. This uses the "System Preferences: Displays" panel, which
% takes 30 s to open if it isn't already open. I set up the AutoBrightness
% applescript to always leave System Preferences open, so you won't waste
% your observer's time waiting 30 s for System Preferences to open every
% time you call AutoBrightness.
%
% APPLE SECURITY. The first time any application (e.g. MATLAB) asks
% AutoBrightness.applescript to change a setting, the request will be
% blocked and an error dialog window will appear saying the application is
% "not allowed assistive access." This means that the application needs an
% administrator's permission to control the computer. A user with admin
% privileges should then click as requested to provide that permission.
% This needs to be done only once (for each application).
%
% MULTIPLE SCREENS: All my computers have only one screen, so I haven't
% tested this on screens other than screen 0, the main screen.
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
% AutoBrightness.m
% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
%
if ~IsOSX
    % I believe that Applescript works only within Mac OS X. It is
    % conceivable that Apple's auto brightness feature is implemented on
    % Macintoshes running Linux or Windows, in which case someone might
    % enhance this program to return a correct answer for those cases.
    oldProfileName=[];
    return
end
script='ScreenProfile.applescript';
scriptPath=which(script);
if length(scriptPath)==0
    error('Cannot find %s within the MATLAB path.',script);
end
command=sprintf('osascript "%s"',scriptPath);
if nargin>0
    command=sprintf('%s %d',command,screenNumber);
end
if nargin>1
    command=sprintf('%s "%s"',command,newProfileName);
end
[status,oldProfileName]=system(command);
oldProfileName=deblank(oldProfileName); % strip off trailing <return> character
end

