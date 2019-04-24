function nominalCrowdingDistanceDeg=NominalCrowdingDistanceDeg(eccentricityXYDeg)
% Eq. 14 from Song, Levi, and Pelli (2014).
% Revised to match foveal measurement of Pelli et al. (2016).
% See also: NominalAcuityDeg
% You can pass one or more eccentricities. Each row is one eccentricity.
% The result is a column with one value per row.
assert(size(eccentricityXYDeg,2)==2)
ecc=sqrt(sum(eccentricityXYDeg.^2,2));
nominalCrowdingDistanceDeg=0.3*(ecc+0.15);
% ecc= (nominal/0.3)-0.15;
% If nominal is 0.2 or 1 deg, then critical ecc. is 0.5 or 3 deg.
% Thus 0.2 deg monospaced tesxt will be read within ecc <0.5 deg.
% 1 deg text will have a critical ecc. of 3 deg.
% 2 deg text will have a critical ecc. of 7 deg.
% Thus most of the visual span will be more than 1 deg of fixation.
% And the visual span will depend on crowding distance at 7 deg.
