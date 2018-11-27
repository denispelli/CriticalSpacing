% runCrowdingSurvey.m
% MATLAB script to run CriticalSpacing.m
% Copyright 2018 Denis G. Pelli, denis.pelli@nyu.edu
% 
% I estimate that runCrowdingSurvey will take 15 minutes to complete. It
% measures 6 thresholds. It tests two locations: (-15,0) deg and (+15,0)
% deg. At each location it measure acuity, plus crowding radially and
% tangentially. 
% 
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
% 
% PLEASE USE BINOCULAR VIEWING, USING BOTH EYES AT ALL TIMES.
% 
% IT IS VERY IMPORTANT TO USE A METER STICK OR TAPE MEASURE TO ACTUALLY
% MEASURE THE VIEWING DISTANCE AND ENSURE THAT THE OBSERVER'S EYE IS
% ACTUALLY AT THE DISTANCE THAT THE PROGRAM THINKS IT IS. PLEASE ENCOURAGE
% THE OBSERVER TO MAINTAIN THE SAME VIEWING DISTANCE FOR THE WHOLE
% EXPERIMENT. From this perspective, a few cm variation matters less from a
% larger viewing distance. So err on the high side when selecting viewing
% distance.
%
% denis.pelli@nyu.edu November 12, 2018
% 646-258-7524

% Crowding distance at 2 location x 2 orientation. Acuity at 2 locations.
% * (4 thresholds). Horizontal meridian: ±15 deg X orientations (0, 90 deg)
% * (2 thresholds). Acuity at ±5 deg ecc.
% Total of 6 thresholds.

clear o oo ooo
% SIMULATE OBSERVER TO TEST THRESHOLD ESTIMATION
% o.simulateObserver=true;
% o.simulatedLogThreshold=0;
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
o.experiment='CrowdingSurvey';
ooo={};
for rep=1
    for crowding=[1 0]
        if crowding
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
        else % acuity
            o.conditionName='acuity';
            o.thresholdParameter='size';
            o.flankingDirection='radial'; % Ignored
            ooo{end+1}=o;
        end
        
    end
end
% Test each condition at two symmetric locations, randomly interleaved.
for i=1:length(ooo)
    o=ooo{i};
    o.block=i;
    o.fixationAtCenter=true; 
    o.nearPointXYInUnitSquare=[0.5 0.5];
    o.eccentricityXYDeg=[-15 0];
    radialDeg=sqrt(sum(o.eccentricityXYDeg.^2));
    o.viewingDistanceCm=max(30,min(400,round(9/tand(radialDeg))));
    o.viewingDistanceCm=40;
    oo=o;
    o.eccentricityXYDeg= -o.eccentricityXYDeg;
    oo(2)=o;
    ooo{i}=oo;
end
oo=[];
for i=1:length(ooo)
    if isempty(oo)
        oo=ooo{i};
    else
        oo(end+1:end+2)=ooo{i};
    end
end
t=struct2table(oo);
t % Print the conditions in the Command Window.
% return
for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
%         oo(oi).useFractionOfScreen=0.5;
        if i==1
            oo(oi).experimenter='Darshan';
            oo(oi).observer='';
        else
            oo(oi).experimenter=old.experimenter;
            oo(oi).observer=old.observer;
            oo(oi).viewingDistanceCm=old.viewingDistanceCm;
        end
        oo(oi).fixationCrossBlankedNearTarget=false;
        oo(oi).fixationLineWeightDeg=0.1;
        oo(oi).fixationCrossDeg=1; % 0, 3, and inf are typical values.
        oo(oi).trials=30;
        oo(oi).practicePresentations=0;
        oo(oi).durationSec=0.1; % duration of display of target and flankers
        oo(oi).repeatedTargets=0;
    end
    oo=CriticalSpacing(oo);
    ooo{i}=oo;
    if ~any([oo.quitBlock])
        fprintf('Finished block %d.\n',i);
    end
    if any([oo.quitSession])
        break
    end
    old=oo(1); % Allow reuse of settings.
end
