% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
o.targetHeightOverWidth=3;
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=500;
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.encouragement=0; % Say "good," "very good," or "nice" after every trial.
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.

% You don't need to change any of these parameters.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.usePurring=1; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.negativeFeedback=0;
o.fixationCrossDeg=0;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.task='identify';
o.minimumTargetPix=8; % Make sure the letters are well rendered.
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding 'C'
o.targetFont='Sloan';
o.textFont='Calibri';
o.fixationLocation='center';
o.frameTheTarget=0; % For debugging.
o.useFractionOfScreen=0; % For debugging.

% Set up for interleaved testing of size and spacing thresholds at two
% spacing:size ratios. 

% FIRST RUN (measures four thresholds, interleaved)
o.fixedSpacingOverSize=1.4;
o.repeatedTargets=1;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(2).thresholdParameter='size';
o(3)=o(1);
o(4)=o(2);
o(3).fixedSpacingOverSize=1.2;
o(4).fixedSpacingOverSize=1.2;
% Test four conditions interleaved.
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely