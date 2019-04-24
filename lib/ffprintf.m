function [count] = ffprintf(fid,varargin)
%FFPRINTF is an enhanced fprintf that allows fid to be an array
%   Denis Pelli, NYU, March 24, 2015, 2017
if nargin<2
   error('You must provide two arguments: the fid and a string.');
end
for f=fid
    count=fprintf(f,varargin{:});
end
end
