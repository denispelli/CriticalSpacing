function SaveStickAlphabetToDisk(o)
if nargin<1
  o.alphabet='123456789';
  o.borderLetter='0';
  o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
  o.targetFont='Sticks';
  % this seed ensures no symmetry in a 3x2 block of binary matrix
  % note that they are 14 > 10, which is currectly used, thus last four
  % sticks were NOT in use now
  o.stickSeed = ['111'; '122'; '311'; '121'; '313'; '321'; '232'; '231'; '233';'333'];
  
  % display border letter as well in the response page
  %   o.stickSeed = ['111'; '122'; '311'; '121'; '313'; '321'; '232'; '231'; '233';'333'; '333']; % last one gets ignored automatically, so add another
  %   o.alphabet='123456789X'; % also generate border letter
  
  o.stickUnitHeight = 5;
  o.stickUnitWidth = 1;
  o.generateResponsePage = 1;
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
assert(length(letters)<=size(o.stickSeed,1));

black=0;
white=255;

savedAlphabet(ia).targetFont=o.targetFont;
savedAlphabet(ia).letters=letters;
savedAlphabet(ia).validKeys=o.validKeys;
savedAlphabet(ia).rect=[0 0 2 3*o.stickUnitHeight];
savedAlphabet(ia).meanOverMaxTargetWidth=1;
for i=1:length(letters)
  m = zeros(3*o.stickUnitHeight,2*o.stickUnitWidth);
  for j=1:size(m,1)/o.stickUnitHeight
    unitBlock.h = (j-1)*o.stickUnitHeight+1:j*o.stickUnitHeight;
    unitBlock.v = (str2double(o.stickSeed(i,j))-1)*o.stickUnitWidth+1:str2double(o.stickSeed(i,j))*o.stickUnitWidth;
    if ismember(o.stickSeed(i,j),'12') % ignore 3, common color for column 1 and 2
      m(unitBlock.h, unitBlock.v)=1; % tag with value
    elseif ismember(o.stickSeed(i,j),'3') % common color for column 1 and 2
      m(unitBlock.h, :)=3; % tag with value 3
    end
  end
  m(m==3) = 1;
  % now transform into RGB space
  m = white*(~m);
  savedAlphabet(ia).images{i}=m;
  savedAlphabet(ia).dx(i)=0;
  savedAlphabet(ia).width(i)=RectWidth(savedAlphabet(ia).rect);
  %   figure
  %   imshow(m);%pause
  %   print(['stick' num2str(i) '.png'], '-dpng');
  close
end

% show Response Page for Sticks
if o.generateResponsePage
  figure('PaperType','usletter');
  for i=1:numel(savedAlphabet(ia).images)-1 % last stick is border letter
    subplot(ceil(numel(savedAlphabet(ia).images)/3),3,i);
    imshow(savedAlphabet(ia).images{i});
    title(num2str(o.alphabet(i)));
  end
  %   suptitle('Response Page')
end


filename=fullfile(fileparts(mfilename('fullpath')),'savedAlphabet');
save(filename,'savedAlphabet');
fprintf('Saved images of "%s" alphabet "%s" in file "savedAlphabet".\n',o.targetFont,letters);
fprintf('Done.\n');
sca
