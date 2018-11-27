function ActivateMATLAB
% This applescript command provokes a screen refresh (by selecting MATLAB).
%
% Unfortunately it takes 3 seconds to run. I'm not sure why. It appears
% that AppleScript is always slow.
% denis.pelli@nyu.edu, June 18, 2015

status=system('osascript -e ''tell application "MATLAB" to activate''');
end
