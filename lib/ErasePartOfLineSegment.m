function [xClipped,yClipped]=ErasePartOfLineSegment(x,y,r)
%[x,y]=ErasePartOfLineSegment(x,y,r);
% Removes the part of a line segment that's in a rect, and returns the
% remaining zero, one, or two line segments of non-zero length. The
% original line segment is (x(1),y(1)) to (x(2),y(2)). Direction (from
% point 1 to point 2) is preserved. Returns NANs if you provide an
% ambiguous line segment.
% 2016 denis.pelli@nyu.edu
assert(length(x)>=2 && length(x)/2==round(length(x)/2))
assert(length(y)==length(x));
assert(length(r)==4);
if length(x)>2
   xClipped=[];
   yClipped=[];
   for i=1:2:length(x)-1
      [xTemp,yTemp]=ErasePartOfLineSegment(x(i:i+1),y(i:i+1),r);
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
xClipped=x;
yClipped=y;
if IsInRect(x(1),y(1),r) && IsInRect(x(2),y(2),r)
   % Both endpoints in rect. Nothing left.
   xClipped=[];
   yClipped=[];
   return;
end
% The line has two endpoints. At least one is outside the rect. Count
% points of intersection with the rect. Replace each inside point with the
% point of intersection of the line with the nearest side of the rect.
line=[x;y];
rectLines(:,:,1)=[r(1) r(1);r(2) r(4)];
rectLines(:,:,2)=[r(1) r(3);r(2) r(2)];
rectLines(:,:,3)=[r(3) r(3);r(2) r(4)];
rectLines(:,:,4)=[r(1) r(3);r(4) r(4)];
for i=1:4
   [xHit(i),yHit(i)]=IntersectionOfLineSegments(line,rectLines(:,:,i));
end
xHit=xHit(~isnan(yHit)); % Omit NANs.
yHit=yHit(~isnan(yHit));
if length(xHit)>1
   % Remove duplicates.
   for i=length(xHit):-1:2
      for j=i-1:-1:1
         if xHit(j)==xHit(i) && yHit(j)==yHit(i)
            if i==length(xHit)
               xHit=xHit(1:i-1);
               yHit=yHit(1:i-1);
            else
               xHit=xHit([1:i-1 i+1:end]);
               yHit=yHit([1:i-1 i+1:end]);
            end;
            break;
         end
      end
   end
end
assert(length(xHit)<3);
switch length(xHit)
   case 0;
      % Line is outside clip rect.
      return
   case 1;
      % Clip rect cut off one end of line segment.
      if IsInRect(x(1),y(1),r)
         xClipped(1)=xHit;
         yClipped(1)=yHit;
      end
      if IsInRect(x(2),y(2),r)
         xClipped(2)=xHit;
         yClipped(2)=yHit;
      end
   case 2;
      % Clip rect cut line in two.
      % Retain direction.
      if sign(x(1)-x(2))~=sign(xHit(1)-xHit(2)) || ...
            sign(y(1)-y(2))~=sign(yHit(1)-yHit(2))
         xHit=xHit([2 1]);
         yHit=yHit([2 1]);
      end
      % Clip both ends.
      xClipped(1:4)=[x(1) xHit(1:2) x(2)];
      yClipped(1:4)=[y(1) yHit(1:2) y(2)];
end
% Discard zero-length lines.
if length(xClipped)==4
   if diff(xClipped(3:4))^2+diff(yClipped(3:4))^2==0
      xClipped=xClipped(1:2);
      yClipped=yClipped(1:2);
   end
end
if length(xClipped)==2
   if diff(xClipped(1:2))^2+diff(yClipped(1:2))^2==0
      if length(xClipped)>2
         xClipped=xClipped(3:4);
         yClipped=yClipped(3:4);
      else
         xClipped=[];
         yClipped=[];
      end
   end
end
return
