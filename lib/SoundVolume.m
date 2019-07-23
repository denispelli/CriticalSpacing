function [oldVolume,failed]=SoundVolume(newVolume)
% oldVolume=SoundVolume(newVolume);
% Read and set the output volume slider on the macOS: System Preferences:
% Sound: Output panel. The argument "newVolume" (in range 0.0 to 1.0) is
% optional, and, if present, indicates that you want to set the volume. If
% you call SoundVolume without the newSetting argument or [], then nothing
% is changed. The current state is always reported in the returned
% oldVolume (in range 0.0 to 1.0). The optionally returned "failed" is an
% error code and is always zero unless the osascript failed.
%
% Note that there won't be any sound if muting is on. You can use
% SoundMuting to assess and control muting.
%
% Takes 5 s to read and set the volume.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, July 16, 2019. Based
% on code by Nicholas Robinson-Wall:
% https://coderwall.com/p/22p0ja/set-get-osx-volume-mute-from-the-command-line
%
% SYSTEM COMPATIBILITY. It's based on basic osascripts so I suppose it'll
% work on all versions of macOS. I hope SoundVolume can be extended to
% support Windows and Linux.
%
% See also: SoundMuting.m, Brightness.m

% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291

if nargin<1
    newVolume=[];
end

% Get volume (0.0 to 1.0).
% osascript -e 'output volume of (get volume settings)'
[failed,msg]=system('osascript -e "output volume of (get volume settings)"');
if failed
    failed
    msg
    warning('Applescript failed to read volume.');
    oldVolume=msg;
else
    oldVolume=str2num(msg)/100;
end

% Set volume (0.0 to 1.0)
% osascript -e 'set volume output volume 50'
if ~isempty(newVolume)
    if newVolume<0 || newVolume>1
        error('newVolume %.2f must be in range 0.0 to 1.0.',newVolume);
    end
    str=sprintf('osascript -e "set volume output volume %d"',round(100*newVolume));
    [failed,msg]=system(str);
    if failed
        failed
        msg
        warning('Applescript failed to set volume.');
    end
end
