function oo=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% CriticalSpacing measures an observer's critical spacing and acuity (i.e.
% threshold spacing and size) to help characterize the observer's vision.
% This program takes over your screen to measure the observer's size or
% spacing threshold for letter identification. It takes about 10 minutes to
% measure four thresholds. It's meant to be called by a short user-written
% script, and should work well in clinical environments. All results are
% returned in the "o" struct and also saved to disk in two files whose file
% names include your script name the experimenter and observer names and
% the date. One of those files is plain text .txt and easy for you to read;
% the other is a MATLAB save file .MAT and easily read by MATLAB. Please
% keep both. The filenames are unique and easy to sort, so it's fine to let
% all your data files accumulate in your CriticalSpacing/data/ folder.
% 
% PUBLICATION. You can read more about this program and its purpose in our
% 2016 article:
% 
% Pelli, D. G., Waugh, S. J., Martelli, M., Crutch, S. J., Primativo, S.,
% Yong, K. X., Rhodes, M., Yee, K., Wu, X., Famira, H. F., & Yiltiz, H.
% (2016) A clinical test for visual crowding [version 1; referees: 1
% approved with reservations]. F1000Research 5:81 (doi:
% 10.12688/f1000research.7835.1) http://f1000research.com/articles/5-81/v1
% 
% THE "o" ARGUMENT, INPUT AND OUTPUT. You define a condition by creating an
% "o" struct and setting its fields to specify your testing condition. Call
% CriticalSpacing, passing the "o" struct. CriticalSpacing will measure a
% threshold for your condition and return the "o" struct with all the
% results as additional fields. CriticalSpacing may adjust some of your
% parameters to satisfy physical constraints including screen size and
% maximum possible contrast. If you provide several conditions, as an o
% array, then CriticalSpacing runs all the conditions interleaved,
% measuring a threshold for each. I sometimes pass two identical conditions
% to get two thresholds for the same condition.
% 
% DISPLAY ALPHABET ON SCREEN AND ON PAPER. Anytime you press the "caps
% lock" key, CriticalSpacing will display the alphabet of possible
% responses in the current font. We encourage you to also provide a paper
% copy to most observers. Inside the "CriticalSpacing/pdf/" folder you'll
% find a file "FONT alphabet.pdf" (where FONT is the name of the font
% you're using). Print it on paper and give it to the observer. It shows
% the nine possible letters or digits. Observers will find it helpful to
% consult this page while choosing an answer, especially when they are
% guessing. Children may prefer to respond by pointing at the printed
% target letters on the alphabet page. Patients who have trouble directing
% their attention may be better off without the paper, to give their
% undivided attention to the display.
% 
% NEED MATLAB RUNNING ON A COMPUTER WITH A DIGITAL SCREEN. To run this
% program, you need a computer with MATLAB (or Octave) and the Psychtoolbox
% installed. The computer OS can be OS X, Windows, or Linux.
% CriticalSpacing automatically reads the screen resolution in pixels and
% size in cm. That won't work with an analog CRT display, but we could add
% code to allow you to measure it manually and specify it in your script.
% Let me know if you need that.
% 
% ALLOW MATLAB TO CONTROL YOUR COMPUTER. Only for Macintosh (OS X). Open
% the System Preferences: Security and Privacy: Privacy tab. Select
% Accessibility. Click to open the lock in lower left, providing your
% computer password. Click to select MATLAB, allowing it to control your
% computer. Click the lock again to close it.
% 
% A WIRELESS OR LONG-CABLE KEYBOARD is highly desirable as the viewing
% distance will be 3 m or more. If you must use the built-in keyboard, then
% have the experimenter type the observer's verbal answers. I like the
% Logitech K760 $86 solar-powered wireless keyboard, because its batteries
% never run out. It's no longer made, but still available on Amazon and
% eBay:
% 
% Logitech Wireless Solar Keyboard K760 for Mac/iPad/iPhone
% http://www.amazon.com/gp/product/B007VL8Y2C
% 
% MEASURE VIEWING DISTANCE. The viewing distance will typically be several
% meters, and it's important that you set it accurately, within five
% percent. You can measure it with a $10 tape measure marked in
% centimeters. A fancy $40 alternative is a Bosch laser measure, which
% gives you the answer in two clicks. The laser will work even with a
% mirror.
% 
% http://www.amazon.com/gp/product/B0016A2UHO
% http://www.amazon.com/gp/product/B00LGANH8K
% https://www.boschtools.com/us/en/boschtools-ocs/laser-measuring-glm-15-0601072810--120449-p/
% 
% This Stanley ultrasonic estimator is cheaper, just $23, so I ordered one.
% However, I don't yet know whether a typical laptop screen will be a
% sufficiently large target to allow accurate ultrasonic estimation of
% distance. Ultrasound may not work with a mirror, so you might have to
% make two measurements.
% 
% http://www.amazon.com/Stanley-77-018-IntelliMeasure-Distance-Estimator/dp/B000E8VM8W/ref=cm_rdp_product
% 
% MIRROR. In a small room, you might need a mirror to achieve a long
% viewing distance. When CriticalSpacing asks you about viewing distance,
% you can indicate that you're using a mirror by entering the viewing
% distance as a negative number. It will flip the display to be seen in a
% mirror. (You can also request this, in advance, by setting
% o.flipScreenHorizontally=1; in your run script.) I bought two acrylic
% front surface mirrors for this. 12x24 inches, $46 each from inventables.
% Front surface mirrors preserve image quality, and acrylic is hard to
% break, making it safer than glass. I'm not yet sure how big a mirror one
% needs to accomodate observer's of various heights, so I listed several of
% Amazon's offerings, ranging up to 24" by 48". The five-pack is a good
% deal, five 12"x24" mirrors for $67.
% 
% http://www.amazon.com/Acrylic-Wall-Mirror-Size-24/dp/B001CWAOJW/ref=sr_1_19
% http://www.amazon.com/Childrens-Factory-Look-At-Mirror/dp/B003BL7TMC/ref=sr_1_14
% https://www.inventables.com/technologies/first-surface-mirror-coated-acrylic
% http://www.amazon.com/12-24-Mirror-Acrylic-Plexiglass/dp/B00IVWQPUI/ref=sr_1_39
% http://www.amazon.com/12-Acrylic-Mirror-Sheet-Pack/dp/B00JPJK3T0/ref=sr_1_13
% http://www.amazon.com/Double-Infant-Mirror-surface-Approved/dp/B0041TABOG/ref=pd_sim_sbs_468_9
%
% FONTS. If you set o.readAlphabetFromDisk=1 in your script then you won't
% need to install any fonts. Instead you can use any of the "fonts" inside
% the CriticalSpacing/lib/alphabets/ folder, which you can best see by
% looking at the alphabet files in CriticalSpacing/pdf/. You can easily
% create and add a new "font" to the alphabets folder. Name the folder
% after your "font", and put one image file per letter inside the folder,
% named for the letter. That's it. You can now specify your new "font" as
% the o.targetFont and CriticalSpacing will use it. You can make the
% drawings yourself, or you can run
% CriticalSpacing/lib/SaveAlphabetToDisk.m to create a new folder based on
% a computer font that you already own. This scheme makes it easy to
% develop a new font, and also makes it easy to share font images without
% violating a font's commercial distribution license. (US Copyright law
% does not cover fonts. Adobe patents the font program, but the images are
% public domain.) You can also ask CriticalSpacing to use any font that's
% installed in your computer OS by setting o.readAlphabetFromDisk=0. The
% Pelli and Sloan fonts are provided in the CriticalSpacing/fonts/ folder,
% and you can install them in your computer OS. On a Mac, you can just
% double-click the font file and say "yes" when your computer offers to
% install it for you. Once you've installed a font, you must quit and
% restart MATLAB to use the newly available font.
% 
% RUN SCRIPT. CriticalSpacing.m is meant to be driven by a brief
% user-written script. I have provided runCriticalSpacing as a example. You
% control the behavior of CriticalSpacing by setting parameters in the
% fields of a struct called "o". "o" defines a condition for which a
% threshold will be measured. If you provide several conditions, as an o
% array, then CriticalSpacing runs all the conditions interleaved,
% measuring a threshold for each. CriticalSpacing initially confirms the
% viewing distance, asks for the experimenter's and observer's names, and
% presents a page of instructions. The rest is just one eye chart after
% another, each showing one or two targets (with or without repetitions).
% Presentation can be brief or static (o.durationSec=inf).
% 
% EASE. Adults and children seem to find it easy and intuitive, but we've
% only tested a few children so far. Aenne Brielmann has designed an
% astronaut metaphar for children, to make it more like a game, which we
% plan to implement. Try running runCriticalSpacing. It measures four
% thresholds.
% 
% ESCAPE KEY. You can always terminate the current run by hitting the
% escape key on your keyboard (typically in upper left, labeled "esc").
% CriticalSpacing will then print out (and save to disk) results so far and
% begin the next run.
% 
% CAPS LOCK KEY: DISPLAY THE ALPHABET. Anytime that CriticalSpacing is
% running trials, pressing the caps lock key will display the font's
% alphabet at a large size, filling the screen. (The shift key works too,
% but it's dangerous on Windows. On Windows, pressing the shit key five
% times provokes a "sticky keys" dialog that you won't see because it's
% hidden behind the CriticalSpacing window, so you'll be stuck. The caps
% lock key is always safe.)
% 
% ESCAPE KEY: QUIT. You can always terminate the current run by hitting the
% escape key on your keyboard (typically in upper left, labeled "esc").
% CriticalSpacing will then print out (and save to disk) results so far and
% begin the next run.
% 
% SPACE KEY: SKIP THIS TRIAL. To make it easier to test children, we've
% softened the "forced" in forced choice. If you (the experimenter) think
% the observer is overwhelmed by this trial, you can press the spacebar
% instead of a letter and the program will immediately go to the next
% trial, which will be easier. If you skip that trial too, the next will be
% even easier, and so on. However, as soon as a trial gets a normal
% response then Quest will resume presenting trials near threshold. We hope
% skipping will make the initial experience easier. Eventually the child
% must still do trials near threshold, because threshold estimation
% requires it. Skipping is always available. If you type one letter and
% then skip, the typed letter still counts. There's an invisible timer.
% If you hit space (to skip) less than 8 s after the chart appeared, then
% the program says "Skip", and any responses not yet taken do not count. If
% you wait at least 8 s before hitting space, then the program says
% "Space" and, supposing that the child felt too unsure to choose
% knowledgeably, the program helps out by providing a random guess. By
% chance, that guess will occasionally be right. Please do not tell the
% observer about this option to skip. Use this only rarely, when you need
% it to avoid a crisis. In general it's important to set up the right
% expectation at the outset. Warn the observer that this is a game and
% nobody gets them all right. You just try to get as many as you can.
% 
% THRESHOLD. CriticalSpacing measures threshold spacing or size (i.e.
% acuity). This program measures threshold spacing in either of two
% directions, selected by the variable o.measureThresholdVertically, 1 for
% vertically, and 0 for horizontally. Target size can be made proportional
% to spacing, allowing measurement of critical spacing without knowing the
% acuity, because we use the largest possible letter for each spacing.
% 
% ECCENTRICITY. Set o.eccentricityDeg in your script. Current testing is
% focussed on eccentricity 0 using infinite duration. For peripheral
% testing, it's usually best to set o.durationSec=0.2 to prevent seeing the
% target after a foveating saccade triggers by the brief target
% presentation. When the flankers are radial, the specified spacing refers
% to the inner flanker, between target and fixation. We define scaling
% eccentricity as eccentricity plus 0.45 deg. The critical spacing of
% crowding is proportional to the scaling eccentricity. The outer flanker
% is at the scaling eccentricity that has the same ratio to the target
% scaling eccentricity, as the target scaling eccentricity does to the
% inner-flanker scaling eccentricity.
% 
% VIEWING DISTANCE. The minimum viewing distance depends the smallest
% letter size you want to show with 8 pixels and the resolution (pixels per
% centimeter) of your display. This is Eq. 4 in the Pelli et al. (2016)
% paper mentioned above.
% 
% minViewingDistanceCm=57*(minimumTargetPix/letterDeg)/(screenWidthPix/screenWidthCm);
% 
% where letterDeg=0.02, minimumTargetPix=8.
%
% PROGRAMMING ADVICE FOR KEYBOARD INPUT IN PSYCHTOOLBOX
% [PPT]Introduction to PsychToolbox in MATLAB - Jonas Kaplan
% www.jonaskaplan.com/files/psych599/Week6.pptx
%
% Copyright 2016, Denis Pelli, denis.pelli@nyu.edu
if nargin<1 || ~exist('oIn','var')
   oIn.script=[];
