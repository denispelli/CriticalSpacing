function clippedLines=ClipLines(lines,r)
% lines=ClipLines(lines,r);
% Clips each line segment by a rect, and returns the new line segments.
% Omits lines entirely outside the rect.
% 2016, 2017 denis.pelli@nyu.edu
for i=1:2:size(lines,2)
   line=lines(:,i:i+1);
%    [x,y,xx,yy]=ClipLine(line(1,1),line(2,1),line(1,2),line(2,2),r);
   [xy1,xy2]=ClipLineSegment2(line(:,1),line(:,2),r);
   x=xy1(1);
   y=xy1(2);
   xx=xy2(1);
   yy=xy2(2);
   if any(isnan([x xx y yy]))
      assert(all(isnan([x xx y yy])))
   end
   lines(:,i:i+1)=[x xx;y yy];
end
lines=lines(~isnan(lines));
lines=reshape(lines,2,length(lines)/2);
if isempty(lines)
   lines=[0 0;0 0];
end
clippedLines=lines;
