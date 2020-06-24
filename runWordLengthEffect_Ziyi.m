% runWordLengthEffect_Ziyi.m
% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016, Denis G. Pelli, denis.pelli@nyu.edu
% This script is used to develop and test the 'readAloud' part of
% CriticalSpacing

clear o
% SOUND & FEEDBACK
% o.beepNegativeFeedback=false;
% o.beepPositiveFeedback=true;
% o.showProgressBar=true;
% o.speakEachLetter=true;
% o.speakEncouragement=false;
% o.speakViewingDistance=false;
% o.usePurring=false;
% o.useSpeech=false;

% VISUAL STIMULUS
% o.durationSec=inf; % duration of display of target and flankers
% o.eccentricityXYDeg=[0 0]; % Distance of target from fixation. Positive up and to right.
% o.nearPointXYInUnitSquare=[0.5 0.5]; % Target location, re lower-left corner of screen.
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
% o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
% o.targetSizeIsHeight=true; % "Size" is either height (1) or width (0).
% o.spacingDeg=nan;

% TARGET FONT
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
% o.minimumTargetPix=8; % Depends on font. Minimum viewing distance depends soley on this and pixPerCm.
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='$';
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
% o.markTargetLocation=false; % true to mark target location

% QUEST threshold estimation
% o.beta=nan;
% o.measureBeta=false;
% o.pThreshold=nan;
% o.tGuess=nan;
% o.tGuessSd=nan;
% o.useQuest=true; 

% DEBUGGING AIDS
% o.frameTheTarget=false; 
% o.printScreenResolution=false;
% o.printSizeAndSpacing=false;
% o.showAlphabet=false; 
% o.showBounds=false;
% o.showLineOfLetters=false;
% o.speakSizeAndSpacing=false;

%%
o.experiment='WordLengthEffect';
o.experimenter='Junk'; % Put name here to skip the runtime question.
o.observer='Junk'; % Put name here to skip the runtime question.
o.permissionToChangeResolution=false; 
o.task='readAloud';
o.trialsDesired=2; % Number of trials (i.e. responses) for the threshold estimate.
o.batch=2;
o.viewingDistanceCm=50;
o.eccentricityXYDeg=[0 0]; % Distance of target from fixation. Positive up and to right.
o.flankingDirection='horizontal';
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
o.durationSec=0.5; % duration of display of target and flankers
o.targetFont='Monaco';
o.alphabet='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.borderLetter='$';
o.minimumTargetPix=8; % Depends on font. Minimum viewing distance depends soley on this and pixPerCm.
% o.targetFont='Sans Forgetica';
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.
o.getAlphabetFromDisk=false;
if false
    % Specify letter size.
    o.targetDeg=2;
    o.thresholdParameter='size';
else
    % Specify letter spacing.
    o.readSpacingDeg=1;
    o.thresholdParameter='spacing';
end
o.useFixation=true;
o.isFixationBlankedNearTarget=true;
o.fixationBlankingRadiusReTargetHeight=4;
o.fixationMarkDeg=inf; % 0, 3, and inf are a typical values.
o.fixationThicknessDeg=0.04;

%% Snapshots
o.takeSnapshot=true; % run TakeSnapshotWordLengthEffect, not TakeSnapshot

%% USE THESE ONLY FOR DEBUGGING!!
o.skipScreenCalibration=true; % Skip calibration to save time.
o.useFractionOfScreenToDebug=0.35; 

%% Interleave conditions with different word lengths.
oo=[o o o o];
oo(1).wordLength=3;
oo(2).wordLength=4;
oo(3).wordLength=5;
oo(4).wordLength=6;
oo=CriticalSpacing(oo); 

% Results are printed in MATLAB's Command Window and saved in the
% CriticalSpacing/data/ folder.