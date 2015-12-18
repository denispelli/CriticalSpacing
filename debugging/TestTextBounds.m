textSize=48;
w=Screen('OpenWindow',0,255);
Screen(w,'TextFont','Arial');
Screen(w,'TextSize',textSize);
wScratch=Screen('OpenOffscreenWindow',w,[],[0 0 2*textSize*length(string) 2*textSize]);
Screen(wScratch,'TextFont','Arial');
Screen(wScratch,'TextSize',textSize);
x=50;
y=50+textSize;
for yPositionIsBaseline=0:1
    if yPositionIsBaseline
        string='Origin at baseline. ';
    else
        string='Origin at upper left.';
    end
    t=GetSecs;
    bounds=TextBounds(wScratch,string,yPositionIsBaseline)
    fprintf('TextBounds took %.3f seconds.\n',GetSecs-t);
    [newX,newY]=Screen('DrawText',w,string,x,y,0,255,yPositionIsBaseline);
    Screen('FrameRect',w,0,InsetRect(OffsetRect(bounds,x,y),-1,-1));
    x=newX;
    y=newY;
end
Screen('Close',wScratch);
Screen('Flip',w);
Speak('Click to quit');
GetClicks;
Screen('Close',w);
