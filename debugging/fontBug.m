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

