% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
% This script drives CriticalSpacing.m to measure four thresholds:
% threshold size (acuity) and critical spacing (of crowding), with single
% and repeated targets. The repeated targets have the virtue of being
% immune to eye movements. Pilot data indicate that normal adults (who
% presumably have good fixation) give practically the same thresholds with
% and without repeating of the target. We want to confirm that pilot result
% on more normals, and we want to discover the results in children and
% patient populations.
%
% A "run" is an uninterrupted series of trials, ending in threshold
% estimate(s). A presentation displays one or two targets, which require
% one or two responses. We count each response as a "trial".
%
% We use this parameter to test the observer with and without repeated
% targets. The repeated targets make the test immune to fixation errors,
% but we also want to test in the gold-standard condition, without
% repetition. Having both measures validates the new test in observers who
% fixate well. And assesses the effect of eye position errors in young
% children and patients.
% o.repeatedTargets=0; % 
o.repeatedTargets=1; % Repeating the target letters make the test immune to fixation errors.

% Selecting "spacing" measures the critical spacing of crowding. Selecting
% "size" measures letter acuity. We will test both, usually interleaved.
o.thresholdParameter='spacing';
% o.thresholdParameter='size';

% Each "trial" is one response. When testing with repeated targets, each
% presentation includes two targets, and demands two responses, so it
% counts as two trials. 40 trials per threshold gives a very accurate
% threshold estimate. 20 might be enough. Running this script measures 4
% thresholds, one for each of 4 conditions. That takes about 20 minutes
% when at 40 trials per threshold, and about 10 minutes at 20 trials per
% threshold.
o.trials=40; % Number of trials (i.e. responses) for the threshold estimate.

% The viewing distance is set here. The program will try to use what you
% selected, otherwise it will abort and tell you the minimum viewing
% distance that you need. You must then modify this file to set the new
% viewing distance. And, of course, move the screen to that distance.
o.viewingDistanceCm=410;

% This speaks an encouraging word after every trial, regardless of
% accuracy. I anticipate that young children will like this, whereas adults
% might not.
o.encouragement=0; % Randomly say good, very good, or nice after every trial.

% For normal adults we use the restricted standard Sloan alphabet
% (excluding C, which has been shown to be too similar to O).
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';

% For children, past investigators, including the Cambridge Crowding Cards,
% have used symmetric letters HOTVX, so we provide that option too.
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='N';

% You don't need to change any of these parameters.
o.useScreenCopyWindow=1; % Faster, but fails on some Macs. If your repeated-letters screen is incomplete, set this to 0.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.usePurring=1; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror to achieve a long viewing distance.
o.negativeFeedback=0;
o.fixationCrossDeg=0;
o.useFractionOfScreen=0;
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.task='identify';
minimumTargetPix=8; % Make sure the letters are well rendered.
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o.fixationLocation='center';
o.frameTheTarget=0; % For debugging.

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.
% FIRST RUN (measures two thresholds, interleaved)
o.repeatedTargets=1;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(2).thresholdParameter='size';
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
% oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely

% SECOND RUN (measures two thresholds, interleaved)
% We retain the observer name obtained during the first run for use in the
% second run.
o(1).repeatedTargets=0;
o(2).repeatedTargets=0;
o(1).observer=oRepeated(1).observer;
o(2).observer=oRepeated(2).observer;
% Test two conditions interleaved: 'spacing' and 'size', with single
% target.
oSingle=CriticalSpacing(o); % one target

% Results are printed in the command window and saved in the "data" folder
% within the folder that contains the CriticalSpacing.m program.

% Ignore spurious error messages from the Psychtoolbox about
% synchronization failure. The CriticalSpacing test uses static
% presentation and the reported timing errors are utterly irrelevant.
% "! PTB - ERROR: SYNCHRONIZATION FAILURE !"