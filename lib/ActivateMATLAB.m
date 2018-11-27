function ActivateMATLAB
% This applescript command provokes a screen refresh (by selecting MATLAB).
% denis.pelli@nyu.edu, June 18, 2015

status=system('osascript -e ''tell application "MATLAB" to activate''');
end
