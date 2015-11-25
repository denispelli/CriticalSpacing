clear o
o.repeatedLetters=1;
o.useFractionOfScreen=0;
o.observer='practice';
% o.observer='Shivam';
o.viewingDistanceCm=150;
o.thresholdParameter='spacing';
% o.thresholdParameter='size';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.durationSec=inf; % duration of display of target and flankers
o.trials=80; % number of trials for the threshold estimate
o.measureBeta=0;
o.task='identify';
o.usePurring=1;
minimumTargetPix=8;
Screen('Preference', 'SkipSyncTests', 1);
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o(2)=o(1);
o(2).thresholdParameter='size';
CriticalSpacing(o);
