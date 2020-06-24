% MATLAB script to run CriticalSpacing.m
% Copyright 2019, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear KbWait o
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib'));

% o.useFractionOfScreenToDebug=0.4;
% o.skipScreenCalibration=true; % Skip calibration to save time.
% o.printSizeAndSpacing=true;
o.experiment='CrowdingSurvey';
o.permissionToChangeResolution=true;
o.experimenter='';
o.observer='';
o.showProgressBar=false;
o.useSpeech=false;
o.viewingDistanceCm=100;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0] lower left, [1 1] upper right.
% For 2018-April 2019 this was nominally 200 ms, but actually delivered 280
% ms when tested in April. I've now improved the code to more accurately
% deliver the requested duration, and reduced the request to 150 m.
o.durationSec=0.150; % duration of display of target and flankers
o.getAlphabetFromDisk=true;
o.trialsDesired=30;
o.brightnessSetting=0.87; % Roughly half luminance. Some observers find 1.0 painfully bright.
% o.takeSnapshot=true; % To illustrate your talk or paper.
o.fixationCheck=false;
o.flankingDirection='radial';
o.fixationOnsetAfterTargetOffsetSecs=0;
o.spacingGuessDeg=nan;
o.targetGuessDeg=nan;
o.fixedSpacingOverSize=1.4;
o.spacingDeg=[];
o.fixationThicknessDeg=0.02;
o.fixationMarkDeg=inf;
o.isFixationBlankedNearTarget=true;

ooo={};

if 1
    o.conditionName='reading';
    o.task='read';
    o.thresholdParameter='spacing';
    o.targetFont='Monaco';
    o.getAlphabetFromDisk=false;
    o.targetDeg=nan;
    o.trialsDesired=4;
    o.minimumTargetPix=8;
    o.eccentricityXYDeg=[0 0];
    o.flankingDirection='horizontal';
    % The reading test fills a 15" MacBook Pro screen with 1 deg letters at
    % 50 cm. Larger letters require proportionally smaller viewing
    % distance.
    o.viewingDistanceCm=40;
    o.readSpacingDeg=.8;
    o.printSizeAndSpacing=false;
    if true
        % Adjust viewing distance so text fits on screen.
        o.readLines=12;
        o.readCharPerLine=50;
        o.screen=0;
        maxViewingDistanceCm=MaxViewingDistanceCmForReading(o);
        if o.viewingDistanceCm>maxViewingDistanceCm
            fprintf('Reducing viewing distance from %.0f to %.0f cm.\n',...
                o.viewingDistanceCm,maxViewingDistanceCm);
            o.viewingDistanceCm=maxViewingDistanceCm;
        end
    end
    o.alphabet='abc';
    o.borderLetter='x';
    o.flankingDirection='horizontal';
    o.useFixation=false;
    ooo{end+1}=o;
end
o.trialsDesired=30;
if true
    for ecc=[5 2.5]
        o.conditionName='crowding';
        o.task='identify';
        o.useFixation=true;
        o.targetDeg=2;
        o.spacingDeg=2;
        o.thresholdParameter='spacing';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.flankingDirection='radial';
        o.targetFont='Sloan';
        o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
        o.borderLetter='X';
        o.minimumTargetPix=8;
        o.fixationThicknessDeg=0.03;
        o.fixationMarkDeg=1; % 0, 3, and inf are typical values.
        o.isFixationBlankedNearTarget=false;
        o.flankingDirection='radial';
        o.viewingDistanceCm=40;
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        oo=[o o2];
        if abs(oo(1).eccentricityXYDeg(2))>=10
            oo(1).viewingDistanceCm=25;
            oo(2).viewingDistanceCm=25;
        else
            oo(1).viewingDistanceCm=40;
            oo(2).viewingDistanceCm=40;
        end
        ooo{end+1}=oo;
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
        if ecc==5
            ooPelli=ooo{end-1};
            ooPelli(1).targetFont='Pelli';
            ooPelli(2).targetFont='Pelli';
            ooPelli(1).alphabet='123456789';
            ooPelli(2).alphabet='123456789';
            ooPelli(1).borderLetter='$';
            ooPelli(2).borderLetter='$';
            ooo{end+1}=ooPelli;
        end
    end
end
if true
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
if 1
    for ecc=0
        o.conditionName='crowding';
        o.task='identify';
        o.targetDeg=2;
        o.spacingDeg=2;
        o.thresholdParameter='spacing';
        o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
        o.targetFont='Pelli';
        o.alphabet='123456789';
        o.borderLetter='$';
        o.minimumTargetPix=4;
        o.fixationThicknessDeg=0.02;
        o.fixationMarkDeg=40; % 0, 3, and inf are typical values.
        o.isFixationBlankedNearTarget=true;
        o.flankingDirection='horizontal';
        o.viewingDistanceCm=250;
        o2=o; % Copy the condition
        o2.eccentricityXYDeg=-o.eccentricityXYDeg;
        ooo{end+1}=[o o2];
    end
end
for block=1:length(ooo)
    oo=ooo{block};
    if all([oo.eccentricityXYDeg]==0)
        % Leave alone conditions at zero eccentricity.
        continue
    else
        % Add fixation check to conditions with nonzero eccentricity.
        o=oo(1);
        o.conditionName='fixation check';
        o.task='identify';
        o.fixationCheck=true;
        o.fixationOnsetAfterTargetOffsetSecs=0;
        o.isFixationBlankedNearTarget=true;
        o.fixationMarkDeg=4;
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
        oo(end+1)=o;
        ooo{block}=oo;
    end
end

if rand>0.5
    %         ooo=fliplr(ooo);
end

switch mfilename
    case 'runCrowdingSurvey0'
        % For debugging. Use just two blocks [2 4], 1 trial per condition.
        ooo=ooo([4]);
%         [ooo{1}.trialsDesired]=deal(1);
    case 'runCrowdingSurvey1'
        ooo=ooo(1:5);
    case 'runCrowdingSurvey2'
        ooo=ooo(6:end);
    otherwise
        error('Illegal file name');
end

%% NUMBER THE BLOCKS
for block=1:length(ooo)
    for oi=1:length(ooo{block})
        ooo{block}(oi).block=block;
        ooo{block}(oi).blocksDesired=length(ooo);
    end
end
% ooo=Shuffle(ooo);

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

%% PRINT TABLE OF CONDITIONS, ONE ROW PER THRESHOLD.
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
disp(t(:,{'block' 'endsAtMin' 'experiment' 'conditionName' 'targetFont' ...
    'eccentricityXYDeg' 'flankingDirection' 'viewingDistanceCm' ...
    'trialsDesired' 'fixationMarkDeg' 'isFixationBlankedNearTarget' ...
    'fixationOnsetAfterTargetOffsetSecs'}));
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
    [ooo{block}.isFirstBlock]=deal(block==1);
    [ooo{block}.isLastBlock]=deal(block==length(ooo));
    ooo{block}=CriticalSpacing(ooo{block});
    if any([ooo{block}.quitExperiment])
        break
    end
end
