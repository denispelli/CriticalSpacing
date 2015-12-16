function SaveLettersToDisk(o)
if nargin<1
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.alphabet = ':lijt{}()'; % PTB3 does NOT allow ][;
    o.borderLetter='X';
    o.borderLetter='!';
    o.targetFont='Sloan';
end
letterPix=512;
if IsWindows
    textSizeScalar=1.336;
    textYOffset=0.75;
else
    textSizeScalar=1.0;
    textYOffset=0;
end
window=Screen('OpenWindow',0,255);
Screen('FillRect',window);
Screen('Flip',window);
assert(streq(o.targetFont,'Sloan'));
letters=[o.alphabet o.borderLetter];
canvasRect=[0 0 letterPix letterPix];
black=0;
white=255;
[w,wRect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
Screen('TextFont',w,'Sloan');
font=Screen('TextFont',w);
assert(streq(font,'Sloan'));
Screen('TextSize',w,letterPix/textSizeScalar);
for i=1:length(letters)
    savedLetters(i).letter=letters(i);
    savedLetters(i).rect=canvasRect;
    Screen('FillRect',w,white);
    Screen('DrawText',w,letters(i),0,wRect(4)-textYOffset,black,white,1);
    WaitSecs(0.1);
    letterImage=Screen('GetImage',w,wRect,'drawBuffer');
    savedLetters(i).image=letterImage(:,:,2);
end
Screen('Close',w);
Screen('Close',window);
filename=fullfile(fileparts(mfilename('fullpath')),'savedLetters');
save(filename,'savedLetters');
fprintf('Saved images of Sloan letters %s.\n',letters);
fprintf('Done.\n');