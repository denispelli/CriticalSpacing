% MATLAB script to run CriticalSpacing.m
% Copyright 2016, Denis G. Pelli, denis.pelli@nyu.edu
% runPelliAndSloan.m script to drive CriticalSpacing.m. Use the flag
% o.isChild to indicate whether you are testing a child. On a child, the
% script measures 3 thresholds in one run. On a adult, it measures 12
% thresholds distributed over 5 runs. This will produce a beautiful graph
% for the paper.
clear o
o.isChild=0;

if o(1).isChild
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
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=400;
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

% DEBUGGING AIDS
o.displayAlphabet=0; 
o.showLineOfLetters=0;
o.showBounds=0;
o.frameTheTarget=0; 
o.printSizeAndSpacing=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0; 

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.

if ~o(1).isChild
   % FIRST RUN (measures two thresholds, interleaved) Sloan size
   o=o(1);
   o.fixedSpacingOverSize=1.5; % Requests size proportional to spacing.
   o.targetFont='Sloan';
   o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
   o.borderLetter='X';
   o.validKeys={'D','H','K','N','O','R','S','V','Z'};
   o.repeatedTargets=0;
   o.thresholdParameter='size';
   o(2)=o(1); % Copy the condition
   o=CriticalSpacing(o); % dual targets, repeated indefinitely
end

% SECOND RUN (measures 3 thresholds, interleaved) repeated Pelli spacing
o=o(1);
o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';
o.validKeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
o.repeatedTargets=1; % Repeat targets for immunity to fixation errors.
o.maxFixationErrorXYDeg=[3 3]; % Repeat enough to cope with this.
o.practicePresentations=3;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(3)=o(1); % Copy the condition
o(1).fixedSpacingOverSize=1.2; % Requests size proportional to spacing.
o(2).fixedSpacingOverSize=1.5; % Requests size proportional to spacing.
o(3).fixedSpacingOverSize=1.8; % Requests size proportional to spacing.
o=CriticalSpacing(o); % dual targets, repeated indefinitely

if ~o(1).isChild
   % THIRD RUN (measures 3 thresholds, interleaved) repeated Pelli size
   o=o(1);
   o.repeatedTargets=1;
   o.thresholdParameter='size';
   o(2)=o(1); % Copy the condition
   o(3)=o(1); % Copy the condition
   o(1).fixedSpacingOverSize=1.2; % Requests size proportional to spacing.
   o(2).fixedSpacingOverSize=1.5; % Requests size proportional to spacing.
   o(3).fixedSpacingOverSize=1.8; % Requests size proportional to spacing.
   o=CriticalSpacing(o); % dual targets, repeated indefinitely
   
   % 4TH RUN (measures 3 thresholds, interleaved) single Pelli spacing
   o=o(1);
   o.repeatedTargets=0;
   o.thresholdParameter='spacing';
   o(2)=o(1); % Copy the condition
   o(3)=o(1); % Copy the condition
   o(1).fixedSpacingOverSize=1.2; % Requests size proportional to spacing.
   o(2).fixedSpacingOverSize=1.5; % Requests size proportional to spacing.
   o(3).fixedSpacingOverSize=1.8; % Requests size proportional to spacing.
   o=CriticalSpacing(o); % dual targets, repeated indefinitely
   
   % 5TH RUN (measures 1 threshold) single Pelli size
   o=o(1);
   o.repeatedTargets=0;
   o.thresholdParameter='size';
   o=CriticalSpacing(o); % dual targets, repeated indefinitely
end

% Results are printed in the command window and saved in the "data" folder
% within the folder that contains the CriticalSpacing.m program.
