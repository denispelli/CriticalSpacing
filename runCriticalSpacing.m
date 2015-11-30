clear o
o.trials=20; % Number of presentations (two response per presentation) for the threshold estimate.
% The viewing distance is set here. The program will try to use what you
% selected, otherwise it will abort and tell you the minimum viewing
% distance that you need. You must then modify this file to set the new
% viewing distance. And, of course, move the screen to that distance.
o.viewingDistanceCm=300;
o.flipScreenHorizontally=0; % Set to 1 when using a mirror to achieve a long viewing distance.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.useScreenCopyWindow=1; % Faster, but fails on some Macs. If your repeated-letters screen is incomplete, set this to 0.
o.negativeFeedback=0;
o.encouragement=1; % Randomly say good, very good, or nice after every trial.
o.repeatedLetters=1; % Repeated letter make the test immune to fixation errors.
o.fixationCrossDeg=0;
o.useFractionOfScreen=0;
o.thresholdParameter='spacing';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.durationSec=inf; % duration of display of target and flankers
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
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely
% We retain the observer name obtained during the first run for use in the
% second run.
o(1).repeatedLetters=0;
o(2).repeatedLetters=0;
o(1).observer=oRepeated(1).observer;
o(2).observer=oRepeated(2).observer;
% Test two conditions interleaved: 'spacing' and 'size', with single
% target.
oSingle=CriticalSpacing(o); % one target
