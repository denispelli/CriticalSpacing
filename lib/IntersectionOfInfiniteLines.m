function [x,y]=IntersectionOfInfiniteLines(lineA,lineB)
% Each "line" is a two-row vector containing the x and y coordinates of the
% line segments: Pairs of consecutive columns define (x,y) positions of the
% starts and ends of line segments. The provided line segments define
% (infinite) lines. If the lines intersect, we return a point of
% intersection. If the infinite lines are identical we return a point on
% one of the supplied line segments. If the lines do not intersect we
% return NAN for both x and y. It is an error for either line segment to
% have zero length.
% 2016 by denis.pelli@nyu.edu
bA=diff(lineA(2,:))/diff(lineA(1,:)); % dy/dx
aA=lineA(2,1)-bA*lineA(1,1);
bB=diff(lineB(2,:))/diff(lineB(1,:)); % dy/dx
aB=lineB(2,1)-bB*lineB(1,1);
if isnan(bA) || isnan(bB)
    lineA
    lineB
    x=nan;
    y=nan;
    if norm(diff(lineA'))
        warning('lineA has zero length');
    end
    if norm(diff(lineB'))
        warning('lineB has zero length');
    end
    return
end
if bA==bB
    if aA==aB
        x=lineA(1,1);
        y=lineA(2,1);
    else
        x=nan;
        y=nan;
    end
    return
end
if isinf(bA)
    x=lineA(1,1);
    y=aB+bB*x;
    return
end
if isinf(bB)
    x=lineB(1,1);
    y=aA+bA*x;
    return
end
x=-(aA-aB)/(bA-bB);
y=aA+bA*x;
if ~isfinite(x) || ~isfinite(y)
    warning('Infinite result (%.1f, %.1f) makes no sense.',x,y);
end

