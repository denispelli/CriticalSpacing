function CloseWindowsAndCleanup()
% Closes any windows opened by the Psychtoolbox Screen command, re-enables
% the keyboard, shows the cursor, and restores the video color lookup
% tables (cluts). This function is similar to "sca".
%
% It can be frustrating to have your program terminate, possibly due to an
% error, while a psychtoolbox window obscures your view of the MATLAB
% Command Window. You can avoid that problem by planning ahead. Call
% onCleanup at the beginning of your main program to request a clean up
% whenever your program terminates, even by error or control-c.
%
% cleanup=onCleanup(@() CloseWindowsAndCleanup);
%
% denis.pelli@nyu.edu, November 27, 2018

if ~isempty(Screen('Windows'))
    Screen('CloseAll'); % May take many seconds.
    if ismac
        AutoBrightness(0,1); % May take many seconds.
    end
end
% These three are quick.
ListenChar;
ShowCursor;
RestoreCluts;
end % function CloseWindowsAndCleanup()


