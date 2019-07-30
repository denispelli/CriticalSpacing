% MATLAB script to run CriticalSpacing.m
% Copyright 2019, Denis G. Pelli, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear o ooo
% o.useFractionOfScreenToDebug=0.3; %% ONLY FOR DEBUGGING
% o.skipScreenCalibration=true; %% ONLY FOR DEBUGGING
% o.printSizeAndSpacing=true;
o.experiment='Reading';
o.experimenter='';
o.observer='';
o.viewingDistanceCm=100;
o.useSpeech=false;
o.speakViewingDistance=false;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
o.durationSec=0.15; % duration of display of target and flankers
o.getAlphabetFromDisk=true;
o.trialsDesired=40;
o.readSpacingDeg=nan;
o.spacingDeg=nan;
o.fixationLineWeightDeg=0.03;
o.fixationCrossDeg=3;
o.fixationCrossBlankedNearTarget=false;
o.brightnessSetting=0.87; % Half luminance. Some observers find 1.0 painfully bright.
o.readLines=12;
o.readCharsPerLine=50;
o.screen=0;
ooo={};

if 1
    o.conditionName='reading';
    o.task='read';
    o.thresholdParameter='spacing';
    o.targetFont='Monaco';
    o.targetDeg=nan;
    o.getAlphabetFromDisk=false;
    o.trialsDesired=2;
    o.minimumTargetPix=8;
    o.eccentricityXYDeg=[0 0];
    % The reading test fills a 15" MacBook Pro screen with 1 deg letters at
    % 50 cm. Larger letters require proportionally smaller viewing
    % distance.
    o.viewingDistanceCm=18;
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
        o.trialsDesired=40;
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

% Adjust viewing distance so text fits on screen.
for block=1:length(ooo)
    for oi=1:length(ooo{block})
        o=ooo{block}(oi);
        switch o.task
            case 'read'
                o.readLines=12;
                o.readCharsPerLine=50;
                o.screen=0;
                maxViewingDistanceCm=MaxViewingDistanceCmForReading(o);
                if o.viewingDistanceCm>maxViewingDistanceCm
                    fprintf('Block %f. Reducing viewing distance from %.0f to %.0f cm.\n',...
                        block,o.viewingDistanceCm,maxViewingDistanceCm);
                    o.viewingDistanceCm=maxViewingDistanceCm;
                end
                ooo{block}(oi)=o;
        end
    end
end

%% Number the blocks.
for block=1:length(ooo)
    for oi=1:length(ooo{block})
        ooo{block}(oi).block=block;
        ooo{block}(oi).blocksDesired=length(ooo);
    end
end
% ooo=Shuffle(ooo);

%% Print as a table. One row per threshold.
for block=1:length(ooo)
    if block==1
        oo=ooo{1};
    else
        try
            oo=[oo ooo{block}];
        catch e
            fprintf('Success with %d conditions in %d blocks, but failed on next block.\n',...
                length(oo),max([oo.block]));
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'trialsDesired' 'targetFont'  ...
    'readSpacingDeg' 'eccentricityXYDeg' 'viewingDistanceCm'}));
trials=sum([oo.trialsDesired]);
fprintf('Total of %d trials, which may take about %.0f minutes. But reading trials take longer.\n',trials,trials/10);
return

%% Run.
for block=1:length(ooo)
    if isempty(ooo{block}(1).experimenter) && block>1
        [ooo{block}.experimenter]=deal(ooo{block-1}(1).experimenter);
    end
    if isempty(ooo{block}(1).observer) && block>1
        [ooo{block}.observer]=deal(ooo{block-1}(1).observer);
    end
    [ooo{block}.isFirstBlock]=deal(block==1);
    [ooo{block}.isLastBlock]=deal(block==length(ooo));
    ooo{block}=CriticalSpacing(ooo{block});
    if any([ooo{block}.quitExperiment])
        break
    end
end
