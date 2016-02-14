function quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect)
% quitSession=OfferToQuitSession(window,oo,instructionalMargin,screenRect)
if oo(1).speakEachLetter && oo(1).useSpeech
   Speak('Escape');
end
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
Screen('FillRect',window);
Screen('TextFont',window,oo(1).textFont,0);
string='Now quitting run. Hit ESCAPE again to quit the whole session. Or SPACE or RETURN to proceed with the next run.';
black=0;
white=255;
DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,65,[],[],1.1);
% Screen('DrawText',window,'Hit ESCAPE to terminate, or SPACE or RETURN to continue:',instructionalMargin,screenRect(4)/2);
Screen('TextSize',window,round(oo(1).textSize*0.4));
Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
Screen('TextSize',window,oo(1).textSize);
Screen('Flip',window);
answer=GetKeypress([returnKeyCode spaceKeyCode escapeKeyCode],oo(1).deviceIndex);
quitSession=streq(answer,'ESCAPE');
if oo(1).useSpeech
   if quitSession
      Speak('Escape. You''re done.');
   else
      Speak('Proceeding to next run.');
   end
end
Screen('FillRect',window);
end