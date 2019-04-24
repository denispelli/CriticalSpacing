function nominalCriticalSpacingDeg=NominalCriticalSpacingDeg(eccentricityXYDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% Revised to match foveal measurement of Pelli et al. (2016).
% You can pass one or more eccentricities. Each row is one eccentricityy.
% The result is a column with one value per row.
% This is identical to NominalCrowdingDistanceDeg.
% See also: NominalAcuityDeg
assert(size(eccentricityXYDeg,2)==2)
ecc=sqrt(sum(eccentricityXYDeg.^2,2));
nominalCriticalSpacingDeg=0.3*(ecc+0.15);
