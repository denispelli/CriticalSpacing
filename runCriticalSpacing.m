% MATLAB script to run CriticalSpacing.m
% Copyright 2015, Denis G. Pelli, denis.pelli@nyu.edu
clear o
% This script drives CriticalSpacing.m to measure four thresholds:
% threshold size (acuity) and critical spacing (of crowding), with single
% and repeated targets. The repeated targets have the virtue of being
% immune to eye movements. The first empirical question is to check that
% normal adults (who presumably have good fixation) give practically the
% same thresholds with and without repeating of the target.
%
% I don't know yet how many trials are needed. Note that each "trial"
% is one presentation. Thus testing repeated letters, there are two
% targets, and two responses per "trial". You'll probably want twice as
% many "trials" when testing with a single target. 40 responses per
% threshold
% gives a very accurate threshold estimate. 20 might be enough. Running
% this script measures 4 thresholds. That takes about 20 minutes when at 40
% trials per threshold, and about 10 minutes at 20 trials perthreshold.
% When there are two targets (repeatedTargets==1) we thus set trials=20.
o.trials=20; % Number of presentations (two response per presentation) for the threshold estimate.

% The viewing distance is set here. The program will try to use what you
% selected, otherwise it will abort and tell you the minimum viewing
% distance that you need. You must then modify this file to set the new
% viewing distance. And, of course, move the screen to that distance.
o.viewingDistanceCm=410;

% This enables an encouraging word after every trial, regardless of
% accuracy. I anticipate that young children will like this, whereas adults
% might not.
o.encouragement=0; % Randomly say good, very good, or nice after every trial.

% We use this parameter a lot to test observer with and without repeated
% targets. The repeated targets make the test immune to fixation errors,
% but we also want to test in the gold-standard condition without
% repetition in order to validate (in observers who fixate well) or assess
% the effect of eye position errors in young children and patients.
o.repeatedTargets=1; % Repeated letter make the test immune to fixation errors.

% Selecting "spacing" measures the critical spacing of crowding. Selecting
% "size" measures letter acuity. We will test both, usually interleaved.
o.thresholdParameter='spacing';
% o.thresholdParameter='size';

% You don't need to change any of these parameters.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.usePurring=1; % Play purring sound while awaiting user response.
% o.radialOrTangential='tangential'; % vertically arranged flankers for single target
o.radialOrTangential='radial'; % horizontally arranged flankers for single target
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror to achieve a long viewing distance.
o.useScreenCopyWindow=1; % Faster, but fails on some Macs. If your repeated-letters screen is incomplete, set this to 0.
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
o.frameTheTarget=0; % Handy for debugging the display.

% Set up for interleaved testing of size and spacing thresholds. In the
% first run we'll use repeated targets. In the second run we'll use single
% targets.
o.repeatedTargets=1;
o.thresholdParameter='spacing';
o(2)=o(1); % Copy the condition
o(2).thresholdParameter='size';
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely
% We retain the observer name obtained during the first run for use in the
% second run.
o(1).repeatedTargets=0;
o(2).repeatedTargets=0;
o(1).trials=2*o(1).trials(1); % doubled because just one response per trial
o(2).trials=o(1).trials;
o(1).observer=oRepeated(1).observer;
o(2).observer=oRepeated(2).observer;
% Test two conditions interleaved: 'spacing' and 'size', with single
% target.
oSingle=CriticalSpacing(o); % one target

% Results are printed in the command window and saved in the "data" folder.