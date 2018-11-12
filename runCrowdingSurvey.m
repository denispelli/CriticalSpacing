% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016,2017 Denis G. Pelli, denis.pelli@nyu.edu

% Crowding distance at 2 location x 2 orientation. Acuity at 2 locations.
% * (4 thresholds). Horizontal meridian: ±5 deg X orientations (0, 90 deg)
% * (2 thresholds). Acuity at ±5 deg ecc.
% Repeat all of it. Total of 12 thresholds.
clear o oo
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
for ecc=[-5 5]
    o.eccentricityXYDeg=[ecc 0];
    for rep=1:2
        for crowding=0:1
            if crowding
                o.thresholdParameter='spacing';
                for radial=0:1
                    if radial
                        o.flankingDirection='radial';
                    else
                        o.flankingDirection='tangential';
                    end
                    if exist('oo','var')
                        oo(end+1)=o;
                    else
                        oo=o;
                    end
                end
            else % acuity
                o.thresholdParameter='size';
                o.flankingDirection='radial'; % Ignored
                if exist('oo','var')
                    oo(end+1)=o;
                else
                    oo=o;
                end
            end
            
        end
    end
end
for i=1:length(oo)
   radialDeg=sqrt(sum(oo(i).eccentricityXYDeg.^2));
   oo(i).viewingDistanceCm=max(30,min(400,round(9/tand(radialDeg))));
   oo(i).viewingDistanceCm=75;
   oo(i).row=i;
end
t=struct2table(oo);
t % Print the conditions in the Command Window.
for i=1:length(oo)
   o=oo(i);
   % o.useFractionOfScreen=0.5;
   if i==1
       o.experimenter='Darshan';
       o.observer='';
   else
       o.experimenter=old.experimenter;
       o.observer=old.observer;
       o.viewingDistanceCm=old.viewingDistanceCm;
   end
   o.fixationLineWeightDeg=0.04;
   o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
   o.trials=30;
   o.practicePresentations=0;
   o.durationSec=0.2; % duration of display of target and flankers
   o.repeatedTargets=0;
   o=CriticalSpacing(o);
   if ~o.quitBlock
      fprintf('Finished row %d.\n',i);
   end
   if o.quitSession
      break
   end
   old=o;
end
