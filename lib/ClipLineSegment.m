function [xClipped,yClipped]=ClipLineSegment(x,y,r)
%[x,y]=ClipLineSegment(x,y,r);
% Clips a line segment by a rect, and returns the new line segment, or
% point, or nothing. The line segment is (x(1),y(1)) to (x(2),y(2)). The
% point is (x(1),y(1)). Unused elements of x and y are set to NAN.
% 2016 denis.pelli@nyu.edu
xClipped=x;
yClipped=y;
if IsInRect(x(1),y(1),r) && IsInRect(x(2),y(2),r)
   % Both endpoints in rect. No clipping required.
   return;
end
% The line has two endpoints. At least one is outside rect. Replace each
% point outside rect with the point of intersection of the line with the
% nearest side of the rect. Return nans if there is no intersection.
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
      for j=1:i-1
         if xHit(j)==xHit(i) && yHit(j)==yHit(i)
            xHit=xHit([1:i-1 min(i+1,end):end]);
            yHit=yHit([1:i-1 min(i+1,end):end]);
         end
      end
   end
end
assert(length(xHit)<3);
switch length(xHit)
   case 0;
      % Nothing in clip rect.
      xClipped=[nan nan];
      yClipped=[nan nan];
      return
   case 1;
      % Clip rect cuts off one end of line segment.
      if ~IsInRect(x(1),y(1),r)
         xClipped(1)=xHit;
         yClipped(1)=yHit;
      end
      if ~IsInRect(x(2),y(2),r)
         xClipped(2)=xHit;
         yClipped(2)=yHit;
      end
      return
   case 2;
      % Clip rect cuts off both ends of line segment.
      % Retain direction.
      if sign(x(1)-x(2))~=sign(xHit(1)-xHit(2)) || sign(y(1)-y(2))~=sign(yHit(1)-yHit(2))
         xHit=xHit([2 1]);
         yHit=yHit([2 1]);
      end
      % Clip both ends.
      xClipped=xHit;
      yClipped=yHit;
      return
end
