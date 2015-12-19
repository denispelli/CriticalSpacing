function bounds=ImageBounds(theImage,white)
% bounds=ImageBounds(theImage)
%
% Returns the smallest enclosing rect for the non-white pixels.
%
% OSX: Also see Screen 'TextBounds'.
% Also see TextBounds.

% 12/18/15   dgp wrote it, based on my TextBounds
if nargin<2
    white = 255;
end

% Find all nonwhite pixels:
[y,x]=find(theImage(:,:)~=white);

% Compute their bounding rect and return it:
if isempty(y) || isempty(x)
    bounds=[0 0 0 0];
else
    bounds=SetRect(min(x)-1,min(y)-1,max(x),max(y));
end
return;
