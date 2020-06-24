% MATLAB script to run CriticalSpacing.m
% denis.pelli@nyu.edu
% Look at boilerplate.m for a list of all fields that can be set.

clear o
% boilerplate;
% o.useFractionOfScreenToDebug=0.3; 
o.trialsDesired=40;
o.practicePresentations=0;
o.experiment='CriticalSpacingAntjeBilateral';
o.condition='CrowdingDistance';
o.experimenter='Antje';
o.observer='';
o.viewingDistanceCm=50;
o.flankingDirection='radial'; 
o.eccentricityXYDeg=[10 0]; % Distance of target from fixation. Positive up and to right.
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower right, [1 1] upper right.
o.durationSec=0.2; % duration of display of target and flankers
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.targetDeg=2;
o.repeatedTargets=0;
o.thresholdParameter='spacing';
o.setNearPointEccentricityTo='fixation';
o.fixationMarkDeg=3; % 0, 3, and inf are a typical values.
o.fixationThicknessDeg=0.02;

% Randomly interleave testing left and right.
oo=[o o];
oo(2).eccentricityXYDeg=-oo(2).eccentricityXYDeg;

% Print list of conditions.
t=struct2table(oo);
fields={'experiment','condition','experimenter','observer','thresholdParameter','trials','eccentricityXYDeg'};
disp(t(:,fields));

% Measure left and right thresholds, interleaved.
o=CriticalSpacing(oo); 

% Results are printed in MATLAB's Command Window and saved in the
% CriticalSpacing "data" folder.