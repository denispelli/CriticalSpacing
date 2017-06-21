function [newXY1,newXY2] = ClipLine2(xy1,xy2,r)
% [xy1,xy2,] = ClipLine2(xy1,xy2,r); Given a rect and an infinite line
% (specified by two points), returns the clipped line. If there's nothing
% left, the output arguments are NaN.
dxy=xy2-xy1;
dr=r(1:2)-r(3:4);
scalar=1e6*sqrt(sum(dr.^2))/sqrt(sum(dxy.^2));
% We extend the provided line segment to be 1e6 times bigger than the
% diagonal length of the rect, in both directions.
% That's good enough for my application.
[newXY1, newXY2] = ClipLineSegment2(xy1+scalar*dxy,xy1-scalar*dxy,r);
