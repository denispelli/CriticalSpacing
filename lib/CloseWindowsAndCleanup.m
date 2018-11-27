function CloseWindowsAndCleanup()
% Close any windows opened by the Psychtoolbox Screen command, 
% re-enable the keyboard, show the cursor, and restore the cluts. This
% function is similar to "sca", but much quicker if no window is open.
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
    Screen('CloseAll');
    if ismac
        AutoBrightness(0,1);
    end
end
% These three are quick, about 0.1 s.
ListenChar;
ShowCursor;
RestoreCluts;
end % function CloseWindowsAndCleanup()


