% trying to replicate problem that appeared on michelle fogarty's mac.
% no success.
Screen('Preference', 'SkipSyncTests', 1);
textFont='Trebuchet MS';
[window,r]=Screen('OpenWindow',0,255,[0 0 100 100]);
Screen('TextSize',window,14);
Screen('TextFont',window,textFont,0);
Screen('TextFont',window)
boundsRect=Screen('TextBounds',window,'hello');
sca
