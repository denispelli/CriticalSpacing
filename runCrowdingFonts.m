% MATLAB script to run CriticalSpacing.m
% Copyright 2020, denis.pelli@nyu.edu

%% DEFINE CONDITIONS
clear o
mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib'));

o.isFixationBlankedNearTarget=true;
isEccentricityMirrored=true;
o.group='one';
% o.useFractionOfScreenToDebug=0.3;% USE ONLY FOR DEBUGGING.
% o.skipScreenCalibration=true;    % USE ONLY FOR DEBUGGING.
% o.printSizeAndSpacing=true;
o.experiment='CrowdingFonts';
o.permissionToChangeResolution=false;
o.experimenter='';
o.observer='';
o.showProgressBar=false;
o.useSpeech=false;
o.viewingDistanceCm=100;
o.setNearPointEccentricityTo='fixation';
o.nearPointXYInUnitSquare=[0.5 0.5]; % Location on screen. [0 0] lower left, [1 1] upper right.
% For 2018-April 2019 this was nominally 200 ms, but actually delivered 280
% ms when tested in April. I've now improved the code to more accurately
% deliver the requested duration, and reduced the request to 150 m.
o.durationSec=0.150; % duration of display of target and flankers
% o.durationSec=1; % duration of display of target and flankers

o.getAlphabetFromDisk=true;
% o.trialsDesired=30;
% o.trialsDesired=3;
o.screen=0;
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
o.screenSizeCm=[screenWidthMm screenHeightMm]/10;

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
o.blankingClipRectInUnitSquare=[0.2 0.2 0.8 0.8]; 
o.isFixationBlankedNearTarget=true;

ooo={};

if false
    o.conditionName='reading';
    o.task='read';
    o.thresholdParameter='spacing';
    o.targetFont='Monaco';
    o.getAlphabetFromDisk=false;
    o.targetDeg=nan;
%     o.trialsDesired=4;
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

o.trialsDesired=40;
fonts={'Sloan' 'Pelli'};
if true
    % Crowding at 0 and 5 deg. Pelli at both. Sloan only at 5 deg.
    for ecc=[5 0]
        for iFont=1:length(fonts)
            o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
            switch fonts{iFont}
                case 'Sloan'
                    if norm(o.eccentricityXYDeg)==0
                        % Skip Sloan crowding at fovea.
                        continue
                    end
                    o.targetFont='Sloan';
                    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
                    o.borderLetter='X';
                    o.minimumTargetPix=8;
                    o.fixationBlankingRadiusReTargetHeight=3;
                case 'Pelli'
                    o.targetFont='Pelli';
                    o.alphabet='123456789';
                    o.borderLetter='$';
                    o.minimumTargetPix=8; % width
                    o.fixationBlankingRadiusReTargetHeight=2;
                otherwise
                    error('Unsupported font %s.\n',fonts{iFont});
            end
            o.conditionName='crowding';
            o.task='identify';
            o.useFixation=true;
            o.targetDeg=2;
            o.spacingDeg=2;
            o.thresholdParameter='spacing';
            o.fixationThicknessDeg=0.03;
%             o.isFixationBlankedNearTarget=false;
            if norm(o.eccentricityXYDeg)==0
                o.flankingDirection='horizontal';
            else
                o.flankingDirection='radial';
            end
            if norm(o.eccentricityXYDeg)>0
                o.fixationThicknessDeg=0.03;
%                 o.fixationMarkDeg=1; % 0, 3, and inf are typical values.
%                 o.isFixationBlankedNearTarget=false;
                o.flankingDirection='radial';
            else
                o.fixationThicknessDeg=0.02;
%                 o.fixationMarkDeg=inf; % 0, 3, and inf are typical values.
                o.isFixationBlankedNearTarget=true;
                o.flankingDirection='horizontal';
            end
            if isEccentricityMirrored
                o2=o; % Copy the condition
                o2.eccentricityXYDeg=-o.eccentricityXYDeg;
                oo=[o o2];
            else
                oo=o;
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
end
if true
    % Measure acuity at 0 and 5 deg. Use Sloan and Pelli at both.
    for ecc=[0 5]
        for iFont=1:length(fonts)
            o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
            switch fonts{iFont}
                case 'Sloan'
                    o.targetFont='Sloan';
                    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
                    o.borderLetter='X';
                    o.minimumTargetPix=8;
                    o.fixationBlankingRadiusReTargetHeight=3;
                case 'Pelli'
                    o.targetFont='Pelli';
                    o.alphabet='123456789';
                    o.borderLetter='$';
                    o.minimumTargetPix=8;
                    o.fixationBlankingRadiusReTargetHeight=1;
                otherwise
                    error('Unsupported font %s.\n',fonts{iFont});
            end
            o.conditionName='acuity';
            o.task='identify';
            o.targetDeg=4;
            o.thresholdParameter='size';
            o.eccentricityXYDeg=[ecc 0]; % Distance of target from fixation. Positive up and to right.
            if norm(o.eccentricityXYDeg)>0
                o.fixationThicknessDeg=0.03;
%                 o.fixationMarkDeg=1; % 0, 3, and inf are typical values.
%                 o.isFixationBlankedNearTarget=false;
                o.flankingDirection='radial';
                o.viewingDistanceCm=100;
            else
                o.fixationThicknessDeg=0.02;
%                 o.fixationMarkDeg=inf; % 0, 3, and inf are typical values.
                o.isFixationBlankedNearTarget=true;
                o.flankingDirection='horizontal';
                o.viewingDistanceCm=100;
            end
            if isEccentricityMirrored
                o2=o; % Copy the condition
                o2.eccentricityXYDeg=-o.eccentricityXYDeg;
                ooo{end+1}=[o o2];
            else
                ooo{end+1}=o;
            end
        end
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
%         o.fixationMarkDeg=4;
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
        o.fixationBlankingRadiusReTargetHeight=3;
        oo(end+1)=o;
        ooo{block}=oo;
    end
