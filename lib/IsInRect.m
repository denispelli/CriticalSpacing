function inside = IsInRect(x,y,rect)
% inside = IsInRect(x,y,rect)
%
% Is location x,y inside the rect?
%
% Also see PsychRects.

% 3/5/97  dhb  Wrote it.
% 3/13/16 dgp Make returned value logical.

if (x >= rect(RectLeft) && x <= rect(RectRight) && ...
		y >= rect(RectTop) && y <= rect(RectBottom) )
	inside = logical(1);
else
	inside = logical(0);
end
