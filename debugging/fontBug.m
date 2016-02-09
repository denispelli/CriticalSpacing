% My program crashed on a student Mac when textFont was not available on
% her Mac OS. This is my attempt to replicate the problem, but this
% programs runs ok.
window=Screen('OpenWindow',0,255,[0 0 400 100]);
bounds=TextBounds(window,'Hello')
targetFont='xyz';
Screen('TextFont',window,targetFont);
font=Screen('TextFont',window);
if ~streq(font,targetFont)
   warning('The targetFont "%s" is not available. Using "%s".',targetFont,font);
end
bounds=TextBounds(window,'Hello')
Screen('Close',window);

