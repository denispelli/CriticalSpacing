function ActivateMATLAB
% This applescript command provokes a screen refresh (by selecting MATLAB).
% My computers each have only one display, upon which my MATLAB programs
% open a Psychtoolbox window. This applescript eliminates an annoyingly
% long pause at the end of my Psychtoolbox programs running under MATLAB
% 2014a, when returning to the MATLAB command window after twice opening
% and closing Screen windows. Without this command, when I return to
% MATLAB, the whole screen remains blank for a long time, maybe 30 s, or
% until I click something, so I can't tell that I'm back in MATLAB. This
% applescript command provokes a screen refresh, so the MATLAB editor
% appears immediately. Among several computers, the problem is always
% present in MATLAB 2014a and never in MATLAB 2015a. (All computers are
% running Mavericks.) denis.pelli@nyu.edu, June 18, 2015

if 1
    % This short program demonstrates the problem, which is evident if you
    % open and close the window twice, not if you do it only once. If you
    % comment out the applescript command, under MATLAB 2014a, there is a
    % long variable delay (10 to 30 s) between hearing "Done!" and seeing
    % MATLAB. Clicking anytime during that interval reveals the MATLAB
    % editor, silently waiting. With the applescript command, MATLAB
    % appears within a second of hearing "Done!".
    for i=1:2
        window=Screen('OpenWindow',0);
        WaitSecs(1);
        Screen('Close',window); % Calling "sca" instead makes no difference.
    end
    Speak('Done!');
end

status=system('osascript -e ''tell application "MATLAB" to activate''');
end
