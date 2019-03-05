% runComplexity.m
% MATLAB script to run CriticalSpacing.m
% Copyright 2018 Denis G. Pelli, denis.pelli@nyu.edu
%
% I estimate that runComplexity will take ?? minutes to complete. It
% measures ?? thresholds. It tests two locations: (-5,0) deg and (+5,0)
% deg. At each location it measure acuity for many alphabets.
%
% The script specifies "Darshan" as experimenter. You can change that in
% the script below if necessary. On the first block the program will ask
% the observer's name. On subsequent blocks it will remember the observer's
% name.
%
% PLEASE USE BINOCULAR VIEWING, USING BOTH EYES ALL THE TIMES.
%
% The script specifies a viewing distance of 40 cm. PLEASE USE A METER
% STICK OR TAPE MEASURE TO MEASURE THE VIEWING DISTANCE AND ENSURE THAT THE
% OBSERVER'S EYE IS ACTUALLY AT THE DISTANCE THAT THE PROGRAM THINKS IT IS.
% PLEASE ENCOURAGE THE OBSERVER TO MAINTAIN THE SAME VIEWING DISTANCE FOR
% THE WHOLE EXPERIMENT.
%
% denis.pelli@nyu.edu November 20, 2018
% 646-258-7524

% Crowding distance at ±10 deg ecc x 2 orientation.
% Acuity at ±10 deg ecc.

clear o oo ooo
ooo={};
o.experiment='Complexity';

% acuity
o.conditionName='acuity';
o.thresholdParameter='size';
o.flankingDirection='radial'; % Ignored
o.minimumTargetPix=8;

o.recordGaze=true;

if 0
if 1
    % Sloan
    o.targetFont='Sloan';
    o.minimumTargetPix=8;
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
    o.labelAnswers=false;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Checkers alphabet
    o.targetFont='Checkers';
    o.minimumTargetPix=16;
    o.alphabet='abcdefghijklmnopqrstuvwxyz';
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Sans Forgetica
    o.targetFont='Sans Forgetica';
    o.minimumTargetPix=8;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=false;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Kuenstler
    o.targetFont='Kuenstler Script LT Medium';
    o.minimumTargetPix=12;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Black Sabbath
    o.targetFont='SabbathBlackRegular';
    o.minimumTargetPix=10;
    o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    o.borderLetter='$';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Chinese from Qihan
    o.targetFont='Songti TC Regular';
    o.minimumTargetPix=16;
    o.alphabet=[20687 30524 38590 33310 28982 23627 29245 27169 32032 21338 26222 ...
        31661 28246 36891 24808 38065 22251 23500 39119 40517];
    o.alphabet=char(o.alphabet);
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
if 1
    % Japanese: Katakan, Hiragani, and Kanji
    % from Ayaka
    o.targetFont='Hiragino Mincho ProN W3';
    japaneseScript='Kanji';
    switch japaneseScript
        case 'Katakana'
            o.alphabet=[12450 12452 12454 12456 12458 12459 12461 12463 12465 12467 12469 ... % Katakana from Ayaka
                12471 12473 12475 12477 12479 12481 12484 12486 12488 12490 12491 ... % Katakana from Ayaka
                12492 12493 12494 12495 12498 12501 12408 12507 12510 12511 12512 ... % Katakana from Ayaka
                12513 12514 12516 12518 12520 12521 12522 12523 12524 12525 12527 ... % Katakana from Ayaka
                12530 12531];                                                      % Katakana from Ayaka
            o.minimumTargetPix=16;
        case 'Hiragana'
            o.alphabet=[12354 12362 12363 12365 12379 12383 12394 12395 12396 12397 12399 ... % Hiragana from Ayako
                12405 12411 12414 12415 12416 12417 12420 12422 12434];            % Hiragana from Ayako
            o.minimumTargetPix=16;
        case 'Kanji'
            o.alphabet=[25010 35009 33016 23041 22654 24149 36605 32302 21213 21127 35069 ... % Kanji from Ayaka
                37806 32190 26286 37707 38525 34276 38360 38627 28187];               % Kanji from Ayaka
            o.minimumTargetPix=16;
    end
    o.alphabet=char(o.alphabet);
    o.borderLetter='';
    o.labelAnswers=true;
    o.readAlphabetFromDisk=true;
    ooo{end+1}=o;
end
end
if 1
    % crowding
    o.conditionName='crowdingDistance';
    o.thresholdParameter='spacing';
    o.targetFont='Sloan';
    o.minimumTargetPix=8;
    o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
    o.borderLetter='X';
    o.labelAnswers=false;
    o.readAlphabetFromDisk=true;
    for radial=0:1
        if radial
            o.flankingDirection='radial';
        else
            o.flankingDirection='tangential';
        end
        ooo{end+1}=o;
    end
end

% Randomly interleave testing left and right.
for i=1:length(ooo)
    o=ooo{i};
    o.block=i;
    o.setNearPointEccentricityTo='fixation';
%     o.nearPointXYInUnitSquare=[0.5 0.5];
    o.viewingDistanceCm=40;
    o.eccentricityXYDeg=[-10 0];
    oo=o;
    o.eccentricityXYDeg=[10 0];
    oo(2)=o;
    ooo{i}=oo;
end

% Print as a table. One row per threshold.
oo=[];
for i=1:length(ooo)
    if isempty(oo)
        oo=ooo{i};
    else
        oo(end+1:end+2)=ooo{i};
    end
end
t=struct2table(oo);
disp(t); % Print the conditions in the Command Window.
return

for i=1:length(ooo)
    oo=ooo{i};
    for oi=1:length(oo)
%         oo(oi).useFractionOfScreenToDebug=0.5; %% USE ONLY FOR DEBUGGING
%         oo(oi).rushToDebug=true; %% USE ONLY FOR DEBUGGING
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
        oo(oi).trials=50;
        oo(oi).practicePresentations=0;
        oo(oi).durationSec=0.2; % duration of display of target and flankers
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
    old=oo(1); % Allow reuse of settings.
end
