function [xClipped,yClipped,xxClipped,yyClipped]=ClipLine(x,y,xx,yy,r)
%[x,y,xx,yy]=ClipLine(x,y,xx,yy,r);
% Clips a line segment by a rect, and returns the new line segment. Returns
% four nans if there is no intersection of the line segment with the rect.
% 2016 denis.pelli@nyu.edu
xClipped=x;
yClipped=y;
xxClipped=xx;
yyClipped=yy;
if IsInRect(x,y,r) && IsInRect(xx,yy,r)
   % Both endpoints in rect. No clipping required.
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
if ~IsInRect(x,y,r) && ~IsInRect(xx,yy,r)
   if isempty(xHit)
      xClipped=nan;
      yClipped=nan;
      xxClipped=nan;
      yyClipped=nan;
      return
   end
   % Clip both ends. Retain direction.
   assert(length(xHit)<3);
   if sign(x-xx)~=sign(xHit(1)-xHit(2)) || sign(y-yy)~=sign(yHit(1)-yHit(2))
      xHit=xHit([2 1]);
      yHit=yHit([2 1]);
   end
   xClipped=xHit(1);
   yClipped=yHit(1);
   xxClipped=xHit(2);
   yyClipped=yHit(2);
end
if length(xHit)==2
   if abs(xHit(1)-xHit(2))+abs(yHit(1)-yHit(2))>1
      xHit
      yHit
      IsInRect(x,y,r)
      IsInRect(xx,yy,r)
      x,y
      xx,yy
      r
   end
%   xxx
%   assert(abs(xHit(1)-xHit(2))+abs(yHit(1)-yHit(2))<1);
   xHit=xHit(1);
   yHit=yHit(1);
end
assert(length(xHit)==1);
if ~IsInRect(x,y,r)
   xClipped=xHit;
   yClipped=yHit;
end
if ~IsInRect(xx,yy,r)
   xxClipped=xHit;
   yyClipped=yHit;
end