end

addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % "lib" folder in same directory as this file
clear Screen
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference','SkipSyncTests',1);

% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.

% SOUND & FEEDBACK
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0;
o.useSpeech=1;
o.speakEachLetter=1;
o.speakEncouragement=0;
o.speakViewingDistance=0;
o.showProgressBar=1;

% PROCEDURE
o.readAlphabetFromDisk=1;
o.takeSnapshot=0; % To illustrate your talk or paper.
o.fractionEasyTrials=0.2; % Add extra easy trials.
o.easyBoost=0.3; % Increase the log threshold parameter of easy trials by this much.
o.secsBeforeSkipCausesGuess=8;
% o.observer='junk';
% o.observer='Shivam'; % specify actual observer name
o.observer=''; % Name is requested at beginning of run.
o.experimenter='';
o.scriptName='';
o.scriptFullFileName='';
o.script='';
o.quit=0;
o.viewingDistanceCm=300;
o.flipScreenHorizontally=0;
o.useQuest=1; % true(1) or false(0)
o.thresholdParameter='spacing';
% o.thresholdParameter='size';
o.deviceIndex=-3; % all keyboard and keypad devices
o.trials=40; % number of trials for the threshold estimate
o.measureBeta=0;
o.task='identify';
if o.measureBeta
   o.trials=200;
   o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
end

% VISUAL STIMULUS

o.permissionToChangeResolution=0; % Works for main screen only, due to Psychtoolbox box.
o.repeatedTargets=1;
o.fourFlankers=0;
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.measureThresholdVertically=nan; % depends on parameter
o.setTargetHeightOverWidth=0;
o.minimumTargetPix=8; % Minimum viewing distance depends soley on this & pixPerCm.
o.eccentricityDeg=0; % location of target, relative to fixation, in degrees
% o.radialOrTangential='tangential'; % values 'radial', 'tangential'
o.radialOrTangential='radial'; % values 'radial', 'tangential'
o.durationSec=inf; % duration of display of target and flankers
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='N';
% o.borderLetter='!';
% o.targetFont='ClearviewText';
% o.targetFont='Gotham Cond SSm XLight';
% o.targetFont='Gotham Cond SSm Light';
% o.targetFont='Gotham Cond SSm Medium';
% o.targetFont='Gotham Cond SSm Book';
% o.targetFont='Gotham Cond SSm Bold';
% o.targetFont='Gotham Cond SSm Black';
% o.targetFont='Arouet';
% o.targetFont='Retina Micro';
% o.targetFont='Calibri';
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
o.targetFont='Pelli';
o.alphabet='123456789'; 
o.borderLetter='$';
o.targetDeg=nan;
o.spacingDeg=nan;

% FIXATION
o.fixationLocation='center'; % 'left', 'right'
o.targetCross=0;
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf;
o.fixationLineWeightDeg=0.02;

% DEBUGGING AIDS
o.showAlphabet=0;
o.frameTheTarget=0;
o.printSizeAndSpacing=0;
o.printScreenResolution=0;
o.showLineOfLetters=0;
o.showBounds=0;
o.speakSizeAndSpacing=0;
o.useFractionOfScreen=0;

% QUEST
o.beta=nan;
o.pThreshold=nan;
o.tGuess=nan;
o.tGuess=nan;
o.tGuessSd=nan;

% STARTING FROM ZERO
o.targetFontNumber=[];
o.easyCount=0;
o.guessCount=0; % artificial guesses
o.targetHeightOverWidth=nan;
o.textFont='Arial';
o.textSizeDeg=0.4;

% PROCESS INPUT.
% o is a single struct, and oIn may be an array of structs.
% Create oo, which replicates o for each condition.
conditions=length(oIn);
oo(1:conditions)=o;
inputFields=fieldnames(o);
clear o; % Now MATLAB will flag an error if we accidentally try to use "o".

% For each condition, all fields in the user-supplied "oIn" overwrite
% corresponding fields in "o". We ignore any field in oIn that is not
% already defined in o. If the ignored field is a known output field, then
% we ignore it silently. We give a warning of the unknown fields we ignore.
% These ignored fields may be typos for input fields.
outputFields={'beginSecs' 'beginningTime' 'cal' 'dataFilename' ...
   'dataFolder' 'eccentricityPix' 'fix' 'functionNames' ...
   'keyboardNameAndTransport' 'minimumSizeDeg' 'minimumSpacingDeg' ...
   'minimumViewingDistanceCm' 'normalAcuityDeg' ...
   'normalCriticalSpacingDeg' 'presentations' 'q' 'responseCount' ...
   'responseKeyCodes' 'results' 'screen' 'snapshotsFolder' 'spacings'  ...
   'spacingsSequence' 'targetFontHeightOverNominalPtSize' 'targetPix' ...
   'textSize' 'totalSecs' 'unknownFields' 'validKeyNames'};
unknownFields=cell(0);
for condition=1:conditions
   fields=fieldnames(oIn(condition));
   oo(condition).unknownFields=cell(0);
   for i=1:length(fields)
      if ismember(fields{i},inputFields)
         oo(condition).(fields{i})=oIn(condition).(fields{i});
      elseif ~ismember(fields{i},outputFields)
         unknownFields{end+1}=fields{i};
         oo(condition).unknownFields{end+1}=fields{i};
      end
   end
   oo(condition).unknownFields=unique(oo(condition).unknownFields);
end
unknownFields=unique(unknownFields);
if ~isempty(unknownFields)
   warning off backtrace
   warning(['Ignoring unknown o fields:' sprintf(' %s',unknownFields{:}) '.']);
   warning on backtrace
end

for condition=1:conditions
   switch oo(condition).thresholdParameter
      case 'size',
         if ~isfinite(oo(condition).measureThresholdVertically)
            oo(condition).measureThresholdVertically=1;
         end
      case 'spacing',
         assert(streq(oo(condition).radialOrTangential,'radial'));
         oo(condition).measureThresholdVertically=0;
   end
end
% Set up for KbCheck. We can safely use this mode AND collect kb responses
% without worrying about writing to MATLAB console/editor
ListenChar(2); % no echo
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]);
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
for condition=1:conditions
   oo(condition).validKeyNames=KeyNamesOfCharacters(oo(condition).alphabet);
   for i=1:length(oo(condition).validKeyNames)
      oo(condition).responseKeyCodes(i)=KbName(oo(condition).validKeyNames{i}); % this returns keyCode as integer
   end
end

% Set up for Screen
oo(1).screen=max(Screen('Screens'));
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',oo(1).screen);
screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',oo(1).screen);
if oo(1).useFractionOfScreen
   screenRect=round(oo(condition).useFractionOfScreen*screenRect);
   screenWidthCm=oo(condition).useFractionOfScreen*screenWidthCm;
end

for condition=1:conditions
   if ismember(oo(condition).borderLetter,oo(condition).alphabet)
      ListenChar(0);
      error('The o.borderLetter "%c" should not be included in the o.alphabet "%s".',oo(condition).borderLetter,oo(condition).alphabet);
   end
   assert(oo(condition).viewingDistanceCm==oo(1).viewingDistanceCm);
   assert(oo(condition).useFractionOfScreen==oo(1).useFractionOfScreen);
end

% Are we using the screen at its maximum native resolution?
ff=1;
res = Screen('Resolutions',oo(1).screen);
oo(1).nativeWidth=0;
oo(1).nativeHeight=0;
for i=1:length(res)
   if res(i).width>oo(1).nativeWidth
      oo(1).nativeWidth=res(i).width;
      oo(1).nativeHeight=res(i).height;
   end
end
actualScreenRect=Screen('Rect',oo(1).screen,1);
if oo(1).nativeWidth==RectWidth(actualScreenRect)
   ffprintf(ff,'Your screen resolution is at its native maximum %d x %d. Excellent!\n',oo(1).nativeWidth,oo(1).nativeHeight);
