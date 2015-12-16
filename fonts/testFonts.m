fi=FontInfo('Fonts');
hits=[streq({fi.familyName},'Gotham Cond SSm')];
myfi=fi(hits);
for i=1:length(myfi)
    fprintf('%s, %d, %d\n',myfi(i).name,myfi(i).number,myfi(i).styleCode);
end

myfi=fi(streq({fi.familyName},'ClearviewText'));
for i=1:length(myfi)
    fprintf('%s, %d, %d\n',myfi(i).name,myfi(i).number,myfi(i).styleCode);
end
myfi=fi(streq({fi.name},'ClearviewText Book'));
for i=1:length(myfi)
    fprintf('%s, %d, %d\n',myfi(i).name,myfi(i).number,myfi(i).styleCode);
end

fi=FontInfo('Fonts');
hit=streq({fi.name},'Gotham Cond SSm Medium');
myfi=fi(hit);
% Screen('TextFont',w,myfi.number);


w=Screen('OpenWindow',0,0,[0 0 400 200]);
% Screen('TextFont',w,'Sloan');
Screen('TextFont',w,fi(streq({fi.name},'Sloan')).number);
Screen('TextFont',w)
Screen('TextFont',w,fi(streq({fi.name},'ClearviewText')).number);
Screen('TextFont',w)
Screen('TextFont',w,fi(streq({fi.name},'ClearviewText')).number);
Screen('TextFont',w,'Retina Micro');
Screen('TextFont',w)
fi=FontInfo('Fonts');
Screen('TextFont',w,fi(streq({fi.name},'Gotham Cond SSm Medium')).number);
Screen('TextFont',w)
Screen('TextFont',w,'Sloan');
Screen('TextFont',w,'Gotham Cond SSm','Medium');
Screen('TextFont',w)
Screen('TextFont',w,'Sloan');
% Screen('TextFont',w,'Gotham Cond SSm',33); % bold
% Screen('TextFont',w)
% Screen('TextFont',w,'Gotham Cond SSm',);
% Screen('TextFont',w)
sca
