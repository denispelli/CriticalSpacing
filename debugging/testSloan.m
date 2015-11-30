% test Sloan
window=Screen('OpenWindow',0);
Screen('TextFont',window,'Sloan');
Screen('TextSize',window,72);
Screen('DrawText',window,'DHNOK',100,100,0,255);
Screen('Flip',window);
GetClicks;
sca