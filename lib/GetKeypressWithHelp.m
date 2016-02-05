function answer=GetKeypressWithHelp(enableKeyCodes,o,window,stimulusRect,letterStruct,responseString)
%GetKeypressWIthHelp
%   Used by CriticalSpacing to get a key stroke. Pressing shift shows
%   the alphabet.

capsLockIsSticky=IsWindows;
useCopyWindow=0; % Works with 0 or 1 on Mac. Hoping 1 helps on Windows.
if nargin<6
   responseString='';
end
makeTextures=nargin<5;
shiftKeyCodes=[KbName('LeftShift') KbName('RightShift') KbName('CapsLock')];
oldEnableKeyCodes=RestrictKeysForKbCheck([shiftKeyCodes enableKeyCodes]);
while(1)
   [~,keyCode] = KbPressWait(o.deviceIndex);
   answer = KbName(keyCode);
   if ismember(answer,{'RightShift','LeftShift','CapsLock'});
      if ismember(answer,{'CapsLock'}) && ~capsLockIsSticky;
         KbReleaseWait(o.deviceIndex);
      end
      % Save screen
      if useCopyWindow
         % CopyWindow copies the backbuffer.
         [width,height]=RectSize(Screen('Rect',window));
         m=zeros([height,width]);
         savedTexture=Screen('MakeTexture',window,m);
         Screen('Flip',window,[],2);
         Screen('CopyWindow',window,savedTexture);
         Screen('Flip',window,[],2);
         Screen('DrawTexture',window,savedTexture);
      else
         saveScreen=Screen('GetImage',window);
         Screen('PutImage',window,saveScreen); % To keep progress bar.
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
      if useCopyWindow
         Screen('DrawTexture',window,savedTexture);
         Screen('Close',savedTexture);
      else
         Screen('PutImage',window,saveScreen);
      end
      Screen('Flip',window,[],1);
   else
      % Ignore any key that has already been pressed.
      if ~ismember(answer,responseString);
         break;
      end
   end
end
RestrictKeysForKbCheck(oldEnableKeyCodes);
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
Screen('Flip',window);
end