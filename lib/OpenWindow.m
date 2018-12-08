function [window,r]=OpenWindow(o)
% Moved this into a subroutine so that we can reuse the same code when we
% close and reopen the window to flip the screen horizontally, when we use
% a mirror.
white=255;
% Detect HiDPI mode, e.g. on a Retina display.
screenBufferRect=Screen('Rect',o.screen);
screenRect=Screen('Rect',o.screen,1);
o.hiDPIMultiple=RectWidth(screenRect)/RectWidth(screenBufferRect);
if 1
   PsychImaging('PrepareConfiguration');
   if o.flipScreenHorizontally
      PsychImaging('AddTask','AllViews','FlipHorizontal');
   end
   if o.hiDPIMultiple~=1
      PsychImaging('AddTask','General','UseRetinaResolution');
   end
   % Mario says the virtual frame buffer makes the back buffer more
   % reliable, for better performance.
   PsychImaging('AddTask','General','UseVirtualFramebuffer');
   if ~o.useFractionOfScreenToDebug
      [window,r]=PsychImaging('OpenWindow',o.screen,white);
   else
      r=round(o.useFractionOfScreenToDebug*screenBufferRect);
      r=AlignRect(r,screenBufferRect,'right','bottom');
      [window,r]=PsychImaging('OpenWindow',o.screen,white,r);
   end
else
   [window,r]=Screen('OpenWindow',o.screen,white,screenBufferRect);
end
