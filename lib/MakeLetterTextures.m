function [letterStruct,canvasRect]=MakeLetterTextures(o,window,savedAlphabet)
% Create textures, one per letter. Called by CriticalSpacing.m.
% Should be easy to eliminate return of canvasRect.
% I'd like to include the file-reading code here, and eliminate the
% "savedAlphabet" argument.
letters=[o.alphabet o.borderLetter];
if o.measureThresholdVertically
   canvasRect=[0 0 o.targetPix o.targetPix];
else
   canvasRect=[0 0 o.targetPix o.targetPix]*o.targetHeightOverWidth;
end
black=0;
white=255;
if o.readAlphabetFromDisk
   for i=1:length(letters)
      which=strfind([savedAlphabet.letters],letters(i));
      if length(which)~=1
         error('Letter %c is not in saved "%s" alphabet "%s".',letters(i),o.targetFont,savedAlphabet.letters);
      end
      assert(length(which)==1);
      r=savedAlphabet.rect;
      letterImage=savedAlphabet.images{which}(r(2)+1:r(4),r(1)+1:r(3));
      letterStruct(i).texture=Screen('MakeTexture',window,letterImage);
      letterStruct(i).rect=Screen('Rect',letterStruct(i).texture);
      % Screen DrawTexture will scale and stretch, as needed.
   end
else
   % Get bounds of font
   scratchWindow=Screen('OpenOffscreenWindow',window,[],canvasRect*4,8,0);
   if ~isempty(o.targetFontNumber)
      Screen('TextFont',scratchWindow,o.targetFontNumber);
      [~,number]=Screen('TextFont',scratchWindow);
      assert(number==o.targetFontNumber);
   else
      Screen('TextFont',scratchWindow,o.targetFont);
      font=Screen('TextFont',scratchWindow);
      assert(streq(font,o.targetFont));
   end
   Screen('TextSize',scratchWindow,sizePix);
   for i=1:length(letters)
      lettersInCells{i}=letters(i);
      letterStruct(i).bounds=TextBounds(scratchWindow,letters(i),1);
   end
   bounds=TextBounds(scratchWindow,lettersInCells,1);
   for i=1:length(letters)
      desiredBounds=CenterRect(letterStruct(i).bounds,bounds);
      letterStruct(i).dx=desiredBounds(1)-letterStruct(i).bounds(1);
      letterStruct(i).width=RectWidth(letterStruct(i).bounds);
   end
   Screen('Close',scratchWindow);
   
   % Create texture for each letter
   canvasRect=bounds;
   canvasRect=OffsetRect(canvasRect,-canvasRect(1),-canvasRect(2));
   fprintf('%d: textSize %.0f, "%s" height %.0f, width %.0f, bounds %.0f %.0f %.0f %.0f\n',condition,sizePix,letters,RectHeight(bounds),RectWidth(bounds),bounds);
   for i=1:length(letters)
      [letterStruct(i).texture,letterStruct(i).rect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
      if ~isempty(o.targetFontNumber)
         Screen('TextFont',letterStruct(i).texture,o.targetFontNumber);
         [font,number]=Screen('TextFont',letterStruct(i).texture);
         assert(number==o.targetFontNumber);
      else
         Screen('TextFont',letterStruct(i).texture,o.targetFont);
         font=Screen('TextFont',letterStruct(i).texture);
         assert(streq(font,o.targetFont));
      end
      Screen('TextSize',letterStruct(i).texture,sizePix);
      Screen('FillRect',letterStruct(i).texture,white);
      Screen('DrawText',letterStruct(i).texture,letters(i),-bounds(1)+letterStruct(i).dx,-bounds(2)-textYOffset,black,white,1);
   end
end