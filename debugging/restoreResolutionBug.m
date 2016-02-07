diary on
% Are we using the screen at its maximum native resolution?
Screen('Preference', 'SkipSyncTests', 1);
white=255;
permissionToChangeResolution=1;
myScreen=max(Screen('Screens'));
screenBufferRect=Screen('Rect',myScreen);
res = Screen('Resolutions',myScreen);
nativeWidth=0;
nativeHeight=0;
for i=1:length(res)
   if res(i).width>nativeWidth
      nativeWidth=res(i).width;
      nativeHeight=res(i).height;
   end
end
actualScreenRect=Screen('Rect',myScreen,1);
if nativeWidth==RectWidth(actualScreenRect)
   fprintf('Your screen resolution is at its native maximum %d x %d. Excellent!\n',nativeWidth,nativeHeight);
else
   warning backtrace off
   if permissionToChangeResolution
      warning('Trying to change your screen resolution to be optimal for this test. ...');
      oldResolution=Screen('Resolution',myScreen,nativeWidth,nativeHeight);
      res=Screen('Resolution',myScreen);
      if res.width==nativeWidth
         fprintf('SUCCESS!\n');
      else
         warning('FAILED.');
         res
      end
      actualScreenRect=Screen('Rect',myScreen,1);
   end
   if nativeWidth==RectWidth(actualScreenRect)
      fprintf('Your screen resolution is at its native maximum %d x %d. Excellent!\n',nativeWidth,nativeHeight);
   else
      if RectWidth(actualScreenRect)<nativeWidth
         fprintf('WARNING: Your screen resolution %d x %d is less that its native maximum %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
         warning('Your screen resolution %d x %d is less that its native maximum %d x %d. This will increase your minimum viewing distance %.1f-fold.',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight,nativeWidth/RectWidth(actualScreenRect));
      else
         fprintf('WARNING: Your screen resolution %d x %d exceeds its maximum native resolution %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
         warning('Your screen resolution %d x %d exceeds its maximum native resolution %d x %d. This may be a problem.',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
      end
      fprintf('(You can use System Preferences:Displays to change resolution.)\n');
      fprintf('(Set your screen to maximum native resolution, or, if you have a Retina/HiDPI screen, then set it to half maximum native.)\n');
      warning backtrace on
   end
end
resolution=Screen('Resolution',myScreen);
[window,r]=Screen('OpenWindow',myScreen);

Screen('CloseAll');
sca;
diary off;
