function [string,terminatorChar] = GetEchoString2(windowPtr, msg, x, y, textColor, bgColor, useKbCheck, varargin)
% [string,terminatorChar] = GetEchoString2(window,msg,x,y,[textColor],[bgColor],[useKbCheck=0],[deviceIndex],[untilTime=inf],[KbCheck args...]);
% 
% Get a string typed at the keyboard. Entry is terminated by <return> or
% <enter>.
%
% NOTE: This should be enhanced to assume or pass a flag to align text at
% baseline. I also specify that when I call DrawText, and it's annoying and
% inconsistent to lack it here.
%
% Typed characters are displayed in the window. The delete or backspace key
% is handled correctly, ie., it erases the last typed character. Useful for
% i/o in a Screen window.
%
% 'window' = Window to draw to. 'msg' = A message string displayed to
% prompt for input. 'x', 'y' = Start position of message prompt.
% 'textColor' = Color to use for drawing the text. 'bgColor' = Background
% color for text. By default, the background is transparent. If a non-empty
% 'bgColor' is specified it will be used. The current alpha blending
% setting will affect the appearance of the text if 'bgColor' is specified!
%
% If the optional flag 'useKbCheck' is set to 1 then KbCheck is used - with
% potential optional additional 'KbCheck args...' for getting the string
% from the keyboard. Otherwise GetChar is used. 'useKbCheck' == 1 is
% restricted to standard alpha-numeric keys (characters, letters and a few
% special symbols). It can't handle all possible characters and doesn't
% work with non-US keyboard mappings. Its advantage is that it works
% reliably on configurations where GetChar may fail, e.g., on MS-Vista and
% Windows-7.
%
% See also: GetNumber, GetString, GetEchoNumber
%

% 2/4/97    dhb       Wrote GetEchoNumber.
% 2/5/97    dhb       Accept <enter> as well as <cr>.
%           dhb       Allow string return as well.
% 3/3/97    dhb       Updated for new DrawText.  
% 3/15/97   dgp       Created GetEchoString2 based on dhb's GetEchoNumber.
% 3/20/97   dhb       Fixed bug in erase code, it wasn't updated for new
%                       initialization.
% 3/31/97   dhb       More fixes for same bug.
% 2/28/98   dgp       Use GetChar instead of obsolete GetKey. Use SWITCH and LENGTH.
% 3/27/98   dhb       Put an abs around char in switch.
% 12/26/08  yaosiang  Port GetEchoString2 from PTB-2 to PTB-3.
% 03/20/08  tsh       Added FlushEvents at the start and made bgColor and
%                     textcolor optional
% 10/22/10  mk        Optionally allow to use KbGetChar for keyboard input.
% 09/06/13  mk        Do not clear window during typing of characters, only
%                     erase relevant portions of the displayed text string.
% 02/10/16  mk        Adapt 'TextAlphaBlending' setup for cross-platform FTGL plugin.
% 02/15/16  dgp       Accept ESC for termination, return terminatorChar.
% 8/1/17    dgp       If no ESCAPE key, treat GraveAccent as terminator.
%                    The 2017 15" MacBook Pro has a touch bar, and no
%                    ESCAPE key. In that case we treat the Grave Accent
%                    key (in upper left of keyboard) as a terminator.

if nargin < 7
    useKbCheck = [];
end

if isempty(useKbCheck)
    useKbCheck = 0;
end

if nargin < 6
    bgColor = [];
end

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    if Screen('Preference', 'TextRenderer') >= 1
        oldalpha = Screen('Preference', 'TextAlphaBlending', 0);
    else
        oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux);
    end
end

if nargin < 5
    textColor = [];
end

if ~useKbCheck
    % Flush the keyboard buffer:
    FlushEvents;
end

string = '';
output = [msg, ' ', string];

% Write the initial message:
Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
Screen('Flip', windowPtr, 0, 1);

while true
    if useKbCheck
        char = GetKbChar(varargin{:});
    else
        char = GetChar;
    end

    if isempty(char)
        string = '';
        terminatorChar = 0;
        break;
    end

    graveAccentChar='`';
    macsWithTouchBars={'MacBookPro14,3'}; % 2017 MacBook Pro 15"; 
    if ismac && ismember(MacModelName,macsWithTouchBars)
       terminators={3, 10, 13, 27, graveAccentChar};
    else
       terminators={3, 10, 13, 27};
    end
    switch abs(char)
        case terminators
            % ctrl-C, enter, return, or escape. 
            % Or graveAccent on Macs with no escape key.
            terminatorChar = abs(char);
            break;
        case 8
            % backspace
            if ~isempty(string)
                % Redraw text string, but with textColor == bgColor, so
                % that the old string gets completely erased:
                oldTextColor = Screen('TextColor', windowPtr);
                Screen('DrawText', windowPtr, output, x, y, bgColor, bgColor);
                Screen('TextColor', windowPtr, oldTextColor);

                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise
            string = [string, char]; %#ok<AGROW>
    end
    output = [msg, ' ', string];
    Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
    Screen('Flip', windowPtr, 0, 1);
end

% Restore text alpha blending state if it was altered:
if ~isempty(bgColor)
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end

return;
