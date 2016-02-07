function [x,y]=IntersectionOfLineSegments(lineA,lineB)
% Each column is the x and y coordinates of a point. Each line segment
% has two points, one per column.
% 2016 denis.pelli@nyu.edu
[x,y]=IntersectionOfInfiniteLines(lineA,lineB);
if isnan(x) || isnan(y)
   return
end
isXInLineSegment=@(x,line)(x>=line(1,1) && x<=line(1,2)) || (x<=line(1,1) && x>=line(1,2));
isYInLineSegment=@(y,line)(y>=line(2,1) && y<=line(2,2)) || (y<=line(2,1) && y>=line(2,2));
if isXInLineSegment(x,lineA) && isYInLineSegment(y,lineA) && isXInLineSegment(x,lineB) && isYInLineSegment(y,lineB) 
   return
end
x=nan;
y=nan;
return

