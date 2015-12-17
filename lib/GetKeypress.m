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
  deviceIndex=-3; % All keyboards and keypads.
end
if nargin<3
  % simulate the bahavior of GetChar() -- only return the character response
  % discarding the second character when two are captured
  simulateGetChar = 1;
end
KbName('UnifyKeyNames'); % make sure this is set

while KbCheck; end
response=0;
% use modern Kb* functions
[secs, keyCode] = KbStrokeWait(deviceIndex); % we only need keyCode
response = KbName(keyCode);
if isDebug;fprintf('You pressed ==>%s<==\n', response);end

if simulateGetChar %KbStrokeWait/KbWait ignores shift
  % KbName returns 2 characters, e.g. '0)', when you press a number
  % key on the main keyboard. So when KbName returns two characters,
  % we return the first and discard the second.  Thus we do not
  % distinguish between a number key on a number pad and a number key
  % on the main keyboard.
  if length(response)==2
    response=response(1);
  end
  if streq(response,'space'); response=' '; end
  if ismember(response, {'period', '.>', '.'}); response = '.'; end
  if isDebug;fprintf('We recorded ==>%s<==\n', response);end


else
  % return all that is captured

  if isDebug;fprintf('We recorded ==>%s<==\n', response);end
end

if 0
  %[keyIsDown, secs, keyCode] = KbCheck(); % we only need keyIsDown and keyCode
  if keyIsDown
    % several keys pressed at once is ignored here for simplicity!
    whichKey = find(keyCode,1);
    if ~isempty(whichKey)
      response = KbName(find(keyCode,1));
    end
  end
  while KbCheck;end
end



if nargin >= 2
  RestrictKeysForKbCheck(oldEnableKeys);
end
end
