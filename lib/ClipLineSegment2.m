function [newXY1,newXY2]=ClipLineSegment2(xy1,xy2,r)
% [xy1,xy2]=ClipLineSegment2(xy1,xy2,r)
%
% Liang-Barsky Algorithm for line clipping. See
% http://en.wikipedia.org/wiki/Liang%E2%80%93Barsky_algorithm
%
% Take a 2-D line from xy1 to xy2, and clip it to fit in rectangle r,
% returning the new line segment from newXY1 to newXY2. If nothing remains,
% the output arguments are NaN.
%
% Inputs must be vectors of length 2. Outputs are vectors of length 2. If
% no outputs are specified, a plot is made.
%
% Original source is online:
% http://mass-communicating.com/code/2013/05/12/line-clipping.html
%
% denis.pelli@nyu.edu, 2016.
v1=r(1:2);
v2=r(3:4);

if length(xy1) ~= 2 || length(xy2) ~= 2 || length(v1) ~= 2 || length(v2) ~= 2
   error('All inputs must be vectors of length 2.');
end

x0 = xy1(1);
x1 = xy2(1);
y0 = xy1(2);
y1 = xy2(2);

x_min = min(v1(1),v2(1));
x_max = max(v1(1),v2(1));
y_min = min(v1(2),v2(2));
y_max = max(v1(2),v2(2));

% Quick hack to trim infinite line that is horizontal or
% vertical. Without this hack we 
if any(~isfinite([x0 x1])) && y0==y1
   x0=min(x0,x_max);
   x0=max(x0,x_min);
   x1=min(x1,x_max);
   x1=max(x1,x_min);
end
if any(~isfinite([y0 y1])) && x0==x1
   y0=min(y0,y_max);
   y0=max(y0,y_min);
   y1=min(y1,y_max);
   y1=max(y1,y_min);
end

newXY1 = nan(size(xy1));
newXY2 = nan(size(xy2));

dx = x1-x0;
dy = y1-y0;

p = [ -dx;
   dx;
   -dy;
   dy ];

q = [ x0-x_min;   % negative => left of window
   x_max-x0;   % negative => right of window
   y0-y_min;   % negative => below window
   y_max-y0;   % negative => above window
   ];

% Test if line isn't visible.
%     for i = 1:4
%         if p(i) == 0 && q(i) < 0
%             return;
%         end
%     end
if ~isempty(find(p == 0 & q < 0,1,'first'))
   return;
end

u1 = 0;
u2 = 1;

for i = 1:4
   if p(i) < 0
      u1 = max(u1,q(i)/p(i));
   end
   if p(i) > 0
      u2 = min(u2,q(i)/p(i));
   end
end

if u1 > u2  % line is outside
   return;
end

newXY1(1) = x0 + dx*u1;
newXY1(2) = y0 + dy*u1;

newXY2(1) = x0 + dx*u2;
newXY2(2) = y0 + dy*u2;

if nargout == 0
   rectangle('position',[x_min y_min (x_max-x_min) (y_max-y_min)]);
   
   l1 = line([x0 x1],[y0 y1]);
   set(l1,'color','k','linestyle','--');
   hold all
   l2 = plot([newXY1(1) newXY2(1)],[newXY1(2) newXY2(2)],'o-');
   set(l2,'linestyle','-','linewidth',2);
   
   xlim([ min([x0,x1,x_min])-.1,max([x0,x1,x_max])+.1 ]);
   ylim([ min([y0,y1,y_min])-.1,max([y0,y1,y_max])+.1 ]);
end

if 0
   % This demo produces a pretty plot.
   figure;
   
   ClipLineSegment2([-1,-1],[3,2],[0 0 1 1]);
   ClipLineSegment2([0.5,0.3],[1.3,0.7],[0 0 1 1]);
   ClipLineSegment2([-0.5,1.2],[1.3,0.7],[0 0 1 1]);
   ClipLineSegment2([-0.5,0.7],[0.3,0.7],[0 0 1 1]);
   ClipLineSegment2([0.2,1.3],[0.1,-0.4],[0 0 1 1]);
   
   [newXY1,newXY2] =ClipLineSegment2([0,-.04],[0,-0.04],[0 0 1 1]);
   ClipLineSegment2([0.2,.5],[0.8,.5],[0 0 1 1]);
   ClipLineSegment2([-inf .3],[inf,.3],[0 0 1 1]);
   %    ClipLineSegment2([-100 .5],[100,.5],[0 0 1 1]);
end
end

