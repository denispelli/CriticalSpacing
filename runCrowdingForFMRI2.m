% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016,2017,2018 Denis G. Pelli, denis.pelli@nyu.edu

% July 17, 2018 Minor edit to reuse observer name from previous block.
% July 25, 2018 Use 'horizontal' at ecc [0 0].
% July 30, 2018 Remove boilerplate. To see the default values, try printing
%				 "o" or looking at early part of NoiseDiscrimination2.m.
% Novermber 29, 2018, Correct test sites to match Jing's data.
%% PREPARE THE CONDITIONS
% Crowding distance at 25 combinations of location and orientation:
% * (12 thresholds). Horizontal meridian: 6 ecc. (ﾱ2.5, ﾱ5, ﾱ10 deg) X 2 orientations (0, 90 deg)
% * (8 thresholds). At 5 deg ecc: 4 obliques (45, 135, 225, 315 deg) X 2 orientations
% * (4 thresholds) Vertical meridian: +/-5 deg ecc X 2 orientations
% * (0 threshold) Fovea: Horizontal crowding distance X 1 orientation.
% * (1 threshold) Fovea: Sloan acuity.
clear o oo
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.isolatedTarget=false;
o.flankingDirection='radial';
o.conditionName='crowding';
o.fixationLineWeightDeg=0.04;
o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
o.eccentricityXYDeg=[0 0];
o.isFirstBlock=false;
o.isLastBlock=false;
oo=o; % Include all the fields that we need.
oo(1)=[]; % oo is now empty with the fields that we need.

for ecc=[-10 -5 -2.5 2.5 5 10]
    for rep=1:2
        for radial=0:1
            o.eccentricityXYDeg=[ecc 0];
            if radial
                o.flankingDirection='radial';
            else
                o.flankingDirection='tangential';
            end
            oo(end+1)=o;
        end
    end
end

% * (8 thresholds). At 5 deg ecc: 4 obliques (45, 135, 225, 315 deg) X 2 orientations
for meridianDeg=45:90:315
    for rep=1:2
        for radial=0:1
            o.eccentricityXYDeg=5*[sind(meridianDeg) cosd(meridianDeg)];
            if radial
                o.flankingDirection='radial';
            else
                o.flankingDirection='tangential';
            end
            oo(end+1)=o;
        end
    end
end

% * (4 thresholds) Vertical meridian: +/-5 deg ecc X 2 orientations
for ecc=[-5 5]
    for rep=1:2
        for radial=0:1
            o.eccentricityXYDeg=[0 ecc];
            if radial
                o.flankingDirection='radial';
            else
                o.flankingDirection='tangential';
            end
            oo(end+1)=o;
        end
    end
end

if 0
    % * (1 threshold) Fovea: Horizontal crowding distance X 1 orientation.
    o.targetFont='Pelli';
    o.alphabet='123456789';
    o.borderLetter='$';
    o.thresholdParameter='spacing'; % 'spacing' or 'size'
    o.fixationLineWeightDeg=0.02;
    o.fixationCrossDeg=inf; % 0, 3, and inf are typical values.
    for rep=1:2
        o.eccentricityXYDeg=[0 0];
        o.flankingDirection='horizontal';
        oo(end+1)=o;
    end
end

% * (1 threshold) Fovea: Sloan acuity.
o.conditionName='acuity';
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.thresholdParameter='size'; % 'spacing' or 'size'
o.flankingDirection='horizontal'; % Required, even though no flankers.
o.isolatedTarget=true; % May not be necessary.
o.fixationLineWeightDeg=0.02;
o.fixationCrossDeg=inf; % 0, 3, and inf are typical values.
for rep=1:2
    o.eccentricityXYDeg=[0 0];
    oo(end+1)=o;
end

%% NUMBER THE CONDITIONS, ONE PER ROW.
for i=1:length(oo)
    radialDeg=sqrt(sum(oo(i).eccentricityXYDeg.^2));
    oo(i).viewingDistanceCm=max(30,min(400,round(9/tand(radialDeg))));
    oo(i).condition=i;
end
oo(1).isFirstBlock=true;
oo(end).isLastBlock=true;

%% PRINT TABLE OF CONDITIONS.
t=struct2table(oo);
disp(t(:,{'condition','thresholdParameter','eccentricityXYDeg','flankingDirection','viewingDistanceCm','targetFont'}));

%% RUN THE EXPERIMENT
oOld.observer='';
for i=1:length(oo)
    o=oo(i);
    % o.useFractionOfScreenToDebug=0.5;
    o.trials=30;
    o.practicePresentations=0;
    o.experimenter='Darshan';
    o.observer=oOld.observer;
    o.durationSec=0.2; % duration of display of target and flankers
    o.repeatedTargets=0;
    o=CriticalSpacing(o);
    if ~o.quitBlock
        fprintf('Finished condition %d.\n',i);
    end
    if o.quitSession
        break
    end
    oOld=o;
end
