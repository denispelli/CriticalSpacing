function SaveAlphabetToDisk(o)
% SaveAlphabetToDisk(o);
% Accessory to CriticalSpacing, to enhance portability by doing font
% rendering once on a Mac with all the fancy fonts, and doing all
% subsequent work, on every platform, with the saved rendering. Saves a
% rendered font as image files, one per letter, in a folder with the name
% of the font inside the CriticalSpacing/lib/alphabets/ folder. Both the
% letter and the font name pass through EncodeFilename.

% When you save a new font to the CriticalSpacing/lib/alphabets/ folder,
% SaveAlphabetToDisk first looks for such a folder already there. If it
% finds it, it replaces it.

% December 18, 2015. Written by Denis Pelli, with a big assist from Hormet
% Yiltiz. Hormet wrote the code that gets MATLAB to render a letter,
% independent of the psychtoolbox. We need this because the Psychtoolbox
% Screen GetImage command is very flakey.
% December 29, 2015. Rewritten to save as a folder of images instead of a
% MAT file. This allows the image files to be created outside of MATLAB,
% e.g. in any graphic editing app, like GraphicConverter.
% November 11, 2018. Enhanced to support unicode.
if nargin<1
    sca
    o.generateAlphabetPage=1;
    o.showBorderLetterInAlphabetPage=0;
    if 0
        o.targetFont='Gotham Cond SSm XLight';
        o.targetFont='Gotham Cond SSm Light';
        o.targetFont='Gotham Cond SSm Book';
        o.targetFont='Gotham Cond SSm Medium';
        o.targetFont='Gotham Cond SSm Bold';
        o.targetFont='Gotham Cond SSm Black';
        o.alphabet='123456789';
        o.borderLetter='$';
    end
    if 0
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
    end
    if 1
        o.targetFont='Pelli';
        o.alphabet='1234567890';
        o.borderLetter='$';
    end
    if 0
        % Checkers alphabet
        o.targetFont='Checkers';
        o.alphabet='abcdefghijklmnopqrstuvwxy';
        o.borderLetter='z';
    end
   if 0
        % Sans Forgetica
        o.targetFont='Sans Forgetica';
        o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        o.borderLetter='$';
    end
   if 1
        % Kuenstler
        o.targetFont='Kuenstler Script LT Medium';
        o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        o.borderLetter='$';
    end
   if 0
        % Black Sabbath
        o.targetFont='SabbathBlackRegular';
        o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        o.borderLetter='$';
    end
   if 0
        % Chinese from Qihan
        o.targetFont='Songti TC Regular';
        % o.alphabet='????????????????????'; % Chinese from Qihan.
        o.alphabet=[20687 30524 38590 33310 28982 23627 29245 27169 32032 21338 26222 ...
            31661 28246 36891 24808 38065 22251 23500 39119 40517];
        % o.borderLetter='?';
        o.borderLetter=40517;
    end
    if 0
        % Japanese: Katakan, Hiragani, and Kanji
        % from Ayaka
        o.targetFont='Hiragino Mincho ProN W3';
        %     double('??????????????????????????????????????????????') % Katakana from Ayaka
        %     '??????????????????????????????????????????????'; % Hiragan from Ayako
        %     double('???????????????????'); % Hiragana from Ayako
        %     double('????????????????????') % Kanji from Ayaka
        o.alphabet=[12450 12452 12454 12456 12458 12459 12461 12463 12465 12467 12469 ... % Katakana from Ayaka
            12471 12473 12475 12477 12479 12481 12484 12486 12488 12490 12491 ... % Katakana from Ayaka
            12492 12493 12494 12495 12498 12501 12408 12507 12510 12511 12512 ... % Katakana from Ayaka
            12513 12514 12516 12518 12520 12521 12522 12523 12524 12525 12527 ... % Katakana from Ayaka
            12530 12531 ...                                                       % Katakana from Ayaka
            12354 12362 12363 12365 12379 12383 12394 12395 12396 12397 12399 ... % Hiragana from Ayako
            12405 12411 12414 12415 12416 12417 12420 12422 12434 ...             % Hiragana from Ayako
            25010 35009 33016 23041 22654 24149 36605 32302 21213 21127 35069 ... % Kanji from Ayaka
            37806 32190 26286 37707 38525 34276 38360 38627 28187];               % Kanji from Ayaka
        o.borderLetter='';
    end
    o.useMATLABFontRendering=0;
    showProgress=1;
    useWindow=1;
end
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference','SkipSyncTests',1);
Screen('Preference','SuppressAllWarnings',1);
if ~IsOSX
   useWindow=1;
end
alphabetsFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'alphabets'); % CriticalSpacing/alphabets/
if ~exist(alphabetsFolder,'dir')
   mkdir(alphabetsFolder);
end
pdfFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'pdf');% CriticalSpacing/pdf/
if ~exist(pdfFolder,'dir')
   mkdir(pdfFolder);
