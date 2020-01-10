function [bounds,ok]=TextBounds(window,text,yPositionIsBaseline,centerTheText)
% [bounds,ok]=TextBounds(window,string [,yPositionIsBaseline=0][,centerTheText=0])
%
% Returns "bounds", the smallest enclosing rect for the drawn text,
% relative to the current location. This bound is based on the actual
% pixels drawn, so it incorporates effects of text smoothing, etc. "text"
% may be a cell array or matrix of one or more strings. The strings are
% drawn one on top of another, at the same initial position, before the
% bounds are calculated. This returns the smallest box that will contain
% all the strings. The prior contents of the scratch window are lost.
% Usually it should be an offscreen window, so the user won't see it. The
% scratch window should be at least twice as wide and high as the text, to
% cope with uncertainties about text direction (e.g. Hebrew) and some
% unusual characters that extend greatly to the left of their nominal
% starting point. The second output argument "ok" is true if the text was
% not clipped by the window. (The test assumes the pixels in the character
% are connected. A far flung component, such as an accent, might be clipped
% and not detected.)
%
% If you only know your nominal text size and number of characters, you
% might do this to create your scratch window:
%
% Get the bounding box.
% textSize=48;
% string='Good morning.';
% yPositionIsBaseline=1; % 0 or 1
% window=Screen('OpenWindow',0,255);
% woff=Screen('OpenOffscreenWindow',window,[],[0 0 2*textSize*length(string) 2*textSize]);
% Screen(woff,'TextFont','Arial');
% Screen(woff,'TextSize',textSize);
% t=GetSecs;
% bounds=TextBounds(woff,string,yPositionIsBaseline)
% fprintf('TextBounds took %.3f seconds.\n',GetSecs-t);
% Screen('Close',woff);
%
% Show that it's correct by using the bounding box to frame the text.
% x0=100;
% y0=100;
% Screen(window,'TextFont','Arial');
% Screen(window,'TextSize',textSize);
% Screen('DrawText',window,string,x0,y0,0,255,yPositionIsBaseline);
% Screen('FrameRect',window,0,InsetRect(OffsetRect(bounds,x0,y0),-1,-1));
% Screen('Flip',window);
% Speak('Click to quit');
% GetClicks;
% Screen('Close',window);
%
% The suggested window size in that call is generously large because there
% aren't any guarantees from the font makers about how big the text might
% be for a specified point size. Set your window's font, size, and
% (perhaps) style before calling TextBounds.
%
% Be warned that TextBounds and TextCenteredBounds are slow (taking many
% seconds) if the window is large. They use the whole window, so if the
% window is 1024x1024 they process a million pixels. The slow speed is due
% to Screen 'GetImage'. Its processing time is proportional to the number
% of pixels in the window. On my 2017 MacBook, Screen 'GetImage' of a
% 6000x6000 window takes 0.7 s. So getting bounds of 10 letters takes 7 s,
% which makes observers very impatient. So keep your window small.
%
% Also see Screen 'TextBounds'.
% Also see TextCenteredBounds.

% 9/1/98   dgp wrote it.
% 3/19/00  dgp debugged it.
% 11/17/02 dgp Added fix, image1(:,:,1), suggested by Keith Schneider to
%              support 16 and 32 bit images.
% 9/16/04  dgp Suggest a pixelSize of 1.
% 12/16/04 dgp Fixed handling of cell array.
% 12/17/04 dgp Round x0 so bounds will always be integer. Add comment about
%              speed.
% 1/18/05  dgp Added Charles Collin's two e suggestion for textHeight.
% 1/28/05  dgp Cosmetic.
% 2/4/05   dgp Support both OSX and OS9.
% 12/22/07 mk  Significant rewrite to adapt to current PTB-3.
% 12/16/15 dgp Added yPositionIsBaseline argument.
% 01/10/16 mk  Switch GetImage buffer from backBuffer to drawBuffer for
%              compatibility with use of onscreen window as scratch window
%              with imaging pipeline active.
% 01/6/17  dgp Added fourth argument to implement the tiny change needed
%              for TextCenteredBounds. This makes TextCenteredBounds a
%              trivial wrapper that automatically tracks improvements made
%              to TextBounds.
% 10/10/18 dgp For unicode support, we now pass the string to DrawText as a
%              double.
% 8/7/19   dgp Detect clipping of bounds by window, issue warning, and
%              return second argument "ok". Updated comments about speed.
% 12/20/19 dgp Roughly center letter in the window, to minimize chance of
%              exceeding window bounds.
% 1/7/20   dgp if yPositionIsBaseline: In horizontal centering, don't 
%              assume it's a single character. Use length(text).
% 1/9/20   dgp if yPositionIsBaseline: Polish the vertical centering.

if nargin<2 || isempty(text)
    error(['Require at least 2 arguments. bounds=TextBounds(window, '...
        'string [, yPositionIsBaseline][, centerTheText])']);
