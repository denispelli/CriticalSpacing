window=Screen('OpenWindow',0);
Screen('DrawText',window,'One',0,200);
Screen('Flip',window);
GetClicks;
Screen('DrawText',window,'Two',0,200);
Screen('Flip',window,[],2); % Swap front and back buffers.
GetClicks;
Screen('Flip',window,[],2); % Swap front and back buffers.
GetClicks;
Screen('DrawText',window,'One',0,300);
Screen('Flip',window); % Restore from back buffer.
GetClicks;
Screen('Close',window);
