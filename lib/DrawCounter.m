function DrawCounter(oo)
% DrawCounter(oo)
global window scratchWindow
global blockTrial blockTrials
% Display counter in lower right corner.
if isempty(blockTrial)
    message=sprintf('Block %d of %d.',...
        oo(1).block,oo(1).blocksDesired);
else
    message=sprintf('Trial %d of %d. Block %d of %d.',...
        blockTrial,blockTrials,oo(1).block,oo(1).blocksDesired);
end
counterSize=round(0.6*oo(1).textSize);
oldTextSize=Screen('TextSize',window,counterSize);
Screen('TextSize',scratchWindow,counterSize);
counterBounds=TextBounds(scratchWindow,message,1);
counterBounds=AlignRect(counterBounds,InsetRect(oo(1).stimulusRect,counterSize/4,counterSize/4),'right','bottom');
white=WhiteIndex(window);
black=BlackIndex(window);
Screen('DrawText',window,message,counterBounds(1),counterBounds(4),black,white,1);
Screen('TextSize',window,oldTextSize);
end