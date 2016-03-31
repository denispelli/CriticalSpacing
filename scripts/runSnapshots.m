% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
if 0
   % FOR CHILDREN
   o.showProgressBar=1;
   o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
   o.speakEncouragement=1; % 1 to say "good," "very good," or "nice" after every trial.
   o.speakEachLetter=1;
else
   % FOR ADULTS
   o.showProgressBar=1;
   o.fractionEasyTrials=0; % Add 20% extra easy trials. 0 for none.
   o.speakEncouragement=0; % 1 to say "good," "very good," or "nice" after every trial.
   o.speakEachLetter=1;
end
o.setTargetHeightOverWidth=0;
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.useSpeech=1;
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0;

% You don't need to change any of these parameters.
o.targetSizeIsHeight=0;
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.readAlphabetFromDisk=1; % 1 makes the program more portable.
o.usePurring=0; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.negativeFeedback=0;
o.fixationCrossDeg=0;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.textFont='Calibri';
o.fixationLocation='center';
o.task='identify';
o.minimumTargetPix=8; % Make sure the letters are well rendered.
% o.targetFont='Sloan';
% o.targetFont='ClearviewText';
% o.targetFont='Gotham Cond SSm XLight';
% o.targetFont='Gotham Cond SSm Light';
% o.targetFont='Gotham Cond SSm Medium';
% o.targetFont='Gotham Cond SSm Book';
% o.targetFont='Gotham Cond SSm Bold';
% o.targetFont='Gotham Cond SSm Black';
% o.targetFont='Arouet';
% o.targetFont='Retina Micro';
% o.targetFont='Calibri';

o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';
o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};

% DEBUGGING AIDS
o.displayAlphabet=0; 
o.showLineOfLetters=0;
o.showBounds=0;
o.frameTheTarget=0; 
o.printSizeAndSpacing=1;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0; 

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.

o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o.trials=4; % Number of trials (i.e. responses) for the threshold estimate.

o.takeSnapshot=1;
o.viewingDistanceCm=200;
o.repeatedTargets=0;
o.fourFlankers=0;
o.thresholdParameter='spacing';
o=CriticalSpacing(o); % dual targets, repeated indefinitely
% o.repeatedTargets=0;
% o.thresholdParameter='spacing';
% o=CriticalSpacing(o); % dual targets, repeated indefinitely
% 
% o.viewingDistanceCm=600;
o.repeatedTargets=1; % Repeat targets for immunity to fixation errors.
o.maxFixationErrorXYDeg=[3 3]; % Repeat enough to cope with this.
o.practicePresentations=3;
% o.thresholdParameter='size';
% o=CriticalSpacing(o); % dual targets, repeated indefinitely
% o.repeatedTargets=0;
% o.thresholdParameter='size';
% o=CriticalSpacing(o); % dual targets, repeated indefinitely

