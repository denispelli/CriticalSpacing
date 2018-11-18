function [xClipped,yClipped,xxClipped,yyClipped]=ClipLine(x,y,xx,yy,r)
%[x,y,xx,yy]=ClipLine(x,y,xx,yy,r);
% Clips a line segment by a rect, and returns the new line segment. Returns
% four nans when if the line segment is entirely outside the rect..
% 2016 denis.pelli@nyu.edu
xClipped=x;
yClipped=y;
xxClipped=xx;
yyClipped=yy;
if IsInRect(x,y,r) && IsInRect(xx,yy,r)
   % Both endpoints in rect. No clipping required.
   return;
end
if all([x y]==[xx yy])
   % Zero length, outside rect.
      xClipped=nan;
      yClipped=nan;
      xxClipped=nan;
      yyClipped=nan;
   return;
end
% The line has two endpoints. At least one is outside rect. Replace each
% point outside rect with the point of intersection of the line with the
% nearest side of the rect. Return nans if there is no intersection.
line=[x xx;y yy];
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
      xClipped=nan;
      yClipped=nan;
      xxClipped=nan;
      yyClipped=nan;
      return
   case 1;
      if ~IsInRect(x,y,r)
         xClipped=xHit;
         yClipped=yHit;
      end
      if ~IsInRect(xx,yy,r)
         xxClipped=xHit;
         yyClipped=yHit;
      end
      return
   case 2;
      % Retain direction.
      if sign(x-xx)~=sign(xHit(1)-xHit(2)) || sign(y-yy)~=sign(yHit(1)-yHit(2))
         xHit=xHit([2 1]);
         yHit=yHit([2 1]);
      end
      % Clip both ends.
      xClipped=xHit(1);
      yClipped=yHit(1);
      xxClipped=xHit(2);
      yyClipped=yHit(2);
      return
end
