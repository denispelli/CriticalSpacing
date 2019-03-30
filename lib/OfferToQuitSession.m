function quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect,dontClear)
% quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect,dontClear)
% Setting dontClear='dontClear' allows you to clear the screen yourself and
% add annotations to our display before calling.
global keepWindowOpen
if oo(1).speakEachLetter && oo(1).useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
% spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
graveAccentChar='`';
if nargin<5 || ~streq(dontClear,'dontClear')
    Screen('FillRect',window);
end
Screen('TextFont',window,oo(1).textFont,0);
string='Quitting the block. Hit ESCAPE again to quit the whole session. Or hit RETURN to proceed with the next block.';
black=0;
white=255;
DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,65,[],[],1.1);
Screen('TextSize',window,round(oo(1).textSize*0.35));
Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, 2018, 2019, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
Screen('TextSize',window,oo(1).textSize);
Screen('Flip',window);
answer=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode],oo(1).deviceIndex);
quitSession=ismember(answer,[escapeChar,graveAccentChar]);
if oo(1).useSpeech
    if quitSession
        Speak('Escape. Done.');
    elseif oo(1).isLastBlock
        Speak('Done.');
    else
        Speak('Proceeding to next block.');
    end
end
if quitSession
    keepWindowOpen=false;
elseif oo(1).isLastBlock
    keepWindowOpen=false;
else
    keepWindowOpen=true;
end
Screen('FillRect',window);
Screen('Flip',window);
end