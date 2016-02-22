% Try to access the various styles of my Gotham font. Currently there is no
% way to request a style that is beyond a combination of italic and bold.
% New fonts have a wide range of styles and we need a text string to
% specify the style. We should suggest to Mario that Screen TextFont should
% allow the style argument to be a string instead of a number.
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
fi=FontInfo('Fonts');
hits=[streq({fi.familyName},'Gotham Cond SSm')];
myfi=fi(hits);
fprintf('Number Style  Name\n');
for i=1:length(myfi)
    fprintf('%4d, %4d,   %s\n',myfi(i).number,myfi(i).styleCode,myfi(i).name);
end

myfi=fi(streq({fi.familyName},'ClearviewText'));
for i=1:length(myfi)
    fprintf('%4d, %4d,   %s\n',myfi(i).number,myfi(i).styleCode,myfi(i).name);
end
myfi=fi(streq({fi.name},'ClearviewText Book'));
for i=1:length(myfi)
    fprintf('%4d, %4d,   %s\n',myfi(i).number,myfi(i).styleCode,myfi(i).name);
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
% Screen('TextFont',w,'Gotham Cond SSm','Medium');
Screen('TextFont',w)
Screen('TextFont',w,'Sloan');
% Screen('TextFont',w,'Gotham Cond SSm',33); % bold
% Screen('TextFont',w)
% Screen('TextFont',w,'Gotham Cond SSm',);
% Screen('TextFont',w)
sca
