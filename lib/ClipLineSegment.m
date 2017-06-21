function [xClipped,yClipped]=ClipLineSegment(x,y,r)
%[x,y]=ClipLineSegment(x,y,r);
% Clips one (or more) line segment(s) by a rect, and returns (for each line
% received) a new line segment of non-zero length or nothing. x and y may
% contain many lines on input and output. The first line segment is
% (x(1),y(1)) to (x(2),y(2)). The second line segment is (x(3),y(3)) to
% (x(4),y(4)). And so on. Direction (e.g. from point 1 to point 2) is
% preserved. Returns NANs if you provide an ambiguous line segment.
% 2016 denis.pelli@nyu.edu
assert(length(x)>=2 && length(x)/2==round(length(x)/2));
assert(length(y)==length(x));
assert(length(r)==4);
% If request is for more than one line, recursively call ourselves for each
% line, collect the results, and return.
if length(x)>2
   xClipped=[];
   yClipped=[];
   for i=1:2:length(x)-1
      [xTemp,yTemp]=ClipLineSegment(x(i:i+1),y(i:i+1),r);
      xClipped=[xClipped xTemp];
      yClipped=[yClipped yTemp];
   end
   return
end
% Discard zero-length line.
if diff(x)^2+diff(y)^2==0
   xClipped=[];
   yClipped=[];
   return;
end
% Make sure the two points define a line.
if (any(~isfinite(x)) && y(1)~=y(2)) || (any(~isfinite(y)) && x(1)~=x(2))
   xClipped=[nan nan];
   yClipped=[nan nan];
   return
end
xy1=[x(1) y(1)];
xy2=[x(2) y(2)];
[xy1,xy2]=ClipLineSegment2(xy1,xy2,r);
xClipped=[xy1(1) xy2(1)];
yClipped=[xy1(2) xy2(2)];
return