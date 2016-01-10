sca
textSize=900;
string='S';
font='Verdana';
black=0;
white=255;
screen=0;
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseRetinaResolution');
[window,r]=PsychImaging('OpenWindow',screen,white,[0 0 256 256]);
[scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],4*[0 0 textSize textSize],8,0);
Screen('TextSize',scratchWindow,textSize);
Screen('TextFont',scratchWindow,font);
bounds=TextBounds(scratchWindow,string);
b=Screen('TextBounds',scratchWindow,string);
fprintf('%s "%c" textSize %d, TextBounds [%d %d %d %d] width x height %d x %d, Screen:TextBounds %.0f x %.0f\n', ...
   font,string,textSize,bounds,RectWidth(bounds),RectHeight(bounds),RectWidth(b),RectHeight(b));
sca