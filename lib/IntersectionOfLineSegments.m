function [x,y]=IntersectionOfLineSegments(lineA,lineB)
% Each column is the x and y coordinates of a point. Each line segment
% has two points, one per column.
% 2016 denis.pelli@nyu.edu
% March 14, 2016, Add jnd of 1e-10 to tolerate numerical error, which was
% 1e-14 in the case I encountered.
[x,y]=IntersectionOfInfiniteLines(lineA,lineB);
if isnan(x) || isnan(y)
   return
end
jnd=1e-10;
isXInLineSegment=@(x,line)(x>=line(1,1)-jnd && x<=line(1,2)+jnd) || (x<=line(1,1)+jnd && x>=line(1,2)-jnd);
isYInLineSegment=@(y,line)(y>=line(2,1)-jnd && y<=line(2,2)+jnd) || (y<=line(2,1)+jnd && y>=line(2,2)-jnd);
if isXInLineSegment(x,lineA) && isYInLineSegment(y,lineA) && isXInLineSegment(x,lineB) && isYInLineSegment(y,lineB) 
   return
end
x=nan;
y=nan;
return

