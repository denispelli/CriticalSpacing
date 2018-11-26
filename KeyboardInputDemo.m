% KeyboardInputDemo.m
% Denis Pelli, February 5, 2017
%
% Getting keyboard input in MATLAB is tricky. Unless you suppress keyboard
% echoing, all the keys typed will be passed through as text into the
% Command Window or whatever file is in focus. If you typically run your
% programs by hitting the Run button, then it's easy to end up with
% spurious keypresses typed into the code of the program you're running.
%
% Alas, the best solution is ugly. ListenChar(2) prevents echoing of
% keyboard input. Alas, it also leaves the keyboard dead for normal use
% until you restore normal echoing by calling ListenChar. It's easy to call
% ListenChar(2) at the beginning of your program and ListenChar at the end.
% However, if you program terminates prematurely because of an error, the
% end of your program won't run and the keyboard will be dead. Hitting
% Control-C will restore your keyboard. You can ask MATLAB to clean up
% after an error by using try/catch/end. I routinely put SCA in the catch
% block as well since you'll want to close any window opened by SCREEN, to
% regain control of your computer.
try
   ListenChar(2); % At the beginning, disable keyboard echoing.
   % Use only the Psychtoolbox Kb* commands to interact with keyboard
   % devices. Do not use GetChar(), CharAvail(), etc. because they are
   % slower and less portable.
   for i=1:3
      fprintf('%i of 3. Press and release any key on the keyboard:\n',i);
      % Wait for all keys up, any key down, and all keys back up.
      [~,keyCode]=KbStrokeWait();
      fprintf('%s\n',KbName(keyCode));
   end
   fprintf('Done.\n');
   ListenChar; % At the end, restore keyboard echoing.
catch
   ListenChar; % Restore keyboard echoing.
   sca; % Restore screen.
   % Restoring the screen is irrelevant here, but important for programs
   % that use Psychtoolbox SCREEN to open a window obscuring MATLAB's
   % Command Window. You can't interact with MATLAB's Command window until
   % the SCREEN window is closed. Calling ListenChar and SCA give you a
   % good chance of being in control after an error stops execution.
end