else
   warning backtrace off
   if oo(1).permissionToChangeResolution
      warning('Trying to change your screen resolution to be optimal for this test. ...');
      oo(1).oldResolution=Screen('Resolution',oo(1).screen,oo(1).nativeWidth,oo(1).nativeHeight);
      res=Screen('Resolution',oo(1).screen);
      if res.width==oo(1).nativeWidth
         fprintf('SUCCESS!\n');
      else
         warning('FAILED.');
         res
      end
      actualScreenRect=Screen('Rect',oo(1).screen,1);
   end
   if oo(1).nativeWidth==RectWidth(actualScreenRect)
      ffprintf(ff,'Your screen resolution is at its native maximum %d x %d. Excellent!\n',oo(1).nativeWidth,oo(1).nativeHeight);
   else
      if RectWidth(actualScreenRect)<oo(1).nativeWidth
         ffprintf(ff,'WARNING: Your screen resolution %d x %d is less that its native maximum %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
         warning('Your screen resolution %d x %d is less that its native maximum %d x %d. This will increase your minimum viewing distance %.1f-fold.',RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight,oo(1).nativeWidth/RectWidth(actualScreenRect));
      else
         ffprintf(ff,'WARNING: Your screen resolution %d x %d exceeds its maximum native resolution %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
         warning('Your screen resolution %d x %d exceeds its maximum native resolution %d x %d. This may be a problem.',RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
      end
      ffprintf(ff,'(You can use System Preferences:Displays to change resolution.)\n');
      ffprintf(ff,'(Set your screen to maximum native resolution, or, if you have a Retina/HiDPI screen, then set it to half maximum native.)\n');
      warning backtrace on
   end
end
oo(1).resolution=Screen('Resolution',oo(1).screen);
   
try
   black=0;
   white=255;
   %     white=WhiteIndex(window);
   %     black=BlackIndex(window);
   oo(1).screen=max(Screen('Screens'));
   computer=Screen('Computer');
   if computer.osx || computer.macintosh
      AutoBrightness(oo(1).screen,0); % Do this BEFORE opening the window, so user can see any alerts.
   end
   screenBufferRect=Screen('Rect',oo(1).screen);
   screenRect=Screen('Rect',oo(1).screen,1);
   [window,r]=OpenWindow(oo(1));
   if oo(1).printScreenResolution
      screenBufferRect=Screen('Rect',oo(1).screen)
      screenRect=Screen('Rect',oo(1).screen,1)
      resolution=Screen('Resolution',oo(1).screen)
   end
   
   for condition=1:conditions
      if ~oo(condition).readAlphabetFromDisk
         % Check availability of fonts.
         if IsOSX
            fontInfo=FontInfo('Fonts');
            % Match full name, including style.
            hits=streq({fontInfo.name},oo(condition).targetFont);
            if sum(hits)<1
               % Match family name, omitting style.
               hits=streq({fontInfo.familyName},oo(condition).targetFont);
            end
            if sum(hits)==0
               error('The o.targetFont "%s" is not available. Please install it.',oo(condition).targetFont);
            end
            if sum(hits)>1
               error('Multiple fonts with name "%s".',oo(condition).targetFont);
            end
            oo(condition).targetFontNumber=fontInfo(hits).number;
            Screen('TextFont',window,oo(condition).targetFontNumber);
            [~,number]=Screen('TextFont',window);
            if ~(number==oo(condition).targetFontNumber)
               error('The o.targetFont "%s" is not available. Please install it.',oo(condition).targetFont);
            end
         else
            oo(condition).targetFontNumber=[];
            Screen('TextFont',window,oo(condition).targetFont);
            font=Screen('TextFont',window);
            if ~streq(font,oo(condition).targetFont)
               error('The o.targetFont "%s" is not available. Please install it.',oo(condition).targetFont);
            end
         end
         % Due to a bug in Screen TextFont (in December 2015), it is
         % imperative to specify a style number of zero in the next call
         % after calling it with a fontNumber, as we did above.
         Screen('TextFont',window,oo(condition).textFont,0);
         font=Screen('TextFont',window);
         if ~streq(font,oo(condition).textFont)
            warning off backtrace
            warning('The o.textFont "%s" is not available. Using %s instead.',oo(condition).textFont,font);
            warning on backtrace
         end
      end % if ~oo(1).readAlphabetFromDisk
   end
   
   screenRect=Screen('Rect',window);
   screenWidth=RectWidth(screenRect);
   screenHeight=RectHeight(screenRect);
   if oo(1).useFractionOfScreen
      pixPerDeg=screenWidth/(oo(1).useFractionOfScreen*screenWidthCm*57/oo(1).viewingDistanceCm);
   else
      pixPerDeg=screenWidth/(screenWidthCm*57/oo(1).viewingDistanceCm);
   end
   for condition=1:conditions
      % Adjust textSize so our string fits on screen.
      instructionalMargin=round(0.08*min(RectWidth(screenRect),RectHeight(screenRect)));
      oo(condition).textSize=round(oo(condition).textSizeDeg*pixPerDeg);
      Screen('TextSize',window,oo(condition).textSize);
      Screen('TextFont',window,oo(condition).textFont,0);
      font=Screen('TextFont',window);
      if ~streq(font,oo(condition).textFont)
         warning off backtrace
         warning('The o.textFont "%s" is not available. Using %s instead.',oo(condition).textFont,font);
         warning on backtrace
      end
      instructionalTextLineSample='Please slowly type your name followed by RETURN. more.....more';
      boundsRect=Screen('TextBounds',window,instructionalTextLineSample);
      fraction=RectWidth(boundsRect)/(screenWidth-2*instructionalMargin);
      oo(condition).textSize=round(oo(condition).textSize/fraction);
   end
   
   % Ask about viewing distance
   while 1
      if oo(1).useFractionOfScreen
         pixPerDeg=screenWidth/(oo(1).useFractionOfScreen*screenWidthCm*57/oo(1).viewingDistanceCm);
      else
         pixPerDeg=screenWidth/(screenWidthCm*57/oo(1).viewingDistanceCm);
      end
      
      for condition=1:conditions
         oo(condition).viewingDistanceCm=oo(1).viewingDistanceCm;
         oo(condition).normalAcuityDeg=0.029*(abs(oo(condition).eccentricityDeg)+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
         if ismember(oo(condition).targetFont,{'Solid','Pelli'})
            oo(condition).normalAcuityDeg=oo(condition).normalAcuityDeg/5; % For Solid font.
         end
         oo(condition).normalCriticalSpacingDeg=0.3*(abs(oo(condition).eccentricityDeg)+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
         if oo(condition).eccentricityDeg==0
            oo(condition).normalCriticalSpacingDeg=0.05;
         end
         normalOverMinimumSize=oo(condition).normalAcuityDeg*pixPerDeg/oo(condition).minimumTargetPix;
         if streq(oo(condition).thresholdParameter,'spacing') && oo(condition).fixedSpacingOverSize
            normalOverMinimumSize=min(normalOverMinimumSize,oo(condition).normalCriticalSpacingDeg*pixPerDeg/oo(condition).fixedSpacingOverSize/oo(condition).minimumTargetPix);
         end
         oo(condition).minimumViewingDistanceCm=10*ceil((2/normalOverMinimumSize)*oo(condition).viewingDistanceCm/10);
      end
      minimumViewingDistanceCm=max([oo.minimumViewingDistanceCm]);
      if oo(1).speakViewingDistance && oo(1).useSpeech
         Speak(sprintf('Please move the screen to be %.0f centimeters from your eye.',oo(1).viewingDistanceCm));
      end
      Screen('FillRect',window,white);
      string=sprintf('Please move me to be %.0f cm from your eye.',oo(1).viewingDistanceCm);
      for condition=1:conditions
         oo(condition).minimumSizeDeg=oo(condition).minimumTargetPix/pixPerDeg;
         if oo(condition).fixedSpacingOverSize
            oo(condition).minimumSpacingDeg=oo(condition).fixedSpacingOverSize*oo(condition).minimumSizeDeg;
         else
            oo(condition).minimumSpacingDeg=1.1*oo(condition).minimumTargetPix/pixPerDeg;
         end
      end
      sizeDeg=max([oo.minimumSizeDeg]);
      spacingDeg=max([oo.minimumSpacingDeg]);
      string=sprintf('%s At this viewing distance, I can display letters as small as %.3f deg with spacing as small as %.3f deg.',string,sizeDeg,spacingDeg);
      string=sprintf('%s If that''s ok, hit RETURN. For ordinary testing, view me from at least %.0f cm.',string,minimumViewingDistanceCm);
      string=sprintf('%s To change your viewing distance, slowly type the new distance below, and hit RETURN.',string);
      string=sprintf('%s Enter a minus sign before the distance if you''re using a mirror.',string);
      Screen('TextSize',window,oo(1).textSize);
      [~,y]=DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,length(instructionalTextLineSample)+3,[],[],1.1);
      
      % Look for external keyboard.
      clear PsychHID; % Force new enumeration of devices to detect external keyboard.
      clear KbCheck; % Clear cache of keyboard devices.
      [~,~,devices]=GetKeyboardIndices;
      for i=1:length(devices)
         oo(1).keyboardNameAndTransport{i}=sprintf('%s (%s)',devices{i}.product,devices{i}.transport);
      end
      if length(GetKeyboardIndices)<2 && oo(1).viewingDistanceCm>100
         warning backtrace off
         warning('You have only one keyboard. The long viewing distance may demand an external keyboard.');
         warning backtrace on
         string=sprintf('WARNING: At this distance you may need an external keyboard, but I can''t detect any. To help you connect a keyboard, I''ll recreate the keyboard list if you type the viewing distance below, followed by RETURN.');
         Screen('TextSize',window,round(oo(1).textSize*0.6));
         DrawFormattedText(window,string,instructionalMargin,y+2*oo(1).textSize,black,length(instructionalTextLineSample)/0.6,[],[],1.1);
      end
      
      Screen('TextSize',window,round(oo(1).textSize*0.4));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      d=GetEchoString(window,'Viewing distance (cm):',instructionalMargin,0.82*screenRect(4),black,[],1,oo(1).deviceIndex);
      if ~isempty(d)
         inputDistanceCm=str2num(d);
         if ~isempty(inputDistanceCm) && inputDistanceCm~=0
            oo(1).viewingDistanceCm=abs(inputDistanceCm);
            oldFlipScreenHorizontally=oo(1).flipScreenHorizontally;
            oo(1).flipScreenHorizontally=inputDistanceCm<0;
            if oo(1).flipScreenHorizontally ~= oldFlipScreenHorizontally
               if oo(1).useSpeech
                  Speak('Now flipping the display.');
               end
               Screen('Close',window);
               window=OpenWindow(oo(1));
            end
         end
      else
         break;
      end
   end
   %    if normalOverMinimumSize<2
   %       msg=sprintf('Please increase your viewing distance to at least %.0f cm. This is called "o.viewingDistanceCm" in your script.',oo(condition).minimumViewingDistanceCm);
   %       if oo(condition).useSpeech
   %          Speak('You are too close to the screen.');
   %          Speak(msg);
   %       end
   %       error(msg);
   %    end
   ListenChar(0); % flush
   ListenChar(2); % no echo
   
   % Ask experimenter name
   if length(oo(1).experimenter)==0
      Screen('FillRect',window);
      Screen('TextFont',window,oo(1).textFont,0);
      Screen('DrawText',window,'',instructionalMargin,screenRect(4)/2-4.5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Hello Experimenter,',instructionalMargin,screenRect(4)/2-5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',instructionalMargin,screenRect(4)/2-3*oo(1).textSize,black,white);
      Screen('TextSize',window,round(0.7*oo(1).textSize));
      Screen('DrawText',window,'You can skip these screens by defining o.experimenter and o.observer in your script.',instructionalMargin,screenRect(4)/2-1.5*oo(1).textSize,black,white);
      Screen('TextSize',window,round(oo(1).textSize*0.4));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      name=GetEchoString(window,'Experimenter name:',instructionalMargin,screenRect(4)/2,black,[],1,oo(1).deviceIndex);
      for i=1:conditions
         oo(i).experimenter=name;
      end
      Screen('FillRect',window);
   end
   
   % Ask observer name
   if length(oo(1).observer)==0
      Screen('FillRect',window);
      Screen('TextSize',window,oo(1).textSize);
      Screen('TextFont',window,oo(1).textFont,0);
      Screen('DrawText',window,'',instructionalMargin,screenRect(4)/2-4.5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Hello Observer,',instructionalMargin,screenRect(4)/2-5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',instructionalMargin,screenRect(4)/2-3*oo(1).textSize,black,white);
      Screen('TextSize',window,round(oo(1).textSize*0.4));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      name=GetEchoString(window,'Observer name:',instructionalMargin,screenRect(4)/2,black,[],1,oo(1).deviceIndex);
      for i=1:conditions
         oo(i).observer=name;
      end
      Screen('FillRect',window);
   end
   
   oo(1).beginSecs=GetSecs;
   oo(1).beginningTime=now;
   timeVector=datevec(oo(1).beginningTime);
   stack=dbstack;
   assert(~isempty(stack));
   if length(stack)==1;
      oo(1).scriptName=[];
      oo(1).functionNames=stack.name;
   else
      oo(1).scriptName=[stack(2).name '.m'];
      oo(1).functionNames=[stack(2).name '-' stack(1).name];
   end
   if ~isempty(oo(1).scriptName)
      oo(1).scriptFullFileName=which(oo(1).scriptName);
      oo(1).script=fileread(oo(1).scriptFullFileName);
      assert(~isempty(oo(1).script));
   else
      oo(1).script=[];
   end
   oo(1).snapshotsFolder=fullfile(fileparts(mfilename('fullpath')),'snapshots');
   if ~exist(oo(1).snapshotsFolder,'dir')
      [success,msg]=mkdir(oo(1).snapshotsFolder);
      if ~success
         error('%s. Could not create snapshots folder: %s',msg,oo(1).snapshotsFolder);
      end
   end
   oo(1).dataFilename=sprintf('%s-%s-%s.%d.%d.%d.%d.%d.%d',oo(1).functionNames,oo(1).experimenter,oo(1).observer,round(timeVector));
   oo(1).dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   if ~exist(oo(1).dataFolder,'dir')
      [success,msg]=mkdir(oo(1).dataFolder);
      if ~success
         error('%s. Could not create data folder: %s',msg,oo(1).dataFolder);
      end
   end
   dataFid=fopen(fullfile(oo(1).dataFolder,[oo(1).dataFilename '.txt']),'rt');
   if dataFid~=-1
      error('Oops. There''s already a file called "%s.txt". Try again.',oo(1).dataFilename);
   end
   [dataFid,msg]=fopen(fullfile(oo(1).dataFolder,[oo(1).dataFilename '.txt']),'wt');
   if dataFid==-1
      error('%s. Could not create data file: %s',msg,[oo(1).dataFilename '.txt']);
   end
   assert(dataFid>-1);
   ff=[1 dataFid];
   ffError=[2 dataFid];
   ffprintf(ff,'\n%s %s\n',oo(1).functionNames,datestr(now));
   ffprintf(ff,'Saving results in:\n');
   ffprintf(ff,'/data/%s.txt and "".mat\n',oo(1).dataFilename);
   for condition=1:conditions
      if ~isempty(oo(condition).unknownFields)
         ffprintf(ff,['%d: Ignoring unknown o fields:' sprintf(' %s',oo(condition).unknownFields{:}) '.\n'],condition);
      end
   end
   for condition=1:conditions
      if oo(condition).showProgressBar
         progressBarRect=[round(screenRect(3)*(1-1/screenWidthCm)) 0 screenRect(3) screenRect(4)]; % 1 cm wide.
      end
      if oo(condition).repeatedTargets
         oo(condition).presentations=ceil(oo(condition).trials/2);
         oo(condition).trials=2*oo(condition).presentations;
      else
         oo(condition).presentations=oo(condition).trials;
      end
      stimulusRect=screenRect;
      if oo(condition).showProgressBar
         stimulusRect(3)=progressBarRect(1);
      end
      % prepare to draw fixation cross
      fixationCrossPix=round(oo(condition).fixationCrossDeg*pixPerDeg);
      fixationCrossPix=min(fixationCrossPix,2*RectWidth(stimulusRect)); % full width and height, can extend off screen
      fixationLineWeightPix=round(oo(condition).fixationLineWeightDeg*pixPerDeg);
      fixationLineWeightPix=max(1,fixationLineWeightPix);
      fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
      oo(condition).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
      switch oo(condition).fixationLocation
         case 'left',
            oo(condition).fix.x=50+stimulusRect(1);
         case 'center',
            oo(condition).fix.x=(stimulusRect(1)+stimulusRect(3))/2; % location of fixation
         case 'right',
            oo(condition).fix.x=stimulusRect(3)-50;
         otherwise
            error('Unknown o.fixationLocation %s',oo(condition).fixationLocation);
      end
      oo(condition).fix.x=round(oo(condition).fix.x);
      oo(condition).fix.y=round(RectHeight(stimulusRect)/2);
      oo(condition).eccentricityPix=round(oo(condition).eccentricityDeg*pixPerDeg);
      oo(condition).fix.eccentricityPix=oo(condition).eccentricityPix;
      oo(condition).fix.clipRect=stimulusRect;
      oo(condition).fix.fixationCrossPix=fixationCrossPix;
      oo(condition).fix.fixationCrossBlankedNearTarget=oo(condition).fixationCrossBlankedNearTarget;
      
      oo(condition).responseCount=1; % When we have two targets we get two responses for each displayed screen.
      if isfield(oo(condition),'targetDegGuess') && isfinite(oo(condition).targetDegGuess)
         oo(condition).targetDeg=oo(condition).targetDegGuess;
      else
         oo(condition).targetDeg=2*oo(condition).normalAcuityDeg; % initial guess for threshold size.
      end
      if oo(condition).eccentricityPix>=0
         % target fits on screen, with half-target margin.
         maxEccPix=round(max(0,stimulusRect(3)-oo(condition).fix.x-pixPerDeg*oo(condition).targetDeg));
         minEccPix=0;
      else
         % target fits on screen, with half-target margin.
         minEccPix=round(min(0,stimulusRect(1)-oo(condition).fix.x+pixPerDeg*oo(condition).targetDeg));
         maxEccPix=0;
      end
      oldEccDeg=oo(condition).eccentricityDeg;
      reducing=oo(condition).eccentricityPix<minEccPix || oo(condition).eccentricityPix>maxEccPix;
      oo(condition).eccentricityPix=max(minEccPix,min(maxEccPix,oo(condition).eccentricityPix));
      oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
      if reducing
         ffprintf(ff,'%d: Reducing eccentricity from %.1f to %.1f deg, to accomodate %.1f deg target on %.1 deg-wide screen.\n',...
            condition,oldEccDeg,oo(condition).eccentricityDeg,oo(condition).targetDeg,RectWidth(stimulusRect)/pixPerDeg);
      end
      addonDeg=0.45;
      addonPix=pixPerDeg*addonDeg;
      if isfield(oo(condition),'spacingDegGuess') && isfinite(oo(condition).spacingDegGuess)
         oo(condition).spacingDeg=oo(condition).spacingDegGuess;
      else
         oo(condition).spacingDeg=oo(condition).normalCriticalSpacingDeg; % initial guess for distance from center of middle letter
      end
      if streq(oo(condition).thresholdParameter,'spacing') && streq(oo(condition).radialOrTangential,'radial')
         assert(oo(condition).eccentricityPix>=0);
         oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(stimulusRect)-oo(condition).fix.x-pixPerDeg*(oo(condition).spacingDeg+oo(condition).targetDeg/2))); % flanker fits on screen.
         oo(condition).eccentricityPix=max(oo(condition).eccentricityPix,0);
         assert(oo(condition).eccentricityPix>=0);
         oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
         oo(condition).normalCriticalSpacingDeg=0.3*(abs(oo(condition).eccentricityDeg)+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
         oo(condition).spacingDeg=oo(condition).normalCriticalSpacingDeg; % initial guess for distance from center of middle letter
      end
      oo(condition).spacings=oo(condition).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
      oo(condition).spacingsSequence=repmat(oo(condition).spacings,1,ceil(oo(condition).presentations/length(oo(condition).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of presentations.
      if oo(condition).useQuest
         if oo(condition).measureThresholdVertically
            ori='vertical';
         else
            ori='horizontal';
         end
         ffprintf(ff,'%d: %.0f trials of QUEST will measure threshold %s %s.\n',condition,oo(condition).trials,ori,oo(condition).thresholdParameter);
      else
         if oo(condition).measureThresholdVertically
            ori='vertical';
         else
            ori='horizontal';
         end
         ffprintf(ff,'%d: %.0f trials of "method of constant stimuli" with fixed list of %s spacings [',condition,oo(condition).trials,ori);
         ffprintf(ff,'%.1f ',oo(condition).spacings);
         ffprintf(ff,'] deg\n');
      end
      
      % Measure targetHeightOverWidth
      oo(condition).targetFontHeightOverNominalPtSize=nan;
      oo(condition).targetPix=200;
      % Get bounds.
      [letterStruct,alphabetBounds]=CreateLetterTextures(condition,oo(condition),window);
      DestroyLetterTextures(letterStruct);
      oo(condition).targetHeightOverWidth=RectHeight(alphabetBounds)/RectWidth(alphabetBounds);
      if ~oo(condition).readAlphabetFromDisk
         oo(condition).targetFontHeightOverNominalPtSize=RectHeight(alphabetBounds)/oo(condition).targetPix;
      end
      oo(condition).targetPix=oo(condition).targetDeg*pixPerDeg;
   
      for cd=1:conditions
         for i=1:length(oo(cd).validKeyNames)
            oo(cd).responseKeyCodes(i)=KbName(oo(cd).validKeyNames{i}); % this returns keyCode as integer
         end
      end
      
      % Set o.targetHeightOverWidth
      if oo(condition).setTargetHeightOverWidth
         oo(condition).targetHeightOverWidth=oo(condition).setTargetHeightOverWidth
      end
      
      % prepare to draw fixation cross
      oo(condition).fix.targetHeightPix=oo(condition).targetPix;
      oo(condition).fix.targetCross=oo(condition).targetCross;
      oo(condition).fix.targetHeightOverWidth=oo(condition).targetHeightOverWidth;
      fixationLines=ComputeFixationLines(oo(condition).fix);
      
      terminate=0;
      
      switch oo(condition).thresholdParameter
         case 'spacing',
            assert(oo(condition).spacingDeg>0);
            oo(condition).tGuess=log10(oo(condition).spacingDeg);
         case 'size',
            assert(oo(condition).targetDeg>0);
            oo(condition).tGuess=log10(oo(condition).targetDeg);
      end
      oo(condition).tGuessSd=2;
      oo(condition).pThreshold=0.7;
      oo(condition).beta=3;
      delta=0.01;
      gamma=1/length(oo(condition).alphabet);
      grain=0.01;
      range=6;
   end % for condition=1:conditions
   
   cal.screen=max(Screen('Screens'));
   if cal.screen>0
      ffprintf(ff,'Using external monitor.\n');
   end
   for condition=1:conditions
      ffprintf(ff,'%d: ',condition);
      if oo(condition).repeatedTargets
         numberTargets='two targets (repeated many times)';
      else
         numberTargets='one target';
      end
      ffprintf(ff,'Observer %s, %s %s, alternatives %d,  beta %.1f,\n',oo(condition).observer,oo(condition).task,numberTargets,length(oo(condition).alphabet),oo(condition).beta);
   end
   for condition=1:conditions
      if streq(oo(condition).thresholdParameter,'spacing')
         if ~oo(condition).repeatedTargets
            if oo(condition).eccentricityDeg~=0
               ffprintf(ff,'%d: Orientation %s\n',condition,oo(condition).radialOrTangential);
            end
         end
      end
   end
   for condition=1:conditions
      if oo(condition).fixedSpacingOverSize
         ffprintf(ff,'%d: Fixed ratio of spacing over size %.2f.\n',condition,oo(condition).fixedSpacingOverSize);
      else
         if streq(oo(condition).thresholdParameter,'size')
            ffprintf(ff,'%d: Measuring threshold size, with no flankers.\n',condition);
         else
            ffprintf(ff,'%d: Target size %.2f deg, %.1f pixels.\n',condition,oo(condition).targetDeg,oo(condition).targetDeg*pixPerDeg);
         end
      end
   end
   for condition=1:conditions
      ffprintf(ff,'%d: Viewing distance %.0f cm. (Must exceed %.0f cm to produce %.3f deg letter.)\n',condition,oo(condition).viewingDistanceCm,oo(condition).minimumViewingDistanceCm,oo(condition).normalAcuityDeg/2);
   end
   ffprintf(ff,'1: %d keyboards: ',length(oo(1).keyboardNameAndTransport));
   for ii=1:length(oo(1).keyboardNameAndTransport)
      ffprintf(ff,'%s,  ',oo(1).keyboardNameAndTransport{ii});
   end
   ffprintf(ff,'\n');
   for condition=1:conditions
      sizesPix=oo(condition).minimumTargetPix*[oo(condition).targetHeightOverWidth 1];
      ffprintf(ff,'%d: Minimum letter size %.0fx%.0f pixels, %.3fx%.3f deg. ',condition,sizesPix,sizesPix/pixPerDeg);
      if oo(condition).fixedSpacingOverSize
         spacingPix=round(oo(condition).minimumTargetPix*oo(condition).fixedSpacingOverSize);
         ffprintf(ff,'Minimum spacing %.0f pixels, %.3f deg.\n',spacingPix,spacingPix/pixPerDeg);
      else
         ffprintf(ff,'Spacing %.0f pixels, %.3f deg.\n',oo(condition).spacingPix,oo(condition).spacingDeg);
      end
   end
   for condition=1:conditions
      if oo(condition).readAlphabetFromDisk
         ffprintf(ff,'%d: %s font from disk. ',condition,oo(condition).targetFont);
      else
         ffprintf(ff,'%d: %s font, live. ',condition,oo(condition).targetFont);
      end
      ffprintf(ff,'Alphabet ''%s'' and borderLetter ''%s''.\n',oo(condition).alphabet,oo(condition).borderLetter);
   end
   for condition=1:conditions
      ffprintf(ff,'%d: %s font o.targetHeightOverWidth %.2f, targetFontHeightOverNominalPtSize %.2f\n',condition,oo(condition).targetFont,oo(condition).targetHeightOverWidth,oo(condition).targetFontHeightOverNominalPtSize);
   end
   for condition=1:conditions
      ffprintf(ff,'%d: durationSec %.2f, eccentricityDeg %.1f\n',condition,oo(condition).durationSec,oo(condition).eccentricityDeg);
   end
   ffprintf(ff,'Viewing distance %.0f cm. ',oo(1).viewingDistanceCm);
%    ffprintf(ff,'Window width %d pix %.1f cm. ',RectWidth(Screen('Rect',window)),screenWidthCm);
%    ffprintf(ff,'pixPerDeg %.2f\n',pixPerDeg);
   
   % Identify the computer
   cal.screen=0;
   computer=Screen('Computer');
   [cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
   if computer.windows
      cal.processUserLongName=getenv('USERNAME');
      cal.machineName=getenv('USERDOMAIN');
      cal.macModelName=[];
   elseif computer.linux
      cal.processUserLongName=getenv('USER');
      cal.machineName=computer.machineName;
      cal.osversion=computer.kern.version;
      cal.macModelName=[];
   elseif computer.osx || computer.macintosh
      cal.processUserLongName=computer.processUserLongName;
      cal.machineName=strrep(computer.machineName,'éˆ??',''''); % work around bug in Screen('Computer')
      cal.macModelName=MacModelName;
   end
   cal.screenOutput=[]; % only for Linux
   cal.ScreenConfigureDisplayBrightnessWorks=1; % default value
   cal.brightnessSetting=1.00; % default value
   cal.brightnessRMSError=0; % default value
   [screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
   cal.screenWidthCm=screenWidthMm/10;
   actualScreenRect=Screen('Rect',cal.screen,1);
%    ffprintf(ff,'Screen width buffer %d, display %d. ',RectWidth(Screen('Rect',cal.screen)),RectWidth(Screen('Rect',cal.screen,1)));
%    ffprintf(ff,'Window width buffer %d, display %d.\n',RectWidth(Screen('Rect',window)),RectWidth(Screen('Rect',window,1)));
   ffprintf(ff,'%s, %s, %s\n',cal.processUserLongName,cal.machineName,cal.macModelName);
   ffprintf(ff,'screen %d, %dx%d pixels, %.1fx%.1f cm, %.1fx%.1f deg, %.0f pix/cm, %.0f pixPerDeg.\n',...
      cal.screen,RectWidth(actualScreenRect),RectHeight(actualScreenRect),...
      screenWidthMm/10,screenHeightMm/10,...
      RectWidth(actualScreenRect)/pixPerDeg,RectHeight(actualScreenRect)/pixPerDeg,...
      RectWidth(actualScreenRect)/(screenWidthMm/10),pixPerDeg);
   assert(cal.screenWidthCm==screenWidthMm/10);
   cal.ScreenConfigureDisplayBrightnessWorks=1;
   if cal.ScreenConfigureDisplayBrightnessWorks
      cal.brightnessSetting=1;
      % ffprintf(ff,'Turning autobrightness off. Setting "brightness" to %.2f, on a scale of 0.0 to 1.0;\n',cal.brightnessSetting);
      % Psychtoolbox Bug: Screen ConfigureDisplay claims that it will
      % silently do nothing if not supported. But when I used it on my
      % video projector, Screen gave a fatal error. That's tolerable, but
      % how do I figure out when it's safe to use?
      if computer.osx || computer.macintosh
         Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
      end
   end
   for condition=1:conditions
      oo(condition).cal=cal;
   end
   
   rightBeep=0.05*MakeBeep(2000,0.05,44100);
   rightBeep(end)=0;
   wrongBeep=0.05*MakeBeep(500,0.5,44100);
   wrongBeep(end)=0;
   purr=MakeBeep(140,1.0,44100);
   purr(end)=0;
   Snd('Open');
   
   % Instructions
   usingDigits=0;
   usingLetters=0;
   for conditions=1:conditions
      usingDigits=usingDigits || all(ismember(oo(condition).alphabet,'0123456789'));
      usingLetters=usingLetters || any(~ismember(oo(condition).alphabet,'0123456789'));
   end
   if usingDigits && usingLetters
      symbolName='character';
   elseif usingDigits && ~usingLetters
      symbolName='digit';
   elseif ~usingDigits && usingLetters
      symbolName='letter';
   elseif  ~usingDigits && ~usingLetters
      error('Targets are neither digits nor letters');
   end
   Screen('FillRect',window,white);
   string=[sprintf('Hello %s,  ',oo(condition).observer)];
   string=[string 'Please turn the computer sound on. '];
   string=[string 'Press CAPS LOCK at any time to see the alphabet of possible letters. '];
   string=[string 'You might also have the alphabet on a piece of paper. '];
   string=[string 'You can respond by typing, speaking, or pointing to a letter on your piece of paper. '];
   for condition=1:conditions
      if ~oo(condition).repeatedTargets && streq(oo(condition).thresholdParameter,'size')
         string=[string 'When you see a letter, please report it. '];
         break;
      end
   end
   for condition=1:conditions
      if ~oo(condition).repeatedTargets && streq(oo(condition).thresholdParameter,'spacing')
         string=[string 'When you see three letters, please report just the middle letter. '];
         break;
      end
   end
   if any([oo.repeatedTargets])
      string=[string 'When you see many letters, they are all repetitions of just two different letters. Please report both. '];
      string=[string 'The two kinds of letter can be mixed over the whole display, or segregated onto left and right sides. '];
   end
   string=[string 'Sometimes the letters will be easy to identify. Sometimes they will be nearly impossible. '];
   string=[string 'You can''t get much more than half right, so relax. Think of it as a guessing game, and just get as many as you can. '];
   string=[string '(Type slowly. Quit anytime by pressing ESCAPE.) '];
   if ~any(isfinite([oo.durationSec]))
      string=[string 'Look in the middle of the screen, ignoring the edges of the screen. '];
   end
   string=[string 'Now, to begin, please press the SPACEBAR. '];
   Screen('TextFont',window,oo(condition).textFont,0);
   Screen('TextSize',window,round(oo(condition).textSize*0.4));
   Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
   Screen('TextSize',window,oo(condition).textSize);
   string=strrep(string,'letter',symbolName);
   DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,length(instructionalTextLineSample)+3,[],[],1.1);
   Screen('Flip',window,[],1);
   SetMouse(screenRect(3),screenRect(4),window);
   answer=GetKeypressWithHelp([spaceKeyCode escapeKeyCode],oo(condition),window,stimulusRect);

   Screen('FillRect',window); % xxx
   if streq(answer,'ESCAPE')
      if oo(1).speakEachLetter && oo(1).useSpeech
         Speak('Escape. This run is done.');
      end
      ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
      oo(1).quit=1;
      ListenChar(0);
      ShowCursor;
      sca;
      return
   end
   fixationClipRect=stimulusRect;
   if any(isfinite([oo.durationSec]))
      string='Please use the crosshairs on every trial. ';
      string=[string 'To begin, please fix your gaze at the center of crosshairs below, and, while fixating, press the SPACEBAR. '];
      string=strrep(string,'letter',symbolName);
      fixationClipRect(2)=5*oo(condition).textSize;
      x=50;
      y=0.3*oo(1).textSize;
      Screen('TextSize',window,oo(condition).textSize);
      DrawFormattedText(window,string,x,y,black,length(instructionalTextLineSample)+3,[],[],1.1);
      Screen('Flip',window,[],1); % Don't clear.
      beginAfterKeypress=1;
   else
      beginAfterKeypress=0;
   end
   easeRequest=0; % Positive to request easier trials.
   easyCount=0; % Number of easy presentations
   guessCount=0; % Number of artificial guess responses
   skipCount=0;
   skipping=0;
   condList=[];
   for condition=1:conditions
      % Run the specified number of presentations of each condition, in
      % random order
      condList = [condList repmat(condition,1,oo(condition).presentations)];
      oo(condition).spacingsSequence=Shuffle(oo(condition).spacingsSequence);
      oo(condition).q=QuestCreate(oo(condition).tGuess,oo(condition).tGuessSd,oo(condition).pThreshold,oo(condition).beta,delta,gamma,grain,range);
   end
   condList=Shuffle(condList);
   presentation=0;
   while presentation<length(condList)
      presentation=presentation+1;
      condition=condList(presentation);
      easyModulus=ceil(1/oo(condition).fractionEasyTrials-1);
      easyPresentation= easeRequest>0 || mod(presentation-1,easyModulus)==0;
      if oo(condition).useQuest
         intensity=QuestQuantile(oo(condition).q);
         if oo(condition).measureBeta
            offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
            intensity=intensity+offsetToMeasureBeta(1);
         end
         if easyPresentation
            easyCount=easyCount+1;
            oo(condition).easyCount=oo(condition).easyCount+1;
            intensity=intensity+oo(condition).easyBoost;
            if easeRequest>1
               intensity=intensity+(easeRequest-1)*oo(condition).easyBoost;
            end
         end
         switch oo(condition).thresholdParameter
            case 'spacing',
               oo(condition).spacingDeg=10^intensity;
               if oo(condition).fixedSpacingOverSize
                  oo(condition).targetDeg=oo(condition).spacingDeg/oo(condition).fixedSpacingOverSize;
               end
            case 'size',
               oo(condition).targetDeg=10^intensity;
         end
      else
         oo(condition).spacingDeg=oo(condition).spacingsSequence(ceil(oo(condition).responseCount/2));
      end
      oo(condition).targetPix=oo(condition).targetDeg*pixPerDeg;
      oo(condition).targetPix=max(oo(condition).targetPix,oo(condition).minimumTargetPix);
      if oo(condition).measureThresholdVertically
         oo(condition).targetPix=max(oo(condition).targetPix,oo(condition).minimumTargetPix*oo(condition).targetHeightOverWidth);
      end
      oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
      if streq(oo(condition).thresholdParameter,'size') && oo(condition).fixedSpacingOverSize
         oo(condition).spacingDeg=oo(condition).targetDeg*oo(condition).fixedSpacingOverSize;
      end
      spacingPix=oo(condition).spacingDeg*pixPerDeg;
      if oo(condition).fixedSpacingOverSize
         spacingPix=max(spacingPix,oo(condition).minimumTargetPix*oo(condition).fixedSpacingOverSize);
      end
      if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetFontHeightOverNominalPtSize %.2f, targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',condition,MFileLineNr,oo(condition).targetFontHeightOverNominalPtSize,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
      if oo(condition).repeatedTargets
         if RectHeight(stimulusRect)/RectWidth(stimulusRect) > oo(condition).targetHeightOverWidth;
            minSpacesY=4;
            minSpacesX=2;
         else
            minSpacesY=2;
            minSpacesX=4;
         end
      else
         % Just one target
         if oo(condition).fourFlankers
            minSpacesY=2;
            minSpacesX=2;
         else
            if oo(condition).measureThresholdVertically
               minSpacesY=2;
               minSpacesX=0;
            else
               minSpacesY=0;
               minSpacesX=2;
            end
         end
      end
      if oo(condition).measureThresholdVertically
         % vertical threshold
         if oo(condition).fixedSpacingOverSize
            spacingPix=min(spacingPix,floor(RectHeight(stimulusRect)/(minSpacesY+1/oo(condition).fixedSpacingOverSize)));
            spacingPix=min(spacingPix,floor(oo(condition).targetHeightOverWidth*RectWidth(stimulusRect)/(minSpacesX+1/oo(condition).fixedSpacingOverSize)));
            oo(condition).targetPix=spacingPix/oo(condition).fixedSpacingOverSize;
         else
            spacingPix=min(spacingPix,floor((RectHeight(stimulusRect)-oo(condition).targetPix)/minSpacesX));
            spacingPix=min(spacingPix,floor(oo(condition).targetHeightOverWidth*(RectWidth(stimulusRect)-oo(condition).targetHeightOverWidth*oo(condition).targetPix)/minSpacesX));
         end
      else
         % horizontal threshold
         if oo(condition).fixedSpacingOverSize
            spacingPix=min(spacingPix,floor(RectWidth(stimulusRect)/(minSpacesX+1/oo(condition).fixedSpacingOverSize)));
            spacingPix=min(spacingPix,floor(RectHeight(stimulusRect)/(minSpacesY+1/oo(condition).fixedSpacingOverSize)/oo(condition).targetHeightOverWidth));
            oo(condition).targetPix=spacingPix/oo(condition).fixedSpacingOverSize;
         else
            spacingPix=min(spacingPix,floor((RectHeight(stimulusRect)-oo(condition).targetPix)/minSpacesX));
            spacingPix=min(spacingPix,floor(oo(condition).targetHeightOverWidth*(RectWidth(stimulusRect)-oo(condition).targetHeightOverWidth*oo(condition).targetPix)/4));
         end
      end
      oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
      oo(condition).spacingDeg=spacingPix/pixPerDeg;
      xT=oo(condition).fix.x+oo(condition).eccentricityPix; % target
      yT=oo(condition).fix.y; % target
      if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f, xT %d, yT %d\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg,xT,yT); end;
      spacingPix=round(spacingPix);
      switch oo(condition).radialOrTangential
         case 'tangential'
            % flanker must fit on screen
            if oo(condition).fixedSpacingOverSize
               spacingPix=min(spacingPix,RectHeight(stimulusRect)/(2+1/oo(condition).fixedSpacingOverSize));
            else
               spacingPix=min(spacingPix,(RectHeight(stimulusRect)-oo(condition).targetPix)/2);
            end
            assert(spacingPix>=0);
            xF=xT;
            xFF=xT;
            yF=yT-spacingPix;
            yFF=yT+spacingPix;
            % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacingPix,requestedSpacing/pixPerDeg,spacingPix/pixPerDeg);
            spacingOuter=0;
         case 'radial'
            if oo(condition).eccentricityPix==0
               % flanker must fit on screen
               if oo(condition).fixedSpacingOverSize
                  spacingPix=min(spacingPix,RectWidth(stimulusRect)/(2+1/oo(condition).fixedSpacingOverSize));
               else
                  spacingPix=min(spacingPix,(RectWidth(stimulusRect)-oo(condition).targetPix)/2);
               end
               assert(spacingPix>=0);
               yF=yT;
               yFF=yT;
               xF=xT-spacingPix;
               xFF=xT+spacingPix;
               % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacingPix,requestedSpacing/pixPerDeg,spacingPix/pixPerDeg);
               spacingOuter=0;
               if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
            else % eccentricity not zero
               assert(spacingPix>=0);
               assert(oo(condition).eccentricityPix>=0);
               spacingPix=min(oo(condition).eccentricityPix,spacingPix); % Inner flanker must be between fixation and target.
               assert(spacingPix>=0);
               if oo(condition).fixedSpacingOverSize
                  spacingPix=min(spacingPix,xT/(1+1/oo(condition).fixedSpacingOverSize/2)); % Inner flanker is on screen.
                  assert(spacingPix>=0);
                  for i=1:100
                     spacingOuter=(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix-spacingPix)-(oo(condition).eccentricityPix+addonPix);
                     assert(spacingOuter>=0);
                     if spacingOuter<=RectWidth(stimulusRect)-xT-spacingPix/oo(condition).fixedSpacingOverSize/2; % Outer flanker is on screen.
                        break;
                     else
                        spacingPix=0.9*spacingPix;
                     end
                  end
                  if i==100
                     ffprintf(ff,'ERROR: spacingOuter %.1f pix exceeds max %.1f pix.\n',spacingPix,spacingOuter,RectWidth(stimulusRect)-xT-spacingPix/oo(condition).fixedSpacingOverSize/2)
                     error('Could not make spacing small enough. Right flanker will be off screen. If possible, try using off-screen fixation.');
                  end
               else
                  spacingPix=min(spacingPix,xT-oo(condition).targetPix/2); % inner flanker on screen
                  spacingOuter=(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix-spacingPix)-(oo(condition).eccentricityPix+addonPix);
                  spacingOuter=min(spacingOuter,RectWidth(stimulusRect)-xT-oo(condition).targetPix/2); % outer flanker on screen
               end
               assert(spacingOuter>=0);
               spacingPix=oo(condition).eccentricityPix+addonPix-(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix+spacingOuter);
               assert(spacingPix>=0);
               spacingPix=round(spacingPix);
               xF=xT-spacingPix; % inner flanker
               yF=yT; % inner flanker
               xFF=xT+round(spacingOuter); % outer flanker
               yFF=yT; % outer flanker
            end
      end
      oo(condition).spacingDeg=spacingPix/pixPerDeg;
      if streq(oo(condition).thresholdParameter,'spacing') && oo(condition).fixedSpacingOverSize
         oo(condition).targetDeg=oo(condition).spacingDeg/oo(condition).fixedSpacingOverSize;
      end
      oo(condition).targetPix=oo(condition).targetDeg*pixPerDeg;
      if oo(condition).measureThresholdVertically
         oo(condition).targetPix=min(oo(condition).targetPix,RectHeight(stimulusRect));
         oo(condition).targetPix=min(oo(condition).targetPix,RectWidth(stimulusRect)*oo(condition).targetHeightOverWidth);
      else
         oo(condition).targetPix=min(oo(condition).targetPix,RectWidth(stimulusRect));
         oo(condition).targetPix=min(oo(condition).targetPix,RectHeight(stimulusRect)/oo(condition).targetHeightOverWidth);
      end
      oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
      if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
      % prepare to draw fixation cross
      oo(condition).fix.targetHeightPix=oo(condition).targetPix;
      oo(condition).fix.bouma=max(0.5,(spacingOuter+oo(condition).targetPix/2)/oo(condition).eccentricityPix);
      oo(condition).fix.targetHeightOverWidth=oo(condition).targetHeightOverWidth;
      if oo(condition).measureThresholdVertically
         oo(condition).fix.targetHeightPix=oo(condition).targetPix;
      else
         oo(condition).fix.targetHeightPix=oo(condition).targetHeightOverWidth*oo(condition).targetPix;
      end
      oo(condition).fix.targetCross=oo(condition).targetCross;
      fixationLines=ComputeFixationLines(oo(condition).fix);
      % Set up fixation.
      if ~oo(condition).repeatedTargets && isfinite(oo(condition).durationSec)
         % Draw fixation.
         fl=ClipLines(fixationLines,fixationClipRect);
         Screen('DrawLines',window,fl,fixationLineWeightPix,black);
      end
      if oo(condition).showProgressBar
         Screen('FillRect',window,[0 220 0],progressBarRect); % green bar
         r=progressBarRect;
         r(4)=round(r(4)*(1-presentation/length(condList)));
         Screen('FillRect',window,[220 220 220],r); % grey background
      end
      Screen('Flip',window,[],1); % Display instructions and fixation. 
      if isfinite(oo(condition).durationSec)
         if beginAfterKeypress
            SetMouse(screenRect(3),screenRect(4),window);
            answer=GetKeypressWithHelp([spaceKeyCode escapeKeyCode],oo(condition),window,stimulusRect);
            if streq(answer,'ESCAPE')
               if oo(1).speakEachLetter && oo(1).useSpeech
                  Speak('Escape. This run is done.');
               end
               ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
               oo(1).quit=1;
               ListenChar(0);
               ShowCursor;
               sca;
               return
            end
            beginAfterKeypress=0;
         end
         Screen('FillRect',window,white,stimulusRect);
         % Define fixation bounds midway through first trial, for rest of
         % trials.
         fixationClipRect=InsetRect(stimulusRect,0,1.6*oo(condition).textSize);
         if ~oo(condition).repeatedTargets && isfinite(oo(condition).durationSec)
            % Draw fixation.
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
         Screen('Flip',window,[],1); % Display fixation.
         WaitSecs(1); % Duration of fixation display, before stimulus appears.
         Screen('FillRect',window,[],stimulusRect); % Clear screen; keep progress bar.
         if ~oo(condition).repeatedTargets && isfinite(oo(condition).durationSec)
            % Draw fixation.
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
      else
         Screen('FillRect',window); % Clear screen.
      end
      stimulus=Shuffle(oo(condition).alphabet);
      stimulus=stimulus(1:3); % three random letters, all different.
      if isfinite(oo(condition).targetFontHeightOverNominalPtSize)
         if oo(condition).measureThresholdVertically
            sizePix=round(oo(condition).targetPix/oo(condition).targetFontHeightOverNominalPtSize);
            oo(condition).targetPix=sizePix*oo(condition).targetFontHeightOverNominalPtSize;
         else
            sizePix=round(oo(condition).targetPix/oo(condition).targetFontHeightOverNominalPtSize*oo(condition).targetHeightOverWidth);
            oo(condition).targetPix=sizePix*oo(condition).targetFontHeightOverNominalPtSize/oo(condition).targetHeightOverWidth;
         end
      end
      oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
      
      % Create letter textures, using font or from disk.
      letterStruct=CreateLetterTextures(condition,oo(condition),window);
      letters=[oo(condition).alphabet oo(condition).borderLetter];
      
      if oo(condition).showAlphabet
         % This is for debugging. We also display the alphabet any time the
         % caps lock key is pressed. That's standard behavior to allow the
         % observer to familiarize herself with the alphabet.
         for i=1:length(letters)
            r=[0 0 RectWidth(letterStruct(i).rect) RectHeight(letterStruct(i).rect)];
            s=RectWidth(stimulusRect)/(1.5*length(letters))/RectWidth(r);
            r=round(s*r);
            r=OffsetRect(r,(0.5+1.5*(i-1))*RectWidth(r),RectHeight(r));
            Screen('DrawTexture',window,letterStruct(i).texture,[],r);
            Screen('FrameRect',window,0,r);
         end
         Screen('Flip',window);
         Speak('Alphabet. Click.');
         GetClicks;
      end
      
      % Create textures for 3 lines. The rest are the copies.
      textureIndex=1;
      spacingPix=floor(spacingPix);
      if oo(condition).measureThresholdVertically
         ySpacing=spacingPix;
         xSpacing=spacingPix/oo(condition).targetHeightOverWidth;
         yPix=oo(condition).targetPix;
         xPix=oo(condition).targetPix/oo(condition).targetHeightOverWidth;
      else
         xSpacing=spacingPix;
         ySpacing=spacingPix*oo(condition).targetHeightOverWidth;
         xPix=oo(condition).targetPix;
         yPix=oo(condition).targetPix*oo(condition).targetHeightOverWidth;
      end
      if oo(condition).printSizeAndSpacing; fprintf('%d: %d: xSpacing %.0f, ySpacing %.0f, ratio %.2f\n',condition,MFileLineNr,xSpacing,ySpacing,ySpacing/xSpacing); end;
      if ~oo(condition).repeatedTargets 
         xStimulus=[xF xT xFF];
         yStimulus=[yF yT yFF];
         if oo(condition).fourFlankers
            assert(~oo(condition).measureThresholdVertically); % this code won't yet handle vertical case
            xStimulus=[xStimulus xT xT];
            yStimulus=[yStimulus yT-ySpacing yT+ySpacing];
            newFlankers=Shuffle(oo(condition).alphabet(oo(condition).alphabet~=stimulus(2)));
            stimulus(end+1)=newFlankers(1);
            stimulus(end+1)=newFlankers(2);
         end
         clear textures dstRects
         for textureIndex=1:length(xStimulus)
            whichLetter=strfind(letters,stimulus(textureIndex));
            assert(length(whichLetter)==1)
            textures(textureIndex)=letterStruct(whichLetter).texture;
            r=round(letterStruct(whichLetter).rect);
            oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
            if oo(condition).setTargetHeightOverWidth
               r=round(ScaleRect(letterStruct(whichLetter).rect,oo(condition).targetHeightOverWidth/oo(condition).setTargetHeightOverWidth,1));
               oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
               %                      dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
            end
            if oo(condition).measureThresholdVertically
               heightPix=oo(condition).targetPix;
            else
               heightPix=oo(condition).targetHeightOverWidth*oo(condition).targetPix;
            end
            r=round((heightPix/RectHeight(letterStruct(whichLetter).rect))*letterStruct(whichLetter).rect);
            dstRects(1:4,textureIndex)=OffsetRect(r,round(xStimulus(textureIndex)-xPix/2),round(yStimulus(textureIndex)-yPix/2));
            if oo(condition).printSizeAndSpacing
               fprintf('xPix %.0f, yPix %.0f, RectWidth(r) %.0f, RectHeight(r) %.0f, x %.0f, y %.0f, dstRect %0.f %0.f %0.f %0.f\n',xPix,yPix,RectWidth(r),RectHeight(r),xStimulus(textureIndex),yStimulus(textureIndex),dstRects(1:4,textureIndex));
            end
         end
         if ~streq(oo(condition).thresholdParameter,'spacing')
            % Show only the target, omitting all flankers.
            textures=textures(2);
            dstRects=dstRects(1:4,2);
         end
      else
         xMin=xT-xSpacing*floor((xT-0.5*xPix)/xSpacing);
         xMax=xT+xSpacing*floor((RectWidth(stimulusRect)-xT-0.5*xPix)/xSpacing);
         yMin=yT-ySpacing*floor((yT-0.5*yPix)/ySpacing);
         yMax=yT+ySpacing*floor((RectHeight(stimulusRect)-yT-0.5*yPix)/ySpacing);
         if oo(condition).speakSizeAndSpacing; Speak(sprintf('%.0f rows and %.0f columns',1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing));end
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: %.1f rows and %.1f columns, target xT %.0f, yT %.0f\n',condition,MFileLineNr,1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing,xT,yT); end;
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: left & right margins %.0f, %.0f, top and bottom margins %.0f,  %.0f\n',condition,MFileLineNr,xMin,RectWidth(stimulusRect)-xMax,yMin,RectHeight(stimulusRect)-yMax); end;
         clear textures dstRects
         n=length(xMin:xSpacing:xMax);
         textures=zeros(1,n);
         dstRects=zeros(4,n);
         for lineIndex=1:3
            whichTarget=mod(lineIndex,2);
            for x=xMin:xSpacing:xMax
               switch oo(condition).thresholdParameter
                  case 'spacing',
                     whichTarget=mod(whichTarget+1,2);
                  case 'size',
                     whichTarget=x>mean([xMin xMax]);
               end
               if ismember(x,[xMin xMax]) || lineIndex==1
                  letter=oo(condition).borderLetter;
               else
                  letter=stimulus(1+whichTarget);
               end
               whichLetter=strfind(letters,letter);
               assert(length(whichLetter)==1)
               textures(textureIndex)=letterStruct(whichLetter).texture;
               if oo(condition).showLineOfLetters
                  fprintf('textureIndex %d,x %d, whichTarget %d, letter %c, whichLetter %d, texture %d\n',textureIndex,x,whichTarget,letter,whichLetter,textures(textureIndex));
               end
               xPos=round(x-xPix/2);
               
               % Compute o.targetHeightOverWidth, and, if requested,
               % o.setTargetHeightOverWidth
               r=round(letterStruct(whichLetter).rect);
               oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
               if oo(condition).setTargetHeightOverWidth
                  r=round(ScaleRect(letterStruct(whichLetter).rect,oo(condition).targetHeightOverWidth/oo(condition).setTargetHeightOverWidth,1));
                  oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
                  dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
               else
                  if oo(condition).measureThresholdVertically
                     heightPix=oo(condition).targetPix;
                  else
                     heightPix=oo(condition).targetHeightOverWidth*oo(condition).targetPix;
                  end
                  dstRects(1:4,textureIndex)=OffsetRect(round((heightPix/RectHeight(letterStruct(whichLetter).rect))*letterStruct(whichLetter).rect),xPos,0);
               end
               % One dst rect for each letter in the line.
               if oo(condition).showLineOfLetters
                  r=Screen('Rect',textures(textureIndex));
                  Screen('DrawTexture',window,textures(textureIndex),r,dstRects(1:4,textureIndex));
                  Screen('FrameRect',window,0,dstRects(1:4,textureIndex));
                  fprintf('%d: %d: showLineOfLetters width %d, height %d, x %.0f, xPos %.0f, dstRects(1:4,%d) %.0f %.0f %.0f %.0f\n',condition,MFileLineNr,RectWidth(dstRects(1:4,textureIndex)'),RectHeight(dstRects(1:4,textureIndex)'),x,xPos,textureIndex,dstRects(1:4,textureIndex));
               end
               textureIndex=textureIndex+1;
            end
            if oo(condition).showLineOfLetters
               Screen('Flip',window);
               Speak(sprintf('Line %d. Click.',lineIndex));
               GetClicks;
            end
            % Create a texture holding one line of letters.
            [lineTexture(lineIndex),lineRect{lineIndex}]=Screen('OpenOffscreenWindow',window,[],[0 0 RectWidth(stimulusRect) heightPix],8,0);
            Screen('FillRect',lineTexture(lineIndex),white);
            r=Screen('Rect',textures(1));
            Screen('DrawTextures',lineTexture(lineIndex),textures,r,dstRects);
         end
         clear textures dstRects
         lineIndex=1;
         for y=yMin:ySpacing:yMax
            if ismember(y,[yMin yMax])
               whichLetter=1;
            else
               whichLetter=2+mod(lineIndex,2);
            end
            textures(lineIndex)=lineTexture(whichLetter);
            dstRects(1:4,lineIndex)=OffsetRect(lineRect{1},0,round(y-RectHeight(lineRect{1})/2));
            %                 fprintf('line %d, whichLetter %d, texture %d, dstRect %d %d %d %d\n',lineIndex,whichLetter,lineTexture(whichLetter),dstRects(1:4,lineIndex));
            lineIndex=lineIndex+1;
         end
      end
      Screen('DrawTextures',window,textures,[],dstRects);
      if oo(condition).frameTheTarget
         fprintf('%d: %d: line heights',condition,MFileLineNr);
         for ii=1:size(dstRects,2)
            y=RectHeight(dstRects(:,ii)');
            fprintf(' %d',y);
         end
         fprintf('\n');
         fprintf('%d: %d: line dstRects centered at',condition,MFileLineNr);
         for ii=1:size(dstRects,2)
            [x,y]=RectCenter(dstRects(:,ii));
            fprintf(' (%d,%d)',x,y);
            Screen('FrameRect',window,[255 0 0],dstRects(:,ii),4);
         end
         fprintf('. target center (%d,%d)\n',xT,yT);
         letterRect=OffsetRect([-0.5*xPix -0.5*yPix 0.5*xPix 0.5*yPix],xT,yT);
         Screen('FrameRect',window,[255 0 0],letterRect);
         fprintf('%d: %d: screenHeight %d, letterRect height %.0f, targetPix %.0f, textSize %.0f, xPix %.0f, yPix %.0f\n',...
            condition,MFileLineNr,RectHeight(stimulusRect),RectHeight(letterRect),oo(condition).targetPix,Screen('TextSize',window),xPix,yPix);
      end
      Screen('TextFont',window,oo(condition).textFont,0);
      if oo(condition).showProgressBar
         Screen('FillRect',window,[0 220 0],progressBarRect); % green bar
         r=progressBarRect;
         r(4)=round(r(4)*(1-presentation/length(condList)));
         Screen('FillRect',window,[220 220 220],r); % grey background
      end
      if oo(condition).usePurring
         Snd('Play',purr);
      end
      Screen('Flip',window,[],1); % Display stimulus & fixation.
      trialTimeSecs=GetSecs;
      % Discard the line textures, to free graphics memory.
      if exist('lineTexture','var')
         for i=1:length(lineTexture)
            Screen('Close',lineTexture(i));
         end
         clear lineTexture
      end
      if oo(condition).repeatedTargets
         targets=stimulus(1:2);
      else
         targets=stimulus(2);
      end
      if isfinite(oo(condition).durationSec)
         WaitSecs(oo(condition).durationSec); % display of letters
         Screen('FillRect',window,white,stimulusRect); % Clear letters.
         if ~oo(condition).repeatedTargets && isfinite(oo(condition).durationSec)
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
         Screen('Flip',window,[],1); % Remove stimulus. Display fixation.
         Screen('FillRect',window,white,stimulusRect);
         WaitSecs(0.2); % pause before response screen
         Screen('TextFont',window,oo(condition).textFont,0);
         Screen('TextSize',window,oo(condition).textSize);
         string='Type your response, or ESCAPE to quit.   ';
         if oo(condition).repeatedTargets
            string=strrep(string,'response','two responses');
         end
         % Clear space for text.
         texture=Screen('OpenOffscreenWindow',window);
         Screen('TextFont',texture,oo(condition).textFont,0);
         Screen('TextSize',texture,oo(condition).textSize);
         bounds=TextBounds(texture,string,1);
         Screen('Close',texture);
         x=50;
         y=-bounds(2)+0.3*oo(condition).textSize;
%          fixationClipRect=stimulusRect;
%          fixationClipRect(2)=y+bounds(4)+0.3*oo(condition).textSize;
         % Draw text.
         Screen('DrawText',window,string,x,y,black,white,1);
         Screen('TextSize',window,oo(condition).textSize);
         [letterStruct,alphabetBounds]=CreateLetterTextures(condition,oo(condition),window);
         alphabetBounds=round(alphabetBounds*oo(condition).textSize/RectHeight(alphabetBounds));
         x=50;
         y=stimulusRect(4)-0.3*RectHeight(alphabetBounds);
%          fixationClipRect(4)=y-1.3*RectHeight(alphabetBounds);
         for i=1:length(oo(condition).alphabet)
            dstRect=OffsetRect(alphabetBounds,x,y-RectHeight(alphabetBounds));
            for j=1:length(letterStruct)
               if oo(condition).alphabet(i)==letterStruct(j).letter
                  Screen('DrawTexture',window,letterStruct(i).texture,[],dstRect);
               end
            end
            x=x+1.5*RectWidth(dstRect);
         end
         Screen('TextFont',window,oo(condition).textFont,0);
         if ~oo(condition).repeatedTargets && isfinite(oo(condition).durationSec)
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
         Screen('Flip',window,[],1); % Display fixation & response instructions.
         Screen('FillRect',window,white,stimulusRect);
      end
      
      if oo(condition).takeSnapshot
         mypath=oo(1).snapshotsFolder;
         filename=oo(1).dataFilename;
         saveSnapshotFid=fopen(fullfile(mypath,[filename '.png']),'rt');
         if saveSnapshotFid~=-1
            for suffix='a':'z'
               saveSnapshotFid=fopen(fullfile(mypath,[filename suffix '.png']),'rt');
               if saveSnapshotFid==-1
                  filename=[filename suffix];
                  break
               end
            end
            if saveSnapshotFid~=-1
               error('Can''t save file. Already 26 files with that name plus a-z');
            end
         end
         filename=[filename '.png'];
         img=Screen('GetImage',window);
         imwrite(img,fullfile(mypath,filename),'png');
         ffprintf(ff,'Saving image to file "%s" ',filename);
      end
      
      responseString='';
      skipping=0;
      for i=1:length(targets)
         answer=GetKeypressWithHelp([spaceKeyCode escapeKeyCode oo(condition).responseKeyCodes],oo(condition),window,stimulusRect,letterStruct,responseString);
         if streq(answer,'ESCAPE')
            ListenChar(0);
            ffprintf(ff,'*** Observer typed <escape>. Run terminated.\n');
            terminate=1;
            break;
         end
         if streq(upper(answer),'SPACE')
            responsesNumber=length(responseString);
            if GetSecs-trialTimeSecs>oo(condition).secsBeforeSkipCausesGuess
               if oo(condition).speakEachLetter && oo(condition).useSpeech
                  Speak('space');
               end
               guesses=0;
               while length(responseString)<length(targets)
                  reportedTarget=randsample(oo(condition).alphabet,1); % Guess.
                  responseString=[responseString reportedTarget];
                  guesses=guesses+1;
               end
               guessCount=guessCount+guesses;
               oo(condition).guessCount=oo(condition).guessCount+guesses;
            else
               if oo(condition).speakEachLetter && oo(condition).useSpeech
                  Speak('skip');
               end
               guesses=0;
               presentation=presentation-floor(1-length(responseString)/length(targets));
            end
            skipping=1;
            skipCount=skipCount+1;
            easeRequest=easeRequest+1;
            ffprintf(ff,'*** Typed <space>. Skipping to next trial. Observer gave %d responses, and we added %d guesses.\n',responsesNumber,guesses);
            break;
         end
         % GetKeypress returns, in answer, both key labels when there
         % are two, e.g. "3#". We score the response as whichever target
         % letter is included in the "answer" string.
         reportedTarget = oo(condition).alphabet(ismember(upper(oo(condition).alphabet),upper(answer)));
         if oo(condition).speakEachLetter && oo(condition).useSpeech
            % Speak the target that the observer saw, e.g '1', not the keyCode '1!'
            Speak(reportedTarget);
         end
         if ismember(upper(reportedTarget),upper(targets))
            if oo(condition).beepPositiveFeedback
               Snd('Play',rightBeep);
            end
         else
            if oo(condition).beepNegativeFeedback
               Snd('Play',wrongBeep);
            end
         end
         responseString=[responseString reportedTarget];
      end
      DestroyLetterTextures(letterStruct);
      if ~skipping
         easeRequest=0;
      end
      if oo(condition).speakEncouragement && oo(condition).useSpeech && ~terminate && ~skipping
         switch randi(3);
            case 1
               Speak('Good!');
            case 2
               Speak('Nice');
            case 3
               Speak('Very good');
         end
      end
      if terminate
         break;
      end
      responses=ismember(responseString,targets);
      oo(condition).spacingDeg=spacingPix/pixPerDeg;
      for response=responses
         switch oo(condition).thresholdParameter
            case 'spacing',
               oo(condition).results(oo(condition).responseCount,1:2)=[oo(condition).spacingDeg response];
               %                     oo(condition).results(oo(condition).responseCount,2)=response;
               oo(condition).responseCount=oo(condition).responseCount+1;
               intensity=log10(oo(condition).spacingDeg);
            case 'size'
               oo(condition).results(oo(condition).responseCount,1:2)=[oo(condition).targetDeg response];
               %                     oo(condition).results(oo(condition).responseCount,2)=response;
               oo(condition).responseCount=oo(condition).responseCount+1;
               intensity=log10(oo(condition).targetDeg);
         end
         %             ffprintf(ff,'QuestUpdate %.3f deg\n',oo(condition).targetDeg);
         oo(condition).q=QuestUpdate(oo(condition).q,intensity,response);
      end
      if terminate
         break;
      end
   end % for presentation=1:length(condList)
   
   Screen('FillRect',window);
   Screen('Flip',window);
   if oo(1).useSpeech
      Speak('Congratulations.  This run is done.');
   end
   trials=0;
   oo(1).totalSecs=GetSecs-oo(1).beginSecs;
   for condition=1:conditions
      trials=trials+oo(condition).responseCount;
   end
   ffprintf(ff,'Took %.0f s for %.0f trials, or %.0f s/trial.\n',oo(1).totalSecs,trials,oo(1).totalSecs/trials);
   ffprintf(ff,'%d skips, %d easy presentations, %d artificial guesses. \n',skipCount,easyCount,guessCount);
   for condition=1:conditions
      ffprintf(ff,'CONDITION %d **********\n',condition);
      % Ask Quest for the final estimate of threshold.
      t=QuestMean(oo(condition).q);
      sd=QuestSd(oo(condition).q);
      if oo(condition).measureThresholdVertically
         ori='vertical';
      else
         ori='horizontal';
      end
      switch oo(condition).thresholdParameter
         case 'spacing',
            if ~oo(condition).repeatedTargets && oo(condition).eccentricityDeg~=0
               switch(oo(condition).radialOrTangential)
                  case 'radial'
                     ffprintf(ff,'Radial spacing of far flanker from target.\n');
                  case 'tangential'
                     ffprintf(ff,'Tangential spacing up and down.\n');
               end
            end
            ffprintf(ff,'Threshold log %s spacing deg (mean +-sd) is %.2f +-%.2f, which is %.3f deg.\n',ori,t,sd,10^t);
            if 10^t<oo(condition).minimumSpacingDeg
               ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed spacing %.3f deg. Please increase viewing distance.\n',10^t,oo(condition).minimumSpacingDeg);
               if oo(condition).useSpeech
%                   Speak('WARNING: Please increase viewing distance.');
               end
            end
            if oo(condition).responseCount>1
               trials=QuestTrials(oo(condition).q);
               if any(~isreal(trials.intensity))
                  error('trials.intensity returned by Quest should be real, but is complex.');
               end
               ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
               ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(condition).q,trials.intensity-oo(condition).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
         case 'size',
            ffprintf(ff,'Threshold log %s size deg (mean +-sd) is %.2f +-%.2f, which is %.3f deg.\n',ori,t,sd,10^t);
            if 10^t<oo(condition).minimumSizeDeg
               ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed size %.3f deg. Please increase viewing distance.\n',10^t,oo(condition).minimumSizeDeg);
               if oo(condition).useSpeech
                  Speak('WARNING: Please increase viewing distance.');
               end
            end
            if oo(condition).responseCount>1
               trials=QuestTrials(oo(condition).q);
               ffprintf(ff,'Size(deg)	P fit	P       Trials\n');
               ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(condition).q,trials.intensity-oo(condition).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
      end
      for condition=1:conditions
         if oo(condition).measureBeta
            % reanalyze the data with beta as a free parameter.
            ffprintf(ff,'%d: o.measureBeta **************************************\n',condition);
            ffprintf(ff,'offsetToMeasureBeta %.1f to %.1f\n',min(offsetToMeasureBeta),max(offsetToMeasureBeta));
            bestBeta=QuestBetaAnalysis(oo(condition).q);
            qq=oo(condition).q;
            qq.beta=bestBeta;
            qq=QuestRecompute(qq);
            ffprintf(ff,'thresh %.2f deg, log thresh %.2f, beta %.1f\n',10^QuestMean(qq),QuestMean(qq),qq.beta);
            ffprintf(ff,' deg     t     P fit\n');
            tt=QuestMean(qq);
            for offset=sort(offsetToMeasureBeta)
               t=tt+offset;
               ffprintf(ff,'%5.2f   %5.2f  %4.2f\n',10^t,t,QuestP(qq,t));
            end
            if oo(condition).responseCount>1
               trials=QuestTrials(qq);
               switch oo(condition).thresholdParameter
                  case 'spacing',
                     ffprintf(ff,'\n Spacing(deg)   P fit	P actual Trials\n');
                  case 'size',
                     ffprintf(ff,'\n Size(deg)   P fit	P actual Trials\n');
               end
               ffprintf(ff,'%5.2f           %4.2f    %4.2f     %d\n',[10.^trials.intensity;QuestP(qq,trials.intensity);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
            ffprintf(ff,'o.measureBeta done **********************************\n');
         end
      end
      ListenChar(0); % flush and reenable keyboard
      Snd('Close');
      ShowCursor;
      Screen('CloseAll');
      sca;
  end
   for condition=1:conditions
      if exist('results','var') && oo(condition).responseCount>1
         ffprintf(ff,'%d:',condition);
         trials=QuestTrials(oo(condition).q);
         p=sum(trials.responses(2,:))/sum(sum(trials.responses));
         switch oo(condition).thresholdParameter
            case 'spacing',
               ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',oo(condition).observer,100*p,oo(condition).targetDeg,oo(condition).eccentricityDeg,10^QuestMean(oo(condition).q));
            case 'size',
               ffprintf(ff,'%s: p %.0f%%, ecc. %.2f deg, threshold size %.3f deg.\n',oo(condition).observer,100*p,oo(condition).eccentricityDeg,10^QuestMean(oo(condition).q));
         end
      end
   end
   save(fullfile(oo(1).dataFolder,[oo(1).dataFilename '.mat']),'oo');
   if exist('dataFid','file')
      fclose(dataFid);
      dataFid=-1;
   end
   fprintf('Results saved in %s.txt and "".mat\nin folder %s\n',oo(1).dataFilename,oo(1).dataFolder);
catch
   ListenChar(0);
   % Some of these functions spoil psychlasterror, so i don't use them.
   %     Snd('Close');
   %     ShowCursor;
   if exist('dataFid','file') && dataFid~=-1
      fclose(dataFid);
      dataFid=-1;
   end
   sca; % screen close all. This cleans up without canceling the error message.
   psychrethrow(psychlasterror);
end
end
