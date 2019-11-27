function xy=LimitXYToRect(xy,rect)
% xy=LimitXYToRect(xy,rect);
% Restrict x and y to lie inside rect. If xy is inside rect, return it. If
% xy is outside rect, return nearest point on rect. rect is defined by two
% points, [x1 y1 x2 y2]. In Apple screen coordinates y increases downward,
% whereas in ordinary coordinates, y increases upward. Thus we assume 
% x2 >= x1, but we don't assume any relation between y2 and y1.
% denis.pelli@nyu.edu, 2019

if rect(2)>rect(4)
     rect=rect([1 4 3 2]);
end
% Now we can assume that x and y are both increasing within the new rect,
% and use that rect to limit xy.
xy=max(xy,rect(1:2));
xy=min(xy,rect(3:4));
end
