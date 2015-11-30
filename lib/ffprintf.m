function [count] = ffprintf(fid,varargin)
%FFPRINTF is an enhanced fprintf that allows fid to be an array
%   Denis Pelli, NYU, March 24, 2015
for f=fid
    count=fprintf(f,varargin{:});
end
end
