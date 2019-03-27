% MATLAB script to run CriticalSpacing.m
% Copyright 2019, Denis G. Pelli, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear o
% o.useFractionOfScreenToDebug=0.3;
% o.skipScreenCalibration=true; % Skip calibration to save time.
o.experiment='CrowdingSurvey';
o.experimenter='';
o.observer='';
o.viewingDistanceCm=100;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0]  lower right, [1 1] upper right.
o.durationSec=0.2; % duration of display of target and flankers
o.readAlphabetFromDisk=true;
ooo={};
for ecc=[0 2.5 5 10]
    o.conditionName='crowding';
    o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
    if ecc>0
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.fixationLineWeightDeg=0.03;
        o.fixationCrossDeg=1; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=false;
        o.flankingDirection='radial';
        o.viewingDistanceCm=50;
    else
        o.targetFont='Pelli';
        o.alphabet='123456789';
        o.borderLetter='$';
        o.fixationLineWeightDeg=0.01;
        o.fixationCrossDeg=40; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=true;
        o.flankingDirection='horizontal';
        o.viewingDistanceCm=200;
    end
    o.targetDeg=2;
    o.thresholdParameter='spacing';
    o2=o; % Copy the condition
    o2.eccentricityXYDeg=-o.eccentricityXYDeg;
    ooo{end+1}=[o o2];
end
for ecc=[0 5]
    o.conditionName='acuity';
    o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
    if ecc>0
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.fixationLineWeightDeg=0.03;
        o.fixationCrossDeg=1; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=false;
        o.flankingDirection='radial';
        o.viewingDistanceCm=100;
    else
        o.targetFont='Pelli';
        o.alphabet='123456789';
        o.borderLetter='$';
        o.fixationLineWeightDeg=0.01;
        o.fixationCrossDeg=40; % 0, 3, and inf are typical values.
        o.fixationCrossBlankedNearTarget=true;
        o.flankingDirection='horizontal';
        o.viewingDistanceCm=250;
    end
    o.targetDeg=4;
    o.thresholdParameter='size';
    o2=o; % Copy the condition
    o2.eccentricityXYDeg=-o.eccentricityXYDeg;
    ooo{end+1}=[o o2];
end

%% Number the blocks.
for i=1:length(ooo)
    for oi=1:length(ooo{i})
        ooo{i}(oi).block=i;
    end
end
ooo=Shuffle(ooo);

%% Print as a table. One row per threshold.
for i=1:length(ooo)
    if i==1
        oo=ooo{1};
    else
        try
        oo=[oo ooo{i}];
        catch e
            fprintf('Success with %d conditions in %d blocks, but failed on next block.\n',length(oo),max([oo.block]));
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'targetFont' 'observer' 'targetDeg' 'eccentricityXYDeg' 'viewingDistanceCm'})); 
% return

%% Run.
for i=1:length(ooo)
    if isempty(ooo{i}(1).experimenter) && i>1
        [ooo{i}.experimenter]=deal(ooo{i-1}(1).experimenter);
    end
    if isempty(ooo{i}(1).observer) && i>1
        [ooo{i}.observer]=deal(ooo{i-1}(1).experimenter);
    end
    [ooo{i}.isFirstBlock]=deal(i==1);
    [ooo{i}.isLastBlock]=deal(i==length(ooo));
    ooo{i}=CriticalSpacing(ooo{i});
    if any([ooo{i}.quitSession])
        break
    end
end