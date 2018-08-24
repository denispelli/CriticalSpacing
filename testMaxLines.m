%% DENIS'S TESTING
% Test the new o.maxLines feature. o.maxLines can have any integer value of
% 3 or more, up to inf.
clear o oo
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.isolatedTarget=false;
o.conditionName='crowding';
o.fixationLineWeightDeg=0.04;
o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
o.eccentricityXYDeg=[0 1];
o.flankingDirection='tangential';
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.viewingDistanceCm=50;
o.condition=1;
o.trials=30;
o.practicePresentations=0;
o.experimenter='Denis';
o.durationSec=2; % duration of display of target and flankers
% o.speakSizeAndSpacing=true;
% o.printSizeAndSpacing=true;
% o.useFractionOfScreen=0.5;
o.repeatedTargets=true;
o.maxLines=3;
% o.maxLines=inf;
o=CriticalSpacing(o);

