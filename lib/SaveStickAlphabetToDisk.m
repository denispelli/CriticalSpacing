function SaveStickAlphabetToDisk(o)
if nargin<1
    o.alphabet='123456789';
    o.borderLetter='0';
    o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
    o.targetFont='Sticks';
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
letters=[o.alphabet o.borderLetter];
s = ['111'; '211'; '311'; '121'; '221'; '321'; '131'; '231'; '331'; '122'; '113'; '213'; '313'; '133'];
assert(length(letters)<=size(s,1));
black=0;
white=255;
unitHeight = 10;
savedAlphabet(ia).targetFont=o.targetFont;
savedAlphabet(ia).letters=letters;
savedAlphabet(ia).validKeys=o.validKeys;
savedAlphabet(ia).rect=[0 0 2 3*unitHeight];
savedAlphabet(ia).meanOverMaxTargetWidth=1;
for i=1:length(letters)
    m = zeros(3*unitHeight,2);
    for j=1:size(m,1)/unitHeight
        if ismember(s(i,j),'12') %ignore 3
            m((j-1)*unitHeight+1:j*unitHeight,str2num(s(i,j)))=1;
        end
    end
    savedAlphabet(ia).images{i}=m;
    savedAlphabet(ia).dx(i)=0;
    savedAlphabet(ia).width(i)=RectWidth(savedAlphabet(ia).rect);
%     figure
%     imshow(m);
%     print(['stick' num2str(i) '.png'], '-dpng');
%     close
end
save(filename,'savedAlphabet');
fprintf('Saved images of "%s" alphabet "%s".\n',o.targetFont,letters);
fprintf('Done.\n');
