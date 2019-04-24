function inside = IsRectInRect(smallRect,bigRect)
% inside = IsRectInRect(smallRect,bigRect)
%
% Is smallRect inside bigRect?
%
% Also see PsychRects.

% July 9, 2015  dgp  Wrote it.

inside=IsInRect(smallRect(1),smallRect(2),bigRect) && IsInRect(smallRect(3),smallRect(4),bigRect);
