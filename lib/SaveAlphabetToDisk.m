function savedAlphabet=SaveAlphabetToDisk(o)

% Accessory to CriticalSpacing, to enhance portability by doing font
% rendering once on a Mac with all the fancy fonts, and doing all
% subsequent work, on every platform, with the saved rendering. Saves a
% rendered font and alphabet in a MAT file, savedAlphabet, which can hold
% any number.

% When you save a new font to the MAT file, SaveAlphabetToDisk first looks
% for that font in the MAT file. if it finds it, it overwrites it.
% Otherwise it adds the new font. Thus one can freely write many fonts to
% it and always be sure of retrieving the latest of what's available in the
% file.
%
% Right now, we save a list of letters to use, in the MAT file. i think it
% would be more elegant to consider the MAT file as a data base and allow
% the user to use any set of letters that is present in the MAT file,
% without necessarily using them all. this will require only minor changes
% to CriticalSpacing.m, giving preference to the new request over what is
% saved.

% December 18, 2015. Written by Denis Pelli, with a big assist from Hormet
% Yiltiz. Hormet wrote the code that gets MATLAB to render a letter,
% independent of the psychtoolbox. We need this because the Psychtoolbox
% Screen GetImage command is very flakey.

if nargin<1
   sca
   
   o.targetFont='Sloan';
   o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
   o.borderLetter='X';
   o.validKeys = {'d','h','k','n','o','r','s','v','z'};
   
%    o.targetFont='Gotham Cond SSm Medium';
%    o.alphabet='123456789';
%    o.borderLetter='0';
%    o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
   
   o.useMATLABFontRendering=1;
   showProgress=1;
   useWindow=0;
end
filename=fullfile(fileparts(mfilename('fullpath')),'savedAlphabet');
try
   load(filename,'savedAlphabet');
catch
   clear savedAlphabet
end
if exist('savedAlphabet','var')
   for ia=1:length(savedAlphabet)
      match=streq(savedAlphabet(ia).targetFont,o.targetFont);
      if match
         savedAlphabet(ia).letters='';
         savedAlphabet(ia).validKeys={};
         savedAlphabet(ia).bounds={};
         savedAlphabet(ia).images={};
         savedAlphabet(ia).rect=[];
         savedAlphabet(ia).dx=[];
         savedAlphabet(ia).width=[];
         savedAlphabet(ia).meanOverMaxTargetWidth=[];
         break;
      end;
   end
   if ~match
      ia=length(savedAlphabet)+1;
   end
else
   ia=1;
end
letters=[o.alphabet o.borderLetter];
letterPix=512;
savedAlphabet(ia).targetFont=o.targetFont;
savedAlphabet(ia).letters=letters;
savedAlphabet(ia).validKeys=o.validKeys;
if useWindow
   black=0;
   white=255;
   [window,windowRect]=Screen('OpenWindow',0,255,[0 0 512 512]);
   % Screen('preference','ConserveVRAM',2);
   Screen('FillRect',window);
   Screen('Flip',window);
   [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],2*[0 0 letterPix letterPix]);
end
% Set font.
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
   if useWindow
      Screen('TextFont',window,o.targetFontNumber);
      [font,number]=Screen('TextFont',window);
      if ~(number==o.targetFontNumber)
         error('The o.targetFont "%s" is not available. Please install it.',o.targetFont);
      end
   end
else
   if useWindow
      o.targetFontNumber=[];
      Screen('TextFont',window,o.targetFont);
      font=Screen('TextFont',window);
      if ~streq(font,o.targetFont)
         error('The o.targetFont "%s" is not available. Please install it.',o.targetFont);
      end
   end
end
if useWindow
   if ~isempty(o.targetFontNumber)
      Screen('TextFont',scratchWindow,o.targetFontNumber);
      [font,number]=Screen('TextFont',scratchWindow);
      assert(number==o.targetFontNumber);
   else
      Screen('TextFont',scratchWindow,o.targetFont);
      font=Screen('TextFont',scratchWindow);
      assert(streq(font,o.targetFont));
   end
   Screen('TextSize',scratchWindow,letterPix);
   for i=1:length(letters)
      lettersInCells{i}=letters(i);
   end
   bounds=TextBounds(scratchWindow,lettersInCells,1);
   savedAlphabet(ia).rect=OffsetRect(bounds,-bounds(1),-bounds(2));
   for i=1:length(letters)
      letterBounds=TextBounds(scratchWindow,letters(i),1);
      desiredBounds=CenterRect(letterBounds,bounds);
      savedAlphabet(ia).dx(i)=desiredBounds(1)-letterBounds(1);
      savedAlphabet(ia).width(i)=RectWidth(letterBounds);
   end
   savedAlphabet(ia).meanOverMaxTargetWidth=mean([savedAlphabet(ia).width])/RectWidth(bounds);
