function [x,y]=ClipInfiniteLine(x,y,r)
%[x,y]=ClipInfiniteLine(x,y,r);
% Clips a line by a rect, and returns the new line segment (possibly zero
% length) or nothing (empty rects). The line segment argument defines an
% infinite line going through the segment, extended indefinitely in both
% directions. The line segment is (x(1),y(1)) to (x(2),y(2)). Returns nans
% if you provide a zero-length or otherwise undefined line.
% 2016 denis.pelli@nyu.edu

% Make sure the two points define a line.
if any([isnan(x) isnan(y)]) || (x(1)==x(2) && y(1)==y(2))
   x=[nan nan];
   y=[nan nan];
   return
end
% Special case: Vertical line.
if x(1)==x(2)
   if y(1)>y(2)
      y=[r(4) r(2)];
   else
      y=[r(2) r(4)];
   end
   if all(x<r(1)) || all(x>r(3))
      x=[];
      y=[];
   end
   return
end
% Special case: Horizontal line.
if y(1)==y(2)
   if x(1)>x(2)
      x=[r(3) r(1)];
   else
      x=[r(1) r(3)];
   end
   if all(y<r(2)) || all(y>r(4))
      x=[];
      y=[];
   end
   return
end
% Now we know the line isn't horizontal or vertical, so we can always
% compute x from y, and visa versa. Use the x-range of the rect to select a
% segment of the line.
slope=(y(2)-y(1))/(x(2)-x(1));
xNew=[r(1) r(3)];
yNew=slope*(xNew-x(1))+y(1);
x=xNew;
y=yNew;
% Nothing in the rect?
if all(y<r(2)) || all(y>r(4))
   x=[];
   y=[];
   return
end
% Use the y-range of the rect to select a segment of the line.
for i=1:2
   yNew(i)=min(y(i),r(4));
   yNew(i)=max(yNew(i),r(2));
end
xNew=x(1)+(yNew-y(1))/slope;
x=xNew;
y=yNew;
return
end
