% MATLAB script to run CriticalSpacing.m
% Copyright 2016 Denis G. Pelli, denis.pelli@nyu.edu

% We recommend leaving the boilerplate header alone, and customizing by
% copying lines from the boilerplate to your customized section at the
% bottom and modifying it there. This facilitates comparison of scripts.

%% BOILERPLATE HEADER
clear o

% PROCEDURE
o.viewingDistanceCm=400; % Default for runtime question.
o.experimenter=''; % Put name here to skip the runtime question.
o.observer=''; % Put name here to skip the runtime question.
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.readAlphabetFromDisk=1; % 1 makes the program more portable.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this & pixPerCm.
o.measureThresholdVertically=0;
o.textFont='Arial';
o.showProgressBar=1;
o.task='identify';

% SOUND
o.speakEachLetter=1;
o.useSpeech=1;
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0; % Play purring sound while awaiting user response.

% VISUAL STIMULUS
o.durationSec=inf; % duration of display of target and flankers
o.repeatedTargets=1;
o.fourFlankers=1;
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o.setTargetHeightOverWidth=0;
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target

% TARGET FONT
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
% o.targetFont='Pelli';
% o.alphabet='123456789'; 
% o.borderLetter='$';
% o.targetFont='ClearviewText';
% o.targetFont='Gotham Cond SSm XLight';
% o.targetFont='Gotham Cond SSm Light';
% o.targetFont='Gotham Cond SSm Medium';
% o.targetFont='Gotham Cond SSm Book';
% o.targetFont='Gotham Cond SSm Bold';
% o.targetFont='Gotham Cond SSm Black';
% o.targetFont='Arouet';
% o.targetFont='Pelli';
% o.targetFont='Retina Micro';

% FIXATION
o.fixationCrossDeg=0;
o.fixationLocation='center';

% QUEST threshold estimation
o.measureBeta=0;

% DEBUGGING AIDS
o.showAlphabet=0; 
o.showLineOfLetters=0;
o.showBounds=0;
o.frameTheTarget=0; 
o.printSizeAndSpacing=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0; 

% FOR CHILDREN
% o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
% o.speakEncouragement=1; % 1 to say "good," "very good," or "nice" after every trial.

%% CUSTOM CODE

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.

% o.useFractionOfScreen=0.3; 
o.viewingDistanceCm=200; % Default for runtime question.
o.fixationCrossDeg=inf;

% RUN measure thresholds for size
o.durationSec=0.2; % duration of display of target and flankers
o.repeatedTargets=0;
o.fourFlankers=1;
o.thresholdParameter='size';
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o.eccentricityDeg=0;
o.fixationLocation='center';
o=CriticalSpacing(o); % dual targets, repeated indefinitely

% RUN measure thresholds for size
o.eccentricityDeg=4;
o.fixationLocation='left';
o=CriticalSpacing(o); % dual targets, repeated indefinitely

% Results are printed in MATLAB's Command Window and saved in the
% CriticalSpacing/data/ folder.