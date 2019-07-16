function wrappedString=WrapString(string,maxLineLength)
% wrappedString=WrapString(string,[maxLineLength])
%
% Wraps text by changing spaces into linebreaks '\n', making each line as
% long as possible without exceeding maxLineLength (default 74
% characters). WrapString does not break words, even if you have a word
% that exceeds maxLineLength. The returned "wrappedString" is identical to
% the supplied "string" except for the conversion of some spaces into
% linebreaks. Besides making the text look pretty, wrapping the text will
% make the printout narrow enough that it can be sent by email and
% received as sent, not made hard to read by mindless breaking of every
% line.
%
% Note that this schemes is based on counting characters, not pixels, so
% it will give a fairly even right margin only for monospaced fonts, not
% proportionally spaced fonts. The more general solution would be based on
% counting pixels, not characters, using either Screen 'TextWidth' or
% TextBounds.
%
% Special case: When the above algorithm would break a line before a space,
% we instead keep the (invisible) space in the old line, even though it's
% past the margin. This avoids beginning the new line with a space. The
% margin overrun is harmless because spaces are invisible.

% 6/30/02 dgp Wrote it.
% 10/2/02 dgp Make it clear that maxLineLength is in characters, not pixels.
% 09/20/09 mk Improve argument handling as per suggestion of Peter April.
% 10/31/14 mk Fix Octave-4 warning, white-space/indentation cleanup.
% 7/16/19 dgp Wrapping will now never begin new line with a space.
% 7/16/19 dgp Use built-in MATLAB symbol "newline" for char(10).

if nargin>2 || nargout>1
    error('Usage: wrappedString=WrapString(string,[maxLineLength])\n');
end
if nargin<2
    maxLineLength=[];
end
if isempty(maxLineLength) || isnan(maxLineLength)
    maxLineLength=74;
end
% In MATLAB 2018a, inexplicably, even though "newline" is present as a
% built-in function, I am unable to call it from this routine. So I define
% it myself. This must be a bug in MATLAB.
newline=char(10); % Introduced in MATLAB 2016b.
wrapped='';
while length(string)>maxLineLength
    l=strfind(char(string),newline);
    l=min([l length(string)+1]);
    if l<maxLineLength
        % line is already short enough
        [wrapped,string]=onewrap(wrapped,string,l);
    else
        s=strfind(char(string),' ');
        n=find(s<maxLineLength);
        if ~isempty(n)
            % ignore spaces before the furthest one before maxLineLength
            s=s(max(n):end);
        end
        % break at nearest space, linebreak, or end.
        s=sort([s l]);
        [wrapped,string]=onewrap(wrapped,string,s(1));
    end
end
wrappedString=[wrapped string];
return

function [wrapped,string]=onewrap(wrapped,string,n)
if n>length(string)
    wrapped=[wrapped string];
    string='';
    return
end
while n<length(string) && string(n+1)==' '
    % Wrapping should not produce a new line that begins with a space, so
    % we have the old line retain any spaces that would end up at the
    % beginning of the new line.
    n=n+1;
end
wrapped=[wrapped string(1:n-1) newline];
string=string(n+1:end);
return