end

%% COMPUTE MINIMUM VIEWING DISTANCE FOR EACH BLOCK
% To provide enough pixels in target at half nominal threshold size.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        switch oo(oi).thresholdParameter
            case 'spacing'
                if oo(oi).fixationCheck
                    s=0.3;
                else
                    % Make sure we can measure half of nominal threshold.
                    s=0.5*NominalCrowdingDistanceDeg(oo(oi).eccentricityXYDeg);
                end
                sizeDeg=s/oo(oi).fixedSpacingOverSize;
            case 'size'
                % Make sure we can measure half of nominal threshold.
                sizeDeg=0.5*NominalAcuityDeg(oo(oi).eccentricityXYDeg);
            otherwise
                continue
        end
        minPixPerDeg=oo(oi).minimumTargetPix/sizeDeg;
        pixPerCm=RectWidth(Screen('Rect',oo(oi).screen,1))/oo(oi).screenSizeCm(1);
        maxDegPerCm=pixPerCm/minPixPerDeg;
        oo(oi).minRecommendedViewingDistanceCm=ceil(1/tand(maxDegPerCm));
    end
    [oo.minRecommendedViewingDistanceCm]=deal(max([oo.minRecommendedViewingDistanceCm]));
    ooo{block}=oo;
end

%% COMPUTE MAXIMUM VIEWING DISTANCE FOR EACH BLOCK
% To keep target on screen.
for block=1:length(ooo)
    oo=ooo{block};
    for oi=1:length(oo)
        switch oo(oi).setNearPointEccentricityTo
            case 'fixation'
                for i=1:2
                    if oo(oi).eccentricityXYDeg(i)>0
                        minScreenSizeDeg(i)=...
                            (oo(oi).eccentricityXYDeg(i)+oo(oi).targetDeg)/...
                            (1-oo(oi).nearPointXYInUnitSquare(i));
                    else
                        minScreenSizeDeg(i)=...
                            (abs(oo(oi).eccentricityXYDeg(i))+oo(oi).targetDeg)/...
                            oo(oi).nearPointXYInUnitSquare(i);
                    end
                    % fprintf('%2d: o.nearPointXYInUnitSquare=[%.1f %.1f]; o.eccentricityXYDeg=[%.0f %.0f].\n',...
                    %     block,oo(oi).nearPointXYInUnitSquare,oo(oi).eccentricityXYDeg);
                end
            otherwise
                error('Don''t yet support o.setNearPointEccentricityTo=''%s''.',...
                    oo(oi).setNearPointEccentricityTo);
        end
        maxViewingDistanceCm=0.5*oo(oi).screenSizeCm ./ tand(0.5*minScreenSizeDeg);
        maxViewingDistanceCm=floor(maxViewingDistanceCm);
        oo(oi).maxViewingDistanceCm=min(maxViewingDistanceCm);
    end
    [oo.maxViewingDistanceCm]=deal(min([oo.maxViewingDistanceCm]));
    ooo{block}=oo;
end

%% SELECT VIEWING DISTANCE BETWEEN MIN AND MAX CLOSEST TO DESIRED.
preferredCm=60;
for block=1:length(ooo)
    oo=ooo{block};
    if oo(1).minRecommendedViewingDistanceCm>oo(1).maxViewingDistanceCm
        msg=sprintf(['Block %d: Not enough target pixels. Need bigger screen.\n' ...
            'minRecommendedViewingDistanceCm %.0f exceeds maxViewingDistanceCm %.0f. Using max.'],...
            block,oo(1).minRecommendedViewingDistanceCm,oo(1).maxViewingDistanceCm);
        warning(msg);
        [oo.viewingDistanceCm]=deal(oo(1).maxViewingDistanceCm);
    elseif preferredCm<oo(1).minRecommendedViewingDistanceCm
        [oo.viewingDistanceCm]=deal(oo(1).minRecommendedViewingDistanceCm);
    elseif oo(1).maxViewingDistanceCm<preferredCm
        [oo.viewingDistanceCm]=deal(oo(1).maxViewingDistanceCm);
    else
        [oo.viewingDistanceCm]=deal(preferredCm);
    end
    if oo(1).viewingDistanceCm>100
        [oo.viewingDistanceCm]=deal(round(oo(1).viewingDistanceCm,-1));
    end
    ooo{block}=oo;
end

%% COMPUTE screenSizeCm, screenSizeDeg.
[widthMm,heightMm]=Screen('DisplaySize',o.screen);
screenSizeCm=[widthMm heightMm]/10;
for block=1:length(ooo)
    oo=ooo{block};
    screenSizeDeg=2*[atan2d(screenSizeCm(1)/2,oo(1).viewingDistanceCm), ...
        atan2d(screenSizeCm(2)/2,oo(1).viewingDistanceCm)];
    for oi=1:length(oo)
        oo(oi).screenSizeCm=screenSizeCm;
        oo(oi).screenSizeDeg=screenSizeDeg;
    end
    ooo{block}=oo;
end

%% SORT BLOCKS IN ORDER OF INCREASING VIEWING DISTANCE
d=[];
for block=1:length(ooo)
    d(block)=ooo{block}(1).viewingDistanceCm;
end
[~,ii]=sort(d);
ooo=ooo(ii);

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
    case 'runCrowdingFonts'
%         ooo=ooo([5 6 7]);
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
    'eccentricityXYDeg' 'targetDeg' 'flankingDirection' 'viewingDistanceCm' ...
    ... % 'targetHeightIsSize' ...
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
