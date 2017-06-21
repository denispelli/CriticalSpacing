function oo=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% CriticalSpacing measures an observer's critical spacing and acuity (i.e.
% threshold spacing and size) to help characterize the observer's vision.
% This program takes over your screen to measure the observer's size or
% spacing threshold for letter identification. It takes about 5 minutes to
% measure two thresholds. It's meant to be called by a short user-written
% script, and should work well in clinical environments. All results are
% returned in the "o" struct and also saved to disk in two files whose file
% names include your script name, the experimenter and observer names, and
% the date. One of those files is plain text .txt and easy for you to read;
% the other is a MATLAB save file .MAT and easily read by MATLAB programs.
% It's best to keep both. The filenames are unique and easy to sort, so
% it's fine to let all your data files accumulate in your
% CriticalSpacing/data/ folder.
%
% THE "o" ARGUMENT, INPUT AND OUTPUT. You define a condition by creating an
% "o" struct and setting its fields to specify your testing condition. Call
% CriticalSpacing, passing the "o" struct. CriticalSpacing will measure a
% threshold for your condition and return the "o" struct including all the
% results as additional fields. CriticalSpacing may adjust some of your
% parameters to satisfy physical constraints including screen size and
% maximum possible contrast. If you provide several conditions, as an o
% array, then CriticalSpacing runs all the conditions randomly interleaved,
% measuring a threshold for each. I sometimes pass two identical conditions
% to get two thresholds for the same condition.
%
% USER-WRITTEN SCRIPTS. CriticalSpacing.m is meant to be driven by a brief
% user-written script. Your run script is short and very easy to write. It
% just assigns values to the fields of an "o" struct and then calls
% CriticalSpacing to measure a threshold. I have provided
% runCriticalSpacing as an example. You control the behavior of
% CriticalSpacing by setting parameters in the fields the "o" struct. "o"
% defines a condition for which a threshold will be measured. If you
% provide several conditions, as an o array, then CriticalSpacing runs all
% the conditions interleaved, measuring a threshold for each.
% CriticalSpacing initially confirms the viewing distance, asks for the
% experimenter's and observer's names, and presents a page of instructions.
% The rest is just one eye chart after another, each showing one or two
% targets (with or without repetitions). Presentation can be brief or
% static (o.durationSec=inf).
%
% RUN A SCRIPT. To test an observer, double click "runCriticalSpacing.m" or
% your own modified script. They're easy to write. Say "Ok" if MATLAB
% offers to change the current folder. CriticalSpacing automatically saves
% your results to the "CriticalSpacing/data" folder. The data filenames are
% unique and intuitive, so it's ok to let lots of data accumulate in the
% data folder. runCriticalSpacing takes 5 min to test one observer (with 20
% trials per threshold), measuring two thresholds, interleaved.
%
% PUBLICATION. You can read more about this program and its purpose in our
% 2016 article:
%
% Pelli, D. G., Waugh, S. J., Martelli, M., Crutch, S. J., Primativo, S.,
% Yong, K. X., Rhodes, M., Yee, K., Wu, X., Famira, H. F., & Yiltiz, H.
% (2016) A clinical test for visual crowding. F1000Research 5:81 (doi:
% 10.12688/f1000research.7835.1) http://f1000research.com/articles/5-81/v1
% It's open access. Download freely.
%
% INSTALL. To install and run CriticalSpacing on your computer:
% Download the CriticalSpacing software from
% https://github.com/denispelli/CriticalSpacing/archive/master.zip
% Unpack the zip archive, producing a folder called CriticalSpacing. Inside
% the CriticalSpacing folder, open the Word document "Install
% CriticalSpacing.docx" for detailed instructions for installation of
% MATLAB, Psychtoolbox, and CriticalSpacing software. Install. Type "help
% CriticalSpacing" in the MATLAB Command Window.
%
% PRINT THE ALPHABET ON PAPER. Choose a font from those available in the
% CriticalSpacing/pdf/ folder. They are all available when you set
% o.readAlphabetFromDisk=1. We have done most of our work with the "Sloan"
% and "Pelli" fonts. Only Pelli is skinny enough to measure foveal
% crowding. Outside the fovea you can use any font. We recommend "Pelli"
% for threshold spacing (crowding) in the fovea, and Sloan for threshold
% size (acuity) anywhere. Print the PDF for your font, e.g. "Pelli
% alphabet.pdf" or "Sloan alphabet.pdf". Give the printed alphabet page to
% your observer. It shows the possible letters, e.g. "DHKNORSVZ" or
% "1234567889". Most observers will find it helpful to consult this page
% while choosing an answer, especially when they are guessing. And children
% may prefer to respond by pointing at the printed target letters on the
% alphabet page. However, patients who have trouble directing their
% attention may be better off without the paper, to give their undivided
% attention to the display.
%
% DISPLAY ALPHABET ON SCREEN. Anytime you press the "caps lock" key,
% CriticalSpacing will display the alphabet of possible responses in the
% current font. Like the printed version, it shows the nine possible
% letters or digits. This may help observers choose an answer, especially
% when they are guessing.
%
% MATLAB AND PSYCHTOOLBOX. To run this program, you need a computer with
% MATLAB (or Octave) and the Psychtoolbox installed. The computer OS can be
% OS X, Windows, or Linux. MATLAB is commercially available, and many
% universites have site licences. Psychtoolbox is free.
% https://www.mathworks.com/
% http://psychtoolbox.org/
% 
% OPTIONAL: MEASURE YOUR SCREEN SIZE IN CM. Psychtoolbox automatically
% reads your display screen's resolution in pixels and size in cm, and
% reports them in every data file. Alas, the reported size in cm is
% sometimes (very) wrong in Windows, and is not always available for
% external monitors under any OS. So we allow users to measure the display
% screen size themselves and provide it in the "o" struct as
% o.measuredScreenWidthCm and o.measuredScreenWidthCm. Use a meter stick to
% measure the width and height of your screen's rectangle of glowing
% pixels.
%
% MAC OS X: PERMIT MATLAB TO CONTROL YOUR COMPUTER. Open the System
% Preferences: Security and Privacy: Privacy tab. Select Accessibility.
% Click to open the lock in lower left, providing your computer password.
% Click to select MATLAB, allowing it to control your computer. Click the
% lock again to close it.
%
% A WIRELESS OR LONG-CABLE KEYBOARD is highly desirable because a normally
% sighted observer viewing foveally has excellent vision and must be many
% meters away from the screen, and thus will be unable to reach a built-in
% keyboard attached to the screen. If you must use the built-in keyboard,
% then have the experimenter type the observer's verbal answers. I like the
% Logitech K760 $86 solar-powered wireless keyboard, because its batteries
% never run out. It's no longer made, but still available on Amazon and
% eBay (below). To "pair" the keyboard with your computer's blue tooth,
% press the tiny button on the back of the keyboard.
%
% Logitech Wireless Solar Keyboard K760 for Mac/iPad/iPhone
% http://www.amazon.com/gp/product/B007VL8Y2C
%
% TAPE OR LASER MEASURE FOR VIEWING DISTANCE. The viewing distance will
% typically be several meters, and it's important that you set it
% accurately, within five percent. You can measure it with a $10 tape
% measure marked in centimeters. A fancy $40 alternative is a Bosch laser
% measure, which gives you the answer in two clicks. The laser works even
% with a mirror.
%
% http://www.amazon.com/gp/product/B0016A2UHO
% http://www.amazon.com/gp/product/B00LGANH8K
% https://www.boschtools.com/us/en/boschtools-ocs/laser-measuring-glm-15-0601072810--120449-p/
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
% READ ALPHABET FROM DISK. If you set o.readAlphabetFromDisk=1 in your
% script you can use any of the "fonts" inside the
% CriticalSpacing/alphabets/ folder, which you can best see by looking at
% the alphabet files in CriticalSpacing/pdf/. You can easily create and add
% a new "font" to the alphabets folder. Name the folder after your "font",
% and put one image file per letter inside the folder, named for the
% letter. That's it. You can now specify your new "font" as the
% o.targetFont and CriticalSpacing will use it. You can make the drawings
% yourself, or you can run CriticalSpacing/lib/SaveAlphabetToDisk.m to
% create a new folder based on a computer font that you already own. This
% scheme makes it easy to develop a new font, and also makes it easy to
% share font images without violating a font's commercial distribution
% license. (US Copyright law does not cover fonts. Adobe patents the font
% program, but the images are public domain.) You can also ask
% CriticalSpacing to use any font that's installed in your computer OS by
% setting o.readAlphabetFromDisk=0. The Pelli and Sloan fonts are provided
% in the CriticalSpacing/fonts/ folder, and you can install them in your
% computer OS. On a Mac, you can just double-click the font file and say
% "yes" when your computer offers to install it for you. Once you've
% installed a font, you must quit and restart MATLAB to use the newly
% available font.
%
% OPTIONAL: ADD A NEW FONT. Running the program SaveAlphabetToDisk in
% the CriticalSpacing/lib/ folder, after you edit it to specify the font,
% alphabet, and borderCharacter you want, will add a snapshot of your
% font's alphabet to the pdf folder and add a new folder, named for your
% font, to the CriticalSpacing/alphabets/ folder.
%
% OPTIONAL: USE YOUR COMPUTER'S FONTS, LIVE. Set o.readAlphabetFromDisk=0.
% You may wish to install Pelli or Sloan from the CriticalSpacing/fonts/
% folder into your computer's OS. Restart MATLAB after installing a new
% font. To render fonts well, Psychtoolbox needs to load the FTGL DrawText
% dropin. It typically takes some fiddling with dynamic libraries to make
% sure the right library is available and that access to it is not blocked
% by the presence of an obsolete version. For explanation see "help
% drawtextplugin". You need this only if you want to set
% o.readAlphabetFromDisk=0.
%
% CHILDREN. Adults and children seem to find it easy and intuitive. Sarah
% Waugh (Dept. of Vision and Hearing Sciences, Anglia Ruskin University)
% has tested 200 children of ages 4 to 16 (?). To test children, Sarah used
% an fictional astronaut adventure story about this test. The game,
% designed by Aenne Brielmann, in my lab here at NYU, includes an
% illustrated story book and alien dolls.
%
% CHOOSE A VIEWING DISTANCE. You can provide a default in your script, e.g.
% o.viewingDistanceCm=400. CriticalSpacing invites you to modify the
% viewing distance (or declare that you're using a mirror) at the beginning
% of each run. You need long distance to display tiny letters, and you need
% short viewing distance to display peripheral letters, if fixation is
% on-screen. (We plan to add support for off-screen fixation.) When viewing
% foveally, please err on the side of making the viewing distance longer
% than necessary. If you use too short a viewing distance then the minimum
% size and spacing may be bigger than the threshold you want to measure. At
% the end of the run, CriticalSpacing.m warns you if the estimated
% threshold is smaller than the minimum possible size or spacing at the
% current distance, and suggests that you increase the viewing distance in
% subsequent runs. The minimum viewing distance depends on the smallest
% letter size you want to show with 8 pixels and the resolution (pixels per
% centimeter) of your display. This is Eq. 4 in the Pelli et al. (2016)
% paper cited at the beginning,
%
% minViewingDistanceCm=57*(minimumTargetPix/letterDeg)/(screenWidthPix/screenWidthCm);
%
% where minimumTargetPix=8 and letterDeg=0.02 for the healthy adult fovea.
%
% PERSPECTIVE DISTORTION IS MINIMIZED BY PLACING THE TARGET AT THE NEAR
% POINT. At the beginning of each run, the CriticalSpacing program gives
% directions to arrange the display so that its "near point" (i.e. point
% closest to the observer's eye) is orthogonal to the observer's line of
% sight. This guarantees minimal effects of perspective distortaion on any
% target placed there. 

% ECCENTRICITY OF THE TARGET. Eccentricity of the target is achieved by
% placing fixation appropriately. Modest eccentricities, up to perhaps 30
% deg, are achieved with on-screen fixation. CriticalSpacing automatically
% chooses the fixation location to allow the target to be as near as
% possible to the center of the display. (More precisely, we place the
% target at the near point and place the near point as close as possible to
% o.nearPointXYInUnitSquare, whose default is 0.5 0.5.) If the eccentricity
% is too large for on-screen fixation, then we help you set up off-screen
% fixation.
%
% HORIZONAL OFF-SCREEN FIXATION. To achieve a large horizontaol
% eccentricity, pick a stable object that has roughly the same height as
% your display, perhaps a can or a cardboard box. Place the sturdy object
% next to your display. (Alternatively, a goose neck clamp, described
% below, could be clamped to a side edge of your display.) Follow the
% instructions of CriticalSpacing to draw a fixation mark, e.g. with a
% black sharpee, on your object at the same height as the cross on the
% screen. CriticalSpacing will tell you how far it should be from the
% on-screen cross (the target location) and how far it shold be from the
% observer's eye. In addition to the sturdy object and marker, you'll need
% a meter stick.
%
% VERTICAL OFF-SCREEN FIXATION. To achieve a large vertical eccentricity, I
% recommend a gooseneck clamp, like the Wimberley PP-200 Plamp II used by
% photographers to hold things.
% https://www.amazon.com/gp/product/B00SCXUZM0/ref=oh_aui_detailpage_o01_s00
% For a negative vertical eccentricity, clamp one end on the top edge of
% your display, and CriticalSpacing will tell you how to position the other
% end, which acts as your fixation mark. For a positive eccentricity, bring
% your display forward to the edge of your table, and clamp the bottom edge
% of the display. You need just the gooseneck clamp and a meter stick.
% 
% NAME THE EXPERIMENTER & OBSERVER. If it doesn't already know,
% CriticalSpacing asks for the name of the experimenter and observer. These
% names are included in the data files, and incorporated into the data file
% names. If your know the experimenter or observer name in advance you can
% specify it in your script, e.g. o.experimenter='Denis' or
% o.observer='JohnK', and CriticalSpacing will skip that question.
%
% CAPS-LOCK KEY: DISPLAY THE ALPHABET. Anytime that CriticalSpacing is
% running trials, pressing the caps lock key will display the font's
% alphabet at a large size, filling the screen. (The shift key works too,
% but it's dangerous on Windows. On Windows, pressing the shift key five
% times provokes a "sticky keys" dialog that you won't see because it's
% hidden behind the CriticalSpacing window, so you'll be stuck. The caps
% lock key is always safe.)
%
% ESCAPE KEY: QUIT. You can always terminate the current run by hitting the
% escape key on your keyboard (typically in upper left, labeled "esc").
% Because at least one computer (e.g. the 2017 MacBook Pro with track bar)
% lacks an ESCAPE key, we accept the GRAVE ACCENT key (also in upper left
% of keyboard) as equivalent. CriticalSpacing will then print out (and save
% to disk) results so far, and ask whether you're quitting the whole
% session or proceeding to the next run. Quitting this run sets the flag
% o.quitRun, and quitting the whole session also sets the flag
% o.quitSession. If o.quitSession is already set when you call
% CriticalSpacing, the CriticalSpacing returns immediately after processing
% arguments. (CriticalSpacing ignores o.quitRun on input.)
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
% directions, selected by the variable o.targetSizeIsHeight, 1 for
% vertically, and 0 for horizontally. Target size can be made proportional
% to spacing, allowing measurement of critical spacing without knowing the
% acuity, because we use the largest possible letter for each spacing. The
% ratio SpacingOverSize is computed for spacing and size along the
% axis specified by o.spaceRadialOrTangential. The final report by
% CriticalSpacing includes the aspect ratio of your font: o.heightOverWidth.
%
% ECCENTRICITY. Set o.eccentricityXYDeg in your script. For peripheral
% testing, it's usually best to set o.durationSec=0.2 to exclude eye
% movements during the brief target presentation. When the flankers are
% radial, the specified spacing refers to the inner flanker, between target
% and fixation. We define scaling eccentricity as eccentricity plus 0.015
% deg. The critical spacing of crowding is proportional to the scaling
% eccentricity The outer flanker is at the scaling eccentricity that has
% the same ratio to the target scaling eccentricity, as the target scaling
% eccentricity does to the inner-flanker scaling eccentricity.
%
% SAVING LETTER-CONFUSION DATA
% For each condition we keep track of which letters the observer has
% trouble with (time and accuracy). This might lead us to adjust or drop
% troublesome letters. We save the letter-confusion and reaction-time
% results of every presentation in a trialData array struct that is a field
% of each condition. The index "i" counts presentations. There may be 1 or
% 2 targets per presentation. If there are two targets (characters), then
% there are two targetScores, responses (characters), responseScores, and
% reactionTimes. targetScores and responseScores are 1 or 0 for each item.
% The responses are in the order typed, at times (since Flip) in
% reactionTimes. reactionTime is nan after the observer views the alphabet
% screen.
% oo(oi).trialData(i).targetDeg
% oo(oi).trialData(i).spacingDeg
% oo(oi).trialData(i).targets
% oo(oi).trialData(i).targetScores
% oo(oi).trialData(i).responses
% oo(oi).trialData(i).responseScores
% oo(oi).trialData(i).reactionTimes
% The other relevant parameters of the condition do not change from trial
% to trial: age, font, thresholdParameter, repeatedTargets.
%
% You can use o.stimulusMarginFraction to shrink stimulusRect e.g. 10% so
% that letters have white above and below.
%
% Copyright © 2016, 2017, Denis Pelli, denis.pelli@nyu.edu

%% PLANS
%
% I'd like the viewing-distance page to respond to a new command: "o" to
% set up offscreen fixation.
%
% Add switch to use only border characters as flankers.
%
% In repetition mode, don't assume one centered target and an even number
% of spaces. We might want to center between two targets to show an odd
% number of spaces.

%% HELPFUL PROGRAMMING ADVICE FOR KEYBOARD INPUT IN PSYCHTOOLBOX
% [PPT]Introduction to PsychToolbox in MATLAB - Jonas Kaplan
% www.jonaskaplan.com/files/psych599/Week6.pptx

% UNICODE
% str = unicode2native('?','utf-8');
% Screen('Preference', 'TextEncodingLocale', 'en_US.UTF-8');

% EXPLANATION FROM MARIO KLEINER (2/9/16) ON RESTORING RESOLUTION
% "The current behavior is something like this:
%
% "* On OSX it tries to restore the video mode that was present at the time
% when the user changed video mode the first time in a session via
% Screen('Resolution'), whenever a window gets closed by code or due to
% error. The OS may restore video mode to whatever it thinks makes sense
% also if Matlab/Octave exits or crashes.
%
% "* On Windows some kind of approximation of the above, at the discretion
% of the OS. I don't know if different recent Windows versions could behave
% differently. We tell the OS that the mode we set is dynamic/temporary and
% the OS restores to something meaningful (to it) at error/window close
% time, or probably also at Matlab exit/crash time.
%
% "* Linux X11 approximation of OSX, except in certain multi-display
% configurations where it doesn't auto-restore anything. And a crash/exit
% of Matlab doesn't auto-restore either. Linux with a future Wayland
% display system will likely have a different behavior again, due to
% ongoing design decisions wrt. desktop security.
%
% "It's one of these areas where true cross-platform portability is not
% really possible.
%
% "In my git repo i have a Screen mex file which no longer triggers errors
% during error handling, but just prints an error message if OSX screws up
% in doing its job as an OS:
%
% https://github.com/kleinerm/Psychtoolbox-3/raw/master/Psychtoolbox/PsychBasic/Screen.mexmaci64
%
% "Running latest PsychToolbox on MATLAB 2015b on latest El Capitan on
% MacBook Air with attached Dell display."
%
% -mario

[~,v]=PsychtoolboxVersion;
if v.major*10000 + v.minor*100 + v.point < 30012
   error('CriticalSpacing: Your Psychtoolbox is too old. Please run "UpdatePsychtoolbox".');
end
if nargin<1 || ~exist('oIn','var')
   oIn.script=[];
end

addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % "lib" folder in same directory as this file

% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.

% PROCEDURE
o.easyBoost=0.3; % On easy trials, boost log threshold parameter by this.
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
o.measureViewingDistanceToTargetNotFixation=1;

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
o.contrast=1; % Nominal contrast, not calibrated.
o.eccentricityXYDeg = [0 0]; % eccentricity of target center re fixation, + for right & up.
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0]  lower right, [1 1] upper right.
o.durationSec=inf; % Duration of display of target and flankers
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
o.fourFlankers=0;
o.oneFlanker=0;
o.targetSizeIsHeight=nan; % 0,1 (or nan to depend on o.thresholdParameter)
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this & pixPerCm.
% o.radialOrTangential='tangential'; % Arrange flankers radially or tangentially.
o.radialOrTangential='radial'; % Radially arranged flankers for single target
o.repeatedTargets=1;
o.maxFixationErrorXYDeg=[3 3]; % Repeat targets enough to cope with errors up to this size.
o.practicePresentations=3;
o.setTargetHeightOverWidth=0; % Stretch font to achieve a particular aspect ratio.
o.spacingDeg=nan;
o.targetDeg=nan;
o.stimulusMarginFraction=0.0; % White margin around stimulusRect.
o.targetMargin = 0.25; % Minimum from edge of target to edge of o.stimulusRect, as fraction of targetHeightDeg.
o.textSizeDeg = 0.6;
o.measuredScreenWidthCm = []; % Allow users to provide their own measurement when the OS gives wrong value.
o.measuredScreenHeightCm = [];% Allow users to provide their own measurement when the OS gives wrong value.
o.isolatedTarget=0; % Set to 1 when measuring acuity for a single isolated letter. Not yet fully supported.

% TARGET FONT
% o.targetFont='Sloan';
% o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
% o.borderLetter='X';
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='$';
o.targetFont='Pelli';
o.alphabet='123456789';
o.borderLetter='$';
o.flankerLetter='';
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
o.targetCross=0; % 1 to mark target location
o.useFixation=1;
o.forceFixationOffScreen=0;
o.fixationCoreSizeDeg=1; % We protect this diameter from clipping by screen edge.

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
o.useFractionOfScreen=0;

% TO MEASURE BETA
% o.measureBeta=0;
% o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
% o.trials=200;

% TO HELP CHILDREN
% o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
% o.speakEncouragement=1; % 1 to say "good," "very good," or "nice" after every trial.
% o.practicePresentations=3;   % 0 for none. Ignored unless repeatedTargets==1. 
                        % Provides easy practice presentations, ramping up
                        % the number of targets after each correct report
                        % of both letters in a presentation, until the
                        % observer gets three presentations right. Then we
                        % seamlessly begin the official run.
                        
% PRACTICE PRESENTATIONS.
% In several instances, very young children (4 years old) refused to even
% try to guess the letters when the screen is covered by letters in the
% repeated-letters condition. 8 year olds and adults are unphased. Sarah
% Waugh found that the 4 years olds were willing to identify one or two
% target letters, and we speculated that once they succeeded at that, they
% might be willing to try the repeated-letters condition, with many more
% letters.
%
% You can now request this by setting o.practicePresentations=3. My hope is
% that children will be emboldened by their success on the first three
% trials to succeed on the repeated condition, in which letters cover most
% of the screen.
%
% o.practicePresentations=3 only affects the repeated-targets condition,
% i.e. when o.repeatedTargets=1. This new options adds 3 practice
% presentations at the beginning of every repeatedTargets run. The first
% presentation has only a few target letters (two unique) in a single row.
% Subsequent presentations are similar, until the observer gets both
% targets right. Then it doubles the number of targets. Again it waits for
% the observer to get both targets right, and then doubles the number of
% targets. After 3 successful practice presentations, the official run
% begins. The practice presentation responses are discarded and not passed
% to Quest.
% 
% You can restore the old behavior by setting o.practicePresentations=0.
% After the practice, the run estimates threshold by the same procedure
% whether o.practicePresentation is 0 or 3.
                        
% NOT SET BY USER
o.deviceIndex=-3; % all keyboard and keypad devices
o.easyCount=0;
o.guessCount=0; % artificial guesses
o.quitRun=0;
o.quitSession=0;
o.script='';
o.scriptFullFileName='';
o.scriptName='';
o.targetFontNumber=[];
o.targetHeightOverWidth=nan;

% PROCESS INPUT.
% o is a single struct, and oIn may be an array of structs.
% Create oo, which replicates o for each condition.
conditions=length(oIn);
oo(1:conditions)=o;
inputFields=fieldnames(o);
clear o; % Thus MATLAB will flag an error if we accidentally try to use "o".

% For each condition, all fields in the user-supplied "oIn" overwrite
% corresponding fields in "o". We ignore any field in oIn that is not
% already defined in o. If the ignored field is a known output field, then
% we ignore it silently. We give a warning of the unknown fields we ignore
% because they might be typos for input fields.
outputFields={'beginSecs' 'beginningTime' 'cal' 'dataFilename' ...
   'dataFolder' 'eccentricityXYPix' 'fix' 'functionNames' ...
   'keyboardNameAndTransport' 'minimumSizeDeg' 'minimumSpacingDeg' ...
   'minimumViewingDistanceCm' 'normalAcuityDeg' ...
   'normalCriticalSpacingDeg' 'presentations' 'q' 'responseCount' ...
   'responseKeyCodes' 'results' 'screen' 'snapshotsFolder' 'spacings'  ...
   'spacingsSequence' 'targetFontHeightOverNominalPtSize' 'targetPix' ...
   'textSize' 'totalSecs' 'unknownFields' 'validKeyNames' ...
   'nativeHeight' 'nativeWidth' 'resolution' 'maximumViewingDistanceCm' ...
   'minimumScreenSizeXYDeg' 'typicalThesholdSizeDeg' ...
   'computer' 'matlab' 'psychtoolbox' 'trialData' 'needWirelessKeyboard' ...
   'standardDrawTextPlugin' 'drawTextPluginWarning' 'oldResolution' ...
   'targetSizeIsHeight'  ...
   'maxRepetition' 'practiceCountdown' 'flankerLetter' 'row'};
unknownFields=cell(0);
for oi=1:conditions
   fields=fieldnames(oIn(oi));
   oo(oi).unknownFields=cell(0);
   for i=1:length(fields)
      if ismember(fields{i},inputFields)
         oo(oi).(fields{i})=oIn(oi).(fields{i});
      elseif ~ismember(fields{i},outputFields)
         unknownFields{end+1}=fields{i};
         oo(oi).unknownFields{end+1}=fields{i};
      end
   end
   oo(oi).unknownFields=unique(oo(oi).unknownFields);
end
unknownFields=unique(unknownFields);
if ~isempty(unknownFields)
   warning off backtrace
   warning(['Ignoring unknown o fields:' sprintf(' %s',unknownFields{:}) '.']);
   warning on backtrace
end
if oo(1).quitSession
   return
end
% clear Screen % might help get appropriate restore after using Screen('Resolution');
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference','SkipSyncTests',1);

% Set up defaults. Clumsy.
for oi=1:conditions
   if ~isfinite(oo(oi).targetSizeIsHeight)
      switch oo(oi).thresholdParameter
         case 'size',
            oo(oi).targetSizeIsHeight=1;
         case 'spacing',
            oo(oi).targetSizeIsHeight=0;
      end
   end
end
for oi=1:conditions
   if oo(oi).practicePresentations
      if oo(oi).repeatedTargets
         oo(oi).maxRepetition=1;
      else
         oo(oi).maxRepetition=0;
      end
      oo(oi).practiceCountdown=oo(oi).practicePresentations;
   else
      oo(oi).practiceCountdown=0;
      oo(oi).maxRepetition=inf;
   end
end
Screen('Preference','TextAntiAliasing',1);
% Set up for KbCheck. Calling ListenChar(2) tells the MATLAB console/editor
% to ignore what we type, so we don't inadvertently echo observer responses
% into the Command window or any open file. We use this mode while use the
% KbCheck family of functions to collect keyboard responses. When we exit,
% we must reenable the keyboard by calling ListenChar() or hitting
% Control-C.
ListenChar(2); % no echo
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]);
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('Return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
graveAccentChar='`';
for oi=1:conditions
   oo(oi).validKeyNames=KeyNamesOfCharacters(oo(oi).alphabet);
   for i=1:length(oo(oi).validKeyNames)
      oo(oi).responseKeyCodes(i)=KbName(oo(oi).validKeyNames{i}); % this returns keyCode as integer
   end
end

% Set up for Screen
oo(1).screen=max(Screen('Screens'));
% The screen size in cm is valuable when the OS provides it, via the
% Psychtoolbox, but it's sometimes wrong on Windows computers, and may
% not always be available for external monitors. So we allow users to
% measure it themselves and provide it in the o struct as
% o.measuredScreenWidthCm and o.measuredScreenWidthCm.
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',oo(1).screen);
if isfinite(oo(1).measuredScreenWidthCm)
   screenWidthCm=oo(1).measuredScreenWidthCm;
else
   screenWidthCm=screenWidthMm/10;
end
if isfinite(oo(1).measuredScreenWidthCm)
   screenHeightCm=oo(1).measuredScreenHeightCm;
else
   screenHeightCm=screenHeightMm/10;
end
screenRect=Screen('Rect',oo(1).screen);
if oo(1).useFractionOfScreen
   % We want to simulate the full screen, and what we would normally see in
   % it, shrunken into a tiny fraction. So we use a reduced number of
   % pixels, but we pretend to retain the same screen size in cm, and
   % angular subtense.
   screenRect=round(oo(oi).useFractionOfScreen*screenRect);
end

for oi=1:conditions
   if ismember(oo(oi).borderLetter,oo(oi).alphabet)
      ListenChar(0);
      error('The o.borderLetter "%c" should not be included in the o.alphabet "%s".',oo(oi).borderLetter,oo(oi).alphabet);
   end
   assert(oo(oi).viewingDistanceCm==oo(1).viewingDistanceCm);
   assert(oo(oi).useFractionOfScreen==oo(1).useFractionOfScreen);
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
   ffprintf(ff,'%d: Your screen resolution is at its native maximum %d x %d. Excellent!\n',1,oo(1).nativeWidth,oo(1).nativeHeight);
else
   warning backtrace off
   if oo(1).permissionToChangeResolution
      fprintf('WARNING: Trying to change your screen resolution to be optimal for this test. ...');
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
      ffprintf(ff,'1: Your screen resolution is at its native maximum %d x %d. Excellent!\n',oo(1).nativeWidth,oo(1).nativeHeight);
   else
      if RectWidth(actualScreenRect)<oo(1).nativeWidth
         ffprintf(ff,'WARNING: Your screen resolution %d x %d is less that its native maximum %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
         warning(['You could reduce the minimum viewing distance ' ...
            '%.1f-fold by increasing the screen resolution to native maximum ("Default"). '],...
            oo(1).nativeWidth/RectWidth(actualScreenRect));
      else
         ffprintf(ff,'WARNING: Your screen resolution %d x %d exceeds its maximum native resolution %d x %d.\n',...
            RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
         warning(['Your screen resolution %d x %d exceeds its maximum native resolution %d x %d. '...
            'Small letters may be impossible to read.'],...
            RectWidth(actualScreenRect),RectHeight(actualScreenRect),...
            oo(1).nativeWidth,oo(1).nativeHeight);
      end
      ffprintf(ff,['(To use native resolution, set o.permissionToChangeResolution=1 in your script, \n'...
         'or use System Preferences:Displays to select "Default" resolution.)\n']);
      warning backtrace on
   end
end
oo(1).resolution=Screen('Resolution',oo(1).screen);

try
   oo(1).screen=max(Screen('Screens'));
   computer=Screen('Computer');
   oo(1).computer=computer;
   if computer.osx || computer.macintosh
      AutoBrightness(oo(1).screen,0); % Do this BEFORE opening the window, so user can see any alerts.
   end
   screenBufferRect=Screen('Rect',oo(1).screen);
   screenRect=Screen('Rect',oo(1).screen,1);
   Screen('Preference','TextRenderer',1); % Request FGTL DrawText plugin.
   window=OpenWindow(oo(1));
   white=WhiteIndex(window);
   black=BlackIndex(window);
   if oo(1).printScreenResolution
      % Just to print them.
      screenBufferRect=Screen('Rect',oo(1).screen)
      screenRect=Screen('Rect',oo(1).screen,1)
      resolution=Screen('Resolution',oo(1).screen)
   end
   screenRect=Screen('Rect',window,1);
   % Are we using the FGTL DrawText plugin?
   Screen('TextFont',window,oo(1).textFont);
   % Ignore possible warning: "PTB-WARNING: DrawText: Failed to load
   % external drawtext plugin".
   Screen('Preference','SuppressAllWarnings',0);
   Screen('Preference','Verbosity',2); % Print WARNINGs
   oo(1).dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
   drawTextWarningFileName=fullfile(oo(1).dataFolder,'drawTextWarning');
   if ~exist(oo(1).dataFolder,'dir')
      [success,msg]=mkdir(oo(1).dataFolder);
      if ~success
         error('%s. Could not create data folder: %s',msg,oo(1).dataFolder);
      end
   end
   delete(drawTextWarningFileName);
   diary(drawTextWarningFileName);
   Screen('DrawText',window,'Hello',0,200,255,255); % Exercise DrawText.
   diary off
   Screen('Preference','SuppressAllWarnings',1);
   Screen('Preference','Verbosity',0); % Mute Psychtoolbox INFOs & WARNINGs.
   oo(1).standardDrawTextPlugin = (Screen('Preference','TextRenderer')==1);
   if oo(1).standardDrawTextPlugin
      oo(1).drawTextPluginWarning='';
   else
      fileId=fopen(drawTextWarningFileName);
      oo(1).drawTextPluginWarning= char(fread(fileId)');
      fclose(fileId);
      if oo(oi).readAlphabetFromDisk
         warning backtrace off
         warning('Please ignore any warnings above about DrawText. You aren''t using it.');
         warning backtrace on
      end
   end
   for oi=1:conditions
      oo(oi).stimulusRect=screenRect;
      if oo(oi).showProgressBar
         progressBarRect=[round(screenRect(3)*0.98) 0 screenRect(3) screenRect(4)]; % 2% of screen width.
         oo(oi).stimulusRect(3)=progressBarRect(1);
      end
      clearRect=oo(oi).stimulusRect;
      if oo(oi).stimulusMarginFraction>0
         s=oo(oi).stimulusMarginFraction*oo(oi).stimulusRect;
         s=round(s);
         oo(oi).stimulusRect=InsetRect(oo(oi).stimulusRect,RectWidth(s),RectHeight(s));
      end
      if ~oo(oi).readAlphabetFromDisk
         if ~oo(1).standardDrawTextPlugin
            error(['Sorry. The FGTL DrawText plugin failed to load. ' ...
               'Hopefully there''s an explanatory PTB-WARNING above. ' ...
               'Unless you fix that, you must set o.readAlphabetFromDisk=1 in your script.']);
         end
         % Check availability of fonts.
         if IsOSX
            fontInfo=FontInfo('Fonts');
            % Match full name, including style.
            hits=streq({fontInfo.name},oo(oi).targetFont);
            if sum(hits)<1
               % Match family name, omitting style.
               hits=streq({fontInfo.familyName},oo(oi).targetFont);
            end
            if sum(hits)==0
               error('The o.targetFont "%s" is not available. Please install it.',oo(oi).targetFont);
            end
            if sum(hits)>1
               error('Multiple fonts with name "%s".',oo(oi).targetFont);
            end
            oo(oi).targetFontNumber=fontInfo(hits).number;
            Screen('TextFont',window,oo(oi).targetFontNumber);
            [~,number]=Screen('TextFont',window);
            if ~(number==oo(oi).targetFontNumber)
               error('The o.targetFont "%s" is not available. Please install it.',oo(oi).targetFont);
            end
         else
            oo(oi).targetFontNumber=[];
            Screen('TextFont',window,oo(oi).targetFont);
            font=Screen('TextFont',window);
            if ~streq(font,oo(oi).targetFont)
               error('The o.targetFont "%s" is not available. Please install it.',oo(oi).targetFont);
            end
         end
         % Due to a bug in Screen TextFont (in December 2015), it is
         % imperative to specify a style number of zero in the next call
         % after calling it with a fontNumber, as we did above.
         Screen('TextFont',window,oo(oi).textFont,0);
         font=Screen('TextFont',window);
         if ~streq(font,oo(oi).textFont)
            warning off backtrace
            warning('The o.textFont "%s" is not available. Using %s instead.',oo(oi).textFont,font);
            warning on backtrace
         end
      end % if ~oo(1).readAlphabetFromDisk
   end
   if ~oo(1).standardDrawTextPlugin
      warning off backtrace
      warning('The FGTL DrawText plugin failed to load. ');
      warning on backtrace
      ffprintf(ff,['WARNING: The FGTL DrawText plugin failed to load.\n' ...
         'Hopefully there''s an explanatory PTB-WARNING above, hinting how to fix it.\n' ...
         'This won''t affect the experimental stimuli, but small print in the instructions may be ugly.\n']);
   end
   
   % Ask about viewing distance
   while 1
      screenRect=Screen('Rect',window);
      screenWidthPix=RectWidth(screenRect);
      screenHeightPix=RectHeight(screenRect);
      if oo(1).useFractionOfScreen
%          pixPerDeg=oo(1).useFractionOfScreen*screenWidthPix/(screenWidthCm*57/oo(1).viewingDistanceCm);
%dgp
         pixPerDeg=screenWidthPix/(screenWidthCm*57/oo(1).viewingDistanceCm);
      else
         pixPerDeg=screenWidthPix/(screenWidthCm*57/oo(1).viewingDistanceCm);
      end
      pixPerCm=screenWidthPix/screenWidthCm;
      for oi=1:conditions
         % Adjust textSize so our string fits on screen.
         instructionalMarginPix=round(0.08*min(RectWidth(screenRect),RectHeight(screenRect)));
         oo(oi).textSize=40; % Rough guess.
         Screen('TextSize',window,oo(oi).textSize);
         Screen('TextFont',window,oo(oi).textFont,0);
         font=Screen('TextFont',window);
         if ~streq(font,oo(oi).textFont)
            warning off backtrace
            warning('The o.textFont "%s" is not available. Using %s instead.',oo(oi).textFont,font);
            warning on backtrace
         end
         instructionalTextLineSample='Please slowly type your name followed by RETURN. more.....more';
         boundsRect=Screen('TextBounds',window,instructionalTextLineSample);
         fraction=RectWidth(boundsRect)/(screenWidthPix-2*instructionalMarginPix);
         % Adjust textSize so our line fits perfectly.
         oo(oi).textSize=round(oo(oi).textSize/fraction);
      end
%       fprintf('1: textSize %.0f, textFont %s.\n',oo(1).textSize,font);
      pixPerDeg=screenWidthPix/(screenWidthCm*57/oo(1).viewingDistanceCm);
      for oi=1:conditions
         oo(oi).viewingDistanceCm=oo(1).viewingDistanceCm;
         oo(oi).pixPerDeg=pixPerDeg;
         oo(oi).pixPerCm=pixPerCm;
         eccentricityDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
         oo(oi).normalAcuityDeg=0.029*(eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
         if ismember(oo(oi).targetFont,{'Pelli'})
            oo(oi).normalAcuityDeg=oo(oi).normalAcuityDeg/5; % For Pelli font.
         end
         oo(oi).normalCriticalSpacingDeg=0.3*(eccentricityDeg+0.15); % Adjusted.
         oo(oi).typicalThesholdSizeDeg=oo(oi).normalAcuityDeg;
         if oo(oi).fixedSpacingOverSize && streq(oo(oi).thresholdParameter,'spacing')
            oo(oi).typicalThesholdSizeDeg=max(oo(oi).typicalThesholdSizeDeg,oo(oi).normalCriticalSpacingDeg/oo(oi).fixedSpacingOverSize);
         end
         minimumSizeDeg=oo(oi).minimumTargetPix/pixPerDeg;
         % Distance so minimum size is half the typical threshold (size or
         % spacing, whichever is higher).
         oo(oi).minimumViewingDistanceCm=10*ceil(0.1*oo(oi).viewingDistanceCm*2*minimumSizeDeg/oo(oi).typicalThesholdSizeDeg);
      end
      minimumViewingDistanceCm=max([oo.minimumViewingDistanceCm]);
      if oo(1).speakViewingDistance && oo(1).useSpeech
         Speak(sprintf('Please move the screen to be %.0f centimeters from your eye.',oo(1).viewingDistanceCm));
      end
      minimumScreenSizeXYDeg=[0 0];
      for oi=1:conditions
         % Compute fixation location, given target eccentricity and
         % location.
         
         % PLACE TARGET AT NEAR POINT
         oo(oi).nearPointXYDeg=oo(oi).eccentricityXYDeg;

         %% COPIED FROM SET UP NEAR POINT
         white=WhiteIndex(window);
         black=BlackIndex(window);
         
         % SELECT NEAR POINT
         % The user specifies the target eccentricity o.eccentricityXYDeg,
         % which specifies its offset from fixation. Currently, we always
         % place the target and the near point together. We take
         % o.nearPointXYInUnitSquare as the user's designation of a point
         % on the screen and the desire that the target (and near point) be
         % placed as close to there as possible, while still achieving the
         % specified eccentricity by shifting target and fixation together
         % enough to get the fixation mark to fit on screen. If the
         % eccentricity is too large to allow both the target and fixation
         % to be on-screen, then the fixation mark is placed off-screen and
         % we place the target and near point at o.nearPointXYInUnitSquare.
         % Thus o.eccentricityXYDeg is a requirement, and we'll error-exit
         % if it cannot be achieved, while o.nearPointXYInUnitSquare is
         % merely a preference for where to place the target.
         %
         % To achieve this we first imagine the target at the desired spot
         % (typically the center of the screen) and note where fixation
         % would land, given the specified eccentricity. If it's on-screen
         % then we're done. If it's off-screen then we push the target just
         % enough in the direction of the eccentricity vector to allow the
         % fixation mark to just fit on-screen. If we can do that without
         % pushing the target off-screen, then we're done. 
         %
         % If we can't get both fixation and target on-screen, then the
         % fixation goes off-screen and the target springs back to the
         % desired spot.
         %
         % We don't mind partially clipping the fixation mark 0.5 deg from
         % its center, but the target must not be clipped by the screen
         % edge, and, further more, since this is a crowding test, there
         % should be enough room to place a radial flanker beyond the
         % target and not clip it. To test a diverse population we should
         % allow twice the normal crowding distance beyond the target
         % center, plus half the flanker size. We typically use equal
         % target and flanker size.
         %
         % These requirements extend the eccentricity vector's length,
         % first by adding 0.5 deg for the fixation mark. If necessary to
         % keep fixation on-screen, we shift the target away from the
         % desired location (in the direction of the eccentricity vector)
         % just enough to get fixation on-screen. Then we have
         % to decide whether it's acceptable. If we're measuring acuity, we
         % just need room, radially (i.e. from fixation), beyond the target
         % center for half the target. If we're measuring crowding, we need
         % room radially, beyond the target center, for 2/3 the
         % eccentricity, plus half the target size.
         
         %% SANITY CHECK OF ECCENTRICITY AND DESIRED NEAR POINT
        if ~all(isfinite(oo(oi).eccentricityXYDeg))
            error('o.eccentricityXYDeg (%.1f %.1f) must be finite. o.useFixation=%d is optional.',...
               oo(oi).eccentricityXYDeg,oo(oi).useFixation);
         end
         if ~IsXYInRect(oo(oi).nearPointXYInUnitSquare,[0 0 1 1])
            error('o.nearPointXYInUnitSquare (%.2f %.2f) must be in unit square [0 0 1 1].',oo(oi).nearPointXYInUnitSquare);
         end
         % Provide default target size if not already provided.
         if ~isfinite(oo(oi).targetDeg)
            ecc=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
            oo(oi).targetDeg=0.3*(ecc+0.15)/oo(oi).fixedSpacingOverSize;
         end
         
         %% IS SCREEN BIG ENOUGH TO HOLD TARGET AND FIXATION?
         % We protect fixationCoreSizeDeg diameter from clipping by screen
         % edge.
         if oo(oi).isolatedTarget
            % In the screen, include the target itself, plus a fraction
            % o.targetMargin of the target size.
            totalSizeXYDeg=oo(oi).fixationCoreSizeDeg/2 + abs(oo(oi).eccentricityXYDeg) + oo(oi).targetDeg*(0.5+oo(oi).targetMargin);
         else
            totalSizeXYDeg=oo(oi).fixationCoreSizeDeg/2 + 1.66*abs(oo(oi).eccentricityXYDeg) + oo(oi).targetDeg/2;
         end
         % Compute angular subtense of stimulusRect, assuming the near
         % point is at center.
         xy=oo(oi).stimulusRect(3:4)-oo(oi).stimulusRect(1:2); % width and height
         rectSizeDeg=2*atand(0.5*xy/oo(1).pixPerCm/oo(1).viewingDistanceCm);
         if all(totalSizeXYDeg <= rectSizeDeg);
            oo(oi).fixationOnScreen=1;
            verb='fits in';
         else
            oo(oi).fixationOnScreen=0;
            verb='exceeds';
         end
         if oo(oi).forceFixationOffScreen
            if oo(oi).fixationOnScreen
               ffprintf(ff,'Fixation would fit on-screen, but was forced off by o.forceFixationOffScreen=%d.\n',...
                  oo(oi).forceFixationOffScreen);
            end
            oo(oi).fixationOnScreen=0;
         end
         ffprintf(ff,'%d: Combined size of target and fixation %.1f x %.1f deg %s screen %.1f x %.1f deg.\n',...
            oi,totalSizeXYDeg,verb,rectSizeDeg);
         if streq(verb,'exceeds') && ~oo(oi).forceFixationOffScreen
            ffprintf(ff,'%d: This forces the fixation off-screen. Consider reducing the viewing distance or eccentricity.\n',oi);
         end
       
         %% SET NEAR POINT AS NEAR AS WE CAN TO DESIRED LOCATION
         xy=oo(oi).nearPointXYInUnitSquare;
         xy(2)=1-xy(2); % Move origin from lower left to upper left.
         oo(oi).nearPointXYPix=xy.*[RectWidth(oo(oi).stimulusRect) RectHeight(oo(oi).stimulusRect)];
         oo(oi).nearPointXYPix=oo(oi).nearPointXYPix+oo(oi).stimulusRect(1:2);
         % oo(oi).nearPointXYPix is a screen coordinate.
         oo(oi).nearPointXYDeg=oo(oi).eccentricityXYDeg;
         if oo(oi).fixationOnScreen
            % If necessary, shift nearPointXYPix just enought to get
            % fixation on screen.
            xy=XYPixOfXYDeg(oo(oi),[0 0]);
            pix=oo(oi).pixPerDeg*oo(oi).fixationCoreSizeDeg/2;
            r=InsetRect(oo(1).stimulusRect,pix,pix);
            if ~IsXYInRect(xy,r)
               xyNew=ClipLineSegment2(xy,oo(oi).nearPointXYPix,r);
               % Apply the needed shift of fixation, from xy to xyNew, to the nearPointXYPix
               ffprintf(ff,'%d: Adjusting o.nearPointXYPix from [%.0f %.0f] to [%.0f %.0f] to get fixation onto the screen.\n',...
                  1,oo(oi).nearPointXYPix,oo(oi).nearPointXYPix+xyNew-xy);
               oo(oi).nearPointXYPix=oo(oi).nearPointXYPix+xyNew-xy;
            end
         end
         % XYPixOfXYDeg results depend on o.nearPointXYDeg and
         % o.nearPointXYPix.
         % fix.xy is a screen coordinate.
         oo(oi).fix.xy=XYPixOfXYDeg(oo(oi),[0 0]);
         % eccentricityXYPix is a vector from fixation to target.
         oo(oi).eccentricityXYPix=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg)-oo(oi).fix.xy;

         % Compute minimumScreenSizeXYDeg and maximumViewingDistanceCm required for on-screen fixation.
         if oi==1
            minimumScreenSizeXYDeg=totalSizeXYDeg;
         else
            minimumScreenSizeXYDeg=max(minimumScreenSizeXYDeg,totalSizeXYDeg);
         end
      end
      maximumViewingDistanceCm=round(min( [screenWidthCm screenHeightCm]./(2*tand(0.5*minimumScreenSizeXYDeg)) ));
      
      % Look for wireless keyboard.

      clear PsychHID; % Force new enumeration of devices to detect external keyboard.
      clear KbCheck; % Clear cache of keyboard devices.
      [~,~,devices]=GetKeyboardIndices;
      for i=1:length(devices)
         oo(1).keyboardNameAndTransport{i}=sprintf('%s (%s)',devices{i}.product,devices{i}.transport);
      end
      oo(1).needWirelessKeyboard = oo(1).viewingDistanceCm>100 ...
         && length(GetKeyboardIndices)<2 ...
         && isempty(strfind(oo(1).keyboardNameAndTransport{1},'wireless')) ...
         && isempty(strfind(oo(1).keyboardNameAndTransport{1},'Wireless')) ...
         && isempty(strfind(oo(1).keyboardNameAndTransport{1},'bluetooth')) ...
         && isempty(strfind(oo(1).keyboardNameAndTransport{1},'Bluetooth'));
      if oo(1).needWirelessKeyboard
         warning backtrace off
         warning('You have only one keyboard, and it''s not "wireless" or "bluetooth":');
         warning('The long viewing distance may demand an external keyboard.');
         warning backtrace on
      end
      
      % BIG TEXT
      % Say hello, and get viewing distance.
      Screen('FillRect',window,white);
      cmString=sprintf('%.0f cm',oo(1).viewingDistanceCm);
      string=sprintf(['Welcome to CriticalSpacing. ' ...
         'If you want a viewing distance of %.0f cm, ' ...
         'please move me to that distance from your eye, and hit RETURN. ' ...
         'Otherwise, please enter the desired distance below, and hit RETURN.'], ...
         oo(1).viewingDistanceCm);
      Screen('TextSize',window,oo(1).textSize);
      [~,y]=DrawFormattedText(window,string,instructionalMarginPix,instructionalMarginPix-0.5*oo(1).textSize,black,length(instructionalTextLineSample)+3-2*length(cmString),[],[],1.1);
      Screen('TextSize',window,2*oo(1).textSize);
      bounds=Screen('TextBounds',window,cmString,[],[],1);
      x=screenRect(3)-bounds(3)-bounds(3)/length(cmString);
      Screen('DrawText',window,cmString,x,y,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      
      % SIZE LIMITS
      string='';
      for oi=1:conditions
         oo(oi).minimumSizeDeg=oo(oi).minimumTargetPix/pixPerDeg;
         if oo(oi).fixedSpacingOverSize
            oo(oi).minimumSpacingDeg=oo(oi).fixedSpacingOverSize*oo(oi).minimumSizeDeg;
         else
            oo(oi).minimumSpacingDeg=1.1*oo(oi).minimumTargetPix/pixPerDeg;
         end
      end
      sizeDeg=max([oo.minimumSizeDeg]);
      spacingDeg=max([oo.minimumSpacingDeg]);

      string=sprintf(['%sSIZE LIMITS: At the current %.0f cm viewing distance, '...
         'the screen is %.0fx%.0f deg, and can display characters'...
         ' as small as %.2f deg with spacing as small as %.2f deg. '],...
         string,oo(1).viewingDistanceCm,RectWidth(screenRect)/pixPerDeg,RectHeight(screenRect)/pixPerDeg,...
         sizeDeg,spacingDeg);
      if any(minimumScreenSizeXYDeg>0)
         string=sprintf(['%sTo display your peripheral targets ' ...
            '(requiring a screen size of at least %.0fx%.0f deg), ' ...
            'view me from at most %.0f cm. '],...
            string,minimumScreenSizeXYDeg,maximumViewingDistanceCm);
      end
      smallestDeg=min([oo.typicalThesholdSizeDeg])/2;
      string=sprintf(['%sTo allow display of your target as small as %.2f deg, ' ...
         'half of typical threshold size, view me from at least %.0f cm.\n\n'], ...
         string,smallestDeg,minimumViewingDistanceCm);
      
      % RESOLUTION
      if oo(1).nativeWidth==RectWidth(actualScreenRect)
         string=sprintf('%sRESOLUTION: Your screen resolution is optimal.\n\n',string);
      else
         if RectWidth(actualScreenRect)<oo(1).nativeWidth
            string=sprintf(['%sRESOLUTION: You could reduce the minimum viewing distance ' ...
               '%.1f-fold by increasing the screen resolution to native resolution. '],...
               string,oo(1).nativeWidth/RectWidth(actualScreenRect));
         else
            string=sprintf(['%sRESOLUTION: Your screen resolution exceeds its maximum native resolution, ' ...
               'and may fail to render small characters. '],string);
         end
         string=sprintf(['%sFor native resolution, ' ...
            'set o.permissionToChangeResolution=1 in your script, ' ...
            'or use System Preferences:Displays to ' ...
            'select "Default" resolution, or type "r" below, ' ...
            'followed by RETURN.\n\n'],string);
      end
      
      % MIRROR
      if oo(1).flipScreenHorizontally
         string=sprintf(['%sMIRROR: To turn off mirroring, ' ...
            'set o.flipScreenHorizontally=0 in your script, ' ...
            'or type "m" below, followed by RETURN.\n\n'],...
            string);
      else
         string=sprintf(['%sMIRROR: To work with a mirror, ' ...
            'set o.flipScreenHorizontally=1 in your script, ' ...
            'or type "m" below, followed by RETURN.\n\n'],...
            string);
      end
      
      % KEYBOARD
      if oo(1).needWirelessKeyboard
         string=sprintf(['%sKEYBOARD: At this distance you may need a wireless keyboard, ' ...
            'but I can''t detect any. After connecting a new keyboard, ' ...
            'use your old keyboard to type "k" below, followed by RETURN, ' ...
            'and I''ll recreate the keyboard list.'],string);
      end
      
    
      % Draw all the small text on screen.
      Screen('TextSize',window,round(oo(1).textSize*0.6));
      [~,y]=DrawFormattedText(window,string,instructionalMarginPix,y+2*oo(1).textSize,black,(1/0.6)*(length(instructionalTextLineSample)+3),[],[],1.1);
      
      % COPYRIGHT
      Screen('TextSize',window,round(oo(1).textSize*0.35));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,white,1);
      
      % Get typed response
      Screen('TextSize',window,oo(1).textSize);
      if IsWindows
         background=[];
      else
         background=WhiteIndex(window);
      end
      Screen('DrawText',window,'To continue to next screen, just hit RETURN. To make a change,',instructionalMarginPix,0.82*screenRect(4)-oo(1).textSize*1.4);
      [d,terminatorChar]=GetEchoString(window,'enter numerical viewing distance (cm) or a command (r, m, or k):',instructionalMarginPix,0.82*screenRect(4),black,background,1,oo(1).deviceIndex);
      if ismember(terminatorChar,[escapeChar graveAccentChar]) 
         oo(1).quitRun=1;
         oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
         if oo(1).quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated. Skipping any remaining runs.\n');
         else
            ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
         end
         ListenChar(0);
         ShowCursor;
         sca;
         return
      end
      if ~isempty(d)
         inputDistanceCm=str2num(d);
         if ~isempty(inputDistanceCm) && inputDistanceCm>0
            oo(1).viewingDistanceCm=inputDistanceCm;
         else
            switch d
               case 'm',
                  oldFlipScreenHorizontally=oo(1).flipScreenHorizontally;
                  oo(1).flipScreenHorizontally=~oo(1).flipScreenHorizontally;
                  if oo(1).useSpeech
                     Speak('Now flipping the display.');
                  end
                  Screen('Close',window);
                  window=OpenWindow(oo(1));
               case 'r',
                  if oo(1).permissionToChangeResolution
                     Speak('Resolution is already optimal.');
                  else
                     if oo(1).useSpeech
                        Speak('Optimizing resolution.');
                     end
                     Screen('Close',window);
                     warning backtrace off
                     warning('Trying to change your screen resolution to be optimal for this test.');
                     warning backtrace on
                     oo(1).oldResolution=Screen('Resolution',oo(1).screen,oo(1).nativeWidth,oo(1).nativeHeight);
                     res=Screen('Resolution',oo(1).screen);
                     if res.width==oo(1).nativeWidth
                        oo(1).permissionToChangeResolution=1;
                        fprintf('SUCCESS!\n');
                     else
                        warning('FAILED.');
                        res
                     end
                     actualScreenRect=Screen('Rect',oo(1).screen,1);
                     window=OpenWindow(oo(1));
                     oo(1).resolution=Screen('Resolution',oo(1).screen);
                     screenBufferRect=Screen('Rect',oo(1).screen);
                     screenRect=Screen('Rect',oo(1).screen,1);
                  end
               case 'k',
                  if oo(1).useSpeech
                     Speak('Recreating list of keyboards.');
                  end
               otherwise,
                  Speak(sprintf('Illegal entry "%s". Try again.',d));
            end
         end
      else
         break;
      end
   end
   ListenChar(0); % flush
   ListenChar(2); % no echo
   
   % Ask experimenter name
   if isempty(oo(1).experimenter)
      Screen('FillRect',window);
      Screen('TextFont',window,oo(1).textFont,0);
      Screen('DrawText',window,'',instructionalMarginPix,screenRect(4)/2-4.5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Hello Experimenter,',instructionalMarginPix,screenRect(4)/2-5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',instructionalMarginPix,screenRect(4)/2-3*oo(1).textSize,black,white);
      Screen('TextSize',window,round(0.6*oo(1).textSize));
      Screen('DrawText',window,'You can skip these screens by defining o.experimenter and o.observer in your script.',instructionalMarginPix,screenRect(4)/2-1.5*oo(1).textSize,black,white);
      Screen('TextSize',window,round(oo(1).textSize*0.35));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      if IsWindows
         background=[];
      else
         background=WhiteIndex(window);
      end
      [name,terminatorChar]=GetEchoString(window,'Experimenter name:',instructionalMarginPix,0.82*screenRect(4),black,background,1,oo(1).deviceIndex);
      if ismember(terminatorChar,[escapeChar graveAccentChar])
         oo(1).quitRun=1;
         oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
         if oo(1).quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
         else
            ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
         end
         ListenChar(0);
         ShowCursor;
         sca;
         return
      end
      for i=1:conditions
         oo(i).experimenter=name;
      end
      Screen('FillRect',window);
   end
   
   % Ask observer name
   if isempty(oo(1).observer)
      Screen('FillRect',window);
      Screen('TextSize',window,oo(1).textSize);
      Screen('TextFont',window,oo(1).textFont,0);
      Screen('DrawText',window,'',instructionalMarginPix,screenRect(4)/2-4.5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Hello Observer,',instructionalMarginPix,screenRect(4)/2-5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',instructionalMarginPix,screenRect(4)/2-3*oo(1).textSize,black,white);
      Screen('TextSize',window,round(oo(1).textSize*0.35));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      if IsWindows
         background=[];
      else
         background=WhiteIndex(window);
      end
      [name,terminatorChar]=GetEchoString(window,'Observer name:',instructionalMarginPix,0.82*screenRect(4),black,background,1,oo(1).deviceIndex);
      if ismember(terminatorChar,[escapeChar graveAccentChar])
         oo(1).quitRun=1;
         oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
         if oo(1).quitSession
            ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
         else
            ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
         end
         ListenChar(0);
         ShowCursor;
         sca;
         return
      end
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
   ffprintf(ff,'%s %s. ',oo(1).functionNames,datestr(now));
   ffprintf(ff,'Saving results in:\n');
   ffprintf(ff,'/data/%s.txt and "".mat\n',oo(1).dataFilename);
   ffprintf(ff,'Keep both files, .txt and .mat, readable by humans and machines.\n');
   for oi=1:conditions
      if ~isempty(oo(oi).unknownFields)
         ffprintf(ff,['%d: Ignoring unknown o fields:' sprintf(' %s',oo(oi).unknownFields{:}) '.\n'],oi);
      end
   end
   ffprintf(ff,'1: %s: %s\n',oo(1).experimenter,oo(1).observer);
   for oi=1:conditions
       if oo(oi).repeatedTargets
         oo(oi).presentations=ceil(oo(oi).trials/2)+oo(oi).practicePresentations;
         oo(oi).trials=2*oo(oi).presentations;
      else
         oo(oi).presentations=oo(oi).trials;
      end
      if oo(oi).repeatedTargets && streq(oo(oi).radialOrTangential,'tangential')
         warning backtrace off
         warning('You are using o.repeatedTargets=1, so I''m setting o.radialOrTangential=''radial''');
         warning backtrace on
         oo(oi).radialOrTangential='radial';
      end
      % Prepare to draw fixation cross.
      fixationCrossPix=round(oo(oi).fixationCrossDeg*pixPerDeg);
%       fixationCrossPix=min(fixationCrossPix,2*RectWidth(oo(oi).stimulusRect)); % full width and height, can extend off screen
      fixationLineWeightPix=round(oo(oi).fixationLineWeightDeg*pixPerDeg);
      fixationLineWeightPix=max(1,fixationLineWeightPix);
      fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
      oo(oi).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
      oo(oi).fix.clipRect=oo(oi).stimulusRect;
      oo(oi).fix.fixationCrossPix=fixationCrossPix;
   
      oo(oi).fix.xy=XYPixOfXYDeg(oo(oi),[0 0]); 
      oo(oi).eccentricityXYPix=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg)-oo(oi).fix.xy;
      oo(oi).fix.eccentricityXYPix=oo(oi).eccentricityXYPix;
      
      oo(oi).responseCount=1; % When we have two targets we get two responses for each display.
      if streq(oo(oi).thresholdParameter,'size')
         if isfield(oo(oi),'targetDegGuess') && isfinite(oo(oi).targetDegGuess)
            oo(oi).targetDeg=oo(oi).targetDegGuess;
         else
            oo(oi).targetDeg=2*oo(oi).normalAcuityDeg; % initial guess for threshold size.
         end
      end

      for ii=1:conditions
         if oo(ii).repeatedTargets
            oo(ii).useFixation=0;
         end
         oo(ii).textSizeDeg = oo(ii).textSize/oo(1).pixPerDeg;
         oo(ii).textLineLength=floor(1.9*RectWidth(screenRect)/oo(ii).textSize);
         oo(ii).speakInstructions=oo(ii).useSpeech;
      end
      
      oo=SetUpFixation(window,oo,oi,ff);
      
      addonDeg=0.15;
      addonPix=pixPerDeg*addonDeg;
      if isfield(oo(oi),'spacingDegGuess') && isfinite(oo(oi).spacingDegGuess)
         oo(oi).spacingDeg=oo(oi).spacingDegGuess;
      else
         oo(oi).spacingDeg=oo(oi).normalCriticalSpacingDeg; % initial guess for distance from center of middle letter
      end
      eccentricityDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
      oo(oi).normalCriticalSpacingDeg=0.3*(eccentricityDeg+0.15); % modified Eq. 14 from Song, Levi, and Pelli (2014).
      if eccentricityDeg>1 && streq(oo(oi).radialOrTangential,'tangential')
         oo(oi).normalCriticalSpacingDeg=oo(oi).normalCriticalSpacingDeg/2; % Toet and Levi.
      end
      if streq(oo(oi).thresholdParameter,'spacing')
         oo(oi).spacingDeg=oo(oi).normalCriticalSpacingDeg; % initial guess for distance from center of middle letter
      end
      oo(oi).spacings=oo(oi).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
      oo(oi).spacingsSequence=repmat(oo(oi).spacings,1,...
         ceil(oo(oi).presentations/length(oo(oi).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of presentations.
      switch oo(oi).thresholdParameter
         case 'size',
            if oo(oi).targetSizeIsHeight
               ori='vertical';
            else
               ori='horizontal';
            end
         case 'spacing',
            if ~oo(oi).repeatedTargets
               ori=oo(oi).radialOrTangential;
            else
               if oo(oi).targetSizeIsHeight
                  ori='vertical';
               else
                  ori='horizontal';
               end
            end
      end
      if oo(oi).useQuest
         ffprintf(ff,'%d: %.0f trials of QUEST will measure threshold %s %s.\n',oi,oo(oi).trials,ori,oo(oi).thresholdParameter);
      else
         ffprintf(ff,'%d: %.0f trials of "method of constant stimuli" with fixed list of %s spacings [',oi,oo(oi).trials,ori);
         ffprintf(ff,'%.1f ',oo(oi).spacings);
         ffprintf(ff,'] deg\n');
      end
      
      % Measure targetHeightOverWidth
      oo(oi).targetFontHeightOverNominalPtSize=nan;
      oo(oi).targetPix=200;
      % Get bounds.
      [letterStruct,alphabetBounds]=CreateLetterTextures(oi,oo(oi),window);
      DestroyLetterTextures(letterStruct);
      oo(oi).targetHeightOverWidth=RectHeight(alphabetBounds)/RectWidth(alphabetBounds);
      if ~oo(oi).readAlphabetFromDisk
         oo(oi).targetFontHeightOverNominalPtSize=RectHeight(alphabetBounds)/oo(oi).targetPix;
      end
      oo(oi).targetPix=oo(oi).targetDeg*pixPerDeg;
      
      for cd=1:conditions
         for i=1:length(oo(cd).validKeyNames)
            oo(cd).responseKeyCodes(i)=KbName(oo(cd).validKeyNames{i}); % this returns keyCode as integer
         end
      end
      
      % Set o.targetHeightOverWidth
      if oo(oi).setTargetHeightOverWidth
         oo(oi).targetHeightOverWidth=oo(oi).setTargetHeightOverWidth;
      end
      
      % Prepare to draw fixation cross
      oo(oi).fix.eccentricityXYPix=oo(oi).eccentricityXYPix;
      assert(all(isfinite(oo(oi).fix.eccentricityXYPix)));
      oo(oi).fix.clipRect=screenRect;
      oo(oi).fix.fixationCrossPix=fixationCrossPix; % Diameter of fixation cross.
      if oo(oi).targetCross;
         oo(oi).fix.targetCrossPix=oo(oi).targetDeg*pixPerDeg*2;
      else
         oo(oi).fix.targetCrossPix=0;
      end
      if oo(oi).fixationCrossBlankedNearTarget
         % Blanking of marks to prevent masking and crowding of the target
         % by the marks. Blanking radius (centered at target) is max of
         % target diameter and half eccentricity.
         diameter=oo(oi).targetDeg*pixPerDeg;
         if ~oo(oi).targetSizeIsHeight
            diameter=diameter*oo(oi).targetHeightOverWidth;
         end
         eccentricityPix=sqrt(sum(oo(oi).eccentricityXYPix.^2));
         oo(oi).fix.blankingRadiusPix=round(max(diameter,0.5*eccentricityPix));
         if oo(oi).fix.blankingRadiusPix >= eccentricityPix
            % Make sure we can see fixation. Extend the lines.
            oo(oi).fix.fixationCrossPix=inf;
         end
      else
         oo(oi).fix.blankingRadiusPix=0;
      end
      fixationLines=ComputeFixationLines2(oo(oi).fix);
      
      oo(1).quitRun=0;
      
      switch oo(oi).thresholdParameter
         case 'spacing',
            assert(oo(oi).spacingDeg>0);
            oo(oi).tGuess=log10(oo(oi).spacingDeg);
         case 'size',
            assert(oo(oi).targetDeg>0);
            oo(oi).tGuess=log10(oo(oi).targetDeg);
      end
      oo(oi).tGuessSd=2;
      oo(oi).pThreshold=0.7;
      oo(oi).beta=3;
      delta=0.01;
      gamma=1/length(oo(oi).alphabet);
      grain=0.01;
      range=6;
   end % for oi=1:conditions
   
   cal.screen=max(Screen('Screens'));
   if cal.screen>0
      ffprintf(ff,'Using external monitor.\n');
   end
   for oi=1:conditions
      ffprintf(ff,'%d: ',oi);
      if oo(oi).repeatedTargets
         numberTargets='two targets (repeated many times)';
      else
         numberTargets='one target';
      end
      string=sprintf('%s %s, alternatives %d,  beta %.1f\n',oo(oi).task,numberTargets,length(oo(oi).alphabet),oo(oi).beta);
      string(1)=upper(string(1));
      ffprintf(ff,'%s',string);
   end
   for oi=1:conditions
      if oo(oi).fixedSpacingOverSize
         ffprintf(ff,'%d: Fixed ratio of spacing over size %.2f.\n',oi,oo(oi).fixedSpacingOverSize);
      else
         switch oo(oi).thresholdParameter
            case 'size',
               ffprintf(ff,'%d: Measuring threshold size, with no flankers.\n',oi);
            case 'spacing'
               ffprintf(ff,'%d: Target size %.2f deg, %.1f pixels.\n',oi,oo(oi).targetDeg,oo(oi).targetDeg*pixPerDeg);
               if ~isfinite(oo(oi).targetDeg)
                  error('To measure spacing threshold you must define either o.fixedSpacingOverSize or o.targetDeg.');
               end
         end
      end
   end
   for oi=1:conditions
      ffprintf(ff,'%d: Viewing distance %.0f cm. (Must exceed %.0f cm to produce %.3f deg letter.)\n',...
         oi,oo(oi).viewingDistanceCm,oo(oi).minimumViewingDistanceCm,oo(oi).normalAcuityDeg/2);
   end
   ffprintf(ff,['%d: Needing screen size of at least %.0fx%.0f deg, ' ...
      'you should view from at most %.0f cm.\n'],...
      oi,minimumScreenSizeXYDeg,maximumViewingDistanceCm);
   
   ffprintf(ff,'1: %d keyboards: ',length(oo(1).keyboardNameAndTransport));
   for i=1:length(oo(1).keyboardNameAndTransport)
      ffprintf(ff,'%s,  ',oo(1).keyboardNameAndTransport{i});
   end
   ffprintf(ff,'\n');
   for oi=1:conditions
      sizesPix=oo(oi).minimumTargetPix*[oo(oi).targetHeightOverWidth 1];
      ffprintf(ff,'%d: Minimum letter size %.0fx%.0f pix, %.3fx%.3f deg. ',oi,sizesPix,sizesPix/pixPerDeg);
      if oo(oi).fixedSpacingOverSize
         spacingPix=round(oo(oi).minimumTargetPix*oo(oi).fixedSpacingOverSize);
         ffprintf(ff,'Minimum spacing %.0f pix, %.3f deg.\n',spacingPix,spacingPix/pixPerDeg);
      else
         switch oo(oi).thresholdParameter
            case 'size',
               ffprintf(ff,'Spacing %.0f pixels, %.3f deg.\n',oo(oi).spacingPix,oo(oi).spacingDeg);
            case 'spacing',
               ffprintf(ff,'Size %.0f pixels, %.3f deg.\n',oo(oi).targetPix,oo(oi).targetDeg);
         end
      end
   end
   for oi=1:conditions
      if oo(oi).readAlphabetFromDisk
         ffprintf(ff,'%d: "%s" font from disk. ',oi,oo(oi).targetFont);
      else
         ffprintf(ff,'%d: "%s" font, live. ',oi,oo(oi).targetFont);
      end
      ffprintf(ff,'Alphabet ''%s'' and borderLetter ''%s''.\n',oo(oi).alphabet,oo(oi).borderLetter);
   end
   for oi=1:conditions
      ffprintf(ff,'%d: o.targetHeightOverWidth %.2f, targetFontHeightOverNominalPtSize %.2f\n',oi,oo(oi).targetHeightOverWidth,oo(oi).targetFontHeightOverNominalPtSize);
   end
   for oi=1:conditions
      ffprintf(ff,'%d: durationSec %.2f, eccentricityXYDeg [%.1f %.1f]\n',...
         oi,oo(oi).durationSec,oo(oi).eccentricityXYDeg);
   end
   
   % Identify the computer
   cal.screen=0;
   computer=Screen('Computer');
   [cal.screenWidthMm,cal.screenHeightMm]=Screen('DisplaySize',cal.screen);
   if computer.windows
      cal.processUserLongName=getenv('USERNAME');
      cal.localHostName=getenv('USERDOMAIN');
      cal.macModelName=[];
   elseif computer.linux
      cal.processUserLongName=getenv('USER');
      cal.localHostName=computer.localHostName;
      cal.machineName=computer.machineName;
      cal.osversion=computer.kern.version;
      cal.macModelName=[];
   elseif computer.osx || computer.macintosh
      cal.processUserLongName=computer.processUserLongName;
      cal.machineName=strrep(computer.machineName,'éˆ??',''''); % work around bug in Screen('Computer')
      if streq(cal.machineName,'UNKNOWN! QUERY FAILED DUE TO EMPTY OR PROBLEMATIC NAME.')
         cal.machineName='';
      end
      cal.localHostName=computer.localHostName;
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
   if oo(1).flipScreenHorizontally
      ffprintf(ff,'Using mirror. ');
   end
   ffprintf(ff,'%d: Viewing distance %.0f cm,',1,oo(1).viewingDistanceCm);
   xy=oo(oi).stimulusRect(3:4)-oo(oi).stimulusRect(1:2); % width and height
   xyDeg=2*atand(0.5*xy/oo(1).pixPerCm/oo(1).viewingDistanceCm);
   ffprintf(ff,' %.0f pixPerDeg, %.0f pix/cm.\n',...
      pixPerDeg,RectWidth(actualScreenRect)/(screenWidthMm/10));
   ffprintf(ff,'%d: Screen %d, %dx%d pixels (%dx%d native), %.1fx%.1f cm, %.1fx%.1f deg.\n',...
      1,cal.screen,RectWidth(actualScreenRect),RectHeight(actualScreenRect),...
      oo(1).nativeWidth,oo(1).nativeHeight,...
      screenWidthMm/10,screenHeightMm/10,xyDeg);
   ffprintf(ff,'1: %s, "%s", %s\n',cal.macModelName,cal.localHostName,cal.processUserLongName);
   oo(1).matlab=version;
   [~,oo(1).psychtoolbox]=PsychtoolboxVersion;
   v=oo(1).psychtoolbox;
   ffprintf(ff,'1: %s, MATLAB %s, Psychtoolbox %d.%d.%d\n',computer.system,oo(1).matlab,v.major,v.minor,v.point);
   assert(cal.screenWidthCm==screenWidthMm/10);
   cal.ScreenConfigureDisplayBrightnessWorks=1;
   if cal.ScreenConfigureDisplayBrightnessWorks
      cal.brightnessSetting=1;
      % Psychtoolbox Bug: Screen ConfigureDisplay claims that it will
      % silently do nothing if not supported. But when I used it on my
      % video projector, Screen gave a fatal error. How can my program know
      % when it's safe to use Screen ConfigureDisplay?
      % Bug reported to Psychtoolbox forum June 2017.
      if computer.osx || computer.macintosh
         Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
      end
   end
   for oi=1:conditions
      oo(oi).cal=cal;
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
      usingDigits=usingDigits || all(ismember(oo(oi).alphabet,'0123456789'));
      usingLetters=usingLetters || any(~ismember(oo(oi).alphabet,'0123456789'));
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
   if length(oo(oi).observer)>0
      string=[sprintf('Hello %s. ',oo(oi).observer)];
   else
      string='Hello. ';
   end
   string=[string 'Please turn on this computer''s sound. '];
   string=[string 'Press CAPS LOCK at any time to see the alphabet of possible letters. '];
   string=[string 'You might also have the alphabet on a piece of paper. '];
   string=[string 'You can respond by typing or speaking, or by pointing to a letter on your piece of paper. '];
   for oi=1:conditions
      if ~oo(oi).repeatedTargets && streq(oo(oi).thresholdParameter,'size')
         string=[string 'When you see a letter, please report it. '];
         break;
      end
   end
   for oi=1:conditions
      if ~oo(oi).repeatedTargets && streq(oo(oi).thresholdParameter,'spacing')
         string=[string 'When you see three letters, please report just the middle letter. '];
         break;
      end
   end
   if any([oo.repeatedTargets])
      string=[string 'When you see many letters, they are all repetitions of just two different letters. Please report both. '];
      string=[string 'The two kinds of letter can be mixed together all over the display, or separated into left and right sides. '];
   end
   string=[string 'Sometimes the letters will be easy to identify. Sometimes they will be nearly impossible. '];
   string=[string 'You can''t get much more than half right, so relax. Think of it as a guessing game, ' ...
      'and just get as many as you can. '];
   string=[string 'Type slowly. (Quit anytime by pressing ESCAPE.) '];
   if ~any(oo.useFixation)
      string=[string 'Look in the middle of the screen, ignoring the edges of the screen. '];
   end
   string=[string 'To continue, please hit RETURN. '];
   Screen('TextFont',window,oo(oi).textFont,0);
   Screen('TextSize',window,round(oo(oi).textSize*0.35));
   Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2016, 2017, Denis Pelli. All rights reserved.'),instructionalMarginPix,screenRect(4)-0.5*instructionalMarginPix,black,white,1);
   Screen('TextSize',window,oo(oi).textSize);
   string=strrep(string,'letter',symbolName);
   DrawFormattedText(window,string,instructionalMarginPix,instructionalMarginPix-0.5*oo(1).textSize,black,length(instructionalTextLineSample)+3,[],[],1.1);
   Screen('Flip',window,[],1);
   if 0 && oo(oi).useSpeech
      string=strrep(string,'\n','');
      string=strrep(string,'eye(s)','eyes');
      Speak(string);
   end
   SetMouse(screenRect(3),screenRect(4),window);
   answer=GetKeypressWithHelp([spaceKeyCode returnKeyCode escapeKeyCode graveAccentKeyCode],oo(oi),window,oo(oi).stimulusRect);
   
   Screen('FillRect',window);
   if ismember(answer,[escapeChar graveAccentChar])
      oo(1).quitRun=1;
      oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
      if oo(1).quitSession
         ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
      else
         ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
      end
      ListenChar(0);
      ShowCursor;
      sca;
      return
   end
   fixationClipRect=oo(oi).stimulusRect;
   if any(oo.useFixation)
      string='On each trial, try to identify the target letter by typing that key. Please use the crosshairs on every trial. ';
      if oo(1).fixationOnScreen
         where='below';
      else
         polarDeg=atan2d(-oo(1).nearPointXYDeg(2),-oo(1).nearPointXYDeg(1));
         quadrant=round(polarDeg/90);
         quadrant=mod(quadrant,4);
         switch quadrant
            case 0,
               where='to the right';
            case 1,
               where='above';
            case 2,
               where='to the left';
            case 3,
               where='below';
         end
      end
      string=sprintf('%sTo begin, please fix your gaze at the center of the crosshairs %s, and, while fixating, press the SPACEBAR. ',...
         string,where);
      string=strrep(string,'letter',symbolName);
      fixationClipRect(2)=5*oo(oi).textSize;
      x=instructionalMarginPix;
      y=1.3*oo(1).textSize;
      Screen('TextSize',window,oo(oi).textSize);
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
   for oi=1:conditions
      % Run the specified number of presentations of each condition, in
      % random order
      condList = [condList repmat(oi,1,oo(oi).presentations)];
      oo(oi).spacingsSequence=Shuffle(oo(oi).spacingsSequence);
      oo(oi).q=QuestCreate(oo(oi).tGuess,oo(oi).tGuessSd,oo(oi).pThreshold,oo(oi).beta,delta,gamma,grain,range);
      oo(oi).trialData=struct([]);
   end
   condList=Shuffle(condList);
   presentation=0;
   while presentation<length(condList)
      presentation=presentation+1;
      oi=condList(presentation);
      easyModulus=ceil(1/oo(oi).fractionEasyTrials-1);
      easyPresentation= easeRequest>0 || mod(presentation-1,easyModulus)==0;
      if oo(oi).useQuest
         intensity=QuestQuantile(oo(oi).q);
         if oo(oi).measureBeta
            offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
            intensity=intensity+offsetToMeasureBeta(1);
         end
         if easyPresentation
            easyCount=easyCount+1;
            oo(oi).easyCount=oo(oi).easyCount+1;
            intensity=intensity+oo(oi).easyBoost;
            if easeRequest>1
               intensity=intensity+(easeRequest-1)*oo(oi).easyBoost;
            end
         end
         switch oo(oi).thresholdParameter
            case 'spacing',
               oo(oi).spacingDeg=10^intensity;
               if oo(oi).fixedSpacingOverSize
                  oo(oi).targetDeg=oo(oi).spacingDeg/oo(oi).fixedSpacingOverSize;
               else
                  oo(oi).spacingDeg=max(oo(oi).spacingDeg,1.1*oo(oi).targetDeg);
               end
            case 'size',
               oo(oi).targetDeg=10^intensity;
         end
      else
         oo(oi).spacingDeg=oo(oi).spacingsSequence(ceil(oo(oi).responseCount/2));
      end
      oo(oi).targetPix=oo(oi).targetDeg*pixPerDeg;
      oo(oi).targetPix=max(oo(oi).targetPix,oo(oi).minimumTargetPix);
      if oo(oi).targetSizeIsHeight
         oo(oi).targetPix=max(oo(oi).targetPix,oo(oi).minimumTargetPix*oo(oi).targetHeightOverWidth);
      end
      oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
      if streq(oo(oi).thresholdParameter,'size') && oo(oi).fixedSpacingOverSize
         oo(oi).spacingDeg=oo(oi).targetDeg*oo(oi).fixedSpacingOverSize;
      end
      spacingPix=oo(oi).spacingDeg*pixPerDeg;
      if oo(oi).fixedSpacingOverSize
         spacingPix=max(spacingPix,oo(oi).minimumTargetPix*oo(oi).fixedSpacingOverSize);
      end
      if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetFontHeightOverNominalPtSize %.2f, targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',oi,MFileLineNr,oo(oi).targetFontHeightOverNominalPtSize,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end;
      if oo(oi).repeatedTargets
         if RectHeight(oo(oi).stimulusRect)/RectWidth(oo(oi).stimulusRect) > oo(oi).targetHeightOverWidth;
            minSpacesY=3+1; 
            minSpacesX=0;
         else
            minSpacesY=0;
            minSpacesX=3+1; % Layout code currently assumes a centered target, so minSpaces must be even.
         end
      else
         % Just one target
         % minSpacesX is the in tangential direction
         % minSpacesY is in the radial direction
         switch oo(oi).thresholdParameter
            case 'spacing',
               if oo(oi).fourFlankers
                  minSpacesY=2;
                  minSpacesX=2;
               else
                  if oo(oi).targetSizeIsHeight
                     minSpacesY=2;
                     minSpacesX=0;
                  else
                     minSpacesY=0;
                     minSpacesX=2;
                  end
               end
            case 'size',
               minSpacesY=0;
               minSpacesX=0;
         end
      end
      if oo(oi).practiceCountdown>=3
         if oo(oi).repeatedTargets
            if minSpacesX
               minSpacesX=1;
            end
            if minSpacesY
               minSpacesY=1;
            end
            if minSpacesX && minSpacesY
               minSpacesY=0;
            end
         else
            minSpacesX=0;
            minSpacesY=0;
         end
      end
      if oo(oi).printSizeAndSpacing; fprintf('%d: %d: minSpacesX %d, minSpacesY %d, \n',oi,MFileLineNr,minSpacesX,minSpacesY); end;
      % The spacings are center to center, so we'll fill the screen when we
      % have the prescribed minSpacesX or minSpacesY plus a half letter at
      % each border. We impose an upper bound on spacingPix to guarantee
      % that we have the requested number of spaces horizontally
      % (minSpacesX) and vertically (minSpacesY).
      if ~oo(oi).targetSizeIsHeight
         % spacingPix is vertical. It is scaled by
         % heightOverWidth in the orthogonal direction.
         if oo(oi).fixedSpacingOverSize
            spacingPix=min(spacingPix,floor(RectHeight(oo(oi).stimulusRect)/(minSpacesY+1/oo(oi).fixedSpacingOverSize)));
            spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize)));
            oo(oi).targetPix=spacingPix/oo(oi).fixedSpacingOverSize;
         else
            spacingPix=min(spacingPix,floor((RectHeight(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesY));
            spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*(RectWidth(oo(oi).stimulusRect)-oo(oi).targetPix/oo(oi).targetHeightOverWidth)/minSpacesX));
         end
      else
         % spacingPix is horizontal. It is scaled by
         % heightOverWidth in the orthogonal direction.
         if oo(oi).fixedSpacingOverSize
            spacingPix=min(spacingPix,floor(RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize)));
            spacingPix=min(spacingPix,floor(RectHeight(oo(oi).stimulusRect)/(minSpacesY+1/oo(oi).fixedSpacingOverSize)/oo(oi).targetHeightOverWidth));
            oo(oi).targetPix=spacingPix/oo(oi).fixedSpacingOverSize;
         else
            spacingPix=min(spacingPix,floor((RectHeight(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesX));
            spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*(RectWidth(oo(oi).stimulusRect)-oo(oi).targetHeightOverWidth*oo(oi).targetPix)/4));
         end
      end
      oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
      oo(oi).spacingDeg=spacingPix/pixPerDeg;
      xyT=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg); % target
      if oo(oi).printSizeAndSpacing;
         fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f, xyT %d, %d\n',...
            oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,...
            spacingPix,oo(oi).spacingDeg,xyT);
      end
      spacingPix=round(spacingPix);
      xF=[];
      yF=[];
      if streq(oo(oi).radialOrTangential,'tangential') || (oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing'))
         % Flankers must fit on screen. Compute where tangent line
         % intersects stimulusRect. The tangent line goes through target
         % xyT and is orthogonal to the line from fixation.
         orientation=90+atan2d(oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2));
         if ~IsXYInRect(xyT,oo(oi).stimulusRect)
            ffprintf(ff,'ERROR: the target fell off the screen. Please reduce the viewing distance.\n');
            stimulusSize=[RectWidth(oo(oi).stimulusRect) RectHeight(oo(oi).stimulusRect)];
            ffprintf(ff,'o.stimulusRect %.0fx%.0f pix, %.0fx%.0f deg, fixation at (%.0f,%.0f) deg, eccentricity (%.0f,%.0f) deg, target at (%0.f,%0.f) deg.\n',...
               stimulusSize,stimulusSize/pixPerDeg,...
               oo(oi).fix.x/pixPerDeg,oo(oi).fix.y/pixPerDeg,...
               oo(oi).eccentricityXYDeg,...
               xyT/pixPerDeg);
            error('Sorry the target (eccentricity [%.0f %.0f] deg) is falling off the screen. Please reduce the viewing distance.',oo(oi).eccentricityXYDeg);
         end
         assert(length(spacingPix)==1);
         if oo(oi).fixedSpacingOverSize
            xF=xyT(1)+[-1 1]*spacingPix*(1+0.5*oo(oi).fixedSpacingOverSize)*sind(orientation);
            yF=xyT(2)-[-1 1]*spacingPix*(1+0.5*oo(oi).fixedSpacingOverSize)*cosd(orientation);
            [xF,yF]=ClipLineSegment(xF,yF,oo(oi).stimulusRect);
            spacingPix=min(sqrt((xF-xyT(1)).^2 + (yF-xyT(2)).^2))/(1+0.5*oo(oi).fixedSpacingOverSize);
         else
            xF=xyT(1)+[-1 1]*(spacingPix+0.5*oo(oi).targetPix)*sind(orientation);
            yF=xyT(2)-[-1 1]*(spacingPix+0.5*oo(oi).targetPix)*cosd(orientation);
            [xF,yF]=ClipLineSegment(xF,yF,oo(oi).stimulusRect);
            spacingPix=min(sqrt((xF-xyT(1)).^2 + (yF-xyT(2)).^2))-0.5*oo(oi).targetPix;
         end
         assert(length(spacingPix)==1);
         spacingPix=max(0,spacingPix);
         assert(length(spacingPix)==1);
         xF=xyT(1)+[-1 1]*spacingPix*sind(orientation);
         yF=xyT(2)-[-1 1]*spacingPix*cosd(orientation);
         % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacingPix,requestedSpacing/pixPerDeg,spacingPix/pixPerDeg);
         outerSpacingPix=0;
      end
      if streq(oo(oi).radialOrTangential,'radial') || (oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing'))
%          orientation=oo(oi).eccentricityClockwiseAngleDeg;
         orientation=atan2d(oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2));
         eccentricityPix=sqrt(sum(oo(oi).eccentricityXYPix.^2));
         if eccentricityPix==0
            % Flanker must fit on screen, horizontally
            if oo(oi).fixedSpacingOverSize
               spacingPix=min(spacingPix,RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize));
            else
               spacingPix=min(spacingPix,(RectWidth(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesX);
            end
            assert(spacingPix>=0);
            xF(end+1:end+2)=xyT(1)+[-1 1]*spacingPix*sind(orientation);
            yF(end+1:end+2)=xyT(2)-[-1 1]*spacingPix*cosd(orientation);
            % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacingPix,requestedSpacing/pixPerDeg,spacingPix/pixPerDeg);
            outerSpacingPix=0;
            if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end;
         else % eccentricity not zero
            assert(spacingPix>=0);
            spacingPix=min(eccentricityPix,spacingPix); % Inner flanker must be between fixation and target.
            assert(spacingPix>=0);
            if oo(oi).fixedSpacingOverSize
               spacingPix=min(spacingPix,xyT(1)/(1+1/oo(oi).fixedSpacingOverSize/2)); % Inner flanker is on screen.
               assert(spacingPix>=0);
               for i=1:100
                  outerSpacingPix=(eccentricityPix+addonPix)^2/(eccentricityPix+addonPix-spacingPix)-(eccentricityPix+addonPix);
                  assert(outerSpacingPix>=0);
                  if outerSpacingPix<=RectWidth(oo(oi).stimulusRect)-xyT(1)-spacingPix/oo(oi).fixedSpacingOverSize/2; % Outer flanker is on screen.
                     break;
                  else
                     spacingPix=0.9*spacingPix;
                  end
               end
               if i==100
                  ffprintf(ff,'ERROR: spacingPix %.2f, outerSpacingPix %.2f exceeds max %.2f pix.\n',spacingPix,outerSpacingPix,RectWidth(oo(oi).stimulusRect)-xyT(1)-spacingPix/oo(oi).fixedSpacingOverSize/2);
                  error('Could not make spacing small enough. Right flanker will be off screen. If possible, try using off-screen fixation.');
               end
            else
               spacingPix=min(spacingPix,xyT(1)-oo(oi).targetPix/2); % inner flanker on screen
               outerSpacingPix=(eccentricityPix+addonPix)^2/(eccentricityPix+addonPix-spacingPix)-(eccentricityPix+addonPix);
               outerSpacingPix=min(outerSpacingPix,RectWidth(oo(oi).stimulusRect)-xyT(1)-oo(oi).targetPix/2); % outer flanker on screen
            end
            assert(outerSpacingPix>=0);
            spacingPix=eccentricityPix+addonPix-(eccentricityPix+addonPix)^2/(eccentricityPix+addonPix+outerSpacingPix);
            assert(spacingPix>=0);
            spacingPix=round(spacingPix);
            assert(spacingPix>=0);
            xF(end+1:end+2)=xyT(1)+[-spacingPix outerSpacingPix]*sind(orientation);
            yF(end+1:end+2)=xyT(2)-[-spacingPix outerSpacingPix]*cosd(orientation);
         end
      end
      oo(oi).spacingDeg=spacingPix/pixPerDeg;
      if streq(oo(oi).thresholdParameter,'spacing') && oo(oi).fixedSpacingOverSize
         oo(oi).targetDeg=oo(oi).spacingDeg/oo(oi).fixedSpacingOverSize;
      end
      oo(oi).targetPix=oo(oi).targetDeg*pixPerDeg;
      if oo(oi).targetSizeIsHeight
         oo(oi).targetPix=min(oo(oi).targetPix,RectHeight(oo(oi).stimulusRect));
         oo(oi).targetPix=min(oo(oi).targetPix,RectWidth(oo(oi).stimulusRect)*oo(oi).targetHeightOverWidth);
      else
         oo(oi).targetPix=min(oo(oi).targetPix,RectWidth(oo(oi).stimulusRect));
         oo(oi).targetPix=min(oo(oi).targetPix,RectHeight(oo(oi).stimulusRect)/oo(oi).targetHeightOverWidth);
      end
      oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
      if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end;
      % Prepare to draw fixation cross.
      if oo(oi).fixationCrossBlankedNearTarget
         % Blanking of marks to prevent masking and crowding of the target
         % by the marks. Blanking radius (centered at target) is max of
         % target diameter and half eccentricity.
         diameter=oo(oi).targetDeg*pixPerDeg;
         if ~oo(oi).targetSizeIsHeight
            diameter=diameter*oo(oi).targetHeightOverWidth;
         end
         eccentricityPix=sqrt(sum(oo(oi).eccentricityXYPix.^2));
         oo(oi).fix.blankingRadiusPix=round(max(diameter,0.5*eccentricityPix));
         if oo(oi).fix.blankingRadiusPix >= eccentricityPix
            % Make sure we can see fixation. Extend the lines.
            oo(oi).fix.fixationCrossPix=inf;
         end
      else
         oo(oi).fix.blankingRadiusPix=0;
      end
      fixationLines=ComputeFixationLines2(oo(oi).fix);
      % Set up fixation.
      if ~oo(oi).repeatedTargets && oo(oi).useFixation
         % Draw fixation.
         fl=ClipLines(fixationLines,fixationClipRect);
         Screen('DrawLines',window,fl,fixationLineWeightPix,black);
      end
      if oo(oi).showProgressBar
         Screen('FillRect',window,[0 220 0],progressBarRect); % green bar
         r=progressBarRect;
         r(4)=round(r(4)*(1-presentation/length(condList)));
         Screen('FillRect',window,[220 220 220],r); % grey background
      end
      Screen('Flip',window,[],1); % Display instructions and fixation.
      if oo(oi).useFixation
         if beginAfterKeypress
            SetMouse(screenRect(3),screenRect(4),window);
            answer=GetKeypressWithHelp([spaceKeyCode escapeKeyCode graveAccentKeyCode],oo(oi),window,oo(oi).stimulusRect);
            if ismember(answer,[escapeChar graveAccentChar])
               oo(1).quitRun=1;
               oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
               if oo(1).quitSession
                  ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
               else
                  ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
               end
               ListenChar(0);
               ShowCursor;
               sca;
               return
            end
            beginAfterKeypress=0;
         end
         Screen('FillRect',window,white,oo(oi).stimulusRect);
         Screen('FillRect',window,white,clearRect);
         % Define fixation bounds midway through first trial, for rest of
         % trials.
%          fixationClipRect=InsetRect(oo(oi).stimulusRect,0,1.6*oo(oi).textSize);
         fixationClipRect=oo(oi).stimulusRect;
         if ~oo(oi).repeatedTargets && oo(oi).useFixation
            % Draw fixation.
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,min(7,3*fixationLineWeightPix),white);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
         Screen('Flip',window,[],1); % Display fixation.
         WaitSecs(1); % Duration of fixation display, before stimulus appears.
         Screen('FillRect',window,[],oo(oi).stimulusRect); % Clear screen; keep progress bar.
         Screen('FillRect',window,[],clearRect); % Clear screen; keep progress bar.
         if ~oo(oi).repeatedTargets && oo(oi).useFixation
            % Draw fixation.
            fl=ClipLines(fixationLines,fixationClipRect);
            Screen('DrawLines',window,fl,min(7,3*fixationLineWeightPix),white);
            Screen('DrawLines',window,fl,fixationLineWeightPix,black);
         end
      else
         Screen('FillRect',window); % Clear screen.
      end
      stimulus=Shuffle(oo(oi).alphabet);
      if length(stimulus)>=3
      stimulus=stimulus(1:3); % three random letters, all different.
      else
         % three random letters, independent samples, with replacement.
         b=Shuffle(stimulus);
         c=Shuffle(stimulus);
         stimulus(2)=b(1);
         stimulus(3)=c(1);
      end
      if isfield(oo(oi),'flankerLetter') && length(oo(oi).flankerLetter)==1
         stimulus(1)=oo(oi).flankerLetter;
         stimulus(3)=oo(oi).flankerLetter;
         while stimulus(2)==oo(oi).flankerLetter
            stimulus(2)=oo(oi).alphabet(randi(length(oo(oi).alphabet)));
         end
      end
      if isfinite(oo(oi).targetFontHeightOverNominalPtSize)
         if oo(oi).targetSizeIsHeight
            sizePix=round(oo(oi).targetPix/oo(oi).targetFontHeightOverNominalPtSize);
            oo(oi).targetPix=sizePix*oo(oi).targetFontHeightOverNominalPtSize;
         else
            sizePix=round(oo(oi).targetPix/oo(oi).targetFontHeightOverNominalPtSize*oo(oi).targetHeightOverWidth);
            oo(oi).targetPix=sizePix*oo(oi).targetFontHeightOverNominalPtSize/oo(oi).targetHeightOverWidth;
         end
      end
      oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
      
      % Create letter textures, using font or from disk.
      letterStruct=CreateLetterTextures(oi,oo(oi),window);
      letters=[oo(oi).alphabet oo(oi).borderLetter];
      
      if oo(oi).showAlphabet
         % This is for debugging. We also display the alphabet any time the
         % caps lock key is pressed. That's standard behavior to allow the
         % observer to familiarize herself with the alphabet.
         for i=1:length(letters)
            r=[0 0 RectWidth(letterStruct(i).rect) RectHeight(letterStruct(i).rect)];
            s=RectWidth(oo(oi).stimulusRect)/(1.5*length(letters))/RectWidth(r);
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
      if oo(oi).targetSizeIsHeight
         ySpacing=spacingPix;
         xSpacing=spacingPix/oo(oi).targetHeightOverWidth;
         yPix=oo(oi).targetPix;
         xPix=oo(oi).targetPix/oo(oi).targetHeightOverWidth;
      else
         xPix=oo(oi).targetPix;
         yPix=oo(oi).targetPix*oo(oi).targetHeightOverWidth;
         xSpacing=spacingPix;
         ySpacing=spacingPix*oo(oi).targetHeightOverWidth;
      end
      if oo(oi).printSizeAndSpacing; fprintf('%d: %d: xSpacing %.0f, ySpacing %.0f, ratio %.2f\n',oi,MFileLineNr,xSpacing,ySpacing,ySpacing/xSpacing); end;
      if ~oo(oi).repeatedTargets
         xStimulus=[xF(1) xyT(1) xF(2:end)];
         yStimulus=[yF(1) xyT(2) yF(2:end)];
         if oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing')
            newFlankers=Shuffle(oo(oi).alphabet(oo(oi).alphabet~=stimulus(2)));
            stimulus(end+1:end+2)=newFlankers(1:2);
         end
         clear textures dstRects
         for textureIndex=1:length(xStimulus)
            whichLetter=strfind(letters,stimulus(textureIndex)); % finds stimulus letter in "letters".
            assert(length(whichLetter)==1)
            textures(textureIndex)=letterStruct(whichLetter).texture;
            r=round(letterStruct(whichLetter).rect);
            oo(oi).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
            if oo(oi).setTargetHeightOverWidth
               r=round(ScaleRect(letterStruct(whichLetter).rect,oo(oi).targetHeightOverWidth/oo(oi).setTargetHeightOverWidth,1));
               oo(oi).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
               %                      dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
            end
            if oo(oi).targetSizeIsHeight
               heightPix=oo(oi).targetPix;
            else
               heightPix=oo(oi).targetHeightOverWidth*oo(oi).targetPix;
            end
            r=round((heightPix/RectHeight(letterStruct(whichLetter).rect))*letterStruct(whichLetter).rect);
            dstRects(1:4,textureIndex)=OffsetRect(r,round(xStimulus(textureIndex)-xPix/2),round(yStimulus(textureIndex)-yPix/2));
            if oo(oi).printSizeAndSpacing
               fprintf('xPix %.0f, yPix %.0f, RectWidth(r) %.0f, RectHeight(r) %.0f, x %.0f, y %.0f, dstRect %0.f %0.f %0.f %0.f\n',xPix,yPix,RectWidth(r),RectHeight(r),xStimulus(textureIndex),yStimulus(textureIndex),dstRects(1:4,textureIndex));
            end
         end
         if ~streq(oo(oi).thresholdParameter,'spacing') || oo(oi).practiceCountdown
            % Show only the target, omitting all flankers.
            textures=textures(2);
            dstRects=dstRects(1:4,2);
         end
         if oo(oi).oneFlanker
            % Show target with only one of the two flankers.
            textures=textures(1:2);
            dstRects=dstRects(1:4,1:2);
         end
      else
         % repeatedTargets
         % Screen bounds on letter array.
         xMin=xyT(1)-xSpacing*floor((xyT(1)-oo(oi).stimulusRect(1)-0.5*xPix)/xSpacing);
         xMax=xyT(1)+xSpacing*floor((oo(oi).stimulusRect(3)-xyT(1)-0.5*xPix)/xSpacing);
         yMin=xyT(2)-ySpacing*floor((xyT(2)-oo(oi).stimulusRect(2)-0.5*yPix)/ySpacing);
         yMax=xyT(2)+ySpacing*floor((oo(oi).stimulusRect(4)-xyT(2)-0.5*yPix)/ySpacing);
         % Show only as many letters as we need so that, despite a fixation
         % error (in any direction) as large as roughly +/-
         % maxFixationErrorXYDeg, at least one of the many target letters
         % will land at an eccentricity at which critical spacing (in
         % normal adult) is less than half the actual spacing.
         % criticalSpacing=0.3*(ecc+0.15);
         % ecc=criticalSpacing/0.3-0.15;
         criticalSpacingDeg=0.5*min(xSpacing,ySpacing)/pixPerDeg;
         % Zero, or greatest ecc whose normal adult critical spacing is
         % half the test spacing.
         eccDeg=max(0,criticalSpacingDeg/0.3-0.15);
         % Compute needed extent of the repetition to put some target
         % within that ecc radius.
         xR=max(0,oo(oi).maxFixationErrorXYDeg(1)-eccDeg)*pixPerDeg;
         yR=max(0,oo(oi).maxFixationErrorXYDeg(2)-eccDeg)*pixPerDeg;
         % Round the radius to an integer number of spacings.
         xR=xSpacing*round(xR/xSpacing);
         yR=ySpacing*round(yR/ySpacing);
         if oo(oi).practiceCountdown
            xR=xSpacing*min(xR/xSpacing,oo(oi).maxRepetition);
            yR=ySpacing*min(yR/ySpacing,floor(oo(oi).maxRepetition/4));
         else
            % If nonzero, add a spacing for margin character.
            % But no margin during practice.
            if xR>0
               xR=xR+xSpacing;
            end
            if yR>0
               yR=yR+ySpacing;
            end
         end
         % Enforce minSpacesX and minSpacesY
         xR=max(xSpacing*minSpacesX/2,xR);
         yR=max(ySpacing*minSpacesY/2,yR);
         xR=round(xR);
         yR=round(yR);
         xMin=xyT(1)-min(xR,xyT(1)-xMin);
         xMax=xyT(1)+min(xR,xMax-xyT(1));
         yMin=xyT(2)-min(yR,xyT(2)-yMin);
         yMax=xyT(2)+min(yR,yMax-xyT(2));
         if oo(oi).practiceCountdown>=3
            % Quick hack to reduce 3 letters to two.
            xMin=xyT(1)-min(xR/2,xyT(1)-xMin);
            xMax=xyT(1)+min(xR/2,xMax-xyT(1));
            yMin=xyT(2)-min(yR/2,xyT(2)-yMin);
            yMax=xyT(2)+min(yR/2,yMax-xyT(2));
         end
         if oo(oi).speakSizeAndSpacing; Speak(sprintf('%.0f rows and %.0f columns',1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing));end
         if oo(oi).printSizeAndSpacing; fprintf('%d: %d: %.1f rows and %.1f columns, target xyT [%.0f %.0f]\n',oi,MFileLineNr,1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing,xyT); end;
         if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end;
         if oo(oi).printSizeAndSpacing; fprintf('%d: %d: left & right margins %.0f, %.0f, top and bottom margins %.0f,  %.0f\n',oi,MFileLineNr,xMin,RectWidth(oo(oi).stimulusRect)-xMax,yMin,RectHeight(oo(oi).stimulusRect)-yMax); end;
         clear textures dstRects
         n=length(xMin:xSpacing:xMax);
         textures=zeros(1,n);
         dstRects=zeros(4,n);
         for lineIndex=1:3
            whichTarget=mod(lineIndex,2);
            for x=xMin:xSpacing:xMax
               switch oo(oi).thresholdParameter
                  case 'spacing',
                     whichTarget=mod(whichTarget+1,2);
                  case 'size',
                     whichTarget=x>mean([xMin xMax]);
               end
               if ~oo(oi).practiceCountdown && (ismember(x,[xMin xMax]) || lineIndex==1)
                  letter=oo(oi).borderLetter;
               else
                  letter=stimulus(1+whichTarget);
               end
               whichLetter=strfind(letters,letter);
               assert(length(whichLetter)==1)
               textures(textureIndex)=letterStruct(whichLetter).texture;
               if oo(oi).showLineOfLetters
                  fprintf('%d: %d: textureIndex %d,x %d, whichTarget %d, letter %c, whichLetter %d, texture %d\n',...
                     oi,MFileLineNr,textureIndex,x,whichTarget,letter,whichLetter,textures(textureIndex));
               end
               xPos=round(x-xPix/2);
               
               % Compute o.targetHeightOverWidth, and, if requested,
               % o.setTargetHeightOverWidth
               r=round(letterStruct(whichLetter).rect);
               oo(oi).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
               if oo(oi).setTargetHeightOverWidth
                  r=round(ScaleRect(letterStruct(whichLetter).rect,oo(oi).targetHeightOverWidth/oo(oi).setTargetHeightOverWidth,1));
                  oo(oi).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
                  dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
               else
                  if oo(oi).targetSizeIsHeight
                     heightPix=oo(oi).targetPix;
                  else
                     heightPix=oo(oi).targetHeightOverWidth*oo(oi).targetPix;
                  end
                  dstRects(1:4,textureIndex)=OffsetRect(round((heightPix/RectHeight(letterStruct(whichLetter).rect))*letterStruct(whichLetter).rect),xPos,0);
               end
               % One dst rect for each letter in the line.
               if oo(oi).showLineOfLetters
                  r=Screen('Rect',textures(textureIndex));
                  Screen('DrawTexture',window,textures(textureIndex),r,dstRects(1:4,textureIndex));
                  Screen('FrameRect',window,0,dstRects(1:4,textureIndex));
                  fprintf('%d: %d: showLineOfLetters width %d, height %d, x %.0f, xPos %.0f, dstRects(1:4,%d) %.0f %.0f %.0f %.0f\n',oi,MFileLineNr,RectWidth(dstRects(1:4,textureIndex)'),RectHeight(dstRects(1:4,textureIndex)'),x,xPos,textureIndex,dstRects(1:4,textureIndex));
               end
               textureIndex=textureIndex+1;
            end
            if oo(oi).showLineOfLetters
               Screen('Flip',window);
               Speak(sprintf('Line %d. Click.',lineIndex));
               GetClicks;
            end
            % Create a texture holding one line of letters.
            [lineTexture(lineIndex),lineRect{lineIndex}]=Screen('OpenOffscreenWindow',window,[],[0 0 oo(oi).stimulusRect(3) heightPix],8,0);
            Screen('FillRect',lineTexture(lineIndex),white);
            r=Screen('Rect',textures(1));
            Screen('DrawTextures',lineTexture(lineIndex),textures,r,dstRects);
         end
         clear textures dstRects
         lineIndex=1;
         for y=yMin:ySpacing:yMax
            if minSpacesY>2 && ismember(y,[yMin yMax])
               whichLetter=1; % Horizontal row of border letters.
            else
               whichLetter=2+mod(lineIndex,2); % Horizontal row of targets.
            end
            textures(lineIndex)=lineTexture(whichLetter);
            dstRects(1:4,lineIndex)=OffsetRect(lineRect{1},0,round(y-RectHeight(lineRect{1})/2));
%             fprintf('%d: %d: line %d, whichLetter %d, texture %d, dstRect %.0f %.0f %.0f %.0f\n',...
%                oi,MFileLineNr,lineIndex,whichLetter,lineTexture(whichLetter),dstRects(1:4,lineIndex));
            lineIndex=lineIndex+1;
         end
      end
      Screen('DrawTextures',window,textures,[],dstRects);
      if oo(oi).frameTheTarget
         fprintf('%d: %d: line heights',oi,MFileLineNr);
         for ii=1:size(dstRects,2)
            y=RectHeight(dstRects(:,ii)');
            fprintf(' %.0f',y);
         end
         fprintf('\n');
         fprintf('%d: %d: line dstRects centered at',oi,MFileLineNr);
         for ii=1:size(dstRects,2)
            [x,y]=RectCenter(dstRects(:,ii));
            fprintf(' (%.0f,%.0f)',x,y);
            Screen('FrameRect',window,[255 0 0],dstRects(:,ii),4);
         end
         fprintf('. Target center (%d,%d)\n',xyT);
         letterRect=OffsetRect([-0.5*xPix -0.5*yPix 0.5*xPix 0.5*yPix],xyT(1),xyT(2));
         Screen('FrameRect',window,[255 0 0],letterRect);
         fprintf('%d: %d: screenHeightPix %d, letterRect height %.0f, targetPix %.0f, textSize %.0f, xPix %.0f, yPix %.0f\n',...
            oi,MFileLineNr,RectHeight(oo(oi).stimulusRect),RectHeight(letterRect),oo(oi).targetPix,Screen('TextSize',window),xPix,yPix);
      end
      Screen('TextFont',window,oo(oi).textFont,0);
      if oo(oi).showProgressBar
         Screen('FillRect',window,[0 220 0],progressBarRect); % green bar
         r=progressBarRect;
         r(4)=round(r(4)*(1-presentation/length(condList)));
         Screen('FillRect',window,[220 220 220],r); % grey background
      end
      if oo(oi).usePurring
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
      if oo(oi).repeatedTargets
         targets=stimulus(1:2);
      else
         targets=stimulus(2);
      end
      if isfinite(oo(oi).durationSec)
         WaitSecs(oo(oi).durationSec); % Display letters.
         Screen('FillRect',window,white,oo(oi).stimulusRect); % Clear letters.
         if ~oo(oi).repeatedTargets && oo(oi).useFixation
            fl=ClipLines(fixationLines,fixationClipRect);
             Screen('DrawLines',window,fl,min(7,3*fixationLineWeightPix),white);
             Screen('DrawLines',window,fl,fixationLineWeightPix,black); 
         end
         Screen('Flip',window,[],1); % Remove stimulus. Display fixation.
         Screen('FillRect',window,white,oo(oi).stimulusRect);
         WaitSecs(0.2); % pause before response screen
         Screen('TextFont',window,oo(oi).textFont,0);
         Screen('TextSize',window,oo(oi).textSize);
         if oo(oi).useFixation
            string='Look at the cross as you type your response. Or ESCAPE to quit.   ';
         else
            string='Type your response, or ESCAPE to quit.   ';
         end
         if oo(oi).repeatedTargets
            string=strrep(string,'response','two responses');
         end
         % Clear space for text.
         texture=Screen('OpenOffscreenWindow',window);
         Screen('TextFont',texture,oo(oi).textFont,0);
         Screen('TextSize',texture,oo(oi).textSize);
         bounds=TextBounds(texture,string,1);
         Screen('Close',texture);
         x=instructionalMarginPix;
         y=-bounds(2)+0.3*oo(oi).textSize;
         %          fixationClipRect=oo(oi).stimulusRect;
         %          fixationClipRect(2)=y+bounds(4)+0.3*oo(oi).textSize;
         % Draw text.
         Screen('DrawText',window,string,x,y,black,white,1);
         Screen('TextSize',window,oo(oi).textSize);
         [letterStruct,alphabetBounds]=CreateLetterTextures(oi,oo(oi),window);
         alphabetBounds=round(alphabetBounds*oo(oi).textSize/RectHeight(alphabetBounds));
         x=instructionalMarginPix;
         y=oo(oi).stimulusRect(4)-0.3*RectHeight(alphabetBounds);
         %          fixationClipRect(4)=y-1.3*RectHeight(alphabetBounds);
         for i=1:length(oo(oi).alphabet)
            dstRect=OffsetRect(alphabetBounds,x,y-RectHeight(alphabetBounds));
            for j=1:length(letterStruct)
               if oo(oi).alphabet(i)==letterStruct(j).letter
                  Screen('DrawTexture',window,letterStruct(i).texture,[],dstRect);
               end
            end
            x=x+1.5*RectWidth(dstRect);
         end
         Screen('TextFont',window,oo(oi).textFont,0);
         if ~oo(oi).repeatedTargets && oo(oi).useFixation
            fl=ClipLines(fixationLines,fixationClipRect);
             Screen('DrawLines',window,fl,min(7,3*fixationLineWeightPix),white);
             Screen('DrawLines',window,fl,fixationLineWeightPix,black); 
         end
         Screen('Flip',window,[],1); % Display fixation & response instructions.
         Screen('FillRect',window,white,oo(oi).stimulusRect);
      end
      
      if oo(oi).takeSnapshot
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
         ffprintf(ff,'Saving image to file "%s".\n',filename);
      end
      
      responseString='';
      skipping=0;
      flipSecs=GetSecs;
      for i=1:length(targets)
         [answer,secs]=GetKeypressWithHelp( ...
            [spaceKeyCode escapeKeyCode graveAccentKeyCode oo(oi).responseKeyCodes], ...
            oo(oi),window,oo(oi).stimulusRect,letterStruct,responseString);
         trialData.reactionTimes(i)=secs-flipSecs;
         
         if ismember(answer,[escapeChar graveAccentChar]);
            oo(1).quitRun=1;
            break;
         end
         if streq(upper(answer),' ')
            responsesNumber=length(responseString);
            if GetSecs-trialTimeSecs>oo(oi).secsBeforeSkipCausesGuess
               if oo(oi).speakEachLetter && oo(oi).useSpeech
                  Speak('space');
               end
               guesses=0;
               while length(responseString)<length(targets)
                  reportedTarget=randsample(oo(oi).alphabet,1); % Guess.
                  responseString=[responseString reportedTarget];
                  guesses=guesses+1;
               end
               guessCount=guessCount+guesses;
               oo(oi).guessCount=oo(oi).guessCount+guesses;
            else
               if oo(oi).speakEachLetter && oo(oi).useSpeech
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
         % GetKeypressWithHelp now returns only one character. OBSOLETE:
         % GetKeypress returns, in answer, both key labels when there are
         % two, e.g. "3#". We score the response as whichever target letter
         % is included in the "answer" string.
         reportedTarget = oo(oi).alphabet(ismember(upper(oo(oi).alphabet),upper(answer)));
         if oo(oi).speakEachLetter && oo(oi).useSpeech
            % Speak the target that the observer saw, e.g '1', not the keyCode '1!'
            Speak(reportedTarget);
         end
         if ismember(upper(reportedTarget),upper(targets))
            if oo(oi).beepPositiveFeedback
               Snd('Play',rightBeep);
            end
         else
            if oo(oi).beepNegativeFeedback
               Snd('Play',wrongBeep);
            end
         end
         responseString=[responseString reportedTarget];
      end
      DestroyLetterTextures(letterStruct);
      if ~skipping
         easeRequest=0;
      end
      if oo(oi).speakEncouragement && oo(oi).useSpeech && ~oo(1).quitRun && ~skipping
         switch randi(3);
            case 1
               Speak('Good!');
            case 2
               Speak('Nice');
            case 3
               Speak('Very good');
         end
      end
      if oo(1).quitRun
         break;
      end
      responseScores=ismember(responseString,targets);
      oo(oi).spacingDeg=spacingPix/pixPerDeg;
      
      trialData.targetDeg=oo(oi).targetDeg;
      trialData.spacingDeg=oo(oi).spacingDeg;
      trialData.targets=targets;
      trialData.targetScores=ismember(targets,responseString);
      trialData.responses=responseString;
      trialData.responseScores=responseScores;
      % trialData.reactionTimes is computed above.
      if ~oo(oi).practiceCountdown
         if isempty(oo(oi).trialData)
            oo(oi).trialData=trialData;
         else
            oo(oi).trialData(end+1)=trialData;
         end
      end
      for responseScore=responseScores
         switch oo(oi).thresholdParameter
            case 'spacing',
               intensity=log10(oo(oi).spacingDeg);
            case 'size'
               intensity=log10(oo(oi).targetDeg);
         end
         if ~oo(oi).practiceCountdown
            oo(oi).responseCount=oo(oi).responseCount+1;
            oo(oi).q=QuestUpdate(oo(oi).q,intensity,responseScore);
         end
      end
%       if oo(oi).practiceCountdown
%          fprintf('%d: %d: practiceCountdown %d, maxRepetitions %d\n',...
%             oi,MFileLineNr,oo(oi).practiceCountdown,oo(oi).maxRepetition);
%       end
      if oo(oi).practiceCountdown && all(responseScores)
         oo(oi).practiceCountdown=oo(oi).practiceCountdown-1;
         if oo(oi).practiceCountdown
            oo(oi).maxRepetition=2*oo(oi).maxRepetition;
         else
            oo(oi).maxRepetition=inf;
         end
      end
      if oo(1).quitRun
         break;
      end
   end % for presentation=1:length(condList)
   % Quitting just this run or whole session?
   if oo(1).quitRun
      oo(1).quitSession=OfferToQuitSession(window,oo,instructionalMarginPix,screenRect);
      if oo(1).quitSession
         ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
      else
         ffprintf(ff,'*** User typed ESCAPE. Run terminated.\n');
      end
   end
   Screen('FillRect',window);
   Screen('Flip',window);
   if oo(1).useSpeech
      if ~oo(1).quitRun
         Speak('Congratulations.  This run is done.');
      end
   end
   trials=0;
   oo(1).totalSecs=GetSecs-oo(1).beginSecs;
   for oi=1:conditions
      trials=trials+oo(oi).responseCount;
   end
   ffprintf(ff,'Took %.0f s for %.0f trials, or %.0f s/trial.\n',oo(1).totalSecs,trials,oo(1).totalSecs/trials);
   ffprintf(ff,'%d skips, %d easy presentations, %d artificial guesses. \n',skipCount,easyCount,guessCount);
   for oi=1:conditions
      ffprintf(ff,'CONDITION %d **********\n',oi);
      % Ask Quest for the final estimate of threshold.
      t=QuestMean(oo(oi).q);
      sd=QuestSd(oo(oi).q);
      switch oo(oi).thresholdParameter
         case 'spacing',
            ori=oo(oi).radialOrTangential;
            eccentricityDeg=sqrt(sum(oo(oi).eccentricityXYDeg.^2));
            if ~oo(oi).repeatedTargets && eccentricityDeg>0
               switch(oo(oi).radialOrTangential)
                  case 'radial'
                     ffprintf(ff,'Radial spacing of far flanker from target.\n');
                  case 'tangential'
                     ffprintf(ff,'Tangential spacing of flankers.\n');
               end
            end
            ffprintf(ff,'Threshold log %s spacing deg (mean +-sd) is %.2f +-%.2f, which is %.3f deg.\n',ori,t,sd,10^t);
            if 10^t<oo(oi).minimumSpacingDeg
               ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed spacing %.3f deg. Please increase viewing distance.\n',10^t,oo(oi).minimumSpacingDeg);
            end
            if oo(oi).responseCount>1
               trials=QuestTrials(oo(oi).q);
               if any(~isreal(trials.intensity))
                  error('trials.intensity returned by Quest should be real, but is complex.');
               end
               ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
               ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(oi).q,trials.intensity-oo(oi).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
         case 'size',
            if oo(oi).targetSizeIsHeight
               ori='vertical';
            else
               ori='horizontal';
            end
            ffprintf(ff,'Threshold log %s size deg (mean +-sd) is %.2f +-%.2f, which is %.3f deg.\n',ori,t,sd,10^t);
            if 10^t<oo(oi).minimumSizeDeg
               ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed size %.3f deg. Please increase viewing distance.\n',10^t,oo(oi).minimumSizeDeg);
            end
            if oo(oi).responseCount>1
               trials=QuestTrials(oo(oi).q);
               ffprintf(ff,'Size(deg)	P fit	P       Trials\n');
               ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(oi).q,trials.intensity-oo(oi).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
      end
      for oi=1:conditions
         if oo(oi).measureBeta
            % reanalyze the data with beta as a free parameter.
            ffprintf(ff,'%d: o.measureBeta **************************************\n',oi);
            ffprintf(ff,'offsetToMeasureBeta %.1f to %.1f\n',min(offsetToMeasureBeta),max(offsetToMeasureBeta));
            bestBeta=QuestBetaAnalysis(oo(oi).q);
            qq=oo(oi).q;
            qq.beta=bestBeta;
            qq=QuestRecompute(qq);
            ffprintf(ff,'thresh %.2f deg, log thresh %.2f, beta %.1f\n',10^QuestMean(qq),QuestMean(qq),qq.beta);
            ffprintf(ff,' deg     t     P fit\n');
            tt=QuestMean(qq);
            for offset=sort(offsetToMeasureBeta)
               t=tt+offset;
               ffprintf(ff,'%5.2f   %5.2f  %4.2f\n',10^t,t,QuestP(qq,t));
            end
            if oo(oi).responseCount>1
               trials=QuestTrials(qq);
               switch oo(oi).thresholdParameter
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
   for oi=1:conditions
      if exist('results','var') && oo(oi).responseCount>1
         ffprintf(ff,'%d:',oi);
         trials=QuestTrials(oo(oi).q);
         p=sum(trials.responses(2,:))/sum(sum(trials.responses));
         switch oo(oi).thresholdParameter
            case 'spacing',
               ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. [%.1f  %.1f] deg, critical spacing %.2f deg.\n',...
                  oo(oi).observer,100*p,oo(oi).targetDeg,oo(oi).eccentricityXYDeg,10^QuestMean(oo(oi).q));
            case 'size',
               ffprintf(ff,'%s: p %.0f%%, ecc. [%.2f  %.2f] deg, threshold size %.3f deg.\n',...
                  oo(oi).observer,100*p,oo(oi).eccentricityXYDeg,10^QuestMean(oo(oi).q));
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
   % One or more of these functions spoils psychlasterror, so i don't use them.
   %     Snd('Close');
   %     ShowCursor;
   if exist('dataFid','file') && dataFid~=-1
      fclose(dataFid);
      dataFid=-1;
   end
   sca; % Screen Close All. This cleans up without canceling the error message.
   psychrethrow(psychlasterror);
end
end

function xyPix=XYPixOfXYDeg(o,xyDeg)
% Convert position from deg (relative to fixation) to integet (x,y) screen
% coordinate. Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. We typically put the target there, but that is not assumed in this
% routine.
xyDeg=xyDeg-o.nearPointXYDeg;
rDeg=sqrt(sum(xyDeg.^2));
rPix=o.pixPerCm*o.viewingDistanceCm*tand(rDeg);
if rDeg>0
   xyPix=xyDeg*rPix/rDeg;
   xyPix(2)=-xyPix(2); % Apple y goes down.
else
   xyPix=[0 0];
end
xyPix=xyPix+o.nearPointXYPix;
xyPix=round(xyPix);
end

function isTrue=IsXYInRect(xy,rect)
if nargin~=2
   error('Need two args for function isTrue=IsXYInRect(xy,rect)');
end
if size(xy)~=[1 2]
   error('First arg to IsXYInRect(xy,rect) must be [x y] pair.');
end
isTrue=IsInRect(xy(1),xy(2),rect);
end

function xy=LimitXYToRect(xy,rect)
% Restrict x and y to lie inside rect.
assert(all(rect(1:2)<=rect(3:4)));
xy=max(xy,rect(1:2));
xy=min(xy,rect(3:4));
end

%% SET UP FIXATION
function oo=SetUpFixation(window,oo,oi,ff)
white=WhiteIndex(window);
black=BlackIndex(window);
escapeKeyCode=KbName('ESCAPE');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('Return');
graveAccentKeyCode=KbName('`~');
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
oo(oi).fixationXYPix=XYPixOfXYDeg(oo(oi),[0 0]);
if ~oo(oi).useFixation
   oo(oi).fixationIsOffscreen = 0;
else
   oo(oi).fixationIsOffscreen = ~IsXYInRect(oo(oi).fixationXYPix,oo(oi).stimulusRect);
   if oo(oi).fixationIsOffscreen
      fprintf('%d: Fixation is off screen. fixationXYPix %.0f %.0f, o.stimulusRect [%d %d %d %d]\n',...
         oi,oo(oi).fixationXYPix,oo(oi).stimulusRect);
      % oo(oi).fixationXYPix is in plane of display. Off-screen fixation is
      % not! Instead it is the same distance from the eye as the near point.
      % fixationOffsetXYCm is vector from near point to fixation.
      rDeg=sqrt(sum(oo(oi).nearPointXYDeg.^2));
      ori=atan2d(-oo(oi).nearPointXYDeg(2),-oo(oi).nearPointXYDeg(1));
      rCm=2*sind(0.5*rDeg)*oo(oi).viewingDistanceCm;
      fixationOffsetXYCm=[cosd(ori) sind(ori)]*rCm;
      if 0
         % Check the geometry.
         oriCheck=atan2d(fixationOffsetXYCm(2),fixationOffsetXYCm(1));
         rCmCheck=sqrt(sum(fixationOffsetXYCm.^2));
         rDegCheck=2*asind(0.5*rCm/oo(oi).viewingDistanceCm);
         xyDegCheck=-[cosd(ori) sind(ori)]*rDeg;
         fprintf('CHECK NEAR-POINT GEOMETRY: ori %.1f %.1f; rCm %.1f %.1f; rDeg %.1f %.1f; xyDeg [%.1f %.1f] [%.1f %.1f]\n',...
            ori,oriCheck,rCm,rCmCheck,rDeg,rDegCheck,oo(oi).nearPointXYDeg,xyDegCheck);
      end
      fixationOffsetXYCm(2)=-fixationOffsetXYCm(2); % Make y increase upward.
      string='';
      if fixationOffsetXYCm(1)~=0
         if fixationOffsetXYCm(1) < 0
            string = sprintf('%sPlease create an off-screen fixation mark %.1f cm to the left of the cross. ',string,-fixationOffsetXYCm(1));
            ffprintf(ff,'%d: Requesting fixation mark %.1f cm to the left of the cross.\n',oi,-fixationOffsetXYCm(1));
         else
            string = sprintf('%sPlease create an off-screen fixation mark %.1f cm to the right of the cross. ',string,fixationOffsetXYCm(1));
            ffprintf(ff,'%d: Requesting fixation mark %.1f cm to the right of the cross.\n',oi,fixationOffsetXYCm(1));
         end
      end
      if fixationOffsetXYCm(2)~=0
         if fixationOffsetXYCm(2) < 0
            string = sprintf('%sPlease create an off-screen fixation mark %.1f cm higher than the cross below. ',string,-fixationOffsetXYCm(2));
            ffprintf(ff,'%d: Requesting fixation mark %.1f cm above the cross.\n',oi,-fixationOffsetXYCm(2));
         else
            string = sprintf('%sPlease create an off-screen fixation mark %.1f cm lower than the cross. ',string,fixationOffsetXYCm(2));
            ffprintf(ff,'%d: Requesting fixation mark %.1f cm below the cross.\n',oi,fixationOffsetXYCm(2));
         end
      end
      string = sprintf('%sAdjust the viewing distances so both your fixation mark and the cross below are %.1f cm from the observer''s eye. ',...
         string,oo(oi).viewingDistanceCm);
      string = [string 'Tilt and swivel the display so that the cross is orthogonal to the observer''s line of sight. '...
         'Once the fixation is properly arranged, hit RETURN to proceed. Otherwise hit ESCAPE to quit. '];
      Screen('TextSize',window,oo(oi).textSize);
      Screen('TextFont',window,'Verdana');
      Screen('FillRect',window,white);
      DrawFormattedText(window,string,oo(oi).textSize,1.5*oo(oi).textSize,black,oo(oi).textLineLength,[],[],1.3);
      x=oo(oi).nearPointXYPix(1);
      y=oo(oi).nearPointXYPix(2);
      a=0.1*RectHeight(oo(oi).stimulusRect);
      Screen('DrawLine',window,black,x-a,y,x+a,y,a/20);
      Screen('DrawLine',window,black,x,y-a,x,y+a,a/20);
      Screen('Flip',window); % Display question.
      if 0 && oo(oi).speakInstructions
         string=strrep(string,'below ','');
         string=strrep(string,'.0','');
         Speak(string);
      end
      response=GetKeypress([escapeKeyCode,returnKeyCode,graveAccentKeyCode]);
      answer=[];
      if ismember(response,[escapeChar graveAccentChar])
         answer=0;
      end
      if ismember(response,[returnChar])
         answer=1;
      end
      Screen('FillRect',window,white);
      Screen('Flip',window); % Blank the screen, to acknowledge response.
      if answer
         oo(oi).fixationIsOffscreen = 1;
         ffprintf(ff,'%d: Offscreen fixation mark (%.1f,%.1f) cm from near point of display.\n',oi,fixationOffsetXYCm);
      else
         oo(oi).fixationIsOffscreen = 0;
         ffprintf(ff,['\n\n' WrapString(string) '\n'...
            'ERROR: User declined to set up off-screen fixation.\n'...
            'Consider reducing viewing distance (%.1f cm) or o.eccentricityXYDeg (%.1f %.1f).\n'],...
            oo(oi).viewingDistanceCm,oo(oi).eccentricityXYDeg);
         error('User declined to set up off-screen fixation.');
      end
   else
      oo(oi).fixationIsOffscreen = 0;
   end
end
oo(oi).targetXYPix=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg);
if oo(oi).fixationCrossBlankedNearTarget
   ffprintf(ff,'%d: Fixation cross is blanked near target. No delay in showing fixation after target.\n',oi);
else
   ffprintf(ff,'%d: Fixation cross is blanked during and until %.2f s after target. No selective blanking near target. \n',oi,oo(oi).fixationCrossBlankedUntilSecAfterTarget);
end
end

function xyDeg=XYDegOfXYPix(o,xyPix)
% Convert position from (x,y) coordinate in o.stimulusRect to deg (relative
% to fixation). Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. THe near-point location is specified by o.nearPointXYPix and 
% o.nearPointXYDeg. We typically put the target at the near point, but that
% is not assumed in this routine.
xyPix=xyPix-o.nearPointXYPix;
rPix=sqrt(sum(xyPix.^2));
rDeg=atan2d(rPix/o.pixPerCm,o.viewingDistanceCm);
if rPix>0
   xyPix(2)=-xyPix(2); % Apple y goes down.
   xyDeg=xyPix*rDeg/rPix;
else
   xyDeg=[0 0];
end
xyDeg=xyDeg+o.nearPointXYDeg;
end
