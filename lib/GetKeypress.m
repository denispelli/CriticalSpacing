function response = GetKeypress(enableKeys, deviceIndex, simulateGetChar)
% Wait for keypress, and return the lowercase character, e.g. 'a' or '4',
% or key name, e.g. 'left_shift'. We do not distinguish between pressing a
% number key on the main or separate numeric keyboard; we just return the
% one-digit number as a character. simulateGetChar ensures this behavoir.
% If simulateGetChar is set to false, then full key codes are returned
% instead, e.g. 'a' or '4$'.
%
% Originally called "checkResponse" written by Hormet Yiltiz, October 2015.
% Renamed "GetKeypress" by Denis Pelli, November 2015.

isDebug = 0;
if nargin >= 1
   % make sure enableKeys are cell strings
   oldEnableKeys=RestrictKeysForKbCheck(enableKeys);
   if isDebug; disp('Enabled keys list is:');disp(enableKeys);end
end
if nargin<2
   % Accept input from all keyboards and keypads.
   deviceIndex=-3;
end
if nargin<3
   % Simulate the behavior of GetChar(): Return only the initial character,
   % discarding the second, when two are captured.
   simulateGetChar = 1;
end
KbName('UnifyKeyNames'); % make sure this is set
while KbCheck; end
response=0;
% use modern Kb* functions
[~,keyCode] = KbStrokeWait(deviceIndex);
response = KbName(keyCode);
if isDebug;fprintf('You pressed ?%s?.\n',response);end
if simulateGetChar %KbStrokeWait/KbWait ignores shift
   % KbName returns 2 characters, e.g. '0)', when you press a number key on
   % the main keyboard. So when KbName returns two characters, we return
   % the first and discard the second.  Thus we do not distinguish between
   % a number key on a number pad and a number key on the main keyboard.
   if length(response)==2
      response=response(1);
   end
   if streq(response,'space'); response=' '; end
   if ismember(response, {'period', '.>', '.'}); response = '.'; end
   if isDebug;fprintf('We recorded ?%s?.\n', response);end
else
   % return all that is captured
   if isDebug;fprintf('We recorded ?%s?.\n', response);end
end
if nargin >= 1
   RestrictKeysForKbCheck(oldEnableKeys);
end
end
