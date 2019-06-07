function CloseWindowsAndCleanup
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
% denis.pelli@nyu.edu, May 5, 2019
global skipScreenCalibration keepWindowOpen % Copy to your main program.
global scratchWindow

if ~isempty(Screen('Windows')) && ~keepWindowOpen
    fprintf('CloseWindowsAndCleanup. ... ');
    s=GetSecs;
    Screen('CloseAll'); % May take a minute.
    fprintf('(SCA done %.0f s.) ',GetSecs-s);
    scratchWindow=[];
    if ~skipScreenCalibration
        if IsOSX
            AutoBrightness(0,1); % May take a minute.
            fprintf('(AutoB done %.0f s). ',GetSecs-s);
        end
        RestoreCluts;
    end
    fprintf('Done (%.0f s)\n',GetSecs-s);
end
% These are quick.
ListenChar;
ShowCursor;
end % function CloseWindowsAndCleanup()

