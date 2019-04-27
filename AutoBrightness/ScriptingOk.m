function [ok,status]=ScriptingOk
%ScriptingOk returns true (1) or false (0), indicating whether this
% application has permission to control the computer through scripting.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, June 3, 2015.
%
% INSTALLATION. To work with MATLAB, please put both files (ScriptingOk.m
% and ScriptingOk.applescript) anywhere in MATLAB's path. I hope they will
% be added to the Psychtoolbox.

% See also:
% ScriptingOkShowPermission.m
% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291
%
if ~IsOSX
    % I believe that Applescript works only within Mac OS X. It is
    % conceivable that Apple's auto brightness feature is implemented on
    % Macintoshes running Linux or Windows, in which case someone might
    % enhance this program to return a correct answer for those cases.
    ok=0;
    return
end
script='ScriptingOk.applescript';
scriptPath=which(script);
if isempty(scriptPath)
    error('Cannot find %s within the MATLAB path.',script);
end
command=sprintf('osascript "%s"',scriptPath);
[status,ok]=system(command);
ok=streq(deblank(ok),'true');
end


