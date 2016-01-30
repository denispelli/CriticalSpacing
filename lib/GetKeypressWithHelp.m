function answer=GetKeypressWithHelp(enableKeys,o,window,stimulusRect,letterStruct,responseString)
%GetKeypressWIthHelp
%   Used by CriticalSpacing to get a key stroke. Pressing shift shows
%   alphabet.
global savedAlphabet; % Won't be needed if the disk-reading code is moved into MakeLetterTextures.

if nargin<6
   responseString='';
end
makeTextures=nargin<5;

shiftKeys=[KbName('LeftShift') KbName('RightShift') KbName('CapsLock')];

oldEnableKeys=RestrictKeysForKbCheck([shiftKeys enableKeys]);
while(1)
   %             answer=GetKeypress([spaceKey escapeKey o.responseKeys],o.deviceIndex,0);
   [~,keyCode] = KbPressWait(o.deviceIndex);
   answer = KbName(keyCode);
   if ismember(answer,{'RightShift','LeftShift','CapsLock'});
      if ismember(answer,{'CapsLock'});
         KbReleaseWait(o.deviceIndex);
      end
      % Save screen
      saveScreen=Screen('GetImage',window);
      if makeTextures
         letterStruct=MakeLetterTextures(nan,o,window,savedAlphabet);
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
         saveEnableKeys=RestrictKeysForKbCheck(KbName('CapsLock'));
         KbStrokeWait(o.deviceIndex);
         RestrictKeysForKbCheck(saveEnableKeys);
      else
         KbReleaseWait(o.deviceIndex);
      end
      if makeTextures
         % Discard the letter textures, to free graphics memory.
         for i=1:length(letterStruct)
            Screen('Close',letterStruct(i).texture);
         end
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
RestrictKeysForKbCheck(oldEnableKeys);
end

