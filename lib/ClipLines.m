function clippedLines=ClipLines(lines,r)
%lines=ClipLines(lines,r);
% Clips each line segment by a rect, and returns the new line segment.
% Omits the line when there is no intersection.
% 2016 denis.pelli@nyu.edu
for i=1:2:size(lines,2)
   line=lines(:,i:i+1);
   [x,y,xx,yy]=ClipLine(line(1,1),line(2,1),line(1,2),line(2,2),r);
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