end
for i=1:length(letters)
   if o.useMATLABFontRendering
      f=figure('Units','pixels','Position',[0 0 1024 1024]);
      h=text(0,256,letters(i),'Units','pixels','FontName',o.targetFont,'FontUnits','pixels','FontSize',512,'BackgroundColor',[1 1 1]);
      set(f,'InvertHardcopy','off'); % Attempts to keep background white when we copy it.
      box off
      axis off
      set(gca,'XTick',[],'YTick',[]); 
      letterImage=frame2im(getframe(gcf));
      close; % figure
      letterImage=letterImage(:,:,2); % Convert RGB to grayscale.
      savedAlphabet(ia).bounds{i}=ImageBounds(letterImage,letterImage(end,1));
      savedAlphabet(ia).images{i}=letterImage;
   else
      if useWindow
         Screen('FillRect',scratchWindow,white);
         %     Screen('DrawText',window,letters(i),-bounds(1)+savedAlphabet(ia).dx(i),-bounds(2),black,white,1);
         Screen('DrawText',scratchWindow,letters(i),-bounds(1)+savedAlphabet(ia).dx(i),-bounds(2),black,white,1);
         %     Screen('DrawingFinished',scratchWindow); % Might make GetImage more reliable. Suggested by Mario Kleiner.
         %     Screen('DrawTexture',window,scratchWindow,savedAlphabet(ia).rect,windowRect);
         %     letterImage=Screen('GetImage',scratchWindow,bounds);
         letterImage=Screen('GetImage',window,bounds,'drawBuffer');
         %    imshow(letterImage);
         %    letterImage=Screen('GetImage',scratchWindow,bounds,'drawBuffer');
         savedAlphabet(ia).images{i}=letterImage;
         %    savedAlphabet(ia).images{i}=letterImage(:,:,2);
         %    imshow(savedAlphabet(ia).images{i});
         %    Screen('DrawText',window,letters(i),-bounds(1)+savedAlphabet(ia).dx(i),-bounds(2),black,white,1);
      end
   end
   if useWindow
      Screen('PutImage',window,letterImage,OffsetRect(bounds,400,400));
      Screen('Flip',window);
      WaitSecs(0.5);
   end
end
if o.useMATLABFontRendering
   % Each letter is black on white, surrounded by gray.
   % First we crop to exclude the general gray.
   % Here we extract the black/white letter from the gray.
   b=savedAlphabet(ia).bounds{1};
   for i=1:length(letters)
      b=UnionRect(b,savedAlphabet(ia).bounds{i});
   end
   for i=1:length(letters)
      savedAlphabet(ia).images{i}=savedAlphabet(ia).images{i}(1+b(2):b(4),1+b(1):b(3));
      % Now we find bounds of the black letter in its local white background.
      % We trim off the excess white, and then get a tight bounding box for each
      % letter. We use the union as a cropping rect for the alphabet, and
      % we return a bounding box, within that, for each letter.
      savedAlphabet(ia).bounds{i}=ImageBounds(savedAlphabet(ia).images{i});
   end
   b=savedAlphabet(ia).bounds{1};
   for i=1:length(letters)
      b=UnionRect(b,savedAlphabet(ia).bounds{i});
   end
   for i=1:length(letters)
      savedAlphabet(ia).images{i}=savedAlphabet(ia).images{i}(1+b(2):b(4),1+b(1):b(3));
      savedAlphabet(ia).bounds{i}=OffsetRect(savedAlphabet(ia).bounds{i},-b(1),-b(2));
      savedAlphabet(ia).width(i)=RectWidth(savedAlphabet(ia).bounds{i});
      savedAlphabet(ia).rect=OffsetRect(b,-b(1),-b(2));
      if showProgress
         if useWindow
            Screen('PutImage',window,savedAlphabet(ia).images{i});
            Screen('FrameRect',window,0,savedAlphabet(ia).bounds{i});
            Screen('Flip',window);
            WaitSecs(0.5);
         else
            imshow(savedAlphabet(ia).images{i});
         end
      end
      savedAlphabet(ia).rect=RectOfMatrix(savedAlphabet(ia).images{1});
   end
end
if useWindow
   Screen('Close',scratchWindow);
   Screen('Close',window);
end
filename=fullfile(fileparts(mfilename('fullpath')),'savedAlphabet');
save(filename,'savedAlphabet');
fprintf('Saved images of "%s" alphabet "%s" in file "savedAlphabet".\n',o.targetFont,letters);
fprintf('Done.\n');
sca
