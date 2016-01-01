function SaveAlphabetToDisk(o)
% SaveAlphabetToDisk(o);
% Accessory to CriticalSpacing, to enhance portability by doing font
% rendering once on a Mac with all the fancy fonts, and doing all
% subsequent work, on every platform, with the saved rendering. Saves a
% rendered font as image files, one per letter, in a folder with the name
% of the font inside the SavedAlphabets folder. Both the letter and the
% font name are url encoded (urlencode).

% When you save a new font to the SavedAlphabets folder, SaveAlphabetToDisk
% first looks for such a folder already there. If it finds it, it replaces
% it.

% December 18, 2015. Written by Denis Pelli, with a big assist from Hormet
% Yiltiz. Hormet wrote the code that gets MATLAB to render a letter,
% independent of the psychtoolbox. We need this because the Psychtoolbox
% Screen GetImage command is very flakey.
% December 29, 2015. Rewritten to save as a folder of images instead of a
% MAT file. This allows the image files to be created outside of MATLAB,
% e.g. in any graphic editing app, like GraphicConverter.
if nargin<1
   sca
      o.targetFont='Sloan';
      o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
      o.borderLetter='X';
   o.generateResponsePage=1;
%    o.targetFont='Gotham Cond SSm XLight';
%    o.targetFont='Gotham Cond SSm Light';
%    o.targetFont='Gotham Cond SSm Book';
%    o.targetFont='Gotham Cond SSm Medium';
%    o.targetFont='Gotham Cond SSm Bold';
%    o.targetFont='Gotham Cond SSm Black';
%    o.alphabet='123456789';
%    o.borderLetter='$';
   o.useMATLABFontRendering=0;
   showProgress=1;
   useWindow=1;
end
if ~IsOSX
   useWindow=1;
end
alphabetsFolder=fullfile(fileparts(mfilename('fullpath')),'alphabets');
if ~exist(alphabetsFolder,'dir')
   mkdir(alphabetsFolder);
end
folder=fullfile(alphabetsFolder,urlencode(o.targetFont));
if exist(folder,'dir')
   rmdir(folder,'s');
end
mkdir(folder);
savedAlphabet.letters='';
savedAlphabet.validKeys={};
savedAlphabet.bounds={};
savedAlphabet.images={};
savedAlphabet.rect=[];
savedAlphabet.dx=[];
savedAlphabet.width=[];
savedAlphabet.meanOverMaxTargetWidth=[];
letters=[o.alphabet o.borderLetter];
letterPix=512;
savedAlphabet.targetFont=o.targetFont;
savedAlphabet.letters=letters;
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
   % Match full name, which includes style.
   hits=streq({fontInfo.name},o.targetFont);
   if sum(hits)<1
      % Match file name, which includes style.
      hits=streq({fontInfo.file},o.targetFont);
   end
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
   savedAlphabet.rect=OffsetRect(bounds,-bounds(1),-bounds(2));
   for i=1:length(letters)
      letterBounds=TextBounds(scratchWindow,letters(i),1);
      desiredBounds=CenterRect(letterBounds,bounds);
      savedAlphabet.dx(i)=desiredBounds(1)-letterBounds(1);
      savedAlphabet.width(i)=RectWidth(letterBounds);
   end
   savedAlphabet.meanOverMaxTargetWidth=mean([savedAlphabet.width])/RectWidth(bounds);
end
for i=1:length(letters)
   if o.useMATLABFontRendering
      f=figure('Units','pixels','Position',[0 0 1024 1024]);
      h=text(0,256,letters(i),'Units','pixels','FontName',o.targetFont, 'FontUnits','pixels','FontSize',512,'BackgroundColor',[1 1 1]);
      error('THIS CODE DOES NOT CHECK WHETHER WE GOT THE REQUESTED FONT.');
      set(f,'InvertHardcopy','off'); % Attempts to keep background white when we copy it.
      box off
      axis off
      set(gca,'XTick',[],'YTick',[]);
      letterImage=frame2im(getframe(gcf));
      close; % figure
      letterImage=letterImage(:,:,2); % Convert RGB to grayscale.
      savedAlphabet.bounds{i}=ImageBounds(letterImage,letterImage(end,1));
      savedAlphabet.images{i}=letterImage;
   else
      if useWindow
         Screen('FillRect',scratchWindow,white);
         Screen('DrawText',scratchWindow,letters(i),-bounds(1)+savedAlphabet.dx(i),-bounds(2),black,white,1);
         letterImage=Screen('GetImage',scratchWindow,OffsetRect(bounds,-bounds(1),-bounds(2)),'drawBuffer');
         savedAlphabet.images{i}=letterImage;
      end
   end
   if useWindow
      Screen('PutImage',window,letterImage,OffsetRect(bounds,-bounds(1),-bounds(2)));
      Screen('Flip',window);
      WaitSecs(0.5);
   end
end
if o.useMATLABFontRendering
   % Each letter is black on white, surrounded by gray.
   % First we crop to exclude the general gray.
   % Here we extract the black/white letter from the gray.
   b=savedAlphabet.bounds{1};
   for i=1:length(letters)
      b=UnionRect(b,savedAlphabet.bounds{i});
   end
   for i=1:length(letters)
      savedAlphabet.images{i}=savedAlphabet.images{i}(1+b(2):b(4),1+b(1):b(3));
      % Now we find bounds of the black letter in its local white background.
      % We trim off the excess white, and then get a tight bounding box for each
      % letter. We use the union as a cropping rect for the alphabet, and
      % we return a bounding box, within that, for each letter.
      savedAlphabet.bounds{i}=ImageBounds(savedAlphabet.images{i});
   end
   b=savedAlphabet.bounds{1};
   for i=1:length(letters)
      b=UnionRect(b,savedAlphabet.bounds{i});
   end
   for i=1:length(letters)
      savedAlphabet.images{i}=savedAlphabet.images{i}(1+b(2):b(4),1+b(1):b(3));
      savedAlphabet.bounds{i}=OffsetRect(savedAlphabet.bounds{i},-b(1),-b(2));
      savedAlphabet.width(i)=RectWidth(savedAlphabet.bounds{i});
      savedAlphabet.rect=OffsetRect(b,-b(1),-b(2));
      if showProgress
         if useWindow
            Screen('PutImage',window,savedAlphabet.images{i});
            Screen('FrameRect',window,0,savedAlphabet.bounds{i});
            Screen('Flip',window);
            WaitSecs(0.5);
         else
            imshow(savedAlphabet.images{i});
         end
      end
      savedAlphabet.rect=RectOfMatrix(savedAlphabet.images{1});
   end
end
if useWindow
   Screen('Close',scratchWindow);
   Screen('Close',window);
end
for i=1:length(savedAlphabet.images)
   filename=fullfile(folder,urlencode(savedAlphabet.letters(i)));
   filename=[filename '.png'];
   imwrite(savedAlphabet.images{i},filename,'png');
end
fprintf('Images of "%s" alphabet "%s" have been saved in folder "alphabets%s%s".\n',o.targetFont,letters,filesep,urlencode(o.targetFont));
fprintf('Done.\n');
sca
% show Response Page
if o.generateResponsePage
   figure('PaperType','usletter');
   for i=1:length(savedAlphabet.images)-1 % skip border letter, which is last
      subplot(ceil(numel(savedAlphabet.images)/3),3,i);
      imshow(savedAlphabet.images{i});
   end
   suptitle(sprintf('Response page for %s',o.targetFont));
   saveas(gcf,fullfile(fileparts(mfilename('fullpath')),['Draft+response+page+for+' urlencode(o.targetFont) '.png']));
end

