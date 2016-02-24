% Mario, on the psychtoolbox forum, 2/23/16 explained how to solve this
% problem.
%
% 1.	OS X: In order for Psychtoolbox to be able to load the good DrawText
% plugin you must install the X11 Quartz window package:
% https://support.apple.com/en-us/HT201341
%
% 2.	OS X: In order for Psychtoolbox to be able to load the good DrawText
% plugin in MATLAB 2015b you need to delete or rename this obsolete
% library:  
% /Applications/MATLAB/bin/maci64/libfreetype.6.dylib 
% within MATLAB 2015b so that OS X can find the up-to-date one in X11 
% Quartz.
%
% 3. Try DrawSomeTextDemo. Warning: the first time you load the good
% DrawText plugin there will be a one-minute delay as it converts your
% fonts to its format. Be patient. Hopefully you won?t get a warning
% message saying that Psychtoolbox was unable to load the good DrawText
% plugin. If you do get a warning, the message may give you a hint for
% what?s wrong and how to fix it.

% After doing that, this demo runs perfectly. Without it, the bounding box
% produced by Screen TextBounds is much too big.
%
% denis.pelli@nyu.edu February 2016

font='Pelli'; string='8';
font='Arial'; string='O';
textSize=100;
Screen('Preference','SkipSyncTests',1);
w=Screen('OpenWindow',0,255);
Screen(w,'TextFont',font);
Screen(w,'TextSize',textSize);
wScratch=Screen('OpenOffscreenWindow',w,[],[0 0 2*textSize*length(string) 2*textSize]);
Screen(wScratch,'TextFont',font);
Screen(wScratch,'TextSize',textSize);
x=50;
y=50+textSize;
for yPositionIsBaseline=0:1
   t=GetSecs;
   textBounds=TextBounds(wScratch,string,yPositionIsBaseline);
   fprintf('Width %4.0f, Height %4.0f, TextBounds took %.2f ms. Green.\n',RectWidth(textBounds),RectHeight(textBounds),1000*(GetSecs-t));
   t=GetSecs;
   [screenTextBounds,screenOffsetTextBounds]=Screen('TextBounds',wScratch,string,0,0,yPositionIsBaseline);
   fprintf(2,'Width %4.0f, Height %4.0f, Screen TextBounds took %.2f ms. Red.\n',RectWidth(screenOffsetTextBounds),RectHeight(screenOffsetTextBounds),1000*(GetSecs-t));
   [newX,newY]=Screen('DrawText',w,string,x,y,0,255,yPositionIsBaseline);
   Screen('FrameRect',w,[0 255 0],InsetRect(OffsetRect(textBounds,x,y),-1,-1));
   Screen('FrameRect',w,[255 0 0],InsetRect(OffsetRect(screenOffsetTextBounds,x,y),-1,-1));
   x=newX;
   y=newY;
end
Screen('Close',wScratch);
Screen('Flip',w);
Speak('Click to quit');
GetClicks;
Screen('Close',w);
