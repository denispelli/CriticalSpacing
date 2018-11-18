function quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect)
% quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect)
if oo(1).speakEachLetter && oo(1).useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
% spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
graveAccentChar='`';
Screen('FillRect',window);
Screen('TextFont',window,oo(1).textFont,0);
string='Quitting the block. Hit ESCAPE again to quit the whole session. Or hit RETURN to proceed with the next block.';
black=0;
white=255;
DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,65,[],[],1.1);
Screen('TextSize',window,round(oo(1).textSize*0.35));
Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, 2018, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
Screen('TextSize',window,oo(1).textSize);
Screen('Flip',window);
answer=GetKeypress([returnKeyCode escapeKeyCode graveAccentKeyCode],oo(1).deviceIndex);
quitSession=ismember(answer,[escapeChar,graveAccentChar]);
if oo(1).useSpeech
   if quitSession
      Speak('Escape. Done.');
   else
      Speak('Proceeding to next block.');
   end
end
Screen('FillRect',window);
end