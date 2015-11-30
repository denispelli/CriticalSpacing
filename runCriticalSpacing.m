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
% many "trials" when testing with a single target. I think 40 responses
% will give an accurate threshold estimate. Perhaps 20 would be enough.
% When there are two targets (repeatedLetters==1) we thus set trials=20.
o.trials=20; % Number of presentations (two response per presentation) for the threshold estimate.

% The viewing distance is set here. The program will try to use what you
% selected, otherwise it will abort and tell you the minimum viewing
% distance that you need. You must then modify this file to set the new
% viewing distance. And, of course, move the screen to that distance.
o.viewingDistanceCm=300;

% This parameter is important. We need to assure our readers that the
% reported spacing threshold is independent of this value. I'd guess that
% this is true for the range 1.2 to 2. But large values will prevent us
% from measuring critical spacing that is not much bigger than acuity. We
% need a graph of measured critical spacing vs. this scalar at values 1.2,
% 1.4, 1.6, inf. We already have inf from the single-target size test.
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.

% You probably won't need to change any other parameters.
o.repeatedLetters=1; % Repeated letter make the test immune to fixation errors.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror to achieve a long viewing distance.
o.observer=''; % Ask for name at beginning of run, or
% o.observer='Shivam'; % enter observer name here.
o.useScreenCopyWindow=1; % Faster, but fails on some Macs. If your repeated-letters screen is incomplete, set this to 0.
o.negativeFeedback=0;
o.encouragement=1; % Randomly say good, very good, or nice after every trial.
o.fixationCrossDeg=0;
o.useFractionOfScreen=0;
o.thresholdParameter='spacing';
o.durationSec=inf; % duration of display of target and flankers
o.measureBeta=0;
o.task='identify';
o.usePurring=1;
minimumTargetPix=8; % Make sure the letters are well rendered.
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o.fixationLocation='center';
o(2)=o(1);
o(2).thresholdParameter='size';
% Test two conditions interleaved: 'spacing' and 'size', with repeated
% letters.
oRepeated=CriticalSpacing(o); % dual targets, repeated indefinitely
% We retain the observer name obtained during the first run for use in the
% second run.
o(1).trials=2*o(1).trials;
o(2).trials=2*o(2).trials;
o(1).repeatedLetters=0;
o(2).repeatedLetters=0;
o(1).observer=oRepeated(1).observer;
o(2).observer=oRepeated(2).observer;
% Test two conditions interleaved: 'spacing' and 'size', with single
% target.
oSingle=CriticalSpacing(o); % one target
