% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016,2017 Denis G. Pelli, denis.pelli@nyu.edu

% We recommend leaving the boilerplate header alone, and customizing by
% copying lines from the boilerplate to your customized section at the
% bottom and modifying it there. This facilitates comparison of scripts.

%% BOILERPLATE HEADER
clear o

% PROCEDURE
o.easyBoost=0.3; % Increase the log threshold parameter of easy trials by this much.
o.experimenter=''; % Put name here to skip the runtime question.
o.flipScreenHorizontally=0; % Set to 1 when using a mirror.
o.fractionEasyTrials=0;
o.observer=''; % Put name here to skip the runtime question.
o.permissionToChangeResolution=0; % Works for main screen only, due to Psychtoolbox bug.
o.readAlphabetFromDisk=1; % 1 makes the program more portable.
o.secsBeforeSkipCausesGuess=8;
o.takeSnapshot=0; % To illustrate your talk or paper.
o.task='identify';
o.textFont='Arial';
o.textSizeDeg=0.4;
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.trials=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=400; % Default for runtime question.

% SOUND & FEEDBACK
o.beepNegativeFeedback=0;
o.beepPositiveFeedback=1;
o.showProgressBar=1;
o.speakEachLetter=1;
o.speakEncouragement=0;
o.speakViewingDistance=0;
o.usePurring=0;
o.useSpeech=1;

% VISUAL STIMULUS
o.durationSec=inf; % duration of display of target and flankers
o.eccentricityXYDeg=[0 0]; % Distance of target from fixation. Positive up and to right.
o.nearPointXYInUnitSquare=[0.5 0.5]; % Target location, re lower-left corner of screen.
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
o.fourFlankers=0;
o.targetSizeIsHeight=nan; % "Size" is either height (1) or width (0).
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this and pixPerCm.
% o.flankingDirection='tangential'; % vertically arranged flankers for single target
o.flankingDirection='radial'; % horizontally arranged flankers for single target
o.repeatedTargets=0; % Repeat targets for immunity to fixation errors.
o.maxFixationErrorXYDeg=[3 3]; % Repeat enough to cope with this.
o.practicePresentations=3;
o.setTargetHeightOverWidth=0; % Stretch font to achieve a particular aspect ratio.
o.spacingDeg=nan;
o.targetDeg=nan;

% TARGET FONT
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='$';
o.targetFont='Pelli';
o.alphabet='123456789';
o.borderLetter='$';
% o.targetFont='ClearviewText';
% o.targetFont='Gotham Cond SSm XLight';
% o.targetFont='Gotham Cond SSm Light';
% o.targetFont='Gotham Cond SSm Medium';
% o.targetFont='Gotham Cond SSm Book';
% o.targetFont='Gotham Cond SSm Bold';
% o.targetFont='Gotham Cond SSm Black';
% o.targetFont='Arouet';
% o.targetFont='Pelli';
% o.targetFont='Retina Micro';

% FIXATION
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf; % 0, 3, and inf are a typical values.
o.fixationLineWeightDeg=0.02;
o.markTargetLocation=false; % 1 to mark target location
o.useFixation=1;

% QUEST threshold estimation
o.beta=nan;
o.measureBeta=0;
o.pThreshold=nan;
o.tGuess=nan;
o.tGuessSd=nan;
o.useQuest=1; % true(1) or false(0)

% DEBUGGING AIDS
o.frameTheTarget=0;
o.printScreenResolution=0;
o.printSizeAndSpacing=0;
o.showAlphabet=0;
o.showBounds=0;
o.showLineOfLetters=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreenToDebug=0;

% TO MEASURE BETA
% o.measureBeta=0;
% o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
% o.trials=200;

% TO HELP CHILDREN
% o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
% o.speakEncouragement=1; % 1 to say "good," "very good," or "nice" after every trial.

%% CUSTOM CODE

% Crowding distance at 25 combinations of location and orientation:
% * (12 thresholds). Horizontal meridian: 6 ecc. (±1, ±5, ±25 deg) X 2 orientations (0, 90 deg)
% * (8 thresholds). At 5 deg ecc: 4 obliques (45, 135, 225, 315 deg) X 2 orientations
% * (4 thresholds) Vertical meridian: +/-5 deg ecc X 2 orientations
% * (1 threshold) Fovea: Horizontal crowding distance X 1 orientation.

% * (12 thresholds). Horizontal meridian: 6 ecc. (±1, ±5, ±25 deg) X 2 orientations (0, 90 deg)
clear o oo
o.targetFont='Sloan';
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.borderLetter='X';
for ecc=2
   for rep=1:10
      for radial=0
         o.eccentricityXYDeg=[ecc 0];
         if radial
            o.flankingDirection='radial';
         else
            o.flankingDirection='tangential';
         end
         %    o=CriticalSpacing(o);
         if exist('oo','var')
            oo(end+1)=o;
         else
            oo=o;
         end
      end
   end
end
if 0
% * (8 thresholds). At 5 deg ecc: 4 obliques (45, 135, 225, 315 deg) X 2 orientations
for meridianDeg=45:90:315
   for rep=1:2
      for radial=0:1
         o.eccentricityXYDeg=5*[sind(meridianDeg) cosd(meridianDeg)];
         if radial
            o.flankingDirection='radial';
         else
            o.flankingDirection='tangential';
         end
         %          o=CriticalSpacing(o);
         if exist('oo','var')
            oo(end+1)=o;
         else
            oo=o;
         end
      end
   end
end

% * (4 thresholds) Vertical meridian: +/-5 deg ecc X 2 orientations
for ecc=[-5 5]
   for rep=1:2
      for radial=0:1
         o.eccentricityXYDeg=[0 ecc];
         if radial
            o.flankingDirection='radial';
         else
            o.flankingDirection='tangential';
         end
         %          o=CriticalSpacing(o);
         if exist('oo','var')
            oo(end+1)=o;
         else
            oo=o;
         end
      end
   end
end

% * (1 threshold) Fovea: Horizontal crowding distance X 1 orientation.
o.targetFont='Pelli';
o.alphabet='123456789';
o.borderLetter='$';
for rep=1:2
   o.eccentricityXYDeg=[0 0];
   o.flankingDirection='tangential';
   %    o=CriticalSpacing(o);
   if exist('oo','var')
      oo(end+1)=o;
   else
      oo=o;
   end
end
end
for i=1:length(oo)
   radialDeg=sqrt(sum(oo(i).eccentricityXYDeg.^2));
   oo(i).viewingDistanceCm=max(30,min(400,round(9/tand(radialDeg))));
   oo(i).viewingDistanceCm=150;
   oo(i).row=i;
end
t=struct2table(oo);
t % Print the conditions in the Command Window.
for i=1:length(oo)
   o=oo(i);
% o.useFractionOfScreenToDebug=0.5;
   o.fixationLineWeightDeg=0.04;
   o.fixationCrossDeg=3; % 0, 3, and inf are typical values.
   o.trials=30;
   o.practicePresentations=0;
   o.experimenter='Denis';
   o.observer='Gus';
   o.durationSec=0.2; % duration of display of target and flankers
   o.repeatedTargets=0;
   o.thresholdParameter='spacing';
   o=CriticalSpacing(o);
   if ~o.quitBlock
      fprintf('Finished row %d.\n',i);
   end
   if o.quitSession
      break
   end
end
