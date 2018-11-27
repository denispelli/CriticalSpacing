function CloseWindowsAndCleanup()
% Close any windows opened by the Psychtoolbox Screen command, 
% re-enable the keyboard, show the cursor, and restore the cluts.
if ~isempty(Screen('Windows'))
    % Screen CloseAll is very slow, so we call it only if we need to.
    Screen('CloseAll');
    if ismac
        % Takes 120 s.
        % AutoBrightness(0,1);
    end
end
ListenChar;
ShowCursor;
RestoreCluts;
end % function CloseWindowsAndCleanup()

% Call onCleanup at the beginning of your main program to request a clean
% up whenever your program terminates, even by error or control-c.
% cleanup=onCleanup(@() CloseWindowsAndCleanup);

