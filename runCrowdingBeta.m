% runCrowdingBeta.m
% MATLAB script to run CriticalSpacing.m
% Copyright 2019,2020, denis.pelli@nyu.edu
% denis.pelli@nyu.edu
% February 2020
% 646-258-7524

%% DEFINE CONDITIONS
clear KbWait o oo ooo
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib')); % Folder in same directory as this M file.
addpath(fullfile(mainFolder,'utilities')); % Folder in same directory as this M file.
clear KbWait o oo 
ooo={};
o.askForPartingComments=false;
% o.useFractionOfScreenToDebug=0.4; o.skipScreenCalibration=true; % Skip calibration to save time.
o.procedure='Constant stimuli';
o.simulateObserver=false;
if o.simulateObserver
    o.dontWait=1;
    o.trialsDesired=800;
    o.beta=3;
    o.delta=0.02;
else
    o.trialsDesired=400;
end
% o.printSizeAndSpacing=true;
o.experiment='CrowdingBeta';
o.permissionToChangeResolution=true;
o.fixationOffsetBeforeTargetOnsetSecs=0.5;
o.fixationOnsetAfterTargetOffsetSecs=0.5;
o.experimenter='';
o.observer='';
o.showProgressBar=false;
o.useSpeech=false;
o.viewingDistanceCm=100;
o.setNearPointEccentricityTo='fixation';
% Location on screen. [0 0] is lower left. [1 1] is upper right.
o.nearPointXYInUnitSquare=[0.5 0.5]; 
% From 2018 until April 2019 this was nominally 200 ms, but actually
% delivered 280 ms when tested in April. I've now improved the code to more
% accurately deliver the requested duration, and reduced the request to 150
% m.
o.durationSec=0.150; % duration of display of target and flankers
o.getAlphabetFromDisk=false;
% Roughly half luminance. Some observers find 1.0 painfully bright.
o.brightnessSetting=0.87; 
% o.takeSnapshot=true; % To illustrate your talk or paper.
o.fixationCheck=false;
o.flankingDirection='radial';
o.spacingGuessDeg=nan;
o.targetGuessDeg=nan;
o.fixedSpacingOverSize=1.4;
o.spacingDeg=[];
o.fixationThicknessDeg=0.02;
o.fixationMarkDeg=inf;
o.isFixationBlankedNearTarget=true;
o.procedure='Constant stimuli';

ooo={};

%% MEASURE RADIAL CROWDING
if true
    for ecc= 5 %[5 2.5]
        o.conditionName='crowding';
        o.task='identify';
        o.useFixation=true;
        o.targetDeg=2;
        o.spacingDeg=2;
        o.thresholdParameter='spacing';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.minimumTargetPix=8;
        o.fixationThicknessDeg=0.03;
        o.fixationMarkDeg=1; % 0, 3, and inf are typical values.
        o.isFixationBlankedNearTarget=false;
        o.flankingDirection='radial';
        o.viewingDistanceCm=40;
        % Mirror the condition to negative eccentricity.
        o2=o; 
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        oo=[o o2];
        if abs(oo(1).eccentricityXYDeg(2))>=10
            oo(1).viewingDistanceCm=25;
            oo(2).viewingDistanceCm=25;
        else
            oo(1).viewingDistanceCm=40;
            oo(2).viewingDistanceCm=40;
        end
        if false
            % Add tangential.
            oo(3:4)=oo;
            oo(3).flankingDirection='tangential';
            oo(4).flankingDirection='tangential';
        end
        ooo{end+1}=oo;
        if false
            % Exchange x and y, so we go from horizontal to vertical meridian.
            oo(1).eccentricityXYDeg=flip(oo(1).eccentricityXYDeg);
            oo(2).eccentricityXYDeg=flip(oo(2).eccentricityXYDeg);
            if abs(oo(1).eccentricityXYDeg(2))>=10
                oo(1).viewingDistanceCm=25;
                oo(2).viewingDistanceCm=25;
            else
                oo(1).viewingDistanceCm=40;
                oo(2).viewingDistanceCm=40;
            end
            ooo{end+1}=oo;
        end
    end
end

%% SIMULATE 100 BLOCKS
if ooo{1}(1).simulateObserver
    for block=2:10
        ooo{block}=ooo{1};
        [ooo{block}.block]=deal(block);
    end
end

%% MEASURE ACUITY
if false
    for ecc=[0 5]
        o.conditionName='acuity';
        o.task='identify';
        o.targetDeg=4;
        o.thresholdParameter='size';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        if ecc>0
            o.fixationThicknessDeg=0.03;
            o.fixationMarkDeg=1; % 0, 3, and inf are typical values.
            o.isFixationBlankedNearTarget=false;
            o.flankingDirection='radial';
            o.viewingDistanceCm=100;
        else
            o.fixationThicknessDeg=0.02;
            o.fixationMarkDeg=inf; % 0, 3, and inf are typical values.
            o.isFixationBlankedNearTarget=true;
            o.flankingDirection='horizontal';
            o.viewingDistanceCm=100;
        end
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        ooo{end+1}=[o o2];
    end
end

