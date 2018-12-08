%% DENIS'S TESTING
% Test the new o.maxLines feature. o.maxLines can have any integer value of
% 3 or more, up to inf.
clear o oo
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.isolatedTarget=false;
o.conditionName='crowding';
o.fixationLineWeightDeg=0.04;
o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
o.eccentricityXYDeg=[0 0];
o.flankingDirection='horizontal';
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.viewingDistanceCm=50;
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
o.condition=1;
o.trials=30;
o.practicePresentations=0;
o.experimenter='Denis';
o.durationSec=2; % duration of display of target and flankers
% o.speakSizeAndSpacing=true;
% o.printSizeAndSpacing=true;
% o.useFractionOfScreenToDebug=0.5;
o.repeatedTargets=true;
o.maxFixationErrorXYDeg=[3 3]; % Repeat targets enough to cope with fixation errors up to this size.
o.maxLines=1; % Must be 1,3,4,...inf
% o.maxLines=inf;
% o.useFractionOfScreenToDebug=0.5; 
% o.printSizeAndSpacing=true;
o=CriticalSpacing(o);

