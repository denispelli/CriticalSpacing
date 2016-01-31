function answer=GetKeypressWithHelp(enableKeyCodes,o,window,stimulusRect,letterStruct,responseString)
%GetKeypressWIthHelp
%   Used by CriticalSpacing to get a key stroke. Pressing shift shows
%   alphabet.

if nargin<6
   responseString='';
end
makeTextures=nargin<5;

shiftKeyCodes=[KbName('LeftShift') KbName('RightShift') KbName('CapsLock')];

oldEnableKeyCodes=RestrictKeysForKbCheck([shiftKeyCodes enableKeyCodes]);
while(1)
   %             answer=GetKeypress([spaceKey escapeKey o.responseKeyCodes],o.deviceIndex,0);
   [~,keyCode] = KbPressWait(o.deviceIndex);
   answer = KbName(keyCode);
   if ismember(answer,{'RightShift','LeftShift','CapsLock'});
      if ismember(answer,{'CapsLock'});
         KbReleaseWait(o.deviceIndex);
      end
      % Save screen
      saveScreen=Screen('GetImage',window);
      if makeTextures
         letterStruct=CreateLetterTextures(nan,o,window);
      end
      % Display alphabet
      Screen('PutImage',window,saveScreen); % To save progress bar.
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
      
      % Wait for release of shift
      if ismember(answer,{'CapsLock'});
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
      Screen('PutImage',window,saveScreen);
      Screen('Flip',window);
   else
      % Ignore any key that has already been pressed.
      if ~ismember(answer,responseString);
         break;
      end
   end
end
RestrictKeysForKbCheck(oldEnableKeyCodes);
end

