function nominalAcuityDeg=NominalAcuityDeg(eccentricityDeg)
% Eq. 13 from Song, Levi, and Pelli (2014).
% See also: NominalCriticalSpacingDeg
nominalAcuityDeg=0.029*(eccentricityDeg+2.72);

