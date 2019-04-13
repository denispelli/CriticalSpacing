function nominalAcuityDeg=NominalAcuityDeg(eccentricityXYDeg)
% nominalAcuityDeg=NominalAcuityDeg(eccentricityXYDeg);
% Eq. 13 from Song, Levi, and Pelli (2014).
% You can pass one or more eccentricities. Each row is one eccentry.
% The result is a column with one value per row.
% See also: NominalCriticalSpacingDeg
assert(size(eccentricityXYDeg,2)==2)
ecc=sqrt(sum(eccentricityXYDeg.^2,2));
nominalAcuityDeg=0.029*(ecc+2.72);

