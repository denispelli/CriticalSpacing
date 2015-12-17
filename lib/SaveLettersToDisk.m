function SaveLettersToDisk(o)
if nargin<1
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
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
assert(streq(o.targetFont,o.targetFont));
letters=[o.alphabet o.borderLetter];
canvasRect=[0 0 letterPix letterPix];
black=0;
white=255;
[w,wRect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
Screen('TextFont',w,o.targetFont);
font=Screen('TextFont',w);
assert(streq(font,o.targetFont));
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
fprintf('Saved images of %s letters "%s".\n',o.targetFont,letters);
fprintf('Done.\n');