end
folder=fullfile(alphabetsFolder,EncodeFilename(o.targetFont));
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
if length(letters)>unique(length(letters))
    fprintf('"%s"\n',letters);
    warning('You have at least one duplicated letter.');
end
letterPix=512;
savedAlphabet.targetFont=o.targetFont;
savedAlphabet.letters=letters;
if useWindow
   black=0;
   white=255;
   window=Screen('OpenWindow',0,255,[0 0 512 512]);
   % Screen('preference','ConserveVRAM',2);
   Screen('FillRect',window);
   Screen('Flip',window);
   scratchWindow=Screen('OpenOffscreenWindow',window,[],2*[0 0 letterPix letterPix]);
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
       fprintf('Similarly named fonts:\n');
       begin=o.targetFont(1:min(4,length(o.targetFont)));
       fprintf('(Reporting all font names that match the "%s" beginning of the given name, up to four characters.)\n',begin);
       for i=1:length(fontInfo)
           % Print names of any fonts that have the right first four
           % letters.
           if strncmpi({fontInfo(i).familyName},o.targetFont,min(4,length(o.targetFont)))
               fprintf('%s\n',fontInfo(i).name);
           end
       end
       error('The o.targetFont "%s" is not available. Please install it, or use another font. Any similar names appear above.',o.targetFont);
   end
   if sum(hits)>1
       for i=1:length(fontInfo)
           if streq({fontInfo(i).familyName},o.targetFont)
               fprintf('%s\n',fontInfo(i).name);
           end
       end
       error('Multiple fonts, above, have family name "%s". Pick one.',oo(oi).targetFont);
   end
   o.targetFontNumber=fontInfo(hits).number;
   if useWindow
      Screen('TextFont',window,o.targetFontNumber);
      [~,number]=Screen('TextFont',window);
      if ~(number==o.targetFontNumber)
          error('Unable to select o.targetFont "%s" by its font number %d.',oo(oi).targetFont,oo(oi).targetFontNumber);
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
      [~,number]=Screen('TextFont',scratchWindow);
      assert(number==o.targetFontNumber);
   else
      Screen('TextFont',scratchWindow,o.targetFont);
      font=Screen('TextFont',scratchWindow);
      assert(streq(font,o.targetFont));
   end
   Screen('TextSize',scratchWindow,letterPix);
   for i=1:length(letters)
      bounds=TextBounds(scratchWindow,letters(i),1);
      if i==1
         alphabetBounds=bounds;
      else
         alphabetBounds=UnionRect(alphabetBounds,bounds);
      end
   end
   bounds=alphabetBounds;
   heightOverWidth=RectHeight(bounds)/RectWidth(bounds);
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
      warning('THIS CODE DOES NOT CHECK WHETHER WE GOT THE REQUESTED FONT.');
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
         Screen('DrawText',scratchWindow,double(letters(i)),-bounds(1)+savedAlphabet.dx(i),-bounds(2),black,white,1);
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
    % macOS and Windows use unicode filenames, so they can handle nearly
    % everything, except some punctuation characters that are not allowed
    % in filenames. For them we represents the special character as a code,
    % e.g. %2C for comma. There isn't a standard way to encode unicode in a
    % filename, so we don't intercept the twenty or so unicodes for
    % whitespace.
    name=savedAlphabet.letters(i);
    if length(name)~=1
        error('savedAlphabet.letters(%d) "%s" should be one letter',i,savedAlphabet.letters(i));
    end
    if isspace(double(name)) && double(name)>255
        warning('Using a unicode whitespace as a filename. It will work, but will be invisible.');
    end
    if ismember(name,'% !*''();:@&=+$,/?#[]')
        name=sprintf('%%%2x',name);
    end
    filename=fullfile(folder,[name '.png']);
    imwrite(savedAlphabet.images{i},filename,'png');
end
fprintf('Images of the "%s" alphabet "%s" have been saved in the CriticalSpacing%slib%salphabets%s%s%s folder.\n',o.targetFont,letters,filesep,filesep,filesep,EncodeFilename(o.targetFont),filesep);
sca
% show Alphabet Page
if o.generateAlphabetPage
   figure('PaperType','usletter');
   for i=1:length(savedAlphabet.images)
       if o.borderLetter==savedAlphabet.letters(i)
           continue
       end
       columns=round(heightOverWidth*1.2*sqrt(length(savedAlphabet.images)));
       subplot(ceil(length(savedAlphabet.images)/columns),columns,i);
       imshow(savedAlphabet.images{i});
   end
   suptitle(sprintf('%s alphabet',o.targetFont));
   saveas(gcf,fullfile(pdfFolder,['screenshot of ' EncodeFilename(o.targetFont) ' alphabet.png']));
   fprintf('A screenshot of the whole "%s" alphabet has been saved in the CriticalSpacing%spdf%s folder.\n',o.targetFont,filesep,filesep);
end
fprintf('Done.\n');

