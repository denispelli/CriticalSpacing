clear o
o.observer='';
% o.observer='Shivam'; % Enter observer name here.
o.negativeFeedback=0;
o.encouragement=1;
o.repeatedLetters=1;
o.fixationCrossDeg=0;
o.useScreenCopyWindow=1; % Faster, but doesn't work on all Macs.
o.useFractionOfScreen=0;
o.viewingDistanceCm=150;
o.thresholdParameter='spacing';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.durationSec=inf; % duration of display of target and flankers
o.trials=20; % number of presentations (two response per presentation) for the threshold estimate
o.measureBeta=0;
o.task='identify';
o.usePurring=1;
minimumTargetPix=8;
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o.fixationLocation='center';
o(2)=o(1);
o(2).thresholdParameter='size';
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely
% We retain the observer name obtained during the first run for use in the
% second run.
o(1).repeatedLetters=0;
o(2).repeatedLetters=0;
o(1).observer=oRepeated(1).observer;
o(2).observer=oRepeated(2).observer;
oSingle=CriticalSpacing(o); % one target
