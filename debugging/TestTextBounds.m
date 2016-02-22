font='Pelli'; string='8';
% font='Arial'; string='O';
textSize=100;
Screen('Preference','SkipSyncTests',1);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
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
   %     Screen('FrameRect',w,[0 0 255],InsetRect(OffsetRect(screenTextBounds,x,y),-1,-1));
   Screen('FrameRect',w,[255 0 0],InsetRect(OffsetRect(screenOffsetTextBounds,x,y),-1,-1));
   x=newX;
   y=newY;
end
Screen('Close',wScratch);
Screen('Flip',w);
Speak('Click to quit');
GetClicks;
Screen('Close',w);
