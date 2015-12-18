function SaveAlphabetToDisk(o)
if nargin<1
  o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
  o.validKeys = {'d','h','k','n','o','r','s','v','z'};
  o.borderLetter='X';
  o.targetFont='Sloan';
o.targetFont='Gotham Cond SSm Medium';
end
filename=fullfile(fileparts(mfilename('fullpath')),'savedAlphabet');
try
  load(filename,'savedAlphabet');
catch
  clear savedAlphabet
end
if exist('savedAlphabet','var')
  ia=length(savedAlphabet)+1;
else
  ia=1;
end
letterPix=512;
if IsWindows
  textSizeScalar=1.336;
  textYOffset=0.75;
else
  textSizeScalar=1.0;
  textYOffset=0;
end
letters=[o.alphabet o.borderLetter];
rect=[0 0 letterPix letterPix];
savedAlphabet(ia).targetFont=o.targetFont;
savedAlphabet(ia).letters=letters;
savedAlphabet(ia).validKeys=o.validKeys;
savedAlphabet(ia).rect=rect;
black=0;
white=255;
window=Screen('OpenWindow',0,255);
Screen('FillRect',window);
Screen('Flip',window);
[scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],rect,8,0);
if IsOSX
  fontInfo=FontInfo('Fonts');
  % Match full name, including style.
  hits=streq({fontInfo.name},o.targetFont);
  if sum(hits)<1
    % Match family name, omitting style.
    hits=streq({fontInfo.familyName},o.targetFont);
  end
  if sum(hits)==0
    error('The o.targetFont "%s" is not available. Please install it.',o.targetFont);
  end
  if sum(hits)>1
    error('Multiple fonts with name "%s".',o.targetFont);
  end
  o.targetFontNumber=fontInfo(hits).number;
  Screen('TextFont',window,o.targetFontNumber);
  [font,number]=Screen('TextFont',window);
  if ~(number==o.targetFontNumber)
    error('The o.targetFont "%s" is not available. Please install it.',o.targetFont);
  end
else
  o.targetFontNumber=[];
  Screen('TextFont',window,o.targetFont);
  font=Screen('TextFont',window);
  if ~streq(font,o.targetFont)
    error('The o.targetFont "%s" is not available. Please install it.',o.targetFont);
  end
end
if ~isempty(o.targetFontNumber)
  Screen('TextFont',scratchWindow,o.targetFontNumber);
  [font,number]=Screen('TextFont',scratchWindow);
  assert(number==o.targetFontNumber);
else
  Screen('TextFont',scratchWindow,o.targetFont);
  font=Screen('TextFont',scratchWindow);
  assert(streq(font,o.targetFont));
end
Screen('TextSize',scratchWindow,letterPix/textSizeScalar);
for i=1:length(letters)
  lettersInCells{i}=letters(i);
end
bounds=TextBounds(scratchWindow,lettersInCells,1);

for i=1:length(letters)
  lettersInCells{i}=letters(i);
end
bounds=TextBounds(scratchWindow,lettersInCells,1);
for i=1:length(letters)
  letterBounds=TextBounds(scratchWindow,letters(i),1);
  desiredBounds=CenterRect(letterBounds,bounds);
  savedAlphabet(ia).dx(i)=desiredBounds(1)-letterBounds(1);
  savedAlphabet(ia).width(i)=RectWidth(letterBounds);
end
savedAlphabet(ia).meanOverMaxTargetWidth=mean([savedAlphabet(ia).width])/RectWidth(bounds);
for i=1:length(letters)
  Screen('FillRect',scratchWindow,white);
  Screen('DrawText',scratchWindow,letters(i),-bounds(1)+savedAlphabet(ia).dx(i),-bounds(2)-textYOffset,black,white,1);
  WaitSecs(0.1);
  letterImage=Screen('GetImage',scratchWindow,scratchRect,'drawBuffer');
  savedAlphabet(ia).images{i}=letterImage(:,:,2);
end
Screen('Close',scratchWindow);
Screen('Close',window);
filename=fullfile(fileparts(mfilename('fullpath')),'savedAlphabet');
save(filename,'savedAlphabet');
fprintf('Saved images of "%s" alphabet "%s".\n',o.targetFont,letters);
fprintf('Done.\n');
