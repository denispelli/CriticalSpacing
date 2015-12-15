function SaveLettersToDisk(o)
if nargin<1
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
    o.targetFont='Sloan';
end
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
canvasRect=[0 0 256 256];
black=0;
white=255;
[w,wRect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
Screen('TextFont',w,'Sloan');
font=Screen('TextFont',w);
assert(streq(font,'Sloan'));
Screen('TextSize',w,256/textSizeScalar);
for i=1:length(letters)
    savedLetters(i).letter=letters(i);
    savedLetters(i).rect=canvasRect;
    Screen('FillRect',w,white);
    Screen('DrawText',w,letters(i),0,wRect(4)-textYOffset,black,white,1);
    WaitSecs(0.1);
    savedLetters(i).image=Screen('GetImage',w,wRect,'drawBuffer');
end
Screen('Close',w);
Screen('Close',window);
filename=fullfile(fileparts(mfilename('fullpath')),'savedLetters');
save(filename,'savedLetters');
fprintf('Done.\n');