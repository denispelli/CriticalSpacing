% MATLAB script to run CriticalSpacing.m
% Copyright 2015,2016, Denis G. Pelli, denis.pelli@nyu.edu

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
o.readAlphabetFromDisk=true; % true makes the program more portable.
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
o.markTargetLocation=0; % 1 to mark target location
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
% RUN 

if 0
    % Sans Forgetica
    o.targetFont='Sans Forgetica';
    o.readAlphabetFromDisk=true;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
end
if 0
    % Kuenstler
    o.targetFont='Kuenstler Script LT Medium';
    o.readAlphabetFromDisk=true;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
end
if 0
    % Black Sabbath
    o.targetFont='SabbathBlackRegular';
    o.readAlphabetFromDisk=true;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
end
if 0
    % Chinese from Qihan
    o.targetFont='Songti TC Regular';
    o.readAlphabetFromDisk=true;
    % o.alphabet='????????????????????'; % Chinese from Qihan.
    o.alphabet=[20687 30524 38590 33310 28982 23627 29245 27169 32032 21338 26222 ...
        31661 28246 36891 24808 38065 22251 23500 39119 40517];
    % o.borderLetter='?';
    o.labelAnswers=true;
    o.borderLetter=40517;
end
if 1
    % Japanese: Katakan, Hiragani, and Kanji
    % from Ayaka
    o.targetFont='Hiragino Mincho ProN W3';
    o.readAlphabetFromDisk=true;
    japaneseScript='Kanji';
    switch japaneseScript
        case 'Katakana'
            o.alphabet=[12450 12452 12454 12456 12458 12459 12461 12463 12465 12467 12469 ... % Katakana from Ayaka
                12471 12473 12475 12477 12479 12481 12484 12486 12488 12490 12491 ... % Katakana from Ayaka
                12492 12493 12494 12495 12498 12501 12408 12507 12510 12511 12512 ... % Katakana from Ayaka
                12513 12514 12516 12518 12520 12521 12522 12523 12524 12525 12527 ... % Katakana from Ayaka
                12530 12531];                                                      % Katakana from Ayaka
        case 'Hiragana'
            o.alphabet=[12354 12362 12363 12365 12379 12383 12394 12395 12396 12397 12399 ... % Hiragana from Ayako
                12405 12411 12414 12415 12416 12417 12420 12422 12434];            % Hiragana from Ayako
        case 'Kanji'
            o.alphabet=[25010 35009 33016 23041 22654 24149 36605 32302 21213 21127 35069 ... % Kanji from Ayaka
                37806 32190 26286 37707 38525 34276 38360 38627 28187];               % Kanji from Ayaka
    end
    o.labelAnswers=true;
    o.borderLetter='';
end

% o.useFractionOfScreenToDebug=0.3;

o.practicePresentations=0;
o.experimenter='Darshan';
o.observer='';

o.viewingDistanceCm=50;
o.eccentricityXYDeg=[10 0]; % Distance of target from fixation. Positive up and to right.
o.nearPointXYInUnitSquare=[0.7 0.5]; % location on screen. [0 0]  lower right, [1 1] upper right.

o.durationSec=0.2; % duration of display of target and flankers
if 0
    o.targetFont='Sloan';
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
end
o.targetDeg=2;

o.repeatedTargets=0;
o.thresholdParameter='spacing';
% o(2)=o(1); % Copy the condition
% o=CriticalSpacing(o); 

o.thresholdParameter='size';
% o(2)=o(1); % Copy the condition
o.readAlphabetFromDisk=false; % true makes the program more portable.

% Japanese
% o.targetFont='Hiragino Mincho ProN W3';
% o.alphabet=[26085 26412 35486 12391 12354 12426 12364 12392 12358 12372 12374 12356 12414 12375 12383 12290];
% o.labelAnswers=true;

% Chinese
% o.targetFont='Songti TC Light';
% o.labelAnswers=true;
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% Difficult Roman fonts
% o.targetFont='Kuenstler Script Bold'; 
% o.targetFont='SabbathBlackRegular';
% o.targetFont='SabbathBlack OT';
% o.labelAnswers=false;
% o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWYZ'; 
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% o.targetFont='Sans Forgetica';
% o.minimumTargetPix=16; % Complex fonts need more than the default 6 pix.

% o.readAlphabetFromDisk=true; % true makes the program more portable.
% o.targetFont='Checkers';
% o.alphabet='abcdefghijklmnopqrstuvwxyz'; 
% o.borderLetter='';


o=CriticalSpacing(o); 

% Results are printed in MATLAB's Command Window and saved in the
% CriticalSpacing/data/ folder.