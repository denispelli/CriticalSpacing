% MATLAB script to run CriticalSpacing.m
% Copyright 2019, Denis G. Pelli, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear o
% o.useFractionOfScreenToDebug=0.3;
% o.skipScreenCalibration=true; % Skip calibration to save time.
% o.printSizeAndSpacing=true;
o.experiment='Reading';
o.experimenter='';
o.observer='';
o.viewingDistanceCm=100;
o.useSpeech=false;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
o.durationSec=0.15; % duration of display of target and flankers
o.getAlphabetFromDisk=true;
o.trials=40;
o.readSpacingDeg=nan;
o.spacingDeg=nan;
o.fixationLineWeightDeg=0.03;
o.fixationCrossDeg=3;
o.fixationCrossBlankedNearTarget=false;
o.brightnessSetting=0.87; % Half luminance. Some observers find 1.0 painfully bright.
ooo={};

if 1
    o.conditionName='reading';
    o.task='read';
    o.thresholdParameter='spacing';
    o.targetFont='Monaco';
    o.targetDeg=nan;
    o.getAlphabetFromDisk=false;
    o.trials=2;
    o.minimumTargetPix=8;
    o.eccentricityXYDeg=[0 0];
    % The reading test fills a 15" MacBook Pro screen with 1 deg letters at
    % 50 cm. Larger letters require proportionally smaller viewing
    % distance.
    o.viewingDistanceCm=25;
    o.alphabet='abc';
    o.borderLetter='x';
    o.flankingDirection='horizontal';
    o.useFixation=false;
    o.readSpacingDeg=2;
    ooo{end+1}=o;
    o.readSpacingDeg=1;
    ooo{end+1}=o;
    o.viewingDistanceCm=100;
    o.readSpacingDeg=0.5;
    ooo{end+1}=o;
    o.readSpacingDeg=0.25;
    ooo{end+1}=o;
end
if 1
    for ecc=[ 2.5 ]
        o.conditionName='crowding';
        o.task='identify';
        o.trials=40;
        o.targetDeg=2;
        o.spacingDeg=2;
        o.thresholdParameter='spacing';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Sloan';
        o.getAlphabetFromDisk=true;
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.minimumTargetPix=8;
        o.fixationLineWeightDeg=0.03;
        o.fixationCrossDeg=1; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=false;
        o.flankingDirection='radial';
        o.viewingDistanceCm=100;
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        ooo{end+1}=[o o2];
    end
end
if 1
    for ecc=[0 5]
        o.conditionName='acuity';
        o.targetDeg=4;
        o.thresholdParameter='size';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Sloan';
        o.getAlphabetFromDisk=true;
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        if ecc>0
            o.fixationLineWeightDeg=0.03;
            o.fixationCrossDeg=1; % 0, 3, and inf are typical values.
            o.fixationCrossBlankedNearTarget=false;
            o.flankingDirection='radial';
            o.viewingDistanceCm=100;
        else
            o.fixationLineWeightDeg=0.02;
            o.fixationCrossDeg=inf; % 0, 3, and inf are typical values.
            o.fixationCrossBlankedNearTarget=true;
            o.flankingDirection='horizontal';
            o.viewingDistanceCm=100;
        end
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        ooo{end+1}=[o o2];
    end
end
if 1
    for ecc=0
        o.conditionName='crowding';
        o.targetDeg=2;
        o.spacingDeg=2;
        o.thresholdParameter='spacing';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Pelli';
        o.getAlphabetFromDisk=true;
        o.alphabet='123456789';
        o.borderLetter='$';
        o.minimumTargetPix=4;
        o.fixationLineWeightDeg=0.02;
        o.fixationCrossDeg=40; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=true;
        o.flankingDirection='horizontal';
        o.viewingDistanceCm=250;
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        ooo{end+1}=[o o2];
    end
end
if rand>0.5
%     ooo=fliplr(ooo);
end

%% Number the blocks.
for i=1:length(ooo)
    for oi=1:length(ooo{i})
        ooo{i}(oi).block=i;
        ooo{i}(oi).blocksDesired=length(ooo);
    end
end
% ooo=Shuffle(ooo);

%% Print as a table. One row per threshold.
for i=1:length(ooo)
    if i==1
        oo=ooo{1};
    else
        try
            oo=[oo ooo{i}];
        catch e
            fprintf('Success with %d conditions in %d blocks, but failed on next block.\n',...
                length(oo),max([oo.block]));
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'trials' 'targetFont' 'observer' ...
    'targetDeg' 'readSpacingDeg' 'eccentricityXYDeg' 'viewingDistanceCm'}));
trials=sum([oo.trials]);
fprintf('Total of %d trials, which may take about %.0f minutes. But reading trials take longer.\n',trials,trials/10);
% return

%% Run.
for i=1:length(ooo)
    if isempty(ooo{i}(1).experimenter) && i>1
        [ooo{i}.experimenter]=deal(ooo{i-1}(1).experimenter);
    end
    if isempty(ooo{i}(1).observer) && i>1
        [ooo{i}.observer]=deal(ooo{i-1}(1).observer);
    end
    [ooo{i}.isFirstBlock]=deal(i==1);
    [ooo{i}.isLastBlock]=deal(i==length(ooo));
    ooo{i}=CriticalSpacing(ooo{i});
    if any([ooo{i}.quitExperiment])
        break
    end
end
