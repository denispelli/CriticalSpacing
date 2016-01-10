% MATLAB script to run CriticalSpacing.m
% Copyright 2016, Denis G. Pelli, denis.pelli@nyu.edu
clear o
o.isChild=0;
o.showProgressBar=0;
o.fractionEasyTrials=0; % Add 20% extra easy trials. 0 for none.
o.speakEncouragement=0; % 1 to say "good," "very good," or "nice" after every trial.
o.speakEachLetter=1;
o.setTargetHeightOverWidth=0;
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=400;
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.useSpeech=1;
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0;

% You don't need to change any of these parameters.
o.measureThresholdVertically=0;
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.readAlphabetFromDisk=0; % 1 makes the program more portable.
o.usePurring=0; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.negativeFeedback=0;
o.fixationCrossDeg=1;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.textFont='Calibri';
o.fixationLocation='center';
o.task='identify';
o.minimumTargetPix=8; % Make sure the letters are well rendered.

% DEBUGGING AIDS
o.displayAlphabet=0;
o.showLineOfLetters=0;
o.showBounds=0;
o.frameTheTarget=1;
o.printSizeAndSpacing=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0.5;

o.fixedSpacingOverSize=1.5; % Requests size proportional to spacing.
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.validKeys={'D','H','K','N','O','R','S','V','Z'};
o.repeatedTargets=0;
o.thresholdParameter='size';
o.eccentricityDeg=10;
o=CriticalSpacing(o); 
