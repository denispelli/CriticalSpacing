function nominalCriticalSpacingDeg=NominalCriticalSpacingDeg(eccentricityDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% Revised to match foveal measurement of Pelli et al. (2016).
% See also: NominalAcuityDeg
nominalCriticalSpacingDeg=0.3*(eccentricityDeg+0.45);
nominalCriticalSpacingDeg=0.3*(eccentricityDeg+0.05); % 
