function response = GetKeypress(enableKeys,deviceIndex,returnOneChar)
% response = GetKeypress(enableKeys,deviceIndex,returnOneChar); 
% Wait for a keypress, and return it. If returnOneChar is true (default)
% then "response" is just one character, if possible. (Some keynames, like
% 'left_shift', have no obviously associated character and are passed
% through.) This does not distinguish between pressing a number key on the
% main or separate numeric keyboard. If returnOneChar is false, then the
% full descriptive output of KbName is returned, unmodified, e.g. 'a',
% '1!', 'ESCAPE', or 'left_shift'.
%
% Note that the 2017 MacBook Pro with the track bar has no escape key. My
% workaround, in my programs using GetKeyPress, is to accept as equivalent
% a press of the normally nearby grave accent '`' key.
%
% First version written by Hormet Yiltiz, October 2015, as "checkResponse".
% Renamed "GetKeypress" by Denis Pelli, November 2015, and enhanced.

printLog = 0;
if nargin >= 1
   % enableKeys should be cell strings.
   restrictKeys=1;
   oldEnableKeys=RestrictKeysForKbCheck(enableKeys);
   if printLog; disp('Enabled keys list is:'); disp(enableKeys); end
else
   restrictKeys=0;
end
if nargin<2
   % Accept input from all keyboards and keypads.
   deviceIndex=-3;
end
if nargin<3
   % By default, simulate the behavior of GetChar(), i.e. return an ASCII
   % code corresponding to the key pressed. That's tricky. Each key is in
   % principle associated with a different ASCII code when shifted, but we
   % ignore the shift. Also some ASCII codes (e.g. '1') are associated with
   % multiple keys (on main keyboard and numeric keypad). And some keys
   % (e.g. shift) have no ASCII code. We convert some long character names,
   % e.g. 'escape', back to the single ASCII code. When KbName returns two
   % characters, e.g. for the '1!' key, Return only the initial character,
   % discarding the second,
   returnOneChar = 1;
end
KbName('UnifyKeyNames');
while KbCheck; end
[~,keyCode] = KbStrokeWait(deviceIndex);
response = KbName(keyCode);
if printLog;fprintf('You pressed "%s", ',response);end
if returnOneChar
   response=lower(response);
   if streq(response,'space'); response=' '; end
   if streq(response,'escape'); response=char(27); end
   if streq(response,'return'); response=char(13); end
   % We assume that only one key is pressed (no shift, caps lock, etc.).
   % For keys in the upper row of the keyboard, including the number keys,
   % KbName returns 2 characters, e.g. '0)'. When KbName returns two
   % characters, we return the first and discard the second. Thus we do not
   % distinguish between a number key on a number pad and a number key on
   % the main keyboard.
   if length(response)==2
      response=response(1);
   end
else
   % Pass through the unmodified output from KbName.
end
if printLog;fprintf('and we returned "%s".\n', response); end
if restrictKeys
   RestrictKeysForKbCheck(oldEnableKeys);
end
end
