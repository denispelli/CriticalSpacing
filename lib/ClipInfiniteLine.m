function [xClipped,yClipped]=ClipInfiniteLine(x,y,r)
%[x,y]=ClipInfiniteLine(x,y,r);
% Clips a line by a rect, and returns the new line segment, or point, or
% nothing. The line segment argument defines an infinite line going through
% the segment, extended indefinitely in both directions. The line segment
% is (x(1),y(1)) to (x(2),y(2)). The point is (x(1),y(1)). Unused elements
% of x and y are set to NAN.
% 2016 denis.pelli@nyu.edu

[centerX,centerY] = RectCenter(r);
width=RectWidth(r);
height=RectHeight(r);
if x(1)==x(2)
   if y(1)>y(2)
      y=[r(4) r(2)];
   else
      y=[r(2) r(4)];
   end
   [x,y]=ClipLineSegment(x,y,r);
   return
end
if y(1)==y(2)
   if x(1)>x(2)
      x=[r(3) r(1)];
   else
      x=[r(1) r(3)];
   end
   [x,y]=ClipLineSegment(x,y,r);
   return
end
% Use the x-range of the rect to select a segment of the line.
slope=(y(2)-y(1))/(x(2)-x(1));
xNew=[r(1) r(3)];
yNew=slope*(xNew-x(1))+y(1);
[x,y]=ClipLineSegment(xNew,yNew,r);
return
end
