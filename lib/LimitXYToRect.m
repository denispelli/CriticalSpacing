function xy=LimitXYToRect(xy,rect)
% xy=LimitXYToRect(xy,rect);
% Restrict x and y to lie inside rect.
% If xy is outside rect, return nearest point on rect.
% If xy is inside rect, return it.
% denis.pelli@nyu.edu, 2018
if ~all(rect(1:2)<=rect(3:4))
    error(['Illegal rect [%.0f %.0f %.0f %.0f]. ' ...
        'Upper left corner should not be below or ' ...
        'right of lower right corner.'],...
        rect(1),rect(2),rect(3),rect(4));
end
xy=max(xy,rect(1:2));
xy=min(xy,rect(3:4));
end
