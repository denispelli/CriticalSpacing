% runCrowdingSurvey.m
% MATLAB script to run CriticalSpacing.m
% Copyright 2018 Denis G. Pelli, denis.pelli@nyu.edu
% 
% I estimate that runCrowdingSurvey will take 15 minutes to complete. It
% measures 6 thresholds. It tests two locations: (-15,0) deg and (+15,0)
% deg. At each location it measures acuity, plus crowding radially and
% tangentially.
% 
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
%
% IMPORTANT: Please use binocular viewing, using both eyes at all times.
% 
% IMPORTANT: Use a meter stick or tape measure to actually measure the
% viewing distance and ensure that the observer's eye is actually at the
% distance that the program thinks it is. Please encourage the observer to
% maintain the same viewing distance for the whole experiment. From this
% perspective, a few cm variation matters less from a larger viewing
% distance. So err on the high side when selecting viewing distance.
%
% denis.pelli@nyu.edu November 12, 2018
% 646-258-7524

% CREATE A CELL ARRAY ooo WITH ONE CELL PER BLOCK.
% EACH BLOCK IS SPECIFIED BY A STRUCT ARRAY, WITH ONE STRUCT PER CONDITION.
clear o oo ooo
% o.useFractionOfScreenToDebug=0.5; %% USE ONLY FOR DEBUGGING
% o.rushToDebug=true; %% USE ONLY FOR DEBUGGING
% SIMULATE OBSERVER TO TEST THRESHOLD ESTIMATION
% o.simulateObserver=true;
% o.simulatedLogThreshold=0;
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.experiment='CrowdingSurvey';
ooo={};
for rep=1
    o.conditionName='crowdingDistance';
    o.thresholdParameter='spacing';
    for radial=0:1
        if radial
            o.flankingDirection='radial';
        else
            o.flankingDirection='tangential';
        end
        ooo{end+1}=o;
    end
    
    o.conditionName='acuity';
    o.thresholdParameter='size';
    o.flankingDirection='radial'; % Ignored
    ooo{end+1}=o;
end
% Test each condition at two symmetric locations, randomly interleaved.
for i=1:length(ooo)
    o=ooo{i};
    o.block=i;
    o.setNearPointEccentricityTo='fixation';
    o.nearPointXYInUnitSquare=[0.5 0.5];
    o.eccentricityXYDeg=[-10 0];
%     radialDeg=sqrt(sum(o.eccentricityXYDeg.^2));
%     o.viewingDistanceCm=max(30,min(400,round(9/tand(radialDeg))));
    o.viewingDistanceCm=40;
    oo=o;
    o.eccentricityXYDeg= -o.eccentricityXYDeg;
    oo(2)=o;
    ooo{i}=oo;
end

% PRINT A TABLE OF ALL THE CONDITIONS
oo=[];
for i=1:length(ooo)
    oo=[oo ooo{i}];
end
t=struct2table(oo);
disp(t); % Print the conditions in the Command Window.
% return

% RUN THE CONDITIONS, ONE BLOCK AT A TIME.
for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
        oo(oi).isFirstBlock=false;
        oo(oi).isLastBlock=false;
        if i==1
            oo(oi).experimenter='Darshan';
            oo(oi).observer='';
            oo(oi).isFirstBlock=true;
       else
            oo(oi).experimenter=old.experimenter;
            oo(oi).observer=old.observer;
            oo(oi).viewingDistanceCm=old.viewingDistanceCm;
        end
        oo(oi).fixationCrossBlankedNearTarget=false;
        oo(oi).fixationLineWeightDeg=0.1;
        oo(oi).fixationCrossDeg=1; % 0, 3, and inf are typical values.
        oo(oi).trials=30;
        oo(oi).durationSec=0.1; % duration of display of target and flankers
        oo(oi).repeatedTargets=0;
    end
    ooo{end}(1).isLastBlock=true;
    oo=CriticalSpacing(oo);
    ooo{i}=oo;
    if ~any([oo.quitBlock])
        fprintf('Finished block %d.\n',i);
    end
    if any([oo.quitSession])
        break
    end
    old=oo(1); % Allow reuse of settings from previous block.
end
