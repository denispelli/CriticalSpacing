function nominalAcuityDeg=NominalAcuityDeg(eccentricityXYDeg)
% Eq. 13 from Song, Levi, and Pelli (2014).
% See also: NominalCriticalSpacingDeg
assert(length(eccentricityXYDeg)==2)
nominalAcuityDeg=0.029*(sqrt(sum(eccentricityXYDeg.^2))+2.72);