end
if nargin<3 || isempty(yPositionIsBaseline)
    yPositionIsBaseline = false;
end
if nargin<4
    centerTheText=false;
end
white = 1;

% Clear scratch window to background color black:
Screen('FillRect',window,0);

if yPositionIsBaseline
    % Draw text string with vertical origin at letter baseline and
    % horizontal origin at nominal letter beginning. Allow a wide margin
    % from lower left corner of screen. The left and lower margins
    % accommodate the many fonts with descenders, and the occasional fonts
    % that have fancy capital letters with flourishes that extend to the
    % left of the starting point.
    % We set originXY (from lefth and bottom of window) to roughly center
    % the text in the window, hoping to minimize the chance that the text
    % will exceed the window bounds. To pass our test below, we must end up
    % with a margin of at least 2 pixels on all four sides between the text
    % and the window.
    screenRect=Screen('Rect',window);
    sizeXY=[length(text) 1]*Screen('TextSize',window); % Rough size.
    originXY=([RectWidth(screenRect) RectHeight(screenRect)] - sizeXY)/2;
    originXY=max(originXY,[2 2]);
    originXY=originXY+[0 sizeXY(2)/3]; % Estimate of descender height.
    originXY=ceil(originXY);
    x0=screenRect(1)+originXY(1); % From left edge.
    y0=screenRect(4)-originXY(2); % From bottom edge.
else
    % Draw text string with origin near upper left corner of bounding box.
    % To avoid clipping by the window, we here introduce a 2-pixel clear
    % margin to enable our test below for clipping of the bounds by the
    % window.
    x0=2;
    y0=2;
end
if centerTheText
    x0=(screenRect(1)+screenRect(3))/2;
end
% We've only got one scratch window, so we compute the widths for centering
% in advance, so as not to mess up the accumulation of letters for the
% bounds.
dx=zeros(1,length(text));
if centerTheText
    if iscell(text)
        for i=1:length(text)
            string=char(text(i));
            bounds=Screen('TextBounds',window,double(string));
            width=bounds(3);
            dx(i)=-width/2;
        end
    else
        for i=1:size(text,1)
            string=char(text(i,:));
            bounds=Screen('TextBounds',window,double(string));
            width=bounds(3);
            dx(i)=-width/2;
        end
    end
end

if iscell(text)
    for i=1:length(text)
        string=char(text(i));
        % Unicode support requires that we pass the string as a double.
        Screen('DrawText',window,double(string),...
            x0+dx(i),y0,white,[],yPositionIsBaseline);
    end
else
    for i=1:size(text,1)
        string=char(text(i,:));
        % Unicode support requires that we pass the string as a double.
        Screen('DrawText',window,double(string),...
            x0+dx(i),y0,white,[],yPositionIsBaseline);
    end
end

% For a typical window size, more than 90% of the time in TextBounds is
% spent doing this trivial copy from the screen buffer to a MATLAB array.
% Read back only 1 color channel for efficiency reasons:
image1=Screen('GetImage', window, [], 'drawBuffer', 0, 1);

% if unique(image1)==0
%     error('The image of letter ''%s'' is blank.',string);
% end

% Find all nonzero, i.e. non background, pixels:
[y,x]=find(image1(:,:));
r=RectOfMatrix(image1);

% Use coordinates relative to the origin of the DrawText command.
y=y-y0;
x=x-x0;
r=OffsetRect(r,-x0,-y0);

% Compute the bounding rect and return it:
if isempty(y) || isempty(x)
    bounds=[0 0 0 0];
    ok=false;
else
    bounds=SetRect(min(x)-1,min(y)-1,max(x),max(y));
    % Are the bounds at least 2 pixels within the window rect on every
    % side?
    r=InsetRect(r,2,2);
    ok=IsRectInRect(bounds,r);
    if ~ok
        wRect=Screen('Rect',window);
        boundsAbs=OffsetRect(bounds,x0,y0);
        warning(['bounds [%.0f %.0f %.0f %.0f], '...
            '([%.0f %.0f %.0f %.0f] in window), '...
            'were clipped by window %.0f x %.0f. '...
            'Make text smaller or window bigger.'],...
            bounds(1),bounds(2),bounds(3),bounds(4),...
            boundsAbs(1),boundsAbs(2),boundsAbs(3),boundsAbs(4),...
            RectWidth(wRect),RectHeight(wRect));
    end
end

return

function inside = IsRectInRect(smallRect,bigRect)
% inside = IsRectInRect(smallRect,bigRect)
%
% Is smallRect inside bigRect?
%
% Also see PsychRects.

% July 9, 2015  dgp  Wrote it.

inside=IsInRect(smallRect(1),smallRect(2),bigRect) && IsInRect(smallRect(3),smallRect(4),bigRect);
