function [oldIsMuted,failed]=SoundMuting(newIsMuted)
% [oldIsMuted,failed]=SoundMuting(newIsMuted); 
% Read and control the muting of sound on the macOS: System Preferences:
% Sound: Output panel. The argument "newIsMuted" (logical true or false) is
% optional, and, if present, indicates that you want to set the muting on
% or off. If you call SoundMuting without the newIsMuted argument or [],
% then nothing is changed. The current state is always reported in the
% returned oldIsMuted (logical true or false). The optionally returned
% "failed" is an error code and is always zero unless the osascript failed.
%
% Takes 5 s to read and set the muting state.
%
% Written by denis.pelli@nyu.edu for the Psychtoolbox, July 16, 2019, based
% on code by Nicholas Robinson-Wall:
% https://coderwall.com/p/22p0ja/set-get-osx-volume-mute-from-the-command-line
%
% SYSTEM COMPATIBILITY. It's based on basic osascript so I'd
% suppose it's supported on all versions of macOS. I hope SoundMuting can
% be extended to support Windows and Linux.
%
% See also: SoundVolume.m, Brightness.m

% http://www.manpagez.com/man/1/osascript/
% https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
% https://discussions.apple.com/thread/6418291

oldIsMuted=logical([]); % Make sure output arguments are defined.
failed=false;
if nargin<1
    newIsMuted=logical([]);
end
if ~ismac
    return
end

% Get mute state (logical true or false).
% osascript -e 'output muted of (get volume settings)'
[failed,str]=system('osascript -e "output muted of (get volume settings)"');
if failed
    warning('Applescript failed to read muting.');
    failed
    str
end
if ~isempty(str)
    str=str(1:end-1);
end
switch str
    case 'true'
        oldIsMuted=true;
    case 'false'
        oldIsMuted=false;
    otherwise
        oldIsMuted=logical([]);
end

% Set mute state (logical true or false).
% osascript -e 'set volume output muted true'
if ~isempty(newIsMuted)
    if ~islogical(newIsMuted)
        error('newIsMuted must be logical, true or false.');
    end
    if newIsMuted
        str='true';
    else
        str='false';
    end
    str=sprintf('osascript -e "set volume output muted %s"',str);
    [failed,msg]=system(str);
    if failed
        warning('Applescript failed to set muting.');
        failed
        msg
    end
end

