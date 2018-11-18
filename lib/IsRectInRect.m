function inside = IsRectInRect(rect1,rect2)
% inside = IsRectInRect(rect1,rect2)
%
% Is the first rect inside the second?
%
% Also see PsychRects.

% 1/9/16  dgp  Wrote it.

inside=IsInRect(rect1(1),rect1(2),rect2) && IsInRect(rect1(3),rect1(4),rect2);

