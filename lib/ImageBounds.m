function bounds=ImageBounds(theImage,white)
% bounds=ImageBounds(theImage)
%
% Returns the smallest enclosing rect of the non-white pixels in the
% image matrix argument.
% OSX: Also see Screen 'TextBounds'.
% Also see TextBounds.

% 12/18/15   dgp wrote it, based on his TextBounds.m
if nargin<2
    white = 255;
end

% Find all nonwhite pixels:
if length(white)==1
   if size(theImage,3)>1
      theImage=theImage(:,:,2);
   end
   [y,x]=find(theImage(:,:)~=white);
else
   error('Support for color images not yet implemented.');
end

% Compute their bounding rect and return it:
if isempty(y) || isempty(x)
    bounds=[0 0 0 0];
else
    bounds=SetRect(min(x)-1,min(y)-1,max(x),max(y));
end
return;
