function [answer,secs]=GetKeypressWithHelp(enableKeyCodes,o,window,stimulusRect,letterStruct,responseString)
%[answer,secs]=GetKeypressWithHelp(enableKeyCodes,o,window,stimulusRect,letterStruct,responseString);
%   Used by CriticalSpacing to get a key stroke. Pressing shift shows
%   the alphabet.
%   We assume that, on entry, the back buffer is a copy of the front
%   buffer.
%   denis.pelli@nyu.edu 2016

capsLockIsSticky=IsWindows;
savingMethod='CopyWindow'; % Works on Mac, Windows, and Linux.
% savingMethod='GetImage'; % Works on Mac. Windows? Linux?
if nargin<6
   responseString='';
end
makeTextures=nargin<5;
shiftKeyCodes=[KbName('LeftShift') KbName('RightShift') KbName('CapsLock')];
oldEnableKeyCodes=RestrictKeysForKbCheck([shiftKeyCodes enableKeyCodes]);
reactionTimeIsValid=1;
while 1
   [secs,keyCode]=KbPressWait(o.deviceIndex);
   answer=KbName(keyCode);
   if ismember(answer,{'RightShift','LeftShift','CapsLock'});
      reactionTimeIsValid=0;
      if ismember(answer,{'CapsLock'}) && ~capsLockIsSticky;
         KbReleaseWait(o.deviceIndex);
      end
      % Save screen
      switch savingMethod
         case 'CopyWindow',
            % CopyWindow copies the backbuffer.
            [width,height]=RectSize(Screen('Rect',window));
            m=zeros([height,width]);
            savedTexture=Screen('MakeTexture',window,m); % Black texture
            Screen('CopyWindow',window,savedTexture);
         case 'GetImage',
            saveScreen=Screen('GetImage',window);
            if o.flipScreenHorizontally
               saveScreen=fliplr(saveScreen);
            end
      end
      if makeTextures
         letterStruct=CreateLetterTextures(nan,o,window);
      end
      ShowAlphabet(o,window,stimulusRect,letterStruct);
      % Wait for release of shift
      if ismember(answer,{'CapsLock'}) && ~capsLockIsSticky;
         saveEnableKeyCodes=RestrictKeysForKbCheck(KbName('CapsLock'));
         KbStrokeWait(o.deviceIndex);
         RestrictKeysForKbCheck(saveEnableKeyCodes);
      else
         KbReleaseWait(o.deviceIndex);
      end
      if makeTextures
         % Discard the letter textures, to free graphics memory.
         DestroyLetterTextures(letterStruct);
      end
      % Restore screen
      switch savingMethod
         case 'CopyWindow',
            Screen('DrawTexture',window,savedTexture);
            Screen('Close',savedTexture);
         case 'GetImage',
            Screen('PutImage',window,saveScreen);
      end
      Screen('Flip',window,[],1); % Restore from back buffer.
   else
      % Ignore any key that has already been pressed.
      if ~ismember(answer,responseString);
         break;
      end
   end
end
RestrictKeysForKbCheck(oldEnableKeyCodes);
if ~reactionTimeIsValid
   secs=nan;
end
end

function ShowAlphabet(o,window,stimulusRect,letterStruct)
% Display alphabet
Screen('FillRect',window,255,stimulusRect);
iLetter=1;
for jj=1:3
   for ii=1:ceil(length(o.alphabet)/3)
      r=[0 0 RectWidth(letterStruct(iLetter).rect) RectHeight(letterStruct(iLetter).rect)];
      r=r*RectHeight(stimulusRect)/(0.5+1.5*3)/RectHeight(r);
      r=OffsetRect(r,-0.5*RectWidth(r),-0.5*RectHeight(r));
      r=OffsetRect(r,(ii-0.5)*RectWidth(stimulusRect)/3,(jj-0.5)*RectHeight(stimulusRect)/3);
      Screen('DrawTexture',window,letterStruct(iLetter).texture,[],r);
      if iLetter==length(o.alphabet)
         break;
      end
      iLetter=iLetter+1;
   end
   if iLetter==length(o.alphabet)
      break;
   end
end
Screen('Flip',window,[],2); % Swap front and back buffers.
end