%% ADD FIXATION-CHECK CONDITION TO BLOCKS THAT INCLUDE PERIPHERAL TARGETS.
for block=1:length(ooo)
    oo=ooo{block};
    if all([oo.eccentricityXYDeg]==0) || oo(1).simulateObserver
        continue
    else
        o=oo(1);
        o.conditionName='fixation check';
        o.task='identify';
        o.fixationCheck=true;
%         o.fixationOnsetAfterTargetOffsetSecs=0.5;
        o.eccentricityXYDeg=[0 0];
        o.thresholdParameter='spacing';
        o.flankingDirection='horizontal';
        o.fixedSpacingOverSize=1.4;
        o.targetDeg=0.3;
        o.spacingDeg=1.4*o.targetDeg;
        o.spacingDeg=nan;
        o.spacingGuessDeg=o.spacingDeg;
        o.targetGuessDeg=o.targetDeg;
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.trialsDesired=o.trialsDesired/2;
        oo(end+1)=o;
        ooo{block}=oo;
    end
end

%% SPECIFY SIMULATED THRESHOLD.
% This is ignored unless o.simulateObserver=true.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).simulatedLogThreshold=log10(NominalCrowdingDistanceDeg(oo(oi).eccentricityXYDeg));
    end
    ooo{block}=oo;
end

%% SPECIFY CONSTANT STIMULI
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        oo(oi).spacings=2.^[-4:3]*NominalCrowdingDistanceDeg(oo(oi).eccentricityXYDeg);
        if oo(oi).simulateObserver
            fprintf('%d: spacings:',oi);
            fprintf(' %.1f',oo(oi).spacings);
            fprintf('\n');
        end
    end
    ooo{block}=oo;
end

%% RANDOMLY FLIP ORDER.
% Our experimenters haven't liked this, so we haven't done it. Ideally we
% would do it to counterbalance order effects.
if rand>0.5
    % ooo=fliplr(ooo);
end

%% NUMBER THE BLOCKS AND CONDITIONS
% ooo=Shuffle(ooo);
for block=1:length(ooo)
    for oi=1:length(ooo{block})
        ooo{block}(oi).block=block;
        ooo{block}(oi).blocksDesired=length(ooo);
        ooo{block}(oi).condition=oi;
    end
end

%% COMPUTE MAX VIEWING DISTANCE IN REMAINING BLOCKS
maxCm=0;
for block=length(ooo):-1:1
    maxCm=max([maxCm ooo{block}(1).viewingDistanceCm]);
    [ooo{block}(:).maxViewingDistanceCm]=deal(maxCm);
end

%% ESTIMATE TIME
endsAtMin=0;
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        if ~ismember(oo(oi).observer,{'ideal'})
            endsAtMin=endsAtMin+[oo(oi).trialsDesired]/10;
        end
    end
    [ooo{block}(:).endsAtMin]=deal(endsAtMin);
end

%% MAKE SURE NEEDED FONTS ARE AVAILABLE
CheckExperimentFonts(ooo)

%% PRINT TABLE OF CONDITIONS, ONE ROW PER CONDITION (IE THRESHOLD).
for block=1:length(ooo)
    if block==1
        oo=ooo{1};
    else
        try
            oo=[oo ooo{block}];
        catch e
            fprintf('Success building table with %d conditions in %d blocks, but failed on block %d.\n',...
                length(oo),max([oo.block]),block);
            one=fieldnames(oo);
            two=fieldnames(ooo{block});
            oneMissing=~ismember(one,two);
            twoMissing=~ismember(two,one);
            fprintf('<strong>ERROR: The following fields are not consistently present: </strong>');
            fprintf('%s, ',one{oneMissing});
            fprintf('%s, ',two{twoMissing});
            fprintf('\n');
            throw(e)
        end
    end
end
t=struct2table(oo,'AsArray',true);
% Print the conditions in the Command Window.
disp(t(:,{'block' 'condition' 'endsAtMin' 'experiment' 'conditionName' ...
    'procedure' 'thresholdParameter' 'targetFont' 'eccentricityXYDeg' ...
    'flankingDirection' 'viewingDistanceCm' 'trialsDesired' ...
    'fixationOnsetAfterTargetOffsetSecs' ...
    'fixationOffsetBeforeTargetOnsetSecs'}));
fprintf('Total of %d trials should take about %.0f minutes to run.\n',...
    sum([oo.trialsDesired]),sum([oo.trialsDesired])/10);

% ooo{end}(end)
% return

%% RUN.
for block=1:length(ooo)
    if isempty(ooo{block}(1).experimenter) && block>1
        [ooo{block}.experimenter]=deal(ooo{block-1}(1).experimenter);
    end
    if isempty(ooo{block}(1).observer) && block>1
        [ooo{block}.observer]=deal(ooo{block-1}(1).observer);
    end
    [ooo{block}.block]=deal(block);
    [ooo{block}.isFirstBlock]=deal(block==1);
    [ooo{block}.isLastBlock]=deal(block==length(ooo));
    ooo{block}=CriticalSpacing(ooo{block});
    if any([ooo{block}.quitExperiment])
        break
    end
end
