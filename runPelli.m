% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016, Denis G. Pelli, denis.pelli@nyu.edu
clear o

% PROCEDURE
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.readAlphabetFromDisk=1; % 1 makes the program more portable.
o.viewingDistanceCm=400;
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this & pixPerCm.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.measureThresholdVertically=0;
o.textFont='Calibri';
o.showProgressBar=1;

% SOUND
o.speakEachLetter=1;
o.useSpeech=1;
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0; % Play purring sound while awaiting user response.

% TASK
o.task='identify';

% VISUAL STIMULUS
o.durationSec=inf; % duration of display of target and flankers
o.repeatedTargets=1;
o.fourFlankers=1;
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o.setTargetHeightOverWidth=0;
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';

% FIXATION
o.fixationCrossDeg=0;
o.fixationLocation='center';

% QUEST
o.measureBeta=0;

% DEBUGGING AIDS
o.showAlphabet=0; 
o.showLineOfLetters=0;
o.showBounds=0;
o.frameTheTarget=0; 
o.printSizeAndSpacing=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0; 

if 0
   % FOR CHILDREN
   o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
   o.speakEncouragement=1; % 1 to say "good," "very good," or "nice" after every trial.
else
   % FOR ADULTS
   o.fractionEasyTrials=0; % Add 20% extra easy trials. 0 for none.
   o.speakEncouragement=0; % 1 to say "good," "very good," or "nice" after every trial.
end

% FIRST RUN (measure two thresholds, interleaved)
o(2)=o(1); % Copy the condition
o=CriticalSpacing(o); 

% SECOND RUN (measure two thresholds, interleaved)
o=o(1);
o(1).repeatedTargets=1;
o(2)=o(1);
o=CriticalSpacing(o); 

% Results are printed in the command window and saved in the "data" folder
% within the folder that contains the CriticalSpacing.m program.
