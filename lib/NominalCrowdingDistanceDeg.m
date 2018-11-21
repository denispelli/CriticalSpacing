function nominalCrowdingDistanceDeg=NominalCrowdingDistanceDeg(eccentricityXYDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% Revised to match foveal measurement of Pelli et al. (2016).
% See also: NominalAcuityDeg
assert(length(eccentricityXYDeg)==2)
ecc=sqrt(sum(eccentricityXYDeg.^2));
nominalCrowdingDistanceDeg=0.3*(ecc+0.15);
