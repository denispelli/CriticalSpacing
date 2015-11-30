window=Screen('OpenWindow',0,[255 255 255],[],32);
white=[255 255 255];
black=[0 0 0];
white=WhiteIndex(window);
black=BlackIndex(window);
Screen('FillRect',window,white);
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,48);
Screen('DrawText',window,'Hello World.',200,200,black,white,1);
Screen('Flip',window);
Speak(sprintf('Click to proceed'));
GetClicks;
sca
