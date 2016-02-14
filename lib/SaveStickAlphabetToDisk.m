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
alphabetsFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'alphabets'); % CriticalSpacing/alphabets/
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
assert(length(letters)<=size(o.stickSeed,1));
black=0;
white=255;
savedAlphabet.targetFont=o.targetFont;
savedAlphabet.letters=letters;
savedAlphabet.rect=[0 0 2 3*o.stickUnitHeight];
savedAlphabet.meanOverMaxTargetWidth=1;
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
   savedAlphabet.images{i}=m;
   savedAlphabet.dx(i)=0;
   savedAlphabet.width(i)=RectWidth(savedAlphabet.rect);
   close
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
      title(num2str(savedAlphabet.letters(i)));
  end
   suptitle(sprintf('Response page for %s',o.targetFont));
   saveas(gcf,fullfile(fileparts(mfilename('fullpath')),['Draft+response+page+for+' urlencode(o.targetFont) '.png']));
end
