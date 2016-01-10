function [window,r]=OpenWindow(o)
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
white=255;
% Detect HiDPI mode, e.g. on a Retina display.
o.hiDPIMultiple=RectWidth(screenRect)/RectWidth(screenBufferRect);
if 1
   PsychImaging('PrepareConfiguration');
   if o.flipScreenHorizontally
      PsychImaging('AddTask','AllViews','FlipHorizontal');
   end
   if o.hiDPIMultiple~=1
      PsychImaging('AddTask','General','UseRetinaResolution');
   end
   if ~o.useFractionOfScreen
      [window,r]=PsychImaging('OpenWindow',o.screen,white);
   else
      [window,r]=PsychImaging('OpenWindow',o.screen,white,round(o.useFractionOfScreen*screenBufferRect));
   end
else
   [window,r]=Screen('OpenWindow',0,white,screenBufferRect);
end
