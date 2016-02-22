% Test reliability of Screen GetImage.
% Until December 2016 this was unreliable. Then Mario tracked down the bug
% I reported, and seems to have fixed it. So this program no longer
% reveals any problem.
sca
clear all
addpath(fullfile(fileparts(mfilename('fullpath')),'..','lib'));
black=0;
white=255;
letterPix=256;
try
   Screen('Preference', 'SkipSyncTests', 1);
   % Screen('preference','ConserveVRAM',2); % 64?
   [window,windowRect]=Screen('OpenWindow',0,255,[0 0 letterPix letterPix]);
   [scratchWindow,scratchRect]=Screen('OpenOffscreenWindow',window,[],[0 0 letterPix letterPix]);
   Screen('TextFont',window,'Arial');
   Screen('TextSize',scratchWindow,letterPix);
   letter='A';
   %    bounds=TextBounds(scratchWindow,letter,1);
   bounds=[4 -192 182 0];
   Screen('FillRect',scratchWindow,white);
   Screen('DrawText',scratchWindow,letter,-bounds(1),-bounds(2),black,white,1);
   %    WaitSecs(0.2);
   %    Screen('DrawingFinished',scratchWindow); % Might make GetImage more reliable. Suggested by Mario Kleiner.
   original=Screen('GetImage',scratchWindow,OffsetRect(bounds,-bounds(1),-bounds(2)),'drawBuffer');
   figure;
   subplot(1,2,1);
   imshow(original);
   title('1');
   ok=1;
   for i=1:10000
      letterImage=Screen('GetImage',scratchWindow,OffsetRect(bounds,-bounds(1),-bounds(2)),'drawBuffer');
      if ~all(letterImage==original)
         ok=0;
         break;
      end
   end
   subplot(1,2,2);
   imshow(letterImage);
   if ok
      title(sprintf('%d all equal.',i));
   else
      title(sprintf('%d not equal.',i));
   end
   sca
catch
   sca
end

