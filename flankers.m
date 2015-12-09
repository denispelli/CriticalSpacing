% This shows a triplet, a target and two flankers.
clear o
% o.observer='Shivam'; % Enter observer name here.
o.repeatedTargets=0;
%o.fixationCrossDeg=0;
%o.useScreenCopyWindow=1; % Faster, but doesn't work on all Macs.
o.thresholdParameter='spacing';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.durationSec=inf; % duration of display of target and flankers
o.trials=20; % number of presentations (two response per presentation) for the threshold estimate
oOut=CriticalSpacing(o); % dual targets, repeated indefinitely


% This shows a screen full of letters. They are all one of two letters,
% both are targets.
clear o
% o.observer='Shivam'; % Enter observer name here.
o.repeatedTargets=1;
%o.fixationCrossDeg=0;
%o.useScreenCopyWindow=1; % Faster, but doesn't work on all Macs.
o.thresholdParameter='spacing';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
o.durationSec=inf; % duration of display of target and flankers
o.trials=20; % number of presentations (two response per presentation) for the threshold estimate
oOut=CriticalSpacing(o); % dual targets, repeated indefinitely
