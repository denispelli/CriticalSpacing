% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016, Denis G. Pelli, denis.pelli@nyu.edu

% We recommend leaving the boilerplate header alone, and customizing by
% copying lines from the boilerplate to your customized section at the
% bottom and modifying it there. This facilitates comparison of scripts.

%% BOILERPLATE HEADER
clear o

% PROCEDURE
o.experimenter='Junk'; % Put name here to skip the runtime question.
o.observer='Junk'; % Put name here to skip the runtime question.
o.permissionToChangeResolution=false; % Works for main screen only, due to Psychtoolbox bug.
% o.getAlphabetFromDisk=true; % true makes the program more portable.
o.task='readAloud';
o.textFont='Arial';
o.textSizeDeg=0.4;
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.trialsDesired=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=50; % Default for runtime question.

% SOUND & FEEDBACK
o.beepNegativeFeedback=false;
o.beepPositiveFeedback=true;
o.showProgressBar=true;
o.speakEachLetter=true;
o.speakEncouragement=false;
o.speakViewingDistance=false;
o.usePurring=false;
o.useSpeech=false;

% VISUAL STIMULUS
o.durationSec=inf; % duration of display of target and flankers
o.eccentricityXYDeg=[0 0]; % Distance of target from fixation. Positive up and to right.
o.nearPointXYInUnitSquare=[0.5 0.5]; % Target location, re lower-left corner of screen.
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
o.targetSizeIsHeight=true; % "Size" is either height (1) or width (0).
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this and pixPerCm.
% o.flankingDirection='tangential'; % vertically arranged flankers for single target
o.flankingDirection='radial'; % horizontally arranged flankers for single target
o.spacingDeg=nan;

% TARGET FONT
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='$';
o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';
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
o.fixationCrossBlankedNearTarget=false;
o.fixationCrossDeg=3; % 0, 3, and inf are a typical values.
o.fixationLineWeightDeg=0.02;
o.markTargetLocation=false; % true to mark target location
o.useFixation=true;

% QUEST threshold estimation
o.beta=nan;
o.measureBeta=false;
o.pThreshold=nan;
o.tGuess=nan;
o.tGuessSd=nan;
o.useQuest=true; 

% DEBUGGING AIDS
o.frameTheTarget=false; 
o.printScreenResolution=false;
o.printSizeAndSpacing=false;
o.showAlphabet=false; 
o.showBounds=false;
o.showLineOfLetters=false;
o.speakSizeAndSpacing=false;


%% CUSTOM CODE
% RUN 

o.useFractionOfScreenToDebug=0.3;
o.viewingDistanceCm=50;
o.eccentricityXYDeg=[0 0]; % Distance of target from fixation. Positive up and to right.
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0]  lower right, [1 1] upper right.
o.durationSec=0.2; % duration of display of target and flankers
o.targetFont='Sloan';
%     o.targetFont='Calibri';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.getAlphabetFromDisk=false;
o.targetDeg=2;
% o.targetHeightDeg=2;
o.thresholdParameter='spacing';
% o(2)=o(1); % Copy the condition
% o=CriticalSpacing(o); 

% o.thresholdParameter='size';
% o(2)=o(1); % Copy the condition
% o.getAlphabetFromDisk=false; % true makes the program more portable.

% Japanese
% o.targetFont='Hiragino Mincho ProN W3';
% o.alphabet=[26085 26412 35486 12391 12354 12426 12364 12392 12358 12372 12374 12356 12414 12375 12383 12290];
% o.labelAnswers=true;

% Chinese
% o.targetFont='Songti TC Light';
% o.labelAnswers=true;
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% Difficult Roman fonts
% o.targetFont='Kuenstler Script Bold'; 
% o.targetFont='SabbathBlackRegular';
% o.targetFont='SabbathBlack OT';
% o.labelAnswers=false;
% o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWYZ'; 
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% o.targetFont='Sans Forgetica';
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% o.getAlphabetFromDisk=true; % true makes the program more portable.
% o.targetFont='Checkers';
% o.alphabet='abcdefghijklmnopqrstuvwxyz'; 
% o.borderLetter='';
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
o.skipScreenCalibration=true; % Skip calibration to save time.
o.useFractionOfScreenToDebug=0.3; 
oo=o;
oo=CriticalSpacing(oo); 

% Results are printed in MATLAB's Command Window and saved in the
% CriticalSpacing/data/ folder.