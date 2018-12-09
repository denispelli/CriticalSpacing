function CloseWindowsAndCleanup()
% Closes any windows opened by the Psychtoolbox Screen command, re-enables
% the keyboard, shows the cursor, and restores the video color lookup
% tables (cluts). This function is similar to "sca".
%
% It can be frustrating to have your program terminate, possibly due to an
% error, while a psychtoolbox window obscures the MATLAB Command Window.
% You can avoid that problem by planning ahead. Call onCleanup at the
% beginning of your main program to request a clean up whenever your
% program terminates, even by error or control-c.
%
% cleanup=onCleanup(@() CloseWindowsAndCleanup);
%
% The cleanup function you specify is called when the local variable
% "cleanup" is cleared, which occurs at termination (normal or abnormal) of
% the program that it's in.
%
% denis.pelli@nyu.edu, November 27, 2018
global ff isLastBlock rushToDebug % Set this in your main program. True on last block.

ffprintf(ff,'CloseWindowsAndCleanup. ... '); s=GetSecs;
if ~isempty(Screen('Windows'))
    Screen('CloseAll'); % May take a minute.
    if ismac && isLastBlock && ~rushToDebug
        AutoBrightness(0,1); % May take a minute.
        RestoreCluts;
    end
end
% These are quick.
ListenChar;
ShowCursor;
ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
end % function CloseWindowsAndCleanup()

