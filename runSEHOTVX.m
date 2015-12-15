% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
% This script drives CriticalSpacing.m
o.repeatedTargets=1; % Repeating the target letters make the test immune to fixation errors.
o.thresholdParameter='spacing';
o.trials=40; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=500;
o.encouragement=0; % Randomly say good, very good, or nice after every trial.

% You don't need to change any of these parameters.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.usePurring=0; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror to achieve a long viewing distance.
o.negativeFeedback=0;
o.fixationCrossDeg=0;
o.useFractionOfScreen=0;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.task='identify';
minimumTargetPix=8; % Make sure the letters are well rendered.
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
% o.alphabet='HTOXV'; % to test children
o.targetFont='Sloan';
o.textFont='Calibri';
o.fixationLocation='center';
o.frameTheTarget=0; % For debugging.

o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
o.borderLetter='N';

% Set up for interleaved testing of size and spacing thresholds with
% repeated targets. Each run has a different number of trials: 10, 20, 40,
% 80. If you have only 1 hour, omit the 80-trials condition.
o.repeatedTargets=1;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(2).thresholdParameter='size';
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
for run=1:4
    for trials=[10 20 40]
        for i=1:2
            o(i).trials=trials;
        end
        o=CriticalSpacing(o);
    end
end

% Results are printed in the command window and saved in the "data" folder
% within the folder that contains the CriticalSpacing.m program.