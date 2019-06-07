% MATLAB script to run CriticalSpacing.m
% Copyright 2019, Denis G. Pelli, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear all
clear o
% o.useFractionOfScreenToDebug=0.4;
% o.skipScreenCalibration=true; % Skip calibration to save time.
% o.printSizeAndSpacing=true;
o.experiment='CrowdingSurvey';
o.experimenter='';
o.observer='';
o.showProgressBar=false;
o.viewingDistanceCm=100;
o.useSpeech=false;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
% For 2018-April 2019 this was nominally 200 ms, but actually delivered 280
% ms when tested in April. I've now improved the code to more accurately
% deliver the requested duration, and reduced the request to 150 m.
o.durationSec=0.150; % duration of display of target and flankers
o.getAlphabetFromDisk=true;
o.trialsDesired=40;
o.brightnessSetting=0.87; % Roughly half luminance. Some observers find 1.0 painfully bright.
% o.takeSnapshot=true; % To illustrate your talk or paper.
o.fixationTest=false;
o.flankingDirection='radial';
o.fixationCrossBlankedUntilSecsAfterTarget=0;
ooo={};

if 0
    o.conditionName='reading';
    o.task='read';
    o.thresholdParameter='spacing';
    o.targetFont='Monaco';
    o.getAlphabetFromDisk=false;
    o.targetDeg=nan;
    o.trialsDesired=40;
    o.minimumTargetPix=8;
    o.eccentricityXYDeg=[0 0];
    % The reading test fills a 15" MacBook Pro screen with 1 deg letters at
    % 50 cm. Larger letters require proportionally smaller viewing
    % distance.
    o.viewingDistanceCm=25;
    o.readSpacingDeg=2;
    o.alphabet='abc';
    o.borderLetter='x';
    o.flankingDirection='horizontal';
    o.experimenter='...';
    o.observer='...';
    o.useFixation=false;
    ooo{end+1}=o;
end
for ecc=[10 5 2.5]
    o.conditionName='crowding';
    o.targetDeg=2;
    o.spacingDeg=2;
    o.thresholdParameter='spacing';
    o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
    o.targetFont='Sloan';
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
    o.minimumTargetPix=8;
    o.fixationLineWeightDeg=0.03;
    o.fixationCrossDeg=1; % 0, 3, and inf are typical values.
    o.fixationCrossBlankedNearTarget=false;
    o.flankingDirection='radial';
    o.viewingDistanceCm=50;
    o2=o; % Copy the condition
    o2.eccentricityXYDeg=-o.eccentricityXYDeg;
    oo=[o o2];
    if abs(oo(1).eccentricityXYDeg(2))>=10
        oo(1).viewingDistanceCm=25;
        oo(2).viewingDistanceCm=25;
    else
        oo(1).viewingDistanceCm=50;
        oo(2).viewingDistanceCm=50;
    end
    ooo{end+1}=oo;
    % Flip x and y, so we go from horizontal to vertical meridian.
    oo(1).eccentricityXYDeg=flip(oo(1).eccentricityXYDeg);
    oo(2).eccentricityXYDeg=flip(oo(2).eccentricityXYDeg);
    if abs(oo(1).eccentricityXYDeg(2))>=10
        oo(1).viewingDistanceCm=25;
        oo(2).viewingDistanceCm=25;
    else
        oo(1).viewingDistanceCm=50;
        oo(2).viewingDistanceCm=50;
    end
    ooo{end+1}=oo;
    if ecc==5
        ooPelli=oo;
        ooPelli(1).targetFont='Pelli';
        ooPelli(2).targetFont='Pelli';
        ooPelli(1).alphabet='123456789';
        ooPelli(2).alphabet='123456789';
        ooPelli(1).borderLetter='$';
        ooPelli(2).borderLetter='$';
        ooo{end+1}=ooPelli;
    end
end
if 1
    for ecc=[0 5]
        o.conditionName='acuity';
        o.targetDeg=4;
        o.thresholdParameter='size';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Sloan';
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
for ecc=0
    o.conditionName='crowding';
    o.targetDeg=2;
    o.spacingDeg=2;
    o.thresholdParameter='spacing';
    o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
    o.targetFont='Pelli';
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
for block=1:length(ooo)
    oo=ooo{block};
    if all([oo.eccentricityXYDeg]==0)
        continue
    else
        o=oo(1);
        o.conditionName='Fixation test';
        o.fixationTest=true;
        o.fixationCrossBlankedUntilSecsAfterTarget=0.5;
        o.eccentricityXYDeg=[0 0];
        o.thresholdParameter='spacing';
        o.flankingDirection='horizontal';
        o.targetDeg=0.4;
        o.spacingDeg=1.4*o.targetDeg;
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        oo(end+1)=o;
        ooo{block}=oo;
    end
end

if rand>0.5
    %         ooo=fliplr(ooo);
end

%% Number the blocks.
for block=1:length(ooo)
    for oi=1:length(ooo{block})
        ooo{block}(oi).block=block;
        ooo{block}(oi).blocksDesired=length(ooo);
    end
end
% ooo=Shuffle(ooo);

% COMPUTE MAX VIEWING DISTANCE IN REMAINING BLOCKS
maxCm=0;
for block=length(ooo):-1:1
    maxCm=max([maxCm ooo{block}(1).viewingDistanceCm]);
    ooo{block}(1).maxViewingDistanceCm=maxCm;
end

%% Print as a table. One row per threshold.
for block=1:length(ooo)
    if block==1
        oo=ooo{1};
    else
        try
            oo=[oo ooo{block}];
        catch e
            fprintf('Success building table with %d conditions in %d blocks, but failed on next block.\n',...
                length(oo),max([oo.block]));
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'experiment' 'conditionName' 'fixationCrossBlankedUntilSecsAfterTarget' 'targetFont' 'eccentricityXYDeg' 'flankingDirection' 'viewingDistanceCm' 'maxViewingDistanceCm' 'trialsDesired'}));
fprintf('Total of %d trialsDesired should take about %.0f minutes to run.\n',...
    sum([oo.trialsDesired]),sum([oo.trialsDesired])/10);
% return

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
