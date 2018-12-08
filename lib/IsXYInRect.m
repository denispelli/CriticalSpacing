function isTrue=IsXYInRect(xy,rect)
% isTrue=IsXYInRect(xy,rect)
if nargin~=2
    error('Need two args for function isTrue=IsXYInRect(xy,rect)');
end
if size(xy)~=[1 2]
    error('First arg to IsXYInRect(xy,rect) must be [x y] pair.');
end
isTrue=IsInRect(xy(1),xy(2),rect);
end
