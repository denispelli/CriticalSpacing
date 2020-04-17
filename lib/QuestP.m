function p=QuestP(q,x)
% p=QuestP(q,x)
%
% The probability p of a correct (or yes) response at intensity x, assuming
% threshold is at x=0. x can be a matrix of any size, and the returned p
% will have the same size. Any NaN values in x will produce NaN values in
% p. Each not-nan value of x is bounded to the domain [a.x2(1) a.x2(end)]
% of the psychometric function.
%
% See Quest.

% 7/25/04   awi     Cosmetic (help text layout).
% 8/25/15   dgp     Make sure x is real, not complex.
% 8/25/15   dgp     Added two missing semicolons, to eliminate spurious
%                   printing.
% 3/28/20   dgp     Enhanced to accept matrix x and return matrix p.

% Copyright (c) 1996-2020 Denis Pelli
if any(~isreal(x(:)))
    error('x must be real, not complex.');
end
xSave=x;
x=max(x,q.x2(1));
x=min(x,q.x2(end));
missing=isnan(xSave);
x(missing)=xSave(missing); % Restore the nans.
p=interp1(q.x2,q.p2,x);
if any(~isfinite(p(:)) & isfinite(x(:)))
    i=find(~isfinite(p(:)),1);
    error('psychometric function p=%g at x=%.2g',p(i),x(i));
end
