function [textSize,textLineLength,font]=TextSizeToFit(window,font,lineOfText)
% [textSize,textLineLength]=TextSizeToFit(window,font,lineOfText);
% Set textSize so our lineOfText just fits in window width. You can specify
% a margin by adding extra 'z' or 'Z' characters (e.g. 'ZZZZ') at the
% beginning and end of the lineOfText. Currently, after using TextSizeToFit
% to set textSize, I always use an (x,y) starting point for
% DrawFormattedText of (2*textSize,2.5*textSize), using the default
% baseline alignment. Thus the left margin (about 4 character widths)
% equals the top margin, which is measured from screen top to top of the x
% height. The returned value of textLineLength is the length of the
% lineOfText, ignoring any 'z' and 'Z' margin characters.
if nargin<1
    error('You must provide "window" when calling textSize=TextSizeToFit(window,lineOfText,o).');
end
% This works even if the window is small during debugging.
screenRect=Screen('Rect',window);
if nargin<2 || isempty(font)
    font='Verdana';
end
if nargin<3 || isempty(lineOfText)
    lineOfText='ZZZPlease slowly type the name of the Experimenter who is sup.ZZZ';
end
textSize=round(RectWidth(screenRect)/100);
Screen('TextSize',window,textSize);
Screen('TextFont',window,font,0);
actualFont=Screen('TextFont',window);
if ~streq(actualFont,font)
    warning off backtrace
    warning('The font "%s" is not available. Using %s instead.',font,actualFont);
    warning on backtrace
    font=actualFont;
end
boundsRect=Screen('TextBounds',window,lineOfText);
fraction=RectWidth(boundsRect)/RectWidth(screenRect);
% Adjust textSize so the line fits perfectly across the screen width.
textSize=floor(textSize/fraction);
Screen('TextSize',window,textSize);
lineOfText=strrep(lineOfText,'z',''); % Remove the margin.
lineOfText=strrep(lineOfText,'Z',''); % Remove the margin.
textLineLength=round(length(lineOfText));
end
