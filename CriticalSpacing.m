function oo=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% BUGS: none
% CriticalSpacing measures an observer's crowding distance (formerly
% critical spacing) and acuity (i.e. threshold spacing and size) to help
% characterize the observer's vision. This program takes over your screen
% to measure the observer's size or spacing threshold for letter
% identification. It takes about 5 minutes to measure two thresholds. It's
% meant to be called by a short user-written script, and should work well
% in clinical environments. All results are returned in the "o" struct and
% also saved to disk in two files whose file names include your script
% name, the experimenter and observer names, and the date. One of those
% files is plain text .txt and easy for you to read; the other is a MATLAB
% save file .MAT and easily read by MATLAB programs. It's best to keep
% both. The filenames are unique and easy to sort, so it's fine to let all
% your data files accumulate in your CriticalSpacing/data/ folder.
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
% ESCAPE & RESUME. Every command that accepts keyboard input accepts an
% ESCAPE key. This brings up a dialog offering three choices: to quit the
% whole experiment, to quit the block and begin the next block, to resume
% back where you escaped from. If resuming, the remaining trials are
% shuffled. May 1, 2019.
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
% o.getAlphabetFromDisk=true. We have done most of our work with the
% "Sloan" and "Pelli" fonts. Only Pelli is skinny enough to measure foveal
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
% sometimes very wrong in Windows, and is often not available for external
% monitors under any OS. So we allow users to measure the display screen
% size themselves and provide it in their "o" struct as
% o.measuredScreenWidthCm and o.measuredScreenWidthCm. Your measured values
% will override whatever values your display provides. Use a meter stick to
% measure the width and height of your screen's filled rectangle of glowing
% pixels.
%
% macOS: PERMIT MATLAB TO CONTROL YOUR COMPUTER. Open the System
% Preferences: Security and Privacy: Privacy tab. Select Accessibility.
% Click to open the lock in lower left, providing your computer password.
% Click to select MATLAB, allowing it to control your computer. Click the
% lock again to close it.
%
% CONTROL SCREEN. When you run CriticalSpacing, the first screen you see is
% the "control" screen. It tells you several useful things about your
% display and stimuli. Most prominently, it asks you to adjust the actual
% viewing distance to match the nominal value. I also alows you to change
% the nominal value. Further, it tells you the min and view viewing
% distance to be able to measure acuity at the specified acuity and to put
% both your target and fixation point on the display. Further options
% include mirroring, optimizing resolution,and  helping you to attach a
% wireless keyboard.
%
% A WIRELESS OR LONG-CABLE KEYBOARD is highly desirable because a normally
% sighted observer viewing foveally has excellent vision and must be many
% meters away from the screen in order for us to measure her acuity limit.
% At this distance their hands can't reach the built-in keyboard attached
% to the screen. If you must use the built-in keyboard, then have the
% experimenter type the observer's verbal answers. Instead, I like the
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
% viewing distance. You can request this, in advance, by setting
% o.flipScreenHorizontally=true in your run script. (At run time, when
% CriticalSpacing asks you about viewing distance, you can indicate that
% you're using a mirror by entering the viewing distance as a negative
% number. It will flip the display to be seen in a mirror.) I bought two
% acrylic front surface mirrors for this. 12x24 inches, $46 each from
% inventables. Front surface mirrors preserve image quality, and acrylic is
% hard to break, making it safer than glass. I'm not yet sure how big a
% mirror one needs to accomodate observers of various heights, so I listed
% several of Amazon's offerings, ranging up to 24" by 48". The five-pack is
% a good deal, five 12"x24" mirrors for $67.
%
% http://www.amazon.com/Acrylic-Wall-Mirror-Size-24/dp/B001CWAOJW/ref=sr_1_19
% http://www.amazon.com/Childrens-Factory-Look-At-Mirror/dp/B003BL7TMC/ref=sr_1_14
% https://www.inventables.com/technologies/first-surface-mirror-coated-acrylic
% http://www.amazon.com/12-24-Mirror-Acrylic-Plexiglass/dp/B00IVWQPUI/ref=sr_1_39
% http://www.amazon.com/12-Acrylic-Mirror-Sheet-Pack/dp/B00JPJK3T0/ref=sr_1_13
% http://www.amazon.com/Double-Infant-Mirror-surface-Approved/dp/B0041TABOG/ref=pd_sim_sbs_468_9
%
% READ ALPHABET FROM DISK. If you set o.getAlphabetFromDisk=true in your
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
% setting o.getAlphabetFromDisk=false. The Pelli and Sloan fonts are
% provided in the CriticalSpacing/fonts/ folder, and you can install them
% in your computer OS. On a Mac, you can just double-click the font file
% and say "yes" when your computer offers to install it for you. Once
% you've installed a font, you must quit and restart MATLAB to use the
% newly available font.
%
% OPTIONAL: ADD A NEW FONT. Running the program SaveAlphabetToDisk in
% the CriticalSpacing/lib/ folder, after you edit it to specify the font,
% alphabet, and borderCharacter you want, will add a snapshot of your
% font's alphabet to the pdf folder and add a new folder, named for your
% font, to the CriticalSpacing/alphabets/ folder.
%
% OPTIONAL: USE YOUR COMPUTER'S FONTS, LIVE. Set
% o.getAlphabetFromDisk=false. You may wish to install Pelli or Sloan from
% the CriticalSpacing/fonts/ folder into your computer's OS. Restart MATLAB
% after installing a new font. To render fonts well, Psychtoolbox needs to
% load the FTGL DrawText dropin. It typically takes some fiddling with
% dynamic libraries to make sure the right library is available and that
% access to it is not blocked by the presence of an obsolete version. For
% explanation see "help drawtextplugin". You need this only if you want to
% set o.getAlphabetFromDisk=false.
%
% CHILDREN. Adults and children seem to find CriticalSpacing easy and
% intuitive. Sarah Waugh (Dept. of Vision and Hearing Sciences, Anglia
% Ruskin University) has tested 200 children of ages 3 to 16(?). To test
% children, Sarah used a fictional astronaut adventure story about this
% test. The game, designed by Aenne Brielmann, in my lab here at NYU,
% includes an illustrated story book and alien dolls.
%
% CHOOSE A VIEWING DISTANCE. You can provide a default in your script, e.g.
% o.viewingDistanceCm=400. CriticalSpacing invites you to modify the
% viewing distance (or declare that you're using a mirror) at the beginning
% of each block. You need a long distance to display tiny letters, and, if
% fixation is on-screen, you need short viewing distance to display
% peripheral letters. (We plan to add support for off-screen fixation.)
% When viewing foveally, please err on the side of making the viewing
% distance longer than necessary. Observers don't like being closer than 40
% cm. Also, if you use too short a viewing distance then the minimum size
% and spacing may be bigger than the threshold you want to measure. At the
% end of the block, CriticalSpacing.m warns you if the estimated threshold
% is smaller than the minimum possible size or spacing at the current
% distance, and suggests that you increase the viewing distance in
% subsequent blocks. The minimum viewing distance depends on the smallest
% letter size you want to show with 8 pixels and the resolution (pixels per
% centimeter) of your display. This is Eq. 4 in the Pelli et al. (2016)
% paper cited at the beginning,
%
% minViewingDistanceCm=57*(minimumTargetPix/letterDeg)/(screenWidthPix/screenWidthCm);
%
% where minimumTargetPix=8 and letterDeg=0.02 for the healthy adult fovea.
%
% PERSPECTIVE DISTORTION IS MINIMIZED BY PLACING THE TARGET AT THE NEAR
% POINT (new in June 2017). At the beginning of each block, the
% CriticalSpacing program gives directions to arrange the display so that
% its "near point" (i.e. point closest to the observer's eye) is orthogonal
% to the observer's line of sight. This guarantees minimal effects of
% perspective distortaion on any target placed there.
%
% CHOOSE VIEWING DISTANCE TO ALLOW ON-SCREEN FIXATION. The big control page
% (the "splash screen") now (June 2017) gives advice about whether the
% fixation will fit on-screen, and tells you the maximum viewing distance
% that would allow that.
%
% ECCENTRICITY OF THE TARGET. Eccentricity of the target is achieved by
% appropriate placement of the target and the fixation mark. Modest
% eccentricities, up to perhaps 30 deg, are achieved with on-screen
% fixation. If the eccentricity is too large for on-screen fixation, then
% we help you set up off-screen fixation.
% 1. Set nearPointXYPix according to o.nearPointXYInUnitSquare, whose
% default is 0.5 0.5.
% 2. If setNearPointEccentricityTo==
% 'target', then set nearPointXYDeg=eccentricityXYDeg.
% 'fixation', then set nearPointXYDeg=[0 0].
% 'value', then assume nearPointXYDeg is already set by user script.
% 3. Ask viewer to adjust display so desired near point is at desired
% viewing distance and orthogonal to line of sight from eye.
% 4. If using off-screen fixation, put fixation at same distance from eye
% as the near point, and compute its position relative to near point.

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
% ESCAPE KEY: QUIT. You can always terminate the current block by hitting
% the escape key on your keyboard (typically in upper left, labeled "esc").
% Because at least one computer (e.g. the 2017 MacBook Pro with track bar)
% lacks an ESCAPE key, we always accept the GRAVE ACCENT key (also in upper
% left of keyboard) as equivalent. CriticalSpacing will then print out (and
% save to disk) results so far, and ask whether you're quitting the whole
% session or proceeding to the next block. Quitting this block sets the
% flag o.quitBlock, and quitting the experiment also sets the flag
% o.quitExperiment (and o.isLastBlock=true and isLastBlock=true).
% If o.quitExperiment is already set when you call CriticalSpacing, the
% CriticalSpacing returns immediately after processing arguments.
% (CriticalSpacing ignores o.quitBlock on input.)
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
% nobody gets them all right: "Just try to get as many as you can."
%
% THRESHOLD. CriticalSpacing measures threshold spacing or size (i.e.
% acuity). This program measures threshold spacing in either of two
% directions, selected by the variable o.targetSizeIsHeight, true for
% vertically, and false for horizontally. Target size can be made
% proportional to spacing, allowing measurement of critical spacing without
% knowing the acuity, because we use the largest possible letter for each
% spacing. The ratio SpacingOverSize is computed for spacing and size along
% the axis specified by o.flankingDegVector, a unit length vector. You can
% directly specify o.flankingDegVector, or you can leave it as [] and set
% o.flankingDirection: 'radial', 'tangential', 'horizontal', or 'vertical',
% which will be used to compute o.flankingDegVector. The final report by
% CriticalSpacing includes the aspect ratio of your font:
% o.heightOverWidth.
%
% ECCENTRICITY. Set o.eccentricityXYDeg=[x y] in your script. For
% peripheral testing, it's usually best to set o.durationSec=0.2 to exclude
% eye movements during the brief target presentation. When the flankers are
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
% Copyright © 2016, 2017, 2018, 2019 Denis Pelli, denis.pelli@nyu.edu

% HISTORY:
% August 12, 2019. o.askExperimenterToSetDistance=true asks observer to get
% the experimenter to set the viewing distance each time it changes. The
% experiment types a "signature key" (first letter of the previously given
% o.experimenter name) to continue. This responds to a tendency for
% observers to just click past even bright red screens asking then to set a
% new viewing distance.

%% PLANS
%
% When the alphabet is large (eg. 26) it currently falls off the right
% edge when we display it at the end of a trial. I think we should break it
% into two lines.
%
% I'd like the viewing-distance page to respond to a new command: "o" to
% set up offscreen fixation.
%
% Add switch to use only border characters as flankers.
%
% In repetition mode, don't assume one centered target and an even number
% of spaces. We might want to center between two targets to show an odd
% number of spaces.
%

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
if verLessThan('matlab','9.1')
    % https://en.wikipedia.org/wiki/MATLAB#Release_history
    error('%s requires MATLAB 9.1 (R2016b) or later, for "split" function.',mfilename);
end
if nargin<1 || ~exist('oIn','var')
    oIn.script=[];
end

mainFolder=fileparts(mfilename('fullpath'));
addpath(fullfile(mainFolder,'lib'));
addpath(fullfile(mainFolder,'utilities'));
plusMinus=char(177);

% Once we call onCleanup, until CriticalSpacing ends,
% CloseWindowsAndCleanup will run (closing any open windows) when this
% function terminates for any reason, whether by reaching the end, the
% posting of an error here (or in any function called from here), or the
% user hitting control-C.
cleanup=onCleanup(@() CloseWindowsAndCleanup);
global skipScreenCalibration ff
global window keepWindowOpen % Keep window open until end of last block.
global scratchWindow
global screenRect % For ProcessEscape
persistent drawTextWarning
global corpusFilename corpusText corpusFrequency corpusWord corpusSentenceBegins corpusLineEndings
persistent oldViewingDistanceCm
global blockTrial blockTrials % used in DrawCounter.
keepWindowOpen=false; % Enable only in normal return.
rotate90=[cosd(90) -sind(90); sind(90) cosd(90)];
% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.

% PROCEDURE
o.easyBoost=0.3; % On easy trials, boost log threshold parameter by this.
o.experimenter=''; % Assign your name to skip the runtime question.
o.flipScreenHorizontally=false; % Set to true when using a mirror.
o.fractionEasyTrials=0;
o.observer=''; % Assign the name to skip the runtime question.
o.permissionToChangeResolution=false; % Works for main screen only, due to Psychtoolbox bug.
o.getAlphabetFromDisk=true; % true makes the program more portable.
o.secsBeforeSkipCausesGuess=8;
o.takeSnapshot=false; % To illustrate your talk or paper.
o.task='identify'; % identify, read
o.textFont='Verdana';
o.textSizeDeg=0.4;
o.thresholdParameter='spacing'; % 'spacing' or 'size'
o.trialsDesired=20; % Number of trials (i.e. responses) for the threshold estimate.
o.viewingDistanceCm=400; % Default.
o.maxViewingDistanceCm=0; % Max over remaining blocks in experiment.
% THIS SEEMS TO BE A CLUMSY ANTECEDENT TO THE NEARPOINT IDEA. DGP
o.measureViewingDistanceToTargetNotFixation=true;
o.willTakeMin=[];
o.askExperimenterToSetDistance=true;

o.experiment=''; % Name of this experiment. Used to select files for analysis.
o.block=1; % Each block may contain more than one condition.
o.blocksDesired=1;
o.condition=1; % Integer count of the condition, starting at 1.
o.conditionName='';
o.quitBlock=false;
o.quitExperiment=false;
o.trialsSkipped=0;
o.askForPartingComments=true;
o.partingComments='';

% SOUND & FEEDBACK
o.beepNegativeFeedback=false;
o.beepPositiveFeedback=true;
o.showProgressBar=true;
o.speakEachLetter=true;
o.speakEncouragement=false;
o.speakViewingDistance=false;
o.usePurring=false;
o.useSpeech=false;
o.showCounter=true;
o.soundVolume=0.25;

% VISUAL STIMULUS
o.contrast=1; % Nominal contrast, not calibrated.
o.eccentricityXYDeg = [0 0]; % eccentricity of target center re fixation, + for right & up.
o.nearPointXYInUnitSquare=[0.5 0.5]; % location on screen. [0 0]  lower right, [1 1] upper right.
o.durationSec=inf; % Duration of display of target and flankers
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
o.relationOfSpacingToSize='fixed ratio'; % 'none' 'fixed by font'
o.fourFlankers=0;
o.oneFlanker=0;
o.targetSizeIsHeight=nan; % false, true (or nan to depend on o.thresholdParameter)
o.minimumTargetPix=6; % Minimum viewing distance depends soley on this & pixPerCm.
o.flankingDirection='radial'; % 'radial' or 'tangential' or 'horizontal' or 'vertical'.
o.flankingDegVector=[]; % Specify x,y vector, or [] to specify named o.flankingDirection.
o.repeatedTargets=false;
o.maxLines=inf; % When repeatedTargets==true, max number of lines, including borders. Must be 1,3,4, ... inf.
o.maxFixationErrorXYDeg=[3 3]; % Repeat targets enough to cope with errors up to this size.
o.practicePresentations=0; % 0 for none. Adds easy trials at the beginning that are not recorded.
o.setTargetHeightOverWidth=0; % Stretch font to achieve a particular aspect ratio.
o.spacingDeg=nan;
o.spacingGuessDeg=nan;
o.targetDeg=nan;
o.targetGuessDeg=nan;
o.stimulusMarginFraction=0.0; % White margin around stimulusRect.
o.targetMargin = 0.25; % Minimum from edge of target to edge of o.stimulusRect, as fraction of targetDeg height.
o.measuredScreenWidthCm = []; % Allow users to provide their own measurement when the OS gives wrong value.
o.measuredScreenHeightCm = [];% Allow users to provide their own measurement when the OS gives wrong value.
o.isolatedTarget=false; % Set to true when measuring acuity for a single isolated letter. Not yet fully supported.
o.brightnessSetting=0.87; % Default. Roughly half luminance. Some observers find 1.0 painfully bright.

% READ TEXT
o.readLines=12;
o.readCharPerLine=50;
o.readSpacingDeg=0.3;
o.readString={}; % The string of text to be read.
o.readSecs=[]; % Time spent reading (from press to release of space bar).
o.readChars=[]; % Length of string.
o.readWords=[]; % Words in string.
o.readCharPerSec=[]; % Speed.
o.readWordPerMin=[]; % Speed.
o.readMethod='';
o.readError='';
o.readQuestions=3;
% o.readFilename='MHC928.txt';
o.readFilename='the phantom tollbooth.txt'; % Norton Juster (1961). The Phantom Tollbooth. Random House.
o.readNumberOfResponses=[];
o.readNumberCorrect=[];

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

% GEOMETRY
o.nearPointXYDeg=[0 0]; % Set this explicitly if you set setNearPointEccentricityTo='value'.
o.setNearPointEccentricityTo='target'; % 'target' or 'fixation' or 'value'

% FIXATION
o.fixationCrossBlankedNearTarget=true;
o.fixationCrossBlankedUntilSecsAfterTarget=0;
o.fixationCrossDeg=inf; % 0, 3, and inf are a typical values.
o.fixationLineWeightDeg=0.02;
o.fixationLineMinimumLengthDeg=0.2;
o.markTargetLocation=false; % true to mark target location
o.useFixation=true;
o.forceFixationOffScreen=false;
o.fixationCoreSizeDeg=1; % We protect this diameter from clipping by screen edge.
o.recordGaze=false;
o.fixationCheck=false; % True designates condition as a fixation check.
o.fixationCheckMakeupPresentations=1; % After a mistake, how many correct presentation to require.

% RESPONSE SCREEN
o.labelAnswers=false; % Useful for non-Roman fonts, like Checkers.
o.responseLabels='abcdefghijklmnopqrstuvwxyz123456789';

% SIMULATE OBSERVER
o.simulateObserver=false;
o.simulatedLogThreshold=0;

% QUEST threshold estimation
o.beta=nan;
o.measureBeta=false;
o.pThreshold=nan;
o.tGuess=nan;
o.tGuessSd=nan;
o.useQuest=true; % true or false
o.spacingGuessDeg = 1;

% DEBUGGING AIDS
o.frameTheTarget=false;
o.printScreenResolution=false;
o.printSizeAndSpacing=false;
o.showAlphabet=false;
o.showBounds=false;
o.showLineOfLetters=false;
o.speakSizeAndSpacing=false;
o.useFractionOfScreenToDebug=false;
o.willTakeMin=0;

% BLOCKS AND BRIGHTNESS
% To save time, we set brightness only before the first block, and restore
% it only after the last block. Each call to AutoBrightness seems to take
% about 30 s on an iMac under Mojave. CriticalSpacing doesn't know the
% block number, so we provide two flags to designate the first and last
% blocks. If you provide o.lastBlock=true then brightness
% will be restored at the end of the block (or when CriticalSpacing
% terminates). Otherwise the brightness will remain ready for the next
% block. I think this code eliminates an annoying dead time of 30 to 60 s
% per block.
o.isFirstBlock=true;
o.isLastBlock=true;
o.skipScreenCalibration=false;
skipScreenCalibration=o.skipScreenCalibration; % Global for CloseWindowsAndCleanup.

% TO MEASURE BETA
% o.measureBeta=false;
% o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
% o.trialsDesired=200;

% TO HELP CHILDREN
% o.fractionEasyTrials=0.2; % 0.2 adds 20% easy trials. 0 adds none.
% o.speakEncouragement=true; % true to say "good," "very good," or "nice" after every trial.
% o.practicePresentations=3;   % 0 for none. Ignored unless repeatedTargets==true.
% Provides easy practice presentations, ramping up
% the number of targets after each correct report
% of both letters in a presentation, until the
% observer gets three presentations right. Then we
% seamlessly begin the official block.

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
% i.e. when o.repeatedTargets=true. This new options adds 3 practice
% presentations at the beginning of every repeatedTargets block. The first
% presentation has only a few target letters (two unique) in a single row.
% Subsequent presentations are similar, until the observer gets both
% targets right. Then it doubles the number of targets. Again it waits for
% the observer to get both targets right, and then doubles the number of
% targets. After 3 successful practice presentations, the official block
% begins. The practice presentation responses are discarded and not passed
% to Quest.
%
% You can restore the old behavior by setting o.practicePresentations=0.
% After the practice, the block estimates threshold by the same procedure
% whether o.practicePresentation is 0 or 3.

% NOT SET BY USER
o.deviceIndex=-3; % all keyboard and keypad devices
o.easyCount=0; % Number of easy presentations
o.guessCount=0; % Number of artificial guess responses
o.quitBlock=false;
o.quitExperiment=false;
o.script='';
o.scriptFullFileName='';
o.scriptName='';
o.targetFontNumber=[];
o.targetHeightOverWidth=nan;
o.actualDurationSec=[];
o.actualDurationGetSecsSec=[];
o.actualDurationVBLSec=[];

% PROCESS INPUT.
% o is a single struct, and oIn may be an array of structs.
% Create oo, which replicates o for each condition.
conditions=length(oIn);
clear oo
oo(1:conditions)=o;
inputFields=fieldnames(o);
clear o; % Thus MATLAB will flag an error if we accidentally try to use "o".

% For each condition, all fields in the user-supplied "oIn" overwrite
% corresponding fields in "o". We ignore any field in oIn that is not
% already defined in o. We warn of any unknown field that we ignore, unless
% it's a known output field. It might be a typo for an input fields, or an
% obsolete parameter.
outputFields={'beginSecs' 'beginningTime' 'cal' 'dataFilename' ...
    'dataFolder' 'eccentricityXYPix' 'fix' 'functionNames' ...
    'keyboardNameAndTransport' 'minimumSizeDeg' 'minimumSpacingDeg' ...
    'minimumViewingDistanceCm' 'normalAcuityDeg' ...
    'normalCrowdingDistanceDeg' 'presentations' 'q' 'responseCount' ...
    'responseKeyCodes' 'results' 'screen' 'snapshotsFolder' 'spacings'  ...
    'spacingsSequence' 'targetFontHeightOverNominal' 'targetPix' ...
    'textSize' 'totalSecs' 'unknownFields' 'validKeyNames' ...
    'nativeHeight' 'nativeWidth' 'resolution' 'maximumViewingDistanceCm' ...
    'minimumScreenSizeXYDeg' 'typicalThesholdSizeDeg' ...
    'computer' 'matlab' 'psychtoolbox' 'trialData' 'hasWirelessKeyboard' ...
    'standardDrawTextPlugin' 'drawTextWarning' 'oldResolution' ...
    'targetSizeIsHeight'  ...
    'maxRepetition' 'practiceCountdown' 'flankerLetter' 'row' ...
    'fixationOnScreen' 'fixationXYPix' 'nearPointXYPix' ...
    'pixPerCm' 'pixPerDeg' 'stimulusRect' 'targetXYPix' 'textLineLength' ...
    'speakInstructions' 'fixationOnScreen' 'fixationIsOffscreen' ...
    'okToShiftCoordinates' 'responseTextWidth' ...
    'eccentricityDegVector' 'flankingDegVector'
    };
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
end % for oi=1:conditions
unknownFields=unique(unknownFields);
if ~isempty(unknownFields)
    error(['Unknown o fields:' sprintf(' %s',unknownFields{:}) '.']);
end
if oo(1).quitExperiment
    % Quick return. We're skipping every block in the session.
    keepWindowOpen=false;
    oo=SortFields(oo);
    return
end
skipScreenCalibration=oo(1).skipScreenCalibration; % Global used by CloseWindowsAndCleanup.
% clear Screen % might help get appropriate restore after using Screen('Resolution');
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','Verbosity',0); % Mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference','SkipSyncTests',1);

% Set up defaults. Clumsy.
for oi=1:conditions
    if ~ismember(oo(oi).thresholdParameter,{'spacing' 'size'})
        error('Illegal value ''%s'' of o.thresholdParameter.',oo(oi).thresholdParameter);
    end
end
for oi=1:conditions
    switch oo(oi).task
        case 'read'
            o.relationOfSpacingToSize='fixed by font';
    end
    if ~isfinite(oo(oi).targetSizeIsHeight)
        switch oo(oi).thresholdParameter
            case 'size'
                oo(oi).targetSizeIsHeight=true;
            case 'spacing'
                oo(oi).targetSizeIsHeight=false;
        end
    end
end % for oi=1:conditions
for oi=1:conditions
    if oo(oi).practicePresentations>0
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
end % for oi=1:conditions
for oi=1:conditions
    if ~(oo(oi).maxLines>=1 && round(oo(oi).maxLines)==oo(oi).maxLines && oo(oi).maxLines~=2 )
        error('%d: o.maxLines==%.1f, but should be an integer 1,3,4,... inf.',oi,oo(oi).maxLines);
    end
end
Screen('Preference','TextAntiAliasing',1);
SoundVolume(oo(1).soundVolume);
soundMuting=SoundMuting;
if oo(1).soundVolume>0 && soundMuting
    warning('SoundVolumen %.2f is greater than zero, but SoundMuting is true.',oo(1).soundVolume);
end
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
    if oo(oi).labelAnswers
        if length(oo(oi).alphabet)>length(oo(oi).responseLabels)
            error('o.labelAnswers is true, but o.alphabet is longer than o.responseLabels: %d > %d.',...
                length(oo(oi).alphabet),length(oo(oi).responseLabels));
        end
        oo(oi).validResponseLabels=oo(oi).responseLabels(1:length(oo(oi).alphabet));
        oo(oi).validKeyNames=KeyNamesOfCharacters(oo(oi).validResponseLabels);
    else
        oo(oi).validKeyNames=KeyNamesOfCharacters(oo(oi).alphabet);
    end
    for i=1:length(oo(oi).validKeyNames)
        oo(oi).responseKeyCodes(i)=KbName(oo(oi).validKeyNames{i}); % This returns keyCode as integer.
    end
    if isempty(oo(oi).responseKeyCodes)
        error('No valid o.responseKeyCodes for responding.');
    end
end % for oi=1:conditions

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
if oo(1).useFractionOfScreenToDebug
    % We want to simulate the full screen, and what we would normally see in
    % it, shrunken into a tiny fraction. So we use a reduced number of
    % pixels, but we pretend to retain the same screen size in cm, and
    % angular subtense.
    r=round(oo(oi).useFractionOfScreenToDebug*screenRect);
    screenRect=AlignRect(r,screenRect,'bottom','right');
end
[oo.stimulusRect]=deal(screenRect);
for oi=1:conditions
    if ismember(oo(oi).borderLetter,oo(oi).alphabet)
        ListenChar(0);
        error('The o.borderLetter "%c" should not be included in the o.alphabet "%s".',...
            oo(oi).borderLetter,oo(oi).alphabet);
    end
    assert(oo(oi).viewingDistanceCm==oo(1).viewingDistanceCm);
    assert(oo(oi).useFractionOfScreenToDebug==oo(1).useFractionOfScreenToDebug);
end % for oi=1:conditions

% Are we using the screen at its maximum native resolution?
ff=1;
res=Screen('Resolutions',oo(1).screen);
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
    ffprintf(ff,':: Your screen resolution is at its native maximum %d x %d. Excellent!\n',oo(1).nativeWidth,oo(1).nativeHeight);
else
    warning backtrace off
    if oo(1).permissionToChangeResolution
        s=GetSecs;
        fprintf('WARNING: Trying to optimize screen resolution for this test. ... ');
        oo(1).oldResolution=Screen('Resolution',oo(1).screen,oo(1).nativeWidth,oo(1).nativeHeight);
        res=Screen('Resolution',oo(1).screen);
        fprintf('Done (%.1f s). ',GetSecs-s);
        if res.width==oo(1).nativeWidth
            fprintf('SUCCESS!\n');
        else
            warning('FAILED.');
            res
        end
        actualScreenRect=Screen('Rect',oo(1).screen,1);
    end
    if oo(1).nativeWidth==RectWidth(actualScreenRect)
        ffprintf(ff,':: Your screen resolution is at its native maximum %d x %d. Excellent!\n',oo(1).nativeWidth,oo(1).nativeHeight);
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
        ffprintf(ff,['(To use native resolution, set o.permissionToChangeResolution=true in your script, \n'...
            'or use System Preferences:Displays to select "Default" resolution.)\n']);
        warning backtrace on
    end
end
oo(1).resolution=Screen('Resolution',oo(1).screen);

try
    oo(1).screen=max(Screen('Screens'));
    computer=Screen('Computer');
    oo(1).computer=computer;
    if oo(1).isFirstBlock && ~oo(1).skipScreenCalibration
        if IsOSX
            % Do this BEFORE opening the window, so user can see any alerts.
            ffprintf(ff,'%d: Turning AutoBrightness off. ... ',MFileLineNr);
            s=GetSecs;
            AutoBrightness(oo(1).screen,0); % Takes 25 s.
            ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
        end
    end
    screenBufferRect=Screen('Rect',oo(1).screen);
    screenRect=Screen('Rect',oo(1).screen,1);
    if oo(1).isFirstBlock
        Screen('Preference','TextRenderer',1); % Request FGTL DrawText plugin.
        ffprintf(ff,'%d: OpenWindow. ... ',MFileLineNr);
        s=GetSecs;
        window=OpenWindow(oo(1));
        ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
        scratchWindow=Screen('OpenOffscreenWindow',-1,[],screenRect,8);
    else
        windowsNowOpen=length(Screen('Windows'));
        kind=Screen(window,'WindowKind');
        if kind~=1
            error('Not first block, yet "window" pointer is invalid. %d windows open.',windowsNowOpen);
        end
        kind=Screen(scratchWindow,'WindowKind');
        if kind~=-1
            error('Not first block, yet "scratchWindow" pointer is invalid. %d windows open.',windowsNowOpen);
        end
    end
    white=WhiteIndex(window);
    black=BlackIndex(window);
    if oo(1).printScreenResolution
        % Print in Command Window.
        screenBufferRect=Screen('Rect',oo(1).screen)
        screenRect=Screen('Rect',oo(1).screen,1)
        resolution=Screen('Resolution',oo(1).screen)
    end
    screenRect=Screen('Rect',window,1);
    Screen('TextFont',window,oo(1).textFont);
    
    if oo(1).isFirstBlock
        % Are we using the FGTL DrawText plugin?
        % Ignore possible warning: "PTB-WARNING: DrawText: Failed to load
        % external drawtext plugin".
        Screen('Preference','SuppressAllWarnings',0);
        Screen('Preference','Verbosity',2); % Print WARNINGs
        oo(1).dataFolder=fullfile(mainFolder,'data');
        if ~exist(oo(1).dataFolder,'dir')
            [success,msg]=mkdir(oo(1).dataFolder);
            if ~success
                error('%s. Could not create data folder: %s',msg,oo(1).dataFolder);
            end
        end
        % Record any warnings provoked by calling DrawText.
        if ~isempty(window)
            Screen('FillRect',window);
            r=Screen('Rect',window);
            oo(1).textSize=round(0.02*RectWidth(r)); % Rough guess.
            Screen('TextSize',window,oo(1).textSize);
            if false
                % Appears too briefly to be read. Annoying.
                Screen('DrawText',window,'Testing DrawText (and caching fonts) ...',...
                    2*oo(1).textSize,2.5*oo(1).textSize);
            end
            Screen('Flip',window);
        end
        ffprintf(ff,'Testing DrawText (and caching fonts) ... '); s=GetSecs;
        drawTextWarningFileName=fullfile(oo(1).dataFolder,'drawTextWarning');
        if exist(drawTextWarningFileName,'file')
            delete(drawTextWarningFileName);
        end
        s=GetSecs;
        diary(drawTextWarningFileName);
        Screen('DrawText',window,'Hello',0,200,255,255); % Exercise DrawText.
        diary off
        fileId=fopen(drawTextWarningFileName);
        drawTextWarning=char(fread(fileId)');
        fclose(fileId);
        if ~isempty(drawTextWarning) && oo(oi).getAlphabetFromDisk
            warning backtrace off
            warning('You can ignore the warnings above about DrawText because we aren''t using it.');
            warning backtrace on
        end
        delete(drawTextWarningFileName);
        ffprintf(ff,'Done (%.1f s).\n',GetSecs-s);
        % Below we print any drawTextWarning into our log file.
    end
    oo(1).drawTextWarning=drawTextWarning;
    
    Screen('Preference','SuppressAllWarnings',1);
    Screen('Preference','Verbosity',0); % Mute Psychtoolbox INFOs & WARNINGs.
    oo(1).standardDrawTextPlugin=(Screen('Preference','TextRenderer')==1);
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
        if ~oo(oi).getAlphabetFromDisk
            if ~oo(1).standardDrawTextPlugin
                error(['Sorry. The FGTL DrawText plugin failed to load. ' ...
                    'Hopefully there''s an explanatory PTB-WARNING above. ' ...
                    'Unless you fix that, '...
                    'you must set o.getAlphabetFromDisk=true in your script.']);
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
                    fprintf('Similarly named fonts:\n');
                    begin=oo(oi).targetFont(1:min(4,length(oo(oi).targetFont)));
                    fprintf('(Reporting all font names that match the "%s" beginning of the given name, up to four characters.)\n',begin);
                    for i=1:length(fontInfo)
                        % Print names of any fonts that have the right first four
                        % letters, ignoring capitalization.
                        if strncmpi({fontInfo(i).familyName},oo(oi).targetFont,min(4,length(oo(oi).targetFont)))
                            fprintf('%s\n',fontInfo(i).name);
                        end
                    end
                    error(['The o.targetFont "%s" is not installed in your computer''s OS. \n' ...
                        'If you think it might be in CriticalSpacing''s "alphabet" folder \n' ...
                        'then try setting "o.getAlphabetFromDisk=true;". \n' ...
                        'Otherwise please install the font, or use another font.\n' ...
                        'Similar names of installed fonts appear above.'],oo(oi).targetFont);
                end
                if sum(hits)>1
                    for i=1:length(fontInfo)
                        if streq({fontInfo(i).familyName},oo(oi).targetFont)
                            fprintf('%s\n',fontInfo(i).name);
                        end
                    end
                    error('Multiple fonts, above, have family name "%s". Pick one.',oo(oi).targetFont);
                end
                oo(oi).targetFontNumber=fontInfo(hits).number;
                Screen('TextFont',window,oo(oi).targetFontNumber);
                [~,number]=Screen('TextFont',window);
                if ~(number==oo(oi).targetFontNumber)
                    error('Unable to select o.targetFont "%s" by its font number %d.',oo(oi).targetFont,oo(oi).targetFontNumber);
                end
            else
                oo(oi).targetFontNumber=[];
                Screen('TextFont',window,oo(oi).targetFont);
                % Perform dummy draw call, in case the OS has deferred settings.
                Screen('DrawText',window,' ',0,0);
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
        end % if ~oo(1).getAlphabetFromDisk
    end % for oi=1:conditions
    if ~oo(1).standardDrawTextPlugin
        warning off backtrace
        warning('The FGTL DrawText plugin failed to load. ');
        warning on backtrace
        ffprintf(ff,['WARNING: The FGTL DrawText plugin failed to load.\n' ...
            'Hopefully there''s an explanatory PTB-WARNING above, hinting how to fix it.\n' ...
            'This won''t affect the experimental stimuli, but small print in the instructions may be ugly.\n']);
    end
    
    % In endless loop, ask about viewing distance, keyboard, etc.
    while true
        screenRect=Screen('Rect',window);
        screenWidthPix=RectWidth(screenRect);
        screenHeightPix=RectHeight(screenRect);
        pixPerDeg=0.05*screenHeightPix/atan2d(0.05*screenHeightCm,oo(1).viewingDistanceCm);
        pixPerCm=screenWidthPix/screenWidthCm;
        for oi=1:conditions
            % Adjust textSize so our string fits on screen.
            Screen('TextFont',window,oo(oi).textFont,0);
            font=Screen('TextFont',window);
            if ~streq(font,oo(oi).textFont)
                warning off backtrace
                warning('The o.textFont "%s" is not available. Using %s instead.',oo(oi).textFont,font);
                warning on backtrace
            end
            [oo(oi).textSize,oo(oi).textLineLength]=TextSizeToFit(window,oo(oi).textFont);
        end
        pixPerDeg=0.05*screenHeightPix/atan2d(0.05*screenHeightCm,oo(1).viewingDistanceCm);
        for oi=1:conditions
            oo(oi).viewingDistanceCm=oo(1).viewingDistanceCm;
            oo(oi).pixPerDeg=pixPerDeg;
            oo(oi).pixPerCm=pixPerCm;
            ecc=norm(oo(oi).eccentricityXYDeg);
            oo(oi).normalAcuityDeg=0.029*(ecc+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
            switch oo(oi).targetFont
                case 'Pelli'
                    oo(oi).normalAcuityDeg=oo(oi).normalAcuityDeg/5;
            end
            oo(oi).normalCrowdingDistanceDeg=0.3*(ecc+0.15); % From Pelli et al. (2017).
            switch oo(oi).flankingDirection
                case 'tangential'
                    oo(oi).normalCrowdingDistanceDeg=0.5*oo(oi).normalCrowdingDistanceDeg;
            end
            oo(oi).typicalThesholdSizeDeg=oo(oi).normalAcuityDeg;
            switch oo(oi).thresholdParameter
                case 'spacing'
                    switch oo(oi).relationOfSpacingToSize
                        case 'fixed ratio'
                            % Observer fails if size or spacing is below threshold, so
                            % we care only about the bigger size of failure.
                            oo(oi).typicalThesholdSizeDeg= ...
                                max(oo(oi).typicalThesholdSizeDeg, ...
                                oo(oi).normalCrowdingDistanceDeg/oo(oi).fixedSpacingOverSize);
                        case 'none'
                        case 'fixed by font'
                    end
            end
            minimumSizeDeg=oo(oi).minimumTargetPix/pixPerDeg; % Limited by display resolution.
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    minimumSpacingDeg=oo(oi).fixedSpacingOverSize*minimumSizeDeg;
                case 'none'
                    minimumSpacingDeg=1.4*oo(oi).targetDeg;
                    switch oo(oi).targetFont
                        case 'Pelli'
                            minimumSpacingDeg=minimumSpacingDeg/5; % For Pelli font.
                        otherwise
                    end
                case 'fixed by font'
            end
            % Distance at which minimum size is half the typical threshold
            % whether due to size or spacing.
            switch oo(oi).thresholdParameter
                case 'size'
                    oo(oi).minimumViewingDistanceCm=10*ceil(0.1*oo(oi).viewingDistanceCm*2*minimumSizeDeg/oo(oi).typicalThesholdSizeDeg);
                case 'spacing'
                    oo(oi).minimumViewingDistanceCm=10*ceil(0.1*oo(oi).viewingDistanceCm*2*minimumSpacingDeg/oo(oi).normalCrowdingDistanceDeg);
            end
            
        end
        minimumViewingDistanceCm=max([oo.minimumViewingDistanceCm]);
        if oo(1).speakViewingDistance
            Speak(sprintf('Please move the screen to be %.0f centimeters from your eye.',oo(1).viewingDistanceCm));
        end
        minimumScreenSizeXYDeg=[0 0];
        for oi=1:conditions
            %% COPIED FROM SET UP NEAR POINT
            white=WhiteIndex(window);
            black=BlackIndex(window);
            
            % SELECT NEAR POINT
            % The user specifies the target eccentricity
            % o.eccentricityXYDeg, which specifies its offset from
            % fixation. The user can assign any visual coordinate to the
            % near point, and can explicitly request that it be that of
            % fixation or target. We take o.nearPointXYInUnitSquare as the
            % user's designation the near point's location on the screen.
            %
            % If the user selects setNearPointEccentricityTo='target' then,
            % if necessary, we adjust the visual coordinate of the near
            % point to allow fixation to be on-screen. If the eccentricity
            % is too large to allow both the target and fixation to be
            % on-screen, then the fixation mark is placed off-screen.
            % o.nearPointXYInUnitSquare and o.eccentricityXYDeg are
            % requirements  We'll error-exit if they cannot be achieved,
            % while  is merely a preference for fixation to be on-screen.
            
            % If setNearPointEccentricityTo='target' we adjust the visual
            % coordinate of the near point, if necessary to bring fixation
            % on-screen. To do this we first imagine the target at the
            % desired spot (e.g. the center of the screen) and note where
            % fixation would land, given the specified tsrget eccentricity.
            % If fixation is on-screen then we're done. If it's off-screen
            % then we adjust o.nearPointXYDeg to push fixation and target
            % just enough in the direction of the target to allow the
            % fixation mark to just fit on-screen. If we can do that
            % without pushing the target off-screen, then we're done.
            %
            % If we can't get both fixation and target on-screen, then the
            % fixation goes off-screen and the target springs back to the
            % desired spot.
            %
            % We don't mind allowing the screen edge to partially clip
            % the fixation mark 0.5 deg from its center, but the target
            % must not be clipped by the screen edge, and, further more,
            % since this is a crowding test, there should be enough room to
            % place a radial flanker beyond the target and not clip it. To
            % test a diverse population we should allow twice the normal
            % crowding distance beyond the target center, plus half the
            % flanker size. We typically use equal target and flanker size.
            %
            % These requirements extend the eccentricity vector's length,
            % first by adding 0.5 deg for the fixation mark. If we need to
            % keep fixation on-screen, then we shift the target away from
            % the desired location (in the direction of the eccentricity
            % vector) just enough to get fixation on-screen. Then we have
            % to decide whether it's acceptable. If we're measuring acuity,
            % we just need room, radially (i.e. from fixation), beyond the
            % target center for half the target. If we're measuring
            % crowding, we need room radially, beyond the target center,
            % for 2/3 the eccentricity, plus half the target size.
            
            %% SANITY CHECK OF ECCENTRICITY AND DESIRED NEAR POINT
            if ~all(isfinite(oo(oi).eccentricityXYDeg))
                error('o.eccentricityXYDeg (%.1f %.1f) must be finite. o.useFixation=%d is optional.',...
                    oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2),oo(oi).useFixation);
            end
            if ~IsXYInRect(oo(oi).nearPointXYInUnitSquare,[0 0 1 1])
                error('o.nearPointXYInUnitSquare (%.2f %.2f) must be in unit square [0 0 1 1].',...
                    oo(oi).nearPointXYInUnitSquare(1),oo(oi).nearPointXYInUnitSquare(2));
            end
            % Provide default target size if not already provided.
            if ~isfinite(oo(oi).targetDeg)
                ecc=norm(oo(oi).eccentricityXYDeg);
                oo(oi).targetDeg=0.3*(ecc+0.15)/oo(oi).fixedSpacingOverSize;
            end
            
            %% IS SCREEN BIG ENOUGH TO HOLD TARGET AND FIXATION?
            % We protect fixationCoreSizeDeg diameter from clipping by
            % screen edge.
            if oo(oi).isolatedTarget
                % In the screen, include the target itself, plus a fraction
                % o.targetMargin of the target size.
                totalSizeXYDeg=oo(oi).fixationCoreSizeDeg/2 + abs(oo(oi).eccentricityXYDeg) ...
                    + oo(oi).targetDeg*(0.5+oo(oi).targetMargin);
            else
                totalSizeXYDeg=oo(oi).fixationCoreSizeDeg/2 ...
                    + 1.66*abs(oo(oi).eccentricityXYDeg) + oo(oi).targetDeg/2;
            end
            % Compute angular subtense of stimulusRect, assuming the near
            % point is at center.
            xy=oo(oi).stimulusRect(3:4)-oo(oi).stimulusRect(1:2); % width and height
            rectSizeDeg=2*atand(0.5*xy/oo(1).pixPerCm/oo(1).viewingDistanceCm);
            fprintf('%d: screen %.0fx%.0f = %.1fx%.1f deg, %.0f pixPerDeg, %.1f pixPerCm, viewingDistanceCm %.1f cm, xy %.0f %.0f\n',...
                oi,screenRect(3:4),rectSizeDeg,oo(1).pixPerDeg,oo(1).pixPerCm,oo(1).viewingDistanceCm, xy);
            if all(totalSizeXYDeg <= rectSizeDeg)
                oo(oi).fixationOnScreen=true;
                verb='fits within';
            else
                oo(oi).fixationOnScreen=false;
                verb='exceeds';
            end
            if oo(oi).forceFixationOffScreen
                if oo(oi).fixationOnScreen
                    ffprintf(ff,'Fixation would fit on-screen, but was forced off by o.forceFixationOffScreen=%d.\n',...
                        oo(oi).forceFixationOffScreen);
                end
                oo(oi).fixationOnScreen=false;
            end
            fitsOnScreenString=sprintf('The combined size of target and fixation %.1f x %.1f deg %s the screen %.1f x %.1f deg.',...
                totalSizeXYDeg,verb,rectSizeDeg);
            ffprintf(ff,'%d: %s\n',oi,fitsOnScreenString);
            if streq(verb,'exceeds') && ~oo(oi).forceFixationOffScreen
                ffprintf(ff,'%d: This forces the fixation off-screen. Consider reducing the viewing distance or eccentricity.\n',oi);
            end
            
            %% USE o.nearPointXYInUnitSquare TO SET NEAR POINT SCREEN COORDINATE
            xy=oo(oi).nearPointXYInUnitSquare;
            xy(2)=1-xy(2); % Move origin from lower left to upper left.
            oo(oi).nearPointXYPix=xy.*[RectWidth(oo(oi).stimulusRect) RectHeight(oo(oi).stimulusRect)];
            oo(oi).nearPointXYPix=oo(oi).nearPointXYPix+oo(oi).stimulusRect(1:2);
            oo(oi).nearPointXYPix=round(oo(oi).nearPointXYPix); % DGP
            % oo(oi).nearPointXYPix is a screen coordinate.
            
            %% ASSIGN NEAR POINT VISUAL COORDINATE
            % Enabling okToShiftCoordinates will typical result in
            % different fixation locations for each condition. That may be
            % ok for some experiments, but is not ok when the randomization
            % matters and we don't want the locaiton of fixation to inform
            % the observer about which condition is being tested by this
            % trial. THe current criterion for okToShiftCoordinates may be
            % overly strict and could be relaxed somewhat.
            oo(1).okToShiftCoordinates = length(oo)==1 || all(ismember([oo.setNearPointEccentricityTo],{'target'}));
            [oo.okToShiftCoordinates]=deal(oo(1).okToShiftCoordinates);
            switch oo(oi).setNearPointEccentricityTo
                case 'target'
                    oo(oi).nearPointXYDeg=oo(oi).eccentricityXYDeg;
                case 'fixation'
                    oo(oi).nearPointXYDeg=[0 0];
                case 'value'
                    % Assume user has set oo(1).nearPointXYDeg.
                otherwise
                    error(['o.setNearPointEccentricityTo has illegal value ''%s''. '...
                        'It must be ''target'', ''fixation'', or ''value''.'],...
                        oo(oi).setNearPointEccentricityTo);
            end
            if oo(oi).fixationOnScreen
                % If necessary, try to shift coordinates to get fixation on
                % screen. Enabled by o.okToShiftCoordinates.
                xy=XYPixOfXYDeg(oo(oi),[0 0]); % Current screen coord. of fixation.
                radiusDeg=oo(oi).fixationCoreSizeDeg/2;
                oo(oi)=ShiftPointIntoRect(oo(oi),ff,'fixation',xy,radiusDeg,oo(oi).stimulusRect);
            end
            % In addition to its argument xyDeg, the returned value of
            % XYPixOfXYDeg(xyDeg) depends solely on o.nearPointXYDeg and
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
        end % for oi=1:conditions
        stimulusWidthHeightCm=[RectWidth(oo(1).stimulusRect) RectHeight(oo(1).stimulusRect)]/pixPerCm;
        % This refers to max possible, for this condition. Don't confuse it
        % with o.maxViewingDistanceCm which is max of o.viewingDistanceCm
        % across remaining blocks in experiment.
        maximumViewingDistanceCm=min( stimulusWidthHeightCm./(2*tand(0.5*minimumScreenSizeXYDeg)) );
        
        % BIG TEXT
        % Say hello.
        Screen('FillRect',window,white);
        cmString=sprintf('%.0f cmx',oo(1).viewingDistanceCm);
        % We remove the trailing x from cmString after we compute its
        % bounding box. This gives a nice white border.
        string=sprintf('Block %d of %d.',oo(1).block,oo(1).blocksDesired);
        string=sprintf('%s Welcome to CriticalSpacing.',string);
        Screen('TextSize',window,oo(1).textSize);
        [~,y]=Screen('DrawText',window,string,...
            2*oo(1).textSize,2.5*oo(1).textSize,...
            black,white,1);
        scalar=1.5;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        bounds=Screen('TextBounds',window,cmString,[],[]);
        x=screenRect(3)-bounds(3);
        cmString=cmString(1:end-1);
        Screen('DrawText',window,cmString,x,y,black,white,1);
        Screen('TextSize',window,oo(1).textSize);
        
        % VIEWING DISTANCE
        red=[255 0 0];
        isNewDistance=oo(1).isFirstBlock || oo(1).viewingDistanceCm~=oldViewingDistanceCm;
        if isNewDistance
            color=red;
            string=sprintf(['\n\nDISTANCE: %.0f cm. '...
                'Please use a ruler or tape measure to move the display and ' ...
                'yourself to achieve the new viewing distance of %.0f cm '...
                'from your eye to the screen. '...
                '(Experts can type in a new distance.)'],...
                oo(1).viewingDistanceCm,oo(1).viewingDistanceCm);
            if isempty(oldViewingDistanceCm)
                speech=sprintf('%.0f centimeters. Please use a ruler to adjust your viewing distance to be %.0f centimeters.',...
                    oo(1).viewingDistanceCm,oo(1).viewingDistanceCm);
            else
                speech=sprintf(['%.0f centimeters. The necessary viewing distance has changed. '...
                    'Please use a ruler to adjust your distance to %.0f centimeters.'],...
                    oo(1).viewingDistanceCm,oo(1).viewingDistanceCm);
            end
        else
            color=black;
            string=sprintf(['\n\nDISTANCE: The viewing distance is %.0f cm. ' ...
                'If you''re not aleady there, '...
                'please move me to that distance from your eye, and hit RETURN. ' ...
                '(Experts can enter the new distance.)'], ...
                oo(1).viewingDistanceCm);
            speech='';
        end
        scalar=0.55;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        % Set viewing distance.
        [~,y]=DrawFormattedText(window,string,...
            2*oo(1).textSize,y,color,...
            oo(oi).textLineLength/scalar,...
            [],[],1.1);
        string='';
        
        % WIRELESS KEYBOARD?
        % Now check if any block needs wireless, and alert observer ahead of time.
        [oo(1).hasWirelessKeyboard,oo(1).keyboardNameAndTransport]=HasWirelessKeyboard;
        if ~oo(1).hasWirelessKeyboard
            if oo(1).maxViewingDistanceCm>=80
                color=red;
                string=sprintf(['\n\nKEYBOARD: ' ...
                    'The maximum viewing distance required '...
                    'in the remaining blocks is %.0f cm. '...
                    'At that distance, you may need a wireless keyboard, ' ...
                    'but I can''t detect any. After connecting a new keyboard, ' ...
                    'use your old keyboard to type "k" below, followed by RETURN, ' ...
                    'and I''ll recreate the keyboard list.'],...
                    oo(1).maxViewingDistanceCm);
                Screen('TextSize',window,round(oo(1).textSize*scalar));
                % Need wireless keyboard.
                [~,y]=DrawFormattedText(window,string,...
                    2*oo(1).textSize,y,color,...
                    oo(oi).textLineLength/scalar,...
                    [],[],1.1);
                string='';
                warning backtrace off
                warning('The long o.maxViewingDistanceCm %.0f cm may demand an external keyboard,',...
                    oo(1).maxViewingDistanceCm);
                warning('yet your only keyboard is not "wireless" or "bluetooth".');
                warning backtrace on
            end
        else
            if oo(1).viewingDistanceCm>=80
                string='\n\nKEYBOARD: At this distance you may want to use your wireless keyboard.';
            end
        end
        
        % SIZE LIMITS
        for oi=1:conditions
            oo(oi).minimumSizeDeg=oo(oi).minimumTargetPix/pixPerDeg;
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    oo(oi).minimumSpacingDeg=oo(oi).fixedSpacingOverSize*oo(oi).minimumSizeDeg;
                case 'none'
                    oo(oi).minimumSpacingDeg=1.1*oo(oi).minimumTargetPix/pixPerDeg;
                case 'fixed by font'
            end
        end
        sizeDeg=max([oo.minimumSizeDeg]);
        spacingDeg=max([oo.minimumSpacingDeg]);
        string=sprintf(['%s\n\nSIZE LIMITS: At the current <strong>%.0f cm</strong> viewing distance, '...
            'the screen is %.0fx%.0f deg, and can display characters '...
            'as small as %.3f deg with spacing as small as %.3f deg. '],...
            string,oo(1).viewingDistanceCm,rectSizeDeg,...
            sizeDeg,spacingDeg);
        if any([oo(:).eccentricityXYDeg]~=0)
            string=sprintf(['%s The combined size of the target and fixation %.1f x %.1f deg '...
                '%s the screen %.1f x %.1f deg. ',...
                'To allow on-screen fixation, view screen from at most %.0f cm. '],...
                string,minimumScreenSizeXYDeg,verb,rectSizeDeg,floor(maximumViewingDistanceCm));
        end
        switch oo(oi).thresholdParameter
            case 'size'
                smallestDeg=min([oo.typicalThesholdSizeDeg])/2;
                string=sprintf(['%sTo allow display of your target as small as %.3f deg, ' ...
                    'half of typical threshold size, view screen from <strong>at least %.0f cm</strong>.\n\n'], ...
                    string,smallestDeg,minimumViewingDistanceCm);
            case 'spacing'
                smallestDeg=min([oo.normalCrowdingDistanceDeg])/2;
                string=sprintf(['%sTo allow spacing as small as %.2f deg, ' ...
                    'half of typical crowding distance, view screen from <strong>at least %.0f cm</strong>.\n\n'], ...
                    string,smallestDeg,minimumViewingDistanceCm);
        end
        s=strrep(string,'<strong>','!B'); % Minimize for line breaking.
        s=strrep(s,'</strong>','!b');
        s=regexprep(s,'.{1,80}\s','$0\n'); % Break lines.
        s=strrep(s,'!B','<strong>'); % Restore.
        s=strrep(s,'!b','</strong>');
        ffprintf(ff,'%s',s(1:end-2)); % Print wrapped text including <strong> and </strong>.
        string=strrep(string,'<strong>',''); % Remove <strong> and </strong>.
        string=strrep(string,'</strong>','');
        
        % RESOLUTION
        if oo(1).nativeWidth==RectWidth(actualScreenRect)
            string=sprintf('%sRESOLUTION: %.0fx%.0f. Your screen resolution is optimal.\n\n',string,RectWidth(actualScreenRect),RectHeight(actualScreenRect));
        else
            if RectWidth(actualScreenRect)<oo(1).nativeWidth
                string=sprintf(['%sRESOLUTION: %.0fx%.0f. You could reduce the minimum viewing distance ' ...
                    '%.1f-fold by increasing the screen resolution to native resolution %.0fx%.0f. '],...
                    string,RectWidth(actualScreenRect),RectHeight(actualScreenRect),oo(1).nativeWidth/RectWidth(actualScreenRect),oo(1).nativeWidth,oo(1).nativeHeight);
            else
                string=sprintf(['%sRESOLUTION: Your screen resolution exceeds its maximum native resolution, ' ...
                    'and may fail to render small characters. '],string);
            end
            string=sprintf(['%sFor native resolution, ' ...
                'set o.permissionToChangeResolution=true in your script, ' ...
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
                'set o.flipScreenHorizontally=true in your script, ' ...
                'or type "m" below, followed by RETURN.\n\n'],...
                string);
        end
        
        % Draw the rest of the plain small text onto the screen.
        Screen('TextSize',window,round(oo(1).textSize*scalar));
        % Welcome screen with expert options.
        [~,y]=DrawFormattedText(window,string,...
            2*oo(1).textSize,y,black,...
            oo(oi).textLineLength/scalar,...
            [],[],1.1);
        
        % COPYRIGHT
        Screen('TextSize',window,round(oo(1).textSize*0.35));
        copyright=sprintf('Crowding and Acuity Test. Copyright %c 2016, 2017, 2018, 2019, Denis Pelli. All rights reserved.',169);
        Screen('DrawText',window,double(copyright),...
            2*oo(1).textSize,screenRect(4)-0.2*oo(1).textSize,...
            black,white,1);
        
        % Get typed response
        if IsWindows
            background=[];
        else
            background=WhiteIndex(window);
        end
        scalar=0.95;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        Screen('TextFont',window,oo(1).textFont);
        Screen('DrawText',window,'To continue, just hit RETURN. To make a change, enter numerical',...
            2*oo(1).textSize,0.86*screenRect(4)+scalar*oo(1).textSize*(0.5-1.1),...
            black,white);
        DrawCounter(oo);
        Screen('Flip',window,[],1);
        if ~isempty(speech) && oo(1).useSpeech
            Speak(speech);
        end
        DrawCounter(oo);
        [d,terminatorChar]=GetEchoString(window,'viewing distance in cm or a command (r, m, or k):'...
            ,2*oo(1).textSize,0.86*screenRect(4)+scalar*oo(1).textSize*0.5,black,background,1,oo(1).deviceIndex);
        Screen('TextSize',window,oo(1).textSize);
        if ismember(terminatorChar,[escapeChar graveAccentChar])
            [oo,tryAgain]=ProcessEscape(oo);
            if tryAgain
                continue
            else
                oo=SortFields(oo);
                return
            end
        end
        if ~isempty(d)
            inputDistanceCm=str2num(d);
            if ~isempty(inputDistanceCm) && inputDistanceCm>0
                oo(1).viewingDistanceCm=inputDistanceCm;
            else
                switch d
                    case 'm'
                        oo(1).flipScreenHorizontally=~oo(1).flipScreenHorizontally;
                        ffprintf(ff,'Flipping screen\n');
                        if oo(1).useSpeech
                            Speak('Now flipping the display.');
                        end
                        Screen('CloseAll');
                        window=OpenWindow(oo(1));
                        scratchWindow=Screen('OpenOffscreenWindow',-1,[],screenRect,8);
                    case 'r'
                        if oo(1).permissionToChangeResolution
                            Speak('Resolution is already optimal.');
                        else
                            if oo(1).useSpeech
                                Speak('Optimizing resolution.');
                            end
                            Screen('CloseAll');
                            warning backtrace off
                            warning('Trying to change your screen resolution to be optimal for this test.');
                            warning backtrace on
                            oo(1).oldResolution=Screen('Resolution',oo(1).screen,oo(1).nativeWidth,oo(1).nativeHeight);
                            res=Screen('Resolution',oo(1).screen);
                            if res.width==oo(1).nativeWidth
                                oo(1).permissionToChangeResolution=true;
                                fprintf('SUCCESS!\n');
                            else
                                warning('FAILED.');
                                res
                            end
                            actualScreenRect=Screen('Rect',oo(1).screen,1);
                            window=OpenWindow(oo(1));
                            scratchWindow=Screen('OpenOffscreenWindow',-1,[],screenRect,8);
                            oo(1).resolution=Screen('Resolution',oo(1).screen);
                            screenBufferRect=Screen('Rect',oo(1).screen);
                            screenRect=Screen('Rect',oo(1).screen,1);
                            %                      fprintf('%d: NEW RES: actualScreenRect %.0f, screenBufferRect %.0f, screenRect %.0f\n',...
                            %                          1,actualScreenRect(3),screenBufferRect(3),screenRect(3));
                            
                            for ii=1:conditions
                                oo(ii).stimulusRect=screenRect;
                                if oo(ii).showProgressBar
                                    progressBarRect=[round(screenRect(3)*0.98) 0 screenRect(3) screenRect(4)]; % 2% of screen width.
                                    oo(ii).stimulusRect(3)=progressBarRect(1);
                                end
                                clearRect=oo(ii).stimulusRect;
                                if oo(ii).stimulusMarginFraction>0
                                    s=oo(ii).stimulusMarginFraction*oo(ii).stimulusRect;
                                    s=round(s);
                                    oo(ii).stimulusRect=InsetRect(oo(ii).stimulusRect,RectWidth(s),RectHeight(s));
                                end
                            end
                            
                        end
                    case 'k'
                        if oo(1).useSpeech
                            Speak('Recreating list of keyboards.');
                        end
                    otherwise
                        Speak(sprintf('Illegal entry "%s". Try again.',d));
                end
            end
        else
            break;
        end
    end % while true
    ListenChar(0); % flush
    ListenChar(2); % no echo
    
    % Ask experimenter name
    preface='';
    while length(oo(1).experimenter)<3
        Screen('FillRect',window);
        Screen('TextFont',window,oo(1).textFont,0);
        Screen('TextSize',window,oo(1).textSize);
        % Name of experimenter.
        [x,y]=DrawFormattedText(window,...
            [preface 'Please slowly type the name of the Experimenter '...
            'who is supervising, followed by RETURN.'],...
            2*oo(1).textSize,2.5*oo(1).textSize,black,...
            oo(1).textLineLength,[],[],1.3);
        scalar=0.35;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        Screen('DrawText',window,double(copyright),2*oo(1).textSize,screenRect(4)-0.5*scalar*oo(1).textSize,black,white,1);
        Screen('TextSize',window,oo(1).textSize);
        if IsWindows
            background=[];
        else
            background=WhiteIndex(window);
        end
        DrawCounter(oo);
        [name,terminatorChar]=GetEchoString(window,'Experimenter name:',...
            2*oo(1).textSize,0.82*screenRect(4),black,...
            background,1,oo(1).deviceIndex);
        if length(name)<3
            preface=['Sorry. ''' name ''' is not enough. This name must have at least 3 characters. '];
            continue
        end
        for i=1:conditions
            oo(i).experimenter=name;
        end
        if ismember(terminatorChar,[escapeChar graveAccentChar])
            [oo,tryAgain]=ProcessEscape(oo);
            if tryAgain
                continue
            else
                oo=SortFields(oo);
                return
            end
        end
    end % while length(oo(1).experimenter)<3
    
    % Ask observer name
    preface=['Hello Observer. Please slowly type your full name. '];
    while isempty(oo(1).observer)
        Screen('FillRect',window,white);
        Screen('TextSize',window,oo(1).textSize);
        Screen('TextFont',window,oo(1).textFont,0);
        Screen('DrawText',window,'',2*oo(1).textSize,screenRect(4)/2-4.5*oo(1).textSize,black,white);
        text=[preface 'Type your first and last names, separated by a SPACE. '...
            'Then hit RETURN.'];
        % Name of observer.
        [~,y]=DrawFormattedText(window,text,...
            2*oo(1).textSize,2.5*oo(1).textSize,black,...
            oo(1).textLineLength,[],[],1.3);
        scalar=0.7;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        % Explain how to type name.
        DrawFormattedText(window,...
            ['Please type your full name, like "Jane Doe" or "John Smith", '...
            'in exactly the same way every time. '...
            'If you don''t have a first name, '...
            'you still need the SPACE before your last name. '...
            'In the following blocks, I''ll remember your answers and skip these questions.'],...
            2*oo(1).textSize,y+1.5*scalar*oo(1).textSize,black,...
            oo(1).textLineLength/scalar,[],[],1.3);
        scalar=0.35;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        Screen('TextSize',window,sz);
        Screen('DrawText',window,double(copyright),...
            2*oo(1).textSize,screenRect(4)-0.5*scalar*oo(1).textSize,black,white,1);
        Screen('TextSize',window,oo(1).textSize);
        if IsWindows
            background=[];
        else
            background=WhiteIndex(window);
        end
        DrawCounter(oo);
        [name,terminatorChar]=GetEchoString(window,'Observer name:',...
            2*oo(1).textSize,0.82*screenRect(4),...
            black,background,1,oo(1).deviceIndex);
        if ismember(terminatorChar,[escapeChar graveAccentChar])
            [oo,tryAgain]=ProcessEscape(oo);
            if tryAgain
                continue
            else
                oo=SortFields(oo);
                return
            end
        end
        if length(split(name))<2
            preface=['Sorry. ''' name ''' is not enough. Please enter your first and last names. '];
            continue
        end
        for i=1:conditions
            oo(i).observer=name;
        end
        Screen('FillRect',window);
    end % while isempty(oo(1).observer)
    
    %% IF CHANGED, ASK EXPERIMENTER TO SET VIEWING DISTANCE
    isNewDistance=oo(1).isFirstBlock || oo(1).viewingDistanceCm ~= oldViewingDistanceCm;
    if isNewDistance
        if oo(1).askExperimenterToSetDistance
            string=sprintf(['NEW DISTANCE! Please ask the experimenter to adjust the viewing distance. The ' ...
                'X below should be %.1f cm (%.1f inches) from the observer''s eye. '], ...
                oo(1).viewingDistanceCm,oo(1).viewingDistanceCm/2.54);
        else
            string=sprintf(['NEW DISTANCE! Please adjust the viewing distance so that the ' ...
                'X below is %.1f cm (%.1f inches) from the observer''s eye. '], ...
                oo(1).viewingDistanceCm,oo(1).viewingDistanceCm/2.54);
        end
    else
        string=sprintf(['If necessary, please adjust the viewing distance so that the ' ...
            'X below is still %.1f cm (%.1f inches) from the observer''s eye. '], ...
            oo(1).viewingDistanceCm,oo(1).viewingDistanceCm/2.54);
    end
    oldViewingDistanceCm=oo(1).viewingDistanceCm;
    %    string=[string 'Tilt and swivel the display so the X is orthogonal to the observer''s line of sight. '];
    %    isNewDistance
    %    o.askExperimenterToSetDistance
    if isNewDistance && oo(1).askExperimenterToSetDistance
        string=[string 'Then the Experimenter will type his or her signature key to continue.\n'];
    else
        string=[string 'Then hit RETURN to continue.\n'];
    end
    oo(1).window=window;
    Screen('TextSize',oo(1).window,oo(1).textSize);
    Screen('TextFont',oo(1).window,'Verdana');
    Screen('FillRect',oo(1).window);
    %     Screen('TextBackgroundColor',oo(1).window,oo(1).gray1); % Set background.
    DrawFormattedText(oo(1).window,string,...
        2*oo(1).textSize,2.5*oo(1).textSize,black,...
        oo(1).textLineLength,[],[],1.3);
    x=oo(1).nearPointXYPix(1);
    y=oo(1).nearPointXYPix(2);
    a=0.05*RectHeight(oo(1).stimulusRect);
    [~,~,lineWidthMinMaxPix(1),lineWidthMinMaxPix(2)]=Screen('DrawLines',oo(1).window);
    widthPix=max([min([a/20 lineWidthMinMaxPix(2)]) lineWidthMinMaxPix(1)]);
    Screen('DrawLine',oo(1).window,black,x-a,y-a,x+a,y+a,widthPix);
    Screen('DrawLine',oo(1).window,black,x+a,y-a,x-a,y+a,widthPix);
    DrawCounter(oo);
    Screen('Flip',oo(1).window); % Display request.
    oo(1).speakInstructions=false;
    if oo(1).speakInstructions
        string=strrep(string,'.0','');
        string=strrep(string,'\n','');
        Speak(string);
    end
    if isNewDistance && oo(1).askExperimenterToSetDistance
        allowedCode=KbName(oo(1).experimenter(1));
    else
        allowedCode=returnKeyCode;
    end
    response=GetKeypress([allowedCode escapeKeyCode graveAccentKeyCode],oo(1).deviceIndex);
    if ismember(response,[escapeChar,graveAccentChar])
        [oo(1).quitExperiment,oo(1).quitBlock,oo(1).skipTrial]=...
            OfferEscapeOptions(oo(1).window,o);
        if oo(1).quitExperiment
            ffprintf(ff,'*** User typed ESCAPE twice. Experiment terminated.\n');
            oo=SortFields(oo);
            return
        elseif oo(1).quitBlock
            ffprintf(ff,'*** User typed ESCAPE. Block terminated.\n');
            oo=SortFields(oo);
            return
        else
            ffprintf(ff,'*** User typed ESCAPE, but chose to continue.\n');
        end
    else
        set=true; % Done.
        oldViewingDistanceCm=oo(1).viewingDistanceCm;
    end
    Screen('FillRect',oo(1).window);
    Screen('Flip',oo(1).window); % Blank, to acknowledge response.
    
    %% START TIMER
    oo(1).beginSecs=GetSecs;
    oo(1).beginningTime=now;
    timeVector=datevec(oo(1).beginningTime);
    
    %% SAVE SCRIPT
    stack=dbstack;
    assert(~isempty(stack));
    if length(stack)==1
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
    
    %% CREATE SNAPSHOT FOLDER
    oo(1).snapshotsFolder=fullfile(mainFolder,'snapshots');
    if ~exist(oo(1).snapshotsFolder,'dir')
        [success,msg]=mkdir(oo(1).snapshotsFolder);
        if ~success
            error('%s. Could not create snapshots folder: %s',msg,oo(1).snapshotsFolder);
        end
    end
    
    %% CREATE DATA FILE
    oo(1).dataFilename=sprintf('%s-%s-%s.%d.%d.%d.%d.%d.%d',...
        oo(1).functionNames,oo(1).experimenter,oo(1).observer,round(timeVector));
    oo(1).dataFolder=fullfile(mainFolder,'data');
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
    
    
    %% WRITE LOG
    ffprintf(ff,'<strong>o.experiment ''%s''</strong>, block %d of %d\n',...
        oo(1).experiment,oo(1).block,oo(1).blocksDesired);
    ffprintf(ff,'%s %s. ',oo(1).functionNames,datestr(now));
    ffprintf(ff,'Saving results in:\n');
    ffprintf(ff,'/data/%s.txt and "".mat\n',oo(1).dataFilename);
    ffprintf(ff,'Keep both files, .txt and .mat, readable by humans and machines.\n');
    for oi=2:length(oo)
        oo(oi).dataFilename=oo(1).dataFilename;
        oo(oi).dataFolder=oo(1).dataFolder;
        oo(oi).beginningTime=oo(1).beginningTime;
    end
    if any([oo.recordGaze])
        videoExtension='.avi'; % '.avi', '.mp4' or '.mj2'
        clear cam
        cam=webcam;
        gazeFile=fullfile(oo(1).dataFolder,[oo(1).dataFilename videoExtension]);
        vidWriter=VideoWriter(gazeFile);
        vidWriter.FrameRate=1; % frame/s.
        open(vidWriter);
        ffprintf(ff,'Recording gaze of conditions %s with extension %s\n',...
            num2str(find([oo.recordGaze])),videoExtension);
    end
    if oo(1).useFractionOfScreenToDebug
        ffprintf(ff,'WARNING: Using o.useFractionOfScreenToDebug. This may invalidate all results.\n');
    end
    if oo(1).skipScreenCalibration
        ffprintf(ff,'WARNING: Using o.skipScreenCalibration. This may invalidate all results.\n');
    end
    if ~isempty(oo(1).drawTextWarning) && ~oo(oi).getAlphabetFromDisk
        ffprintf(ff,'Warning from Screen(''DrawText''...):\n%s\n',oo(1).drawTextWarning);
    end
    for oi=1:conditions
        if ~isempty(oo(oi).unknownFields)
            error(['%d: Unknown o fields:' sprintf(' %s',oo(oi).unknownFields{:})],oi);
        end
    end
    ffprintf(ff,':: <strong>%s:%s: %s</strong>\n',oo(1).experiment,oo(1).experimenter,oo(1).observer);
    for oi=1:conditions
        % Print names and eccentricities of all conditions.
        if ~isempty([oo.conditionName])
            ffprintf(ff,'%d: o.conditionName <strong>''%s''</strong>, o.eccentricityXYDeg [%.0f %.0f]\n',...
                oi,oo(oi).conditionName,oo(oi).eccentricityXYDeg);
        end
    end
    for oi=1:conditions % Prepare all the conditions.
        if oo(oi).repeatedTargets
            % The observer reports two targets on each presentation, so we
            % get two trials per presentation.
            oo(oi).presentations=ceil(oo(oi).trialsDesired/2)+oo(oi).practicePresentations;
            oo(oi).trialsDesired=2*oo(oi).presentations;
        else
            oo(oi).presentations=oo(oi).trialsDesired;
        end
        ecc=norm(oo(oi).eccentricityXYDeg);
        if isempty(oo(oi).flankingDegVector) && ecc==0 && ismember(oo(oi).flankingDirection,{'radial' 'tangential'})
            error('At zero o.eccentricityXYDeg, o.flankingDirection must be ''horizontal'' or ''vertical'', not ''%s''.',...
                oo(oi).flankingDirection);
        end
        if isempty(oo(oi).flankingDegVector) && ecc>0 && ismember(oo(oi).flankingDirection,{'horizontal' 'vertical'})
            % Currently, allowing 'horizonal' at nonzero ecc +10 deg would
            % result in tangential (i.e. vertical) flankers, which would be
            % reported as "horizontal". So we insist on just 'radial' or
            % 'tangential'.
            error('At nonzero o.eccentricityXYDeg, o.flankingDirection must be "radial'' or ''tangential'', not ''%s''.',...
                oo(oi).flankingDirection);
        end
        oo(oi).eccentricityDegVector=oo(oi).eccentricityXYDeg/norm(oo(oi).eccentricityXYDeg);
        % We consult the o.flankingDirection string only if the user has
        % not provided o.flankingDegVector.
        if isempty(oo(oi).flankingDegVector)
            switch oo(oi).flankingDirection
                case 'radial'
                    oo(oi).flankingDegVector=oo(oi).eccentricityDegVector;
                case 'tangential'
                    oo(oi).flankingDegVector=oo(oi).eccentricityDegVector*rotate90;
                case 'horizontal'
                    oo(oi).flankingDegVector=[1 0];
                case 'vertical'
                    oo(oi).flankingDegVector=[0 1];
                otherwise
                    error('Unknown o.flankingDirection ''%s''.',oo(oi).flankingDirection);
            end
        end
        if oo(oi).repeatedTargets
            if oo(oi).targetSizeIsHeight
                oo(oi).flankingDegVector=[1 0];
            else
                oo(oi).flankingDegVector=[0 1];
            end
        end
        if isempty(oo(oi).flankingDegVector)
            error('o.flankingDegVector is empty.');
        end
        % From here on we consider o.flankingDegVector primary, and derive
        % frfom it a rough o.flankingDirection. I need the rough
        % o.flankingDirection for print outs and to keep old code that I
        % don't have time to update right now.
        if ecc==0
            if abs(oo(oi).flankingDegVector(1)/oo(oi).flankingDegVector(2))>1
                oo(oi).flankingDirection='horizontal';
            else
                oo(oi).flankingDirection='vertical';
            end
        else
            if norm(oo(oi).flankingDegVector.*oo(oi).eccentricityDegVector)>0.7
                oo(oi).flankingDirection='radial';
            else
                oo(oi).flankingDirection='tangential';
            end
        end % if ecc==0
        % Prepare to draw fixation cross.
        fixationCrossPix=round(oo(oi).fixationCrossDeg*pixPerDeg);
        fixationLineWeightPix=round(oo(oi).fixationLineWeightDeg*pixPerDeg);
        fixationLineWeightPix=max(1,fixationLineWeightPix);
        fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
        oo(oi).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
        oo(oi).fix.clipRect=screenRect;
        oo(oi).fix.fixationCrossPix=fixationCrossPix;
        oo(oi).fix.xy=XYPixOfXYDeg(oo(oi),[0 0]); % Fixation screen location.
        oo(oi).eccentricityXYPix=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg)-oo(oi).fix.xy;
        oo(oi).fix.eccentricityXYPix=oo(oi).eccentricityXYPix;
        
        oo(oi).responseCount=1; % When we have two targets we get two responses for each display.
        if streq(oo(oi).thresholdParameter,'size')
            if isfield(oo(oi),'targetGuessDeg') && isfinite(oo(oi).targetGuessDeg)
                oo(oi).targetDeg=oo(oi).targetGuessDeg;
            else
                oo(oi).targetDeg=2*oo(oi).normalAcuityDeg; % initial guess for threshold size.
            end
        end
        if oi==1
            for ii=1:conditions
                if oo(ii).repeatedTargets
                    oo(ii).useFixation=false;
                end
                oo(ii).textSizeDeg = oo(ii).textSize/oo(1).pixPerDeg;
                oo(ii).speakInstructions=oo(ii).useSpeech;
            end
        end
        
        %% Location of near point, fixation, and target.
        oo=SetUpFixation(window,oo,oi,ff); %  o.targetXYPix, fixationOffsetXYCm, o.nearPointXYPix
        
        %% Crowding distances.
        addOnDeg=0.15;
        addOnPix=pixPerDeg*addOnDeg;
        oo(oi).normalCrowdingDistanceDeg=0.3*(ecc+0.15); % from Pelli et al. (2017).
        % If flanking direction is orthogonal to eccentricity direction,
        % then halve the expected crowding distance. A fully developed
        % model would deal with all possible differences in orientation.
        if ecc>0 && norm(oo(oi).flankingDegVector.*oo(oi).eccentricityDegVector)<0.7
            % Tangential crowding distance is half radial.
            oo(oi).normalCrowdingDistanceDeg=oo(oi).normalCrowdingDistanceDeg/2; % Toet and Levi.
        end
        if isfield(oo(oi),'spacingGuessDeg') && isfinite(oo(oi).spacingGuessDeg)
            oo(oi).spacingDeg=oo(oi).spacingGuessDeg;
        else
            oo(oi).spacingDeg=oo(oi).normalCrowdingDistanceDeg; % initial guess for distance from center of middle letter
        end
        switch oo(oi).task
            case 'read'
                oo(oi).spacingDeg=oo(oi).readSpacingDeg;
        end
        oo(oi).spacings=oo(oi).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
        oo(oi).spacingsSequence=repmat(oo(oi).spacings,1,...
            ceil(oo(oi).presentations/length(oo(oi).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of presentations.
        switch oo(oi).thresholdParameter
            case 'size'
                if oo(oi).targetSizeIsHeight
                    ori='vertical';
                else
                    ori='horizontal';
                end
            case 'spacing'
                if ~oo(oi).repeatedTargets
                    ori=oo(oi).flankingDirection;
                else
                    if oo(oi).targetSizeIsHeight
                        ori='vertical';
                    else
                        ori='horizontal';
                    end
                end
        end % switch oo(oi).thresholdParameter
        if oo(oi).useQuest
            ffprintf(ff,'%d: %.0f trials of QUEST will measure threshold %s %s.\n',oi,oo(oi).trialsDesired,ori,oo(oi).thresholdParameter);
        else
            ffprintf(ff,'%d: %.0f trials of "method of constant stimuli" with fixed list of %s spacings [',oi,oo(oi).trialsDesired,ori);
            ffprintf(ff,'%.1f ',oo(oi).spacings);
            ffprintf(ff,'] deg\n');
        end
        
        %% Measure targetHeightOverWidth
        oo(oi).targetFontHeightOverNominal=nan;
        oo(oi).targetPix=200; % Font size.
        % Get bounds.
        % This is quick for small letter size, under 100, but can take many
        % seconds for a font size of 300.
        [letterStruct,alphabetBounds]=CreateLetterTextures(oi,oo(oi),window);
        DestroyLetterTextures(letterStruct);
        % This aspect ratio is based on bounding box of the whole alphabet.
        % It may not be typical of individual characters.
        oo(oi).targetHeightOverWidth=RectHeight(alphabetBounds)/RectWidth(alphabetBounds);
        if ~oo(oi).getAlphabetFromDisk
            oo(oi).targetFontHeightOverNominal=RectHeight(alphabetBounds)/oo(oi).targetPix;
        end
        oo(oi).targetPix=oo(oi).targetDeg*pixPerDeg;
        
        % Set o.targetHeightOverWidth
        if oo(oi).setTargetHeightOverWidth
            oo(oi).targetHeightOverWidth=oo(oi).setTargetHeightOverWidth;
        end
        
        % Make list of valid response key codes.
        for cond=1:conditions
            for i=1:length(oo(cond).validKeyNames)
                oo(cond).responseKeyCodes(i)=KbName(oo(cond).validKeyNames{i}); % this returns keyCode as integer
            end
        end
        
        % Prepare to draw fixation cross.
        oo(oi).fix.eccentricityXYPix=oo(oi).eccentricityXYPix;
        assert(all(isfinite(oo(oi).fix.eccentricityXYPix)));
        oo(oi).fix.clipRect=screenRect;
        oo(oi).fix.fixationCrossPix=fixationCrossPix; % Diameter of fixation cross.
        oo(oi).fix.fixationLineMinimumLengthPix= ...
            round(oo(oi).fixationLineMinimumLengthDeg*oo(oi).pixPerDeg);
        if oo(oi).markTargetLocation
            oo(oi).fix.markTargetLocationPix=oo(oi).targetDeg*pixPerDeg*2;
        else
            oo(oi).fix.markTargetLocationPix=0;
        end
        oo(oi).fix.targetHeightPix=round(oo(oi).targetDeg*pixPerDeg);
        if oo(oi).fixationCrossBlankedNearTarget
            oo(oi).fix.blankingRadiusPix=[]; % Automatic.
        else
            oo(oi).fix.blankingRadiusPix=0; % None.
        end
        % Calling ComputeFixationLines2 now (it's quick) just to make sure
        % it works. We'll call it again (line 2629), with the same
        % argument, during each trial of this condition.
        fixationLines=ComputeFixationLines2(oo(oi).fix);
        
        oo(1).quitBlock=false;
        
        switch oo(oi).thresholdParameter
            case 'spacing'
                assert(oo(oi).spacingDeg>0);
                oo(oi).tGuess=log10(oo(oi).spacingDeg);
            case 'size'
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
    end % for oi=1:conditions % Prepare all the conditions.
    
    cal.screen=max(Screen('Screens'));
    if cal.screen>0
        ffprintf(ff,'Using external monitor.\n');
    end
    for oi=1:conditions
        ffprintf(ff,'%d: ',oi);
        if oo(oi).repeatedTargets
            numberTargets=sprintf('two targets (repeated many times over %.0f lines)',oo(oi).maxLines);
        else
            numberTargets='one target';
        end
        string=sprintf('%s %s, alternatives %d,  beta %.1f\n',oo(oi).task,numberTargets,length(oo(oi).alphabet),oo(oi).beta);
        string(1)=upper(string(1));
        ffprintf(ff,'%s',string);
    end
    for oi=1:conditions
        switch oo(oi).relationOfSpacingToSize
            case 'fixed ratio'
                ffprintf(ff,'%d: Fixed ratio of spacing over size %.2f.\n',oi,oo(oi).fixedSpacingOverSize);
            case 'none'
                switch oo(oi).thresholdParameter
                    case 'size'
                        ffprintf(ff,'%d: Measuring threshold size, with no flankers.\n',oi);
                    case 'spacing'
                        ffprintf(ff,'%d: Target size %.2f deg, %.1f pixels.\n',oi,oo(oi).targetDeg,oo(oi).targetDeg*pixPerDeg);
                        if ~isfinite(oo(oi).targetDeg)
                            error('To measure threshold spacing you must specify either o.fixedSpacingOverSize or o.targetDeg.');
                        end
                end
            case 'fixed by font'
        end
    end % for oi=1:conditions
    for oi=1:conditions
        switch oo(oi).thresholdParameter
            case 'size'
                ffprintf(ff,'%d: Viewing distance %.0f cm. (Must exceed %.0f cm to produce %.3f deg target.)\n',...
                    oi,oo(oi).viewingDistanceCm,oo(oi).minimumViewingDistanceCm,oo(oi).normalAcuityDeg/2);
            case 'spacing'
                ffprintf(ff,'%d: Viewing distance %.0f cm. (Must exceed %.0f cm to produce %.2f deg spacing.)\n',...
                    oi,oo(oi).viewingDistanceCm,oo(oi).minimumViewingDistanceCm,oo(oi).normalCrowdingDistanceDeg/2);
        end
    end
    s=sprintf([':: Needing screen size of at least %.0fx%.0f deg, ' ...
        'you should view from at most'],minimumScreenSizeXYDeg);
    if maximumViewingDistanceCm<100
        s=sprintf('%s %.0f cm.\n',s,maximumViewingDistanceCm);
    else
        s=sprintf('%s %.1f m.\n',s,maximumViewingDistanceCm/100);
    end
    ffprintf(ff,'%s',s);
    ffprintf(ff,':: %d keyboards: ',length(oo(1).keyboardNameAndTransport));
    for i=1:length(oo(1).keyboardNameAndTransport)
        ffprintf(ff,'%s,  ',oo(1).keyboardNameAndTransport{i});
    end
    ffprintf(ff,'\n');
    for oi=1:conditions
        sizesPix=oo(oi).minimumTargetPix*[oo(oi).targetHeightOverWidth 1];
        ffprintf(ff,'%d: Minimum letter size %.0fx%.0f pix, %.3fx%.3f deg. ',...
            oi,sizesPix,sizesPix/pixPerDeg);
        switch oo(oi).relationOfSpacingToSize
            case 'fixed ratio'
                spacingPix=round(oo(oi).minimumTargetPix*oo(oi).fixedSpacingOverSize);
                ffprintf(ff,'Minimum spacing %.0f pix, %.3f deg.\n',...
                    spacingPix,spacingPix/pixPerDeg);
            case 'none'
                switch oo(oi).thresholdParameter
                    case 'size'
                        ffprintf(ff,'Spacing %.0f pixels, %.3f deg.\n',...
                            oo(oi).spacingPix,oo(oi).spacingDeg);
                    case 'spacing'
                        ffprintf(ff,'Size %.0f pixels, %.3f deg.\n',...
                            oo(oi).targetPix,oo(oi).targetDeg);
                end
            case 'fixed by font'
        end
    end
    for oi=1:conditions
        if oo(oi).getAlphabetFromDisk
            fontString='font from disk';
        else
            fontString='font, live';
        end
        ffprintf(ff,'%d: "%s" %s. ',oi,oo(oi).targetFont,fontString);
        ffprintf(ff,'o.minimumTargetPix %d. ',oo(oi).minimumTargetPix);
        ffprintf(ff,'Alphabet ''%s'' and borderLetter ''%s''.\n',oo(oi).alphabet,oo(oi).borderLetter);
    end
    for oi=1:conditions
        ffprintf(ff,'%d: o.targetHeightOverWidth %.2f, targetFontHeightOverNominal %.2f\n',...
            oi,oo(oi).targetHeightOverWidth,oo(oi).targetFontHeightOverNominal);
    end
    for oi=1:conditions
        ffprintf(ff,'%d: durationSec %.2f, eccentricityXYDeg [%.1f %.1f]\n',...
            oi,oo(oi).durationSec,oo(oi).eccentricityXYDeg);
    end
    
    % Identify the computer
    cal.screen=0;
    computer=Screen('Computer');
    computer.system=strrep(computer.system,'Mac OS','macOS'); % Modernize the spelling.
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
    if isfinite(oo(oi).brightnessSetting)
        cal.brightnessSetting=oo(oi).brightnessSetting;
    else
        cal.brightnessSetting=0.87; % default value
    end
    cal.brightnessRMSError=0; % default value
    [screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
    cal.screenWidthCm=screenWidthMm/10;
    actualScreenRect=Screen('Rect',cal.screen,1);
    %    ffprintf(ff,'Screen width buffer %d, display %d. ',RectWidth(Screen('Rect',cal.screen)),RectWidth(Screen('Rect',cal.screen,1)));
    %    ffprintf(ff,'Window width buffer %d, display %d.\n',RectWidth(Screen('Rect',window)),RectWidth(Screen('Rect',window,1)));
    if oo(1).flipScreenHorizontally
        ffprintf(ff,'Using mirror. ');
    end
    ffprintf(ff,':: Viewing distance %.0f cm,',oo(1).viewingDistanceCm);
    xy=oo(oi).stimulusRect(3:4)-oo(oi).stimulusRect(1:2); % width and height
    xyDeg=2*atand(0.5*xy/oo(1).pixPerCm/oo(1).viewingDistanceCm);
    ffprintf(ff,' %.0f pixPerDeg, %.0f pix/cm.\n',...
        pixPerDeg,RectWidth(actualScreenRect)/(screenWidthMm/10));
    ffprintf(ff,':: Screen %d, %dx%d pixels (%dx%d native), %.1fx%.1f cm, %.1fx%.1f deg.\n',...
        cal.screen,RectWidth(actualScreenRect),RectHeight(actualScreenRect),...
        oo(1).nativeWidth,oo(1).nativeHeight,...
        screenWidthMm/10,screenHeightMm/10,xyDeg);
    ffprintf(ff,':: %s, "%s", %s\n',cal.macModelName,cal.localHostName,cal.processUserLongName);
    oo(1).matlab=version;
    [~,oo(1).psychtoolbox]=PsychtoolboxVersion;
    v=oo(1).psychtoolbox;
    ffprintf(ff,':: %s, MATLAB %s, Psychtoolbox %d.%d.%d\n',computer.system,oo(1).matlab,v.major,v.minor,v.point);
    assert(cal.screenWidthCm==screenWidthMm/10);
    if oo(1).isFirstBlock && ~oo(1).skipScreenCalibration
        %% SET BRIGHTNESS, COPIED FROM NoiseDiscrimination
        % Currently, in December 2018, my Brightness function writes
        % reliably but seems to always fail when reading, returning -1. So
        % we use my function to write (since Screen is unreliable there)
        % and use Screen to read (since my Brightness is failing to read).
        % By the way, the Screen function is quick writing and reading
        % while my function is very slow (20 s) writing and reading.
        useBrightnessFunction=0;
        if useBrightnessFunction
            if ~IsWin
                Screen('FillRect',window);
                Screen('TextSize',window,oo(1).textSize);
                Screen('DrawText',window,'Setting brightness ...',...
                    2*oo(1).textSize,2.5*oo(1).textSize);
                DrawCounter(oo);
                Screen('Flip',window);
                ffprintf(ff,'%d: Brightness. ... ',MFileLineNr); s=GetSecs;
                Brightness(cal.screen,cal.brightnessSetting); % Set
                %                                               brightness.
                for i=1:5
                    % cal.brightnessReading=Brightness(cal.screen); % Read brightness.
                    cal.brightnessReading=Screen('ConfigureDisplay',...
                        'Brightness',cal.screen,cal.screenOutput);
                    if cal.brightnessReading>=0
                        break
                    end
                    % If it failed, try again. The first attempt sometimes
                    % fails. Not sure why. Maybe it times out.
                end
                ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
                % Darshan discovered that some MacBook Pros are missing by
                % a few percent, which doesn't matter, so I increased the
                % tolerance from 1% to 10%. DGP April 2019
                if isfinite(cal.brightnessReading) && abs(cal.brightnessSetting-cal.brightnessReading)>0.1
                    error('Set brightness to %.2f, but read back %.2f',...
                        cal.brightnessSetting,cal.brightnessReading);
                end
            end
        else
            % Caution: Screen ConfigureDisplay Brightness gives a fatal
            % error if not supported, and is unsupported on many devices,
            % including a video projector under macOS. We use try-catch to
            % recover. NOTE: It was my impression in summer 2017 that the
            % Brightness function (which uses AppleScript to control the
            % System Preferences Display panel) is currently more reliable
            % than the Screen ConfigureDisplay Brightness feature (which
            % uses a macOS call). The Screen call adjusts the brightness,
            % but not the slider in the Preferences Display panel, and
            % macOS later unpredictably resets the brightness to the level
            % of the slider, not what we asked for. This is a macOS bug in
            % the Apple call used by Screen.
            ffprintf(ff,'%d: Screen ConfigureDisplay Brightness. ... ',MFileLineNr); s=GetSecs;
            try
                if ~IsWin
                    for i=1:3
                        Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
                        cal.brightnessReading=Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput);
                        if abs(cal.brightnessSetting-cal.brightnessReading)<0.01
                            break;
                        elseif i==3
                            error('Tried three times to set brightness to %.2f, but read back %.2f',...
                                cal.brightnessSetting,cal.brightnessReading);
                        end
                    end
                end
            catch e
                warning('Screen ConfigureDisplay Brightness failed.');
                warning(e.message);
                cal.brightnessReading=NaN;
            end
            ffprintf(ff,'Done (%.1f s)\n',GetSecs-s);
            % END OF SET BRIGHTNESS
        end
    end
    
    skipScreenCalibration=oo(1).skipScreenCalibration; % Global for CloseWindowsAndCleanup.
    
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
    usingDigits=false;
    usingLetters=false;
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
    if ~isempty(oo(oi).observer)
        string=[sprintf('Hello %s. ',oo(oi).observer)];
    else
        string='Hello. ';
    end
    string=[string 'Please make sure this computer''s sound is enabled. ' ...
        'Press CAPS LOCK at any time to see the alphabet of possible letters. ' ...
        'You might also have the alphabet on a piece of paper. ' ...
        'You can respond by typing or speaking, ' ...
        'or by pointing to a letter on your piece of paper. '];
    for oi=1:conditions
        if ~oo(oi).repeatedTargets && streq(oo(oi).thresholdParameter,'size')
            string=[string 'When you see a letter, please report it. '];
            break;
        end
    end
    for oi=1:conditions
        if ~oo(oi).repeatedTargets && streq(oo(oi).thresholdParameter,'spacing') && ~streq(oo(oi).task,'read')
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
    if ~any([oo.useFixation])
        string=[string 'Look in the middle of the screen, ignoring the edges of the screen. '];
    end
    string=[string 'To continue, please hit RETURN. '];
    tryAgain=true;
    while tryAgain
        scalar=0.35;
        sz=round(scalar*oo(1).textSize);
        scalar=sz/oo(1).textSize;
        Screen('TextSize',window,sz);
        Screen('TextFont',window,oo(oi).textFont,0);
        Screen('DrawText',window,double(copyright),2*oo(1).textSize,screenRect(4)-0.5*scalar*oo(1).textSize,black,white,1);
        Screen('TextSize',window,oo(oi).textSize);
        string=strrep(string,'letter',symbolName);
        % General instructions.
        DrawFormattedText(window,string,...
            2*oo(1).textSize,2.5*oo(1).textSize,black,...
            oo(oi).textLineLength,[],[],1.3);
        DrawCounter(oo);
        Screen('Flip',window,[],1);
        if false && oo(oi).useSpeech
            string=strrep(string,'\n','');
            string=strrep(string,'eye(s)','eyes');
            Speak(string);
        end
        SetMouse(screenRect(3),screenRect(4),window);
        answer=GetKeypressWithHelp([returnKeyCode escapeKeyCode graveAccentKeyCode],...
            oo(oi),window,oo(oi).stimulusRect);
        Screen('FillRect',window);
        tryAgain=false;
        if ismember(answer,[escapeChar graveAccentChar])
            [oo,tryAgain]=ProcessEscape(oo);
            if tryAgain
                continue
            else
                oo=SortFields(oo);
                return
            end
        end
    end % while tryAgain
    string='';
    
    % This tryAgain loop presents instructions and waits for RETURN.
    tryAgain=true;
    while tryAgain
        if oo(oi).showProgressBar
            string=[string 'Notice the green progress bar on the right. '...
                'It will rise as you proceed, and reach the top '...
                'when you finish the block. '];
        end
        if true
            switch oo(1).task
                case 'read'
                    string=[string 'On each trial, you''ll read a paragraph. '];
                otherwise
                    string=[string 'On each trial, '...
                        'try to identify the target letter by typing that key. '];
            end
            if any([oo.useFixation])
                string=[string 'Please rest your eye on the cross before each trial. '];
            end
            if ~oo(oi).repeatedTargets ...
                    && streq(oo(oi).thresholdParameter,'spacing') ...
                    && ~streq(oo(oi).task,'read')
                string=[string 'When you see three letters, please report just the middle one. '];
            end
            if false
                if oo(1).fixationOnScreen
                    where='below';
                else
                    polarDeg=atan2d(-oo(1).nearPointXYDeg(2),-oo(1).nearPointXYDeg(1));
                    quadrant=round(polarDeg/90);
                    quadrant=mod(quadrant,4);
                    switch quadrant
                        case 0
                            where='to the right';
                        case 1
                            where='above';
                        case 2
                            where='to the left';
                        case 3
                            where='below';
                    end
                end
            end
            string=[string 'To continue hit RETURN. '];
            string=strrep(string,'letter',symbolName);
            Screen('TextSize',window,oo(oi).textSize);
            Screen('TextBackgroundColor',window,white); % Set background.
            % 'Notice the green progress bar ... hit RETURN.
            DrawFormattedText(window,string,...
                2*oo(oi).textSize,2.5*oo(oi).textSize,black,...
                oo(oi).textLineLength,[],[],1.3);
            string='';
            DrawCounter(oo);
            % 'Notice the green progress bar ... hit RETURN.
            Screen('Flip',window,[],1); % Don't clear buffer.
            if oo(oi).takeSnapshot
                TakeSnapshot(oo);
            end
            answer=GetKeypressWithHelp([returnKeyCode escapeKeyCode graveAccentKeyCode],...
                oo(oi),window,oo(oi).stimulusRect);
            Screen('FillRect',window);
            tryAgain=false;
            if ismember(answer,[escapeChar graveAccentChar])
                [oo,tryAgain]=ProcessEscape(oo);
                if tryAgain
                    continue
                else
                    oo=SortFields(oo);
                    return
                end
            end
        else
            tryAgain=false;
        end % if any ([oo.useFixation])
    end % while tryAgain
    
    
    % Remind to fixate, then wait for RETURN.
    if any([oo.useFixation]) && ~ismember(oo(1).task,{'read'}) && ~oo(1).repeatedTargets
        tryAgain=true;
        while tryAgain
            string=['IMPORTANT: Please resist the temptation to type your response as '...
                'soon as you find a matching response letter. '...
                'Instead, please hold off responding until your eye is back on the cross. '...
                'Always wait until you''re fixating the cross before responding. '...
                'To continue hit RETURN. '];
            Screen('TextSize',window,oo(oi).textSize);
            Screen('TextBackgroundColor',window,white); % Set background.
            % 'IMPORTANT: ... hit RETURN.
            %             Screen('TextStyle',window,1); % Bold
            Screen('TextFont',window,oo(oi).textFont,1);
            [fontName,fontNumber,fontStyle]=Screen('TextFont',window);
            fontSize=Screen('TextSize',window);
            fprintf('Important text is in %d-pt %s style %d.\n',...
                fontSize,fontName,fontStyle);
            % 0.9* because bold is wider, so fewer fit in line.
            % Please wait to respond until you're fixating.
            % This is still preface, before the main loop.
            DrawFormattedText(window,string,...
                2*oo(oi).textSize,2.5*oo(oi).textSize,[0 0 0],...
                0.9*oo(1).textLineLength,[],[],1.3);
            Screen('TextFont',window,oo(oi).textFont,0);
            %             Screen('TextStyle',window,0); % Plain
            string='';
            DrawCounter(oo);
            % 'IMPORTANT: ... hit RETURN.
            Screen('Flip',window,[],1); % Don't clear buffer.
            if oo(oi).takeSnapshot
                TakeSnapshot(oo);
            end
            answer=GetKeypressWithHelp([returnKeyCode escapeKeyCode graveAccentKeyCode],...
                oo(oi),window,oo(oi).stimulusRect);
            Screen('FillRect',window);
            tryAgain=false;
            if ismember(answer,[escapeChar graveAccentChar])
                [oo,tryAgain]=ProcessEscape(oo);
                if tryAgain
                    continue
                else
                    oo=SortFields(oo);
                    return
                end
            end
        end % while tryAgain
    end % if any([oo.useFixation])
    
    easeRequest=0; % Positive to request easier trials.
    easyCount=0; % Number of easy presentations
    guessCount=0; % Number of artificial guess responses
    skipCount=0;
    skipping=false;
    
    %% SET UP condList
    % For all conditions we include the specified number of presentations,
    % o.presentations, for that condition. For most conditions we simply
    % shuffle the list of conditions. The exception is that we always
    % begin with one trial of each condition for which oo(oi).fixationCheck
    % is true.
    condList=[];
    for oi=1:conditions
        % Run the specified number of presentations of each condition, in
        % random order
        if ~oo(oi).fixationCheck
            condList=[condList repmat(oi,1,oo(oi).presentations)];
        else
            % Hold back one instance to place at beginning.
            condList=[condList repmat(oi,1,oo(oi).presentations-1)];
        end
        oo(oi).spacingsSequence=shuffle(oo(oi).spacingsSequence);
        oo(oi).q=QuestCreate(oo(oi).tGuess,oo(oi).tGuessSd,oo(oi).pThreshold,oo(oi).beta,delta,gamma,grain,range);
        oo(oi).trialData=struct([]);
    end % for oi=1:conditions
    condList=shuffle(condList);
    for oi=conditions:-1:1
        if oo(oi).fixationCheck
            % Insert a fixationCheck at the beginning.
            condList=[oi condList];
        end
    end
    presentation=0;
    skipTrial=false;
    encourageFixation=false;
    encourageFixationString='';
    
    % THIS IS THE MAIN LOOP
    while presentation<length(condList)
        if skipTrial
            % We arrive here if user canceled last presentation. In that
            % case, we don't count that presentation and reshuffle all the
            % remaining conditions, including that of the last
            % presentation.
            % Strictly speaking, the presentation might have represented
            % two trials, but it's still one cancellation. Perhaps this
            % should be called presentationsSkipped.
            oo(oi).trialsSkipped=oo(oi).trialsSkipped+1;
            condList(presentation:end)=shuffle(condList(presentation:end));
        else
            presentation=presentation+1;
        end
        blockTrial=presentation; % For DrawCounter
        blockTrials=length(condList); % For DrawCounter
        oi=condList(presentation);
        
        easyModulus=ceil(1/oo(oi).fractionEasyTrials-1);
        easyPresentation= easeRequest>0 || mod(presentation-1,easyModulus)==0;
        if oo(oi).useQuest
            intensity=QuestQuantile(oo(oi).q);
            if oo(oi).measureBeta
                offsetToMeasureBeta=shuffle(offsetToMeasureBeta);
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
                case 'spacing'
                    % Compute maxSpacingDeg.
                    fixationXY=XYPixOfXYDeg(oo(oi),[0 0]);
                    targetXY=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg);
                    switch(oo(oi).flankingDirection)
                        case 'radial'
                            deltaXY=targetXY-fixationXY;
                        case 'tangential'
                            deltaXY=(targetXY-fixationXY)*rotate90;
                        case 'horizontal'
                            deltaXY=[1 0];
                        case 'vertical'
                            deltaXY=[0 1];
                    end
                    deltaXY=deltaXY/norm(deltaXY);
                    deltaXY=deltaXY*RectWidth(oo(oi).stimulusRect);
                    [far1XY,far2XY]=ClipLineSegment2(targetXY+deltaXY,targetXY-deltaXY,oo(oi).stimulusRect);
                    delta1XYDeg=XYDegOfXYPix(oo(oi),far1XY)-oo(oi).eccentricityXYDeg;
                    delta2XYDeg=XYDegOfXYPix(oo(oi),far2XY)-oo(oi).eccentricityXYDeg;
                    maxSpacingDeg=min(norm(delta1XYDeg),norm(delta2XYDeg));
                    maxSpacingDeg=maxSpacingDeg-oo(oi).targetDeg*0.75; % Assume flanker is about size of target.
                    maxSpacingDeg=max(0,maxSpacingDeg); % Stay positive.
                    % maxSpacingDeg is ready.
                    switch oo(oi).task
                        case 'read'
                            oo(oi).spacingDeg=oo(oi).readSpacingDeg;
                        otherwise
                            if ~oo(oi).fixationCheck
                                oo(oi).spacingDeg=min(10^intensity,maxSpacingDeg);
                            else
                                oo(oi).spacingDeg=0.3;
                            end
                    end
                    switch oo(oi).relationOfSpacingToSize
                        case 'fixed ratio'
                            oo(oi).targetDeg=oo(oi).spacingDeg/oo(oi).fixedSpacingOverSize;
                        case 'none'
                            oo(oi).spacingDeg=max(oo(oi).spacingDeg,1.1*oo(oi).targetDeg);
                        case 'fixed by font'
                    end
                case 'size'
                    if ~oo(oi).fixationCheck
                        oo(oi).targetDeg=10^intensity;
                    end
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
        if streq(oo(oi).thresholdParameter,'size')
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    oo(oi).spacingDeg=oo(oi).targetDeg*oo(oi).fixedSpacingOverSize;
                case 'none'
                case 'fixed by font'
            end
        end
        spacingPix=oo(oi).spacingDeg*pixPerDeg; % Now spacingPix is master.
        switch oo(oi).relationOfSpacingToSize
            case 'fixed ratio'
                spacingPix=max(spacingPix,oo(oi).minimumTargetPix*oo(oi).fixedSpacingOverSize);
            case 'none'
            case 'fixed by font'
        end
        if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetFontHeightOverNominal %.2f, targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',...
                oi,MFileLineNr,oo(oi).targetFontHeightOverNominal,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end
        % Screen and letter size vary hugely. For the trial to make sense,
        % we need to guarantee a certain minimum number of characters. We
        % achieve this by specifying the required number of spaces (plus
        % half at each side of screen) using minSpacesX or minSpacesY. If
        % necessary, the software places an upperbound on spacing to make
        % sure the required minSpacesX and minSpacesY are satisfied.
        if oo(oi).repeatedTargets
            % Repeated targets.
            % The block of alternating targets is surrounded by margin
            % characters at left and right. If o.maxLines>1 then it is also
            % surrounded by margin characters at top and bottom. We must
            % show at least two target characters, because we have two
            % targets.
            if RectHeight(oo(oi).stimulusRect)/RectWidth(oo(oi).stimulusRect) > oo(oi).targetHeightOverWidth
                % Height/width ratio of screen exceeds that of target.
                % Tightest case is three letters, with one target
                % sandwiched between two margin characters. We need four
                % letters to show 2 targets.
                minSpacesY=3;
                minSpacesX=2;
            else
                % Height/width ratio of target exceeds that of screen.
                % Tightest case is three letters, with one target sandwiched
                % between two margin characters. We need four letters to
                % show 2 targets.
                minSpacesY=2;
                minSpacesX=3;
            end
            if oo(oi).maxLines<4
                minSpacesX=3;
                minSpacesY=oo(oi).maxLines-1;
            end
        else
            % Just one target.
            % minSpacesX is the in tangential direction.
            % minSpacesY is in the radial direction.
            switch oo(oi).thresholdParameter
                case 'spacing'
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
                case 'size'
                    minSpacesY=0;
                    minSpacesX=0;
            end
        end
        if oo(oi).practiceCountdown>=3
            if oo(oi).repeatedTargets
                if minSpacesX>0
                    minSpacesX=1;
                end
                if minSpacesY>0
                    minSpacesY=1;
                end
                if minSpacesX>0 && minSpacesY>0
                    minSpacesY=0;
                end
            else
                minSpacesX=0;
                minSpacesY=0;
            end
        end
        if oo(oi).printSizeAndSpacing; fprintf('%d: %d: minSpacesX %d, minSpacesY %d, \n',oi,MFileLineNr,minSpacesX,minSpacesY); end
        % The spacings are center to center, so we'll fill the screen when
        % we have the prescribed minSpacesX or minSpacesY plus a half
        % letter at each border. We impose an upper bound on spacingPix to
        % guarantee that we have the requested number of spaces
        % horizontally (minSpacesX) and vertically (minSpacesY).
        if oo(oi).targetSizeIsHeight
            % targetSizeIsHeight==true, so spacingPix is vertical. It is
            % scaled by heightOverWidth in the orthogonal direction.
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    spacingPix=min(spacingPix,floor(RectHeight(oo(oi).stimulusRect)/(minSpacesY+1/oo(oi).fixedSpacingOverSize)));
                    spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize)));
                    oo(oi).targetPix=spacingPix/oo(oi).fixedSpacingOverSize;
                case 'none'
                    spacingPix=min(spacingPix,floor((RectHeight(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesY));
                    spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*(RectWidth(oo(oi).stimulusRect)-oo(oi).targetPix/oo(oi).targetHeightOverWidth)/minSpacesX));
                case 'fixed by font'
            end
        else
            % targetSizeIsHeight==false, so spacingPix is horizontal. It is
            % scaled by heightOverWidth in the orthogonal direction.
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    spacingPix=min(spacingPix,floor(RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize)));
                    spacingPix=min(spacingPix,floor(RectHeight(oo(oi).stimulusRect)/(minSpacesY+1/oo(oi).fixedSpacingOverSize)/oo(oi).targetHeightOverWidth));
                    oo(oi).targetPix=spacingPix/oo(oi).fixedSpacingOverSize;
                case 'none'
                    spacingPix=min(spacingPix,floor((RectHeight(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesX));
                    spacingPix=min(spacingPix,floor(oo(oi).targetHeightOverWidth*(RectWidth(oo(oi).stimulusRect)-oo(oi).targetHeightOverWidth*oo(oi).targetPix)/4));
                case 'fixed by font'
            end
        end
        oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
        oo(oi).spacingDeg=spacingPix/pixPerDeg; % spacingPix is master.
        tXY=XYPixOfXYDeg(oo(oi),oo(oi).eccentricityXYDeg); % target
        if oo(oi).printSizeAndSpacing
            fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f, tXY %d, %d\n',...
                oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,...
                spacingPix,oo(oi).spacingDeg,tXY);
        end
        spacingPix=round(spacingPix);
        fXY=[];
        if ismember(oo(oi).flankingDirection,{'horizontal' 'tangential'}) ...
                || (oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing'))
            % Flankers must fit on screen. Compute where tangent line
            % intersects stimulusRect. The tangent line goes through target
            % tXY and is orthogonal to the line from fixation. NOTE: When
            % dealing with o.fourFlankers, we could analyze only with one
            % pair of flankers or iterate to analyze both pairs.
            %
            % 3/4/19 LIMITATION. Currently, we allow 'horizontal' or
            % 'vertical' only if eccentricity is zero.
            switch(oo(oi).flankingDirection)
                case {'horizontal' 'fourFlankers'}
                    flankingDegVector=[1 0];
                case 'vertical'
                    flankingDegVector=[0 1];
                case 'tangential'
                    flankingDegVector=oo(oi).eccentricityDegVector*rotate90;
            end
            flankingPixVector=flankingDegVector.*[1 -1]; % Because Apple Y coordinate increases downward.
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    pix=spacingPix/oo(oi).fixedSpacingOverSize;
                case 'none'
                    pix=oo(oi).targetPix;
                case 'fixed by font'
            end
            if oo(oi).targetSizeIsHeight
                height=pix;
            else
                height=pix*oo(oi).targetHeightOverWidth;
            end
            r=InsetRect(oo(oi).stimulusRect,0.5*height/oo(oi).targetHeightOverWidth,0.5*height);
            if ~IsXYInRect(tXY,r)
                ffprintf(ff,'ERROR: the target fell off the screen. Please reduce the viewing distance.\n');
                ffprintf(ff,'NOTE: Perhaps this would be fixed by enhancing CriticalSpacing with another call to ShiftPointInRect. Ask denis.pelli@nyu.edu.');
                stimulusSize=[RectWidth(oo(oi).stimulusRect) RectHeight(oo(oi).stimulusRect)];
                ffprintf(ff,'o.stimulusRect %.0fx%.0f pix, %.0fx%.0f deg, fixation at (%.0f,%.0f) deg, eccentricity (%.0f,%.0f) deg, target at (%0.f,%0.f) deg.\n',...
                    stimulusSize,stimulusSize/pixPerDeg,...
                    oo(oi).fix.xy/pixPerDeg,...
                    oo(oi).eccentricityXYDeg,...
                    tXY/pixPerDeg);
                error(['Sorry, the target (eccentricity [%.0f %.0f] deg)'...
                    ' is falling off the screen. ' ...
                    'Please reduce the viewing distance.'],...
                    oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2));
            end
            assert(length(spacingPix)==1);
            fXY=zeros(2,2);
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    % Clip the nominal spacingPix, allowing for half a letter
                    % beyond the spacing, clipped by the stimulusRect.
                    fXY(1,:)=tXY+spacingPix*(1+0.5/oo(oi).fixedSpacingOverSize)*flankingPixVector;
                    fXY(2,:)=tXY-spacingPix*(1+0.5/oo(oi).fixedSpacingOverSize)*flankingPixVector;
                    [fXY(1,:),fXY(2,:)]=ClipLineSegment2(fXY(1,:),fXY(2,:),oo(oi).stimulusRect);
                    v=fXY;
                    for i=1:size(fXY,1)
                        v(i,1:2)=fXY(i,1:2)-tXY;
                    end
                    spacingPix=min(norm(v(1,:)),norm(v(2,:)))/(1+0.5/oo(oi).fixedSpacingOverSize);
                case 'none'
                    % Clip the nominal spacingPix, allowing for half a letter
                    % beyond the spacing, clipped by the stimulusRect.
                    fXY(1,:)=tXY+(spacingPix+0.5*oo(oi).targetPix)*flankingPixVector;
                    fXY(2,:)=tXY-(spacingPix+0.5*oo(oi).targetPix)*flankingPixVector;
                    [fXY(1,:),fXY(2,:)]=ClipLineSegment2(fXY(1,:),fXY(2,:),oo(oi).stimulusRect);
                    v=fXY;
                    for i=1:size(fXY,1)
                        v(i,1:2)=fXY(i,1:2)-tXY;
                    end
                    spacingPix=min(norm(v(1,:)),norm(v(2,:)))-0.5*oo(oi).targetPix;
                case 'fixed by font'
            end
            assert(length(spacingPix)==1);
            spacingPix=max(0,spacingPix);
            assert(length(spacingPix)==1);
            fXY(1,:)=tXY+spacingPix*flankingPixVector;
            fXY(2,:)=tXY-spacingPix*flankingPixVector;
            outerSpacingPix=0;
        end
        if streq(oo(oi).flankingDirection,'radial') || (oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing'))
            flankingDegVector=oo(oi).eccentricityDegVector;
            flankingPixVector=flankingDegVector.*[1 -1]; % Because Apple Y coordinate increases downward.
            eccentricityPix=norm(oo(oi).eccentricityXYPix);
            if eccentricityPix==0
                % Target at fixation. Symmetric flankers must fit on screen.
                switch oo(oi).relationOfSpacingToSize
                    case 'fixed ratio'
                        spacingPix=min(spacingPix,RectWidth(oo(oi).stimulusRect)/(minSpacesX+1/oo(oi).fixedSpacingOverSize));
                    case 'none'
                        spacingPix=min(spacingPix,(RectWidth(oo(oi).stimulusRect)-oo(oi).targetPix)/minSpacesX);
                    case 'fixed by font'
                end
                assert(spacingPix>=0);
                fXY(end+1,1:2)=tXY+spacingPix*flankingPixVector;
                fXY(end+1,1:2)=tXY-spacingPix*flankingPixVector;
                % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacingPix,requestedSpacing/pixPerDeg,spacingPix/pixPerDeg);
                outerSpacingPix=0;
                if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',...
                        oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end
            else % nonzero eccentricity
                assert(spacingPix>=0);
                spacingPix=min(eccentricityPix,spacingPix); % Inner flanker must be between fixation and target.
                assert(spacingPix>=0);
                switch oo(oi).relationOfSpacingToSize
                    case 'fixed ratio'
                        spacingPix=min(spacingPix,norm(tXY)/(1+1/oo(oi).fixedSpacingOverSize/2)); % Inner flanker is on screen.
                        assert(spacingPix>=0);
                        for i=1:100
                            % Our goal is:
                            % (outerSpacingPix+eccentricityPix+addOnPix)/(eccentricityPix+addOnPix)==(eccentricityPix+addOnPix)/(eccentricityPix+addOnPix-spacingPix);
                            % So we solve for outerSpacingPix:
                            outerSpacingPix=(eccentricityPix+addOnPix)^2/(eccentricityPix+addOnPix-spacingPix)-(eccentricityPix+addOnPix);
                            assert(outerSpacingPix>=0);
                            flankerRadius=spacingPix/oo(oi).fixedSpacingOverSize/2;
                            if IsXYInRect(tXY+flankingPixVector*(outerSpacingPix+flankerRadius),oo(oi).stimulusRect)
                                break;
                            else
                                spacingPix=0.9*spacingPix;
                            end
                        end
                        if i==100
                            ffprintf(ff,'ERROR: spacingPix %.2f, outerSpacingPix %.2f exceeds max %.2f pix.\n',spacingPix,outerSpacingPix,RectWidth(oo(oi).stimulusRect)-tXY(1)-spacingPix/oo(oi).fixedSpacingOverSize/2);
                            error('Could not make spacing small enough. Right flanker will be off screen. If possible, try using off-screen fixation.');
                        end
                    case 'none'
                        spacingPix=min(spacingPix,tXY(1)-oo(oi).targetPix/2); % inner flanker on screen
                        outerSpacingPix=(eccentricityPix+addOnPix)^2/(eccentricityPix+addOnPix-spacingPix)-(eccentricityPix+addOnPix);
                        outerSpacingPix=min(outerSpacingPix,RectWidth(oo(oi).stimulusRect)-tXY(1)-oo(oi).targetPix/2); % outer flanker on screen
                    case 'fixed by font'
                end
                assert(outerSpacingPix>=0);
                spacingPix=eccentricityPix+addOnPix-(eccentricityPix+addOnPix)^2/(eccentricityPix+addOnPix+outerSpacingPix);
                assert(spacingPix>=0);
                spacingPix=round(spacingPix);
                assert(spacingPix>=0);
                fXY(end+1,1:2)=tXY-spacingPix*flankingPixVector;
                fXY(end+1,1:2)=tXY+outerSpacingPix*flankingPixVector;
            end
        end % if streq(oo(oi).flankingDirection,'radial') || (oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing'))
        oo(oi).spacingDeg=spacingPix/pixPerDeg;
        if streq(oo(oi).thresholdParameter,'spacing')
            switch oo(oi).relationOfSpacingToSize
                case 'fixed ratio'
                    oo(oi).targetDeg=oo(oi).spacingDeg/oo(oi).fixedSpacingOverSize;
                case 'none'
                case 'fixed by font'
            end
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
        if oo(oi).printSizeAndSpacing
            fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',...
                oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg);
        end
        % This tryAgain loop presents instructions and waits for the
        % observer to press SPACE. If there is fixation we ask the observer
        % to fixate while pressing space. There are three occasions for
        % using this code: 1. First trial; 2. Encourage fixation after
        % observer missed a fixationCheck; 3. After escaping the last
        % presentation and hitting SPACE to resume.
        
        % Before the first trial, when we skip a trial, and when we
        % encourageFixation, we display a screen of text with fixation, and
        % wait for the observer to fixate and press space.
        if oo(oi).useFixation && ...
                (presentation==1 || skipTrial || encourageFixation)
            tryAgain=true;
            while tryAgain
                tryAgain=false;
                % When o.targetKind='letter', we draw the string 'Look at
                % the cross as you type your response.' in three places. First,
                % above at line 2375 (before the display loop), then here
                % (2762) at the top of the loop, preceding the 1 s pause before
                % displaying the stimulus, and then further below (3298), after
                % displaying the stimulus, to request a response. However, when
                % o.targetKind='gabor' this is the only display of the string.
                % The redundancy is inelegant, but harmless.
                % May 2019.
                Screen('FillRect',window); % DGP June 6, 2019.
                string=[string 'Now, while fixating the cross, hit SPACE. '];
                Screen('TextSize',window,oo(oi).textSize);
                Screen('TextFont',window,oo(oi).textFont);
                % While fixating, hit SPACE.
                DrawFormattedText(window,...
                    double([encourageFixationString string]),...
                    2*oo(1).textSize,1.5*oo(oi).textSize,black,...
                    oo(oi).textLineLength,[],[],1.3);
                string='';
                encourageFixation=false;
                encourageFixationString='';
                % Compute fixation lines during first trial, for the
                % remaining trials in the block.
                fixationLines=ComputeFixationLines2(oo(oi).fix);
                % Draw fixation.
                if ~oo(oi).repeatedTargets && oo(oi).useFixation
                    % Draw fixation.
                    if ~isempty(fixationLines)
                        Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
                    end
                end
                if oo(oi).showProgressBar
                    Screen('FillRect',window,[0 220 0],progressBarRect); % green bar
                    r=progressBarRect;
                    r(4)=round(r(4)*(1-presentation/length(condList)));
                    Screen('FillRect',window,[220 220 220],r); % grey background
                end
                if oo(1).showCounter
                    DrawCounter(oo);
                end
                % 'Now, while fixating the cross, hit SPACE.'
                Screen('Flip',window,[],1); % Display instructions and fixation.
                if oo(oi).useFixation
                    SetMouse(screenRect(3),screenRect(4),window);
                    answer=GetKeypressWithHelp([spaceKeyCode escapeKeyCode graveAccentKeyCode],oo(oi),window,oo(oi).stimulusRect);
                    if ismember(answer,[escapeChar graveAccentChar])
                        [oo,tryAgain]=ProcessEscape(oo);
                        if tryAgain
                            continue
                        else
                            oo=SortFields(oo);
                            return
                        end
                    end
                    Screen('FillRect',window,white,oo(oi).stimulusRect);
                    Screen('FillRect',window,white,clearRect);
                    if ~oo(oi).repeatedTargets && oo(oi).useFixation
                        % Draw fixation.
                        if ~isempty(fixationLines)
                            Screen('DrawLines',window,fixationLines,min(7,3*fixationLineWeightPix),white);
                            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
                        end
                    end
                    if oo(1).showCounter
                        DrawCounter(oo);
                    end
                    Screen('Flip',window,[],1); % Display just fixation.
                    WaitSecs(1); % Duration of fixation display, before stimulus appears.
                    Screen('FillRect',window,[],oo(oi).stimulusRect); % Clear screen; keep progress bar.
                    Screen('FillRect',window,[],clearRect); % Clear screen; keep progress bar.
                    if ~oo(oi).repeatedTargets && oo(oi).useFixation
                        % Draw fixation.
                        if ~isempty(fixationLines) && oo(oi).fixationCrossBlankedUntilSecsAfterTarget==0
                            % Paint white border next to the black line.
                            Screen('DrawLines',window,fixationLines,min(7,3*fixationLineWeightPix),white);
                            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
                        end
                    end
                else
                    Screen('FillRect',window); % Clear screen.
                end
            end % while tryAgain
        end % if o.useFixation && (presentation==1 || skipTrial || encourageFixation)
        skipTrial=false;
        switch oo(oi).task
            case 'read'
                % Compute desired font size o.readSize for the text to be read.
                Screen('TextFont',window,oo(oi).targetFont);
                Screen('TextSize',window,oo(1).textSize);
                switch oo(oi).thresholdParameter
                    case 'spacing'
                        % Driven by o.readSpacingDeg.
                        string='abcdefghijklmnopqrstuvwxyz';
                        boundsRect=Screen('TextBounds',window,string);
                        spacingPerNominal=RectWidth(boundsRect)/length(string)/oo(1).textSize;
                        oo(oi).readSize=oo(oi).readSpacingDeg*pixPerDeg/spacingPerNominal;
                        oo(oi).readSize=round(oo(oi).readSize);
                        oo(oi).spacingDeg=oo(oi).readSize*spacingPerNominal/pixPerDeg;
                        oo(oi).targetDeg=oo(oi).readSize*oo(oi).targetFontHeightOverNominal/pixPerDeg;
                        if ~oo(oi).targetSizeIsHeight
                            oo(oi).targetDeg=oo(oi).targetDeg/oo(oi).targetHeightOverWidth;
                        end
                    case 'size'
                        % Driven by o.targetDeg.
                        oo(oi).readSize=oo(oi).targetDeg*pixPerDeg/...
                            oo(oi).targetFontHeightOverNominal;
                        if ~oo(oi).targetSizeIsHeight
                            oo(oi).readSize=oo(oi).readSize/oo(oi).targetHeightOverWidth;
                        end
                        oo(oi).readSize=round(oo(oi).readSize);
                        oo(oi).targetDeg=oo(oi).readSize*oo(oi).targetFontHeightOverNominal/pixPerDeg;
                        if  ~oo(oi).targetSizeIsHeight
                            oo(oi).targetDeg=oo(oi).targetDeg*oo(oi).targetHeightOverWidth;
                        end
                end
                if ~isfinite(oo(oi).readSize) || oo(oi).readSize<=0
                    error(['Condition %d, o.readSize %.1f is not a positive integer. ' ...
                        'Are you sure you want o.task=''read''? '],oi,oo(oi).readSize);
                end
                if ~streq(corpusFilename,oo(oi).readFilename) || isempty(corpusLineEndings)
                    msg='Analyzing text statistics ...';
                    Screen('FillRect',window,[],clearRect);
                    Screen('TextFont',window,oo(oi).textFont);
                    % Analyzing text statistics ...
                    DrawFormattedText(window,msg,...
                        oo(1).textSize,1.5*oo(1).textSize,black);
                    DrawCounter(oo);
                    Screen('Flip',window);
                    AnalyzeCorpusFrequency(oo(oi));
                end
                % Display instructions.
                readInstructions=['When you''re ready, '...
                    'press and hold down the SPACE bar to reveal ' ...
                    'a page of text to be read '...
                    'from beginning to end as quick as you can. '...
                    'While still pressing the space bar, '...
                    'read as fast as you can '...
                    'while maintaining full comprehension. '...
                    'Read every word. ' ...
                    'Release the space bar when you''re done. '...
                    'You will then be tested for comprehension. '...
                    'Speed matters. Once you press the space bar, '...
                    'read the page from beginning to end, '...
                    'and then immediately release the space bar. '...
                    ];
                %                 Screen('FillRect',window,[],clearRect);
                %                 Screen('TextFont',window,oo(oi).textFont);
                %                 % Press SPACE to reveal story.
                %                 DrawFormattedText(window,readInstructions,...
                %                     oo(1).textSize,1.5*oo(1).textSize,black,...
                %                     oo(1).textLineLength,[],[],1.3);
                % Reuse readInstructions if user escapes and resumes.
            case 'identify'
                stimulus=shuffle(oo(oi).alphabet);
                stimulus=shuffle(stimulus); % Make it more random if shuffle isn't utterly random.
                if length(stimulus)>=3
                    % If possible, three random letters, independent samples, without replacement.
                    stimulus=stimulus(1:3); % Three random letters, all different.
                else
                    % Otherwise, three random letters, independent samples, with replacement.
                    b=shuffle(stimulus);
                    c=shuffle(stimulus);
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
                if isfinite(oo(oi).targetFontHeightOverNominal)
                    if oo(oi).targetSizeIsHeight
                        sizePix=round(oo(oi).targetPix/oo(oi).targetFontHeightOverNominal);
                        oo(oi).targetPix=sizePix*oo(oi).targetFontHeightOverNominal;
                    else
                        sizePix=round(oo(oi).targetPix/oo(oi).targetFontHeightOverNominal*oo(oi).targetHeightOverWidth);
                        oo(oi).targetPix=sizePix*oo(oi).targetFontHeightOverNominal/oo(oi).targetHeightOverWidth;
                    end
                end
                oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
                
                % Create letter textures, using font or from disk.
                % Consider doing this just once, and keeping it around, and
                % always scaling it. Consider limiting size of font in this
                % call to something quick, e.g. font size of 100, and then
                % scaling trial by trial as needed. This call is very slow
                % for a large font size, e.g 300, and the super high
                % resolution isn't needed.
                [letterStruct,alphabetBounds]=CreateLetterTextures(oi,oo(oi),window); % Takes 2 s.
                letters=[oo(oi).alphabet oo(oi).borderLetter];
                
                if oo(oi).showAlphabet
                    % This is for debugging. We also display the alphabet
                    % any time the caps lock key is pressed. That's
                    % standard behavior to allow the observer to
                    % familiarize herself with the alphabet.
                    for i=1:length(letters)
                        r=[0 0 RectWidth(letterStruct(i).rect) RectHeight(letterStruct(i).rect)];
                        s=RectWidth(oo(oi).stimulusRect)/(1.5*length(letters))/RectWidth(r);
                        r=round(s*r);
                        r=OffsetRect(r,(0.5+1.5*(i-1))*RectWidth(r),RectHeight(r));
                        Screen('DrawTexture',window,letterStruct(i).texture,[],r);
                        Screen('FrameRect',window,0,r);
                    end
                    if oo(1).showCounter
                        DrawCounter(oo);
                    end
                    Screen('Flip',window);
                    if oo(1).useSpeech
                        Speak('Alphabet. Click.');
                    end
                    GetClicks;
                end
                
                % Create textures for 3 lines. The rest are copies.
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
                if oo(oi).printSizeAndSpacing; fprintf('%d: %d: xSpacing %.0f, ySpacing %.0f, ratio %.2f\n',oi,MFileLineNr,xSpacing,ySpacing,ySpacing/xSpacing); end
                if ~oo(oi).repeatedTargets
                    if isempty(fXY)
                        error('fXY is empty. o.repeatedTargets==%d',oo(oi).repeatedTargets);
                    end
                    stimulusXY=[fXY(1,1:2);tXY;fXY(2:end,1:2)];
                    
                    if 0
                        % Print flanker spacing.
                        fprintf('%d: %s  F T F\n',oi,oo(oi).flankingDirection);
                        xyDeg={};
                        ok=[];
                        for ii=1:3
                            xyDeg{ii}=XYDegOfXYPix(oo(oi),stimulusXY(ii,:));
                            logE(ii)=log10(norm(xyDeg{ii})+addOnDeg);
                            ok(ii)=IsXYInRect(stimulusXY(ii,:),oo(oi).stimulusRect);
                        end
                        fprintf('ok %d %d %d\n',ok);
                        fprintf('x y deg: ');
                        fprintf('(%.1f %.1f) ',xyDeg{:});
                        fprintf('\nlog eccentricity+addOnDeg: ');
                        fprintf('%.2f ',logE);
                        fprintf('\n');
                        fprintf('diff log ecc. %.2f %.2f\n',diff(logE));
                        fprintf('Spacings %.1f %.1f deg\n',norm(xyDeg{1}-xyDeg{2}),norm(xyDeg{2}-xyDeg{3}));
                        if exist('maxSpacingDeg','var')
                            fprintf('maxSpacingDeg %.1f\n',maxSpacingDeg);
                            ecc=norm(xyDeg{2});
                            fprintf('log (ecc+maxSpacingDeg+addOnDeg)/(ecc+addOnDeg) %.1f\n', ...
                                log10((ecc+maxSpacingDeg+addOnDeg)/(ecc+addOnDeg)));
                        end
                    end
                    
                    if oo(oi).fourFlankers && streq(oo(oi).thresholdParameter,'spacing')
                        newFlankers=shuffle(oo(oi).alphabet(oo(oi).alphabet~=stimulus(2)));
                        stimulus(end+1:end+2)=newFlankers(1:2);
                    end
                    %             if oo(oi).isolatedTarget
                    %                 xStimulus=xStimulus(2);
                    %                 yStimulus=yStimulus(2);
                    %                 stimulus=stimulus(2);
                    %             end
                    clear textures dstRects
                    for textureIndex=1:size(stimulusXY,1)
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
                        dstRects(1:4,textureIndex)=OffsetRect(r,round(stimulusXY(textureIndex,1)-xPix/2),round(stimulusXY(textureIndex,2)-yPix/2));
                        if oo(oi).printSizeAndSpacing
                            fprintf('xPix %.0f, yPix %.0f, RectWidth(r) %.0f, RectHeight(r) %.0f, x %.0f, y %.0f, dstRect %0.f %0.f %0.f %0.f\n',...
                                xPix,yPix,RectWidth(r),RectHeight(r),stimulusXY(textureIndex),dstRects(1:4,textureIndex));
                        end
                    end
                    if ~streq(oo(oi).thresholdParameter,'spacing') || oo(oi).practiceCountdown>0
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
                    % Compute screen bounds for letter array.
                    xMin=tXY(1)-xSpacing*floor((tXY(1)-oo(oi).stimulusRect(1)-0.5*xPix)/xSpacing);
                    xMax=tXY(1)+xSpacing*floor((oo(oi).stimulusRect(3)-tXY(1)-0.5*xPix)/xSpacing);
                    yMin=tXY(2)-ySpacing*floor((tXY(2)-oo(oi).stimulusRect(2)-0.5*yPix)/ySpacing);
                    yMax=tXY(2)+ySpacing*floor((oo(oi).stimulusRect(4)-tXY(2)-0.5*yPix)/ySpacing);
                    % Enforce the required minimum number of rows.
                    if (yMax-yMin)/ySpacing<minSpacesY
                        yMin=tXY(2)-ySpacing*minSpacesY/2;
                        yMax=tXY(2)+ySpacing*minSpacesY/2;
                    end
                    % Show only as many letters as we need so that, despite
                    % a fixation error (in any direction) as large as
                    % +/-maxFixationErrorXYDeg, at least one of the many
                    % target letters will escape crowding by landing at a
                    % small enough eccentricity at which the (normal adult)
                    % observer's crowding distance is less than half the
                    % actual spacing. This is the standard formula for
                    % crowding distance, as a function of radial
                    % eccentricity.
                    % crowdingDistance=0.3*(ecc+0.15);
                    % We solve it for eccentricity.
                    % ecc=crowdingDistance/0.3-0.15;
                    % The target will be easily visible if the crowding distance
                    % is less than half the actual spacing.
                    crowdingDistanceDeg=0.5*min(xSpacing,ySpacing)/pixPerDeg;
                    % We solve for eccentricity to get this crowding distance.
                    eccDeg=crowdingDistanceDeg/0.3-0.15;
                    % If positive, this is the greatest ecc whose normal
                    % adult critical spacing is half the test spacing. The
                    % radial eccentricity must be at least zero.
                    eccDeg=max(0,eccDeg);
                    % Assume observer tries to fixate center of target text
                    % block, and actually fixates within a distance
                    % maxFixationErrorXYDeg of that center. Compute needed
                    % horizontal and vertical extent of the repetition to
                    % put some target within that ecc radius.
                    xR=max(0,oo(oi).maxFixationErrorXYDeg(1)-eccDeg)*pixPerDeg;
                    yR=max(0,oo(oi).maxFixationErrorXYDeg(2)-eccDeg)*pixPerDeg;
                    % Round the radius to an integer number of spacings.
                    xR=xSpacing*round(xR/xSpacing);
                    yR=ySpacing*round(yR/ySpacing);
                    if oo(oi).practiceCountdown>0
                        % No margin during practice.
                        xR=xSpacing*min(xR/xSpacing,oo(oi).maxRepetition);
                        yR=ySpacing*min(yR/ySpacing,floor(oo(oi).maxRepetition/4));
                    else
                        % If radius is nonzero, add a spacing for margin
                        % character.
                        if xR>0
                            xR=xR+xSpacing;
                        end
                        if yR>0
                            yR=yR+ySpacing;
                        end
                    end
                    % Enforce minSpacesX and minSpacesY
                    xR=max(xSpacing*minSpacesX/2,xR); % Min horizontal radius of letter block. Pixels.
                    yR=max(ySpacing*minSpacesY/2,yR); % Min vertical radius of letter block. Pixels.
                    xR=round(xR); % Integer pixels.
                    yR=round(yR);
                    % Clip the desired radius by the limits of actual screen.
                    xMin=tXY(1)-min(xR,tXY(1)-xMin);
                    xMax=tXY(1)+min(xR,xMax-tXY(1));
                    yMin=tXY(2)-min(yR,tXY(2)-yMin);
                    yMax=tXY(2)+min(yR,yMax-tXY(2));
                    %             fprintf('%d: %.1f rows, yMin %.0f yMax %.0f.\n',MFileLineNr,1+(yMax-yMin)/ySpacing,yMin,yMax);
                    if oo(oi).repeatedTargets && 1+(yMax-yMin)/ySpacing>oo(oi).maxLines
                        % Restrict to show no more than o.maxLines.
                        s=(oo(oi).maxLines-1)*ySpacing;
                        yMin=tXY(2)-s/2;
                        yMax=tXY(2)+s/2;
                        %                 fprintf('%d: %.1f rows, yMin %.0f yMax %.0f.\n',MFileLineNr,1+(yMax-yMin)/ySpacing,yMin,yMax);
                    end
                    if oo(oi).practiceCountdown>=3
                        % Enforce half xR and yR as upper bound on radius.
                        xMin=tXY(1)-min(xR/2,tXY(1)-xMin);
                        xMax=tXY(1)+min(xR/2,xMax-tXY(1));
                        yMin=tXY(2)-min(yR/2,tXY(2)-yMin);
                        yMax=tXY(2)+min(yR/2,yMax-tXY(2));
                    end
                    % Round (yMax-yMin)/ySpacing and (xMax-xMin)/xSpacing.
                    % This is important because we use for loops, with
                    % steps of xSpacing and ySpacing, to get from xMin and
                    % yMin to xMax and yMax. We need to arrive precisely at
                    % xMax. The rows at yMin and yMax are margins, as are
                    % the columins at xMin and xMax.
                    n=round((xMax-xMin)/xSpacing);
                    xMax=tXY(1)+xSpacing*n/2;
                    xMin=tXY(1)-xSpacing*n/2;
                    n=round((yMax-yMin)/ySpacing);
                    yMax=tXY(2)+ySpacing*n/2;
                    yMin=tXY(2)-ySpacing*n/2;
                    if oo(oi).speakSizeAndSpacing; Speak(sprintf('%.0f rows and %.0f columns',...
                            1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing));end
                    if oo(oi).printSizeAndSpacing; fprintf('%d: %d: %.1f rows and %.1f columns, target tXY [%.0f %.0f]\n',...
                            oi,MFileLineNr,1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing,tXY); end
                    if oo(oi).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.2f, spacingPix %.0f, spacingDeg %.2f\n',...
                            oi,MFileLineNr,oo(oi).targetPix,oo(oi).targetDeg,spacingPix,oo(oi).spacingDeg); end
                    if oo(oi).printSizeAndSpacing; fprintf('%d: %d: left & right margins %.0f, %.0f, top and bottom margins %.0f,  %.0f\n',...
                            oi,MFileLineNr,xMin,RectWidth(oo(oi).stimulusRect)-xMax,yMin,RectHeight(oo(oi).stimulusRect)-yMax); end
                    clear textures dstRects
                    n=length(xMin:xSpacing:xMax);
                    textures=zeros(1,n);
                    dstRects=zeros(4,n);
                    % Create three lines. 1. border, 2. target , 3. alt target.
                    for lineIndex=1:3
                        whichTarget=mod(lineIndex,2);
                        for x=xMin:xSpacing:xMax
                            switch oo(oi).thresholdParameter
                                case 'spacing'
                                    whichTarget=mod(whichTarget+1,2);
                                case 'size'
                                    whichTarget=x>mean([xMin xMax]);
                            end
                            if oo(oi).practiceCountdown==0 && xMax>xMin && (any(abs(x-[xMin xMax])<1e-9) || lineIndex==1)
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
                            
                            % Compute o.targetHeightOverWidth, and, if
                            % requested, o.setTargetHeightOverWidth
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
                            DrawCounter(oo);
                            Screen('Flip',window);
                            if oo(1).useSpeech
                                Speak(sprintf('Line %d. Click.',lineIndex));
                            end
                            GetClicks;
                        end
                        % Create a texture holding one line of letters.
                        [lineTexture(lineIndex),lineRect{lineIndex}]=Screen('OpenOffscreenWindow',window,[],[0 0 oo(oi).stimulusRect(3) heightPix],8,0);
                        Screen('FillRect',lineTexture(lineIndex),white);
                        r=Screen('Rect',textures(1));
                        Screen('DrawTextures',lineTexture(lineIndex),textures,r,dstRects);
                    end
                    clear textures dstRects
                    % Paint screen with desired number of lines. Top and bottom
                    % lines are border. The rest alternate between target and alt
                    % target lines.
                    lineIndex=1;
                    for y=yMin:ySpacing:yMax
                        % If there is only one row, then show no borders.
                        if yMax>yMin && any(abs(y-[yMin yMax])<1e-9) % ismember(y,[yMin yMax])
                            % Border row
                            whichMasterLine=1; % Horizontal row of border letters.
                        else
                            % Target row
                            whichMasterLine=2+mod(lineIndex,2); % Horizontal row of targets.
                        end
                        textures(lineIndex)=lineTexture(whichMasterLine);
                        dstRects(1:4,lineIndex)=OffsetRect(lineRect{1},0,round(y-RectHeight(lineRect{1})/2));
                        %             fprintf('%d: %d: line %d, whichMasterLine %d, texture %d, dstRect %.0f %.0f %.0f %.0f\n',...
                        %                oi,MFileLineNr,lineIndex,whichMasterLine,lineTexture(whichMasterLine),dstRects(1:4,lineIndex));
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
                    fprintf('. Target center (%d,%d)\n',tXY);
                    letterRect=OffsetRect([-0.5*xPix -0.5*yPix 0.5*xPix 0.5*yPix],tXY(1),tXY(2));
                    Screen('FrameRect',window,[255 0 0],letterRect);
                    fprintf('%d: %d: screenHeightPix %d, letterRect height %.0f, targetPix %.0f, textSize %.0f, xPix %.0f, yPix %.0f\n',...
                        oi,MFileLineNr,RectHeight(oo(oi).stimulusRect),RectHeight(letterRect),oo(oi).targetPix,Screen('TextSize',window),xPix,yPix);
                end
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
        if oo(1).showCounter
            DrawCounter(oo);
        end
        % If o.task='read' then ask observer to press and hold the SPACE
        % bar. Otherwise display both the stimulus & the optional fixation.
        [stimulusBeginVBLSec,stimulusBeginSec]=Screen('Flip',window,[],1);
        stimulusFlipSecs=GetSecs;
        if oo(oi).recordGaze
            img=snapshot(cam);
            % FUTURE: Write trial number and condition number in corner of
            % image.
            writeVideo(vidWriter,img); % Write frame to video
        end
        % Discard the line textures, to free graphics memory.
        if exist('lineTexture','var')
            for i=1:length(lineTexture)
                Screen('Close',lineTexture(i));
            end
            clear lineTexture
        end
        if ~ismember(oo(oi).task,{'read'})
            if oo(oi).repeatedTargets
                targets=stimulus(1:2);
            else
                targets=stimulus(2);
            end
        end
        if isfinite(oo(oi).durationSec) && ~ismember(oo(oi).task,{'read'})
            % WaitSecs(oo(oi).durationSec); % Display letters. OLD CODE before 4/30/2019
            Screen('FillRect',window,white,oo(oi).stimulusRect); % Clear letters.
            %             fprintf('Stimulus duration %.3f ms\n',1000*(GetSecs-stimulusFlipSecs));
            if ~oo(oi).repeatedTargets && oo(oi).useFixation
                if ~isempty(fixationLines) && oo(oi).fixationCrossBlankedUntilSecsAfterTarget==0
                    Screen('DrawLines',window,fixationLines,min(7,3*fixationLineWeightPix),white);
                    Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
                end
            end
            % Do not DrawCounter here, because it takes 200 ms.
            if oo(oi).takeSnapshot
                % Beware that taking a snapshot will screw up timing.
                TakeSnapshot(oo);
            end
            % We request a duration that is half a frame short of that
            % desired. Flip waits for the next flip after the requested
            % time. This ought to extend our interval by a random sample
            % from the uniform distribution from 0 to 1 frame, with a mean
            % of half a frame. This should give us a mean duration equal to
            % that desired. We assess that in three ways, and print it out
            % at the end of the block.
            deadSec=GetSecs-stimulusFlipSecs;
            [stimulusEndVBLSec,stimulusEndSec]=Screen('Flip',window,...
                stimulusBeginSec+oo(oi).durationSec-1/60,1); % Remove stimulus. Eventually display fixation.
            fprintf('Dead time between flips %.0f ms.\n',1000*deadSec);
            % We measure stimulus duration in three slightly different
            % ways. We use the VBLTimestamp and StimulusOnsetTime values
            % returned by our call to Screen Flip. And we time the interval
            % between return times of our two calls to Flip. The first Flip
            % displays the stimulus and the second call erases it. All of
            % these have the same purpose of recording what the true
            % stimulus duration is. The documentation of Screen Flip is a
            % bit vague, so we play safe by measuring in three ways.
            oo(oi).actualDurationSec(end+1)=stimulusEndSec-stimulusBeginSec;
            oo(oi).actualDurationVBLSec(end+1)=stimulusEndVBLSec-stimulusBeginVBLSec;
            oo(oi).actualDurationGetSecsSec(end+1)=GetSecs-stimulusFlipSecs;
            Screen('FillRect',window,white,oo(oi).stimulusRect);
            WaitSecs(max([0.2 oo(oi).fixationCrossBlankedUntilSecsAfterTarget])); % Pause before response screen.
            if ~isempty(fixationLines)
                % Paint white border next to the black line.
                Screen('DrawLines',window,fixationLines,min(7,3*fixationLineWeightPix),white);
                Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
            end
            Screen('TextFont',window,oo(oi).textFont,0);
            Screen('TextSize',window,oo(oi).textSize);
            if oo(oi).useFixation
                string=[string 'Look at the cross as you type your response. '];
            else
                string=[string 'Type your response, or ESCAPE to quit. '];
            end
            if oo(oi).repeatedTargets
                string=strrep(string,'response','two responses');
            end
            x=2*oo(1).textSize;
            y=1.5*oo(oi).textSize;
            scalar=1;
            sz=round(scalar*oo(1).textSize);
            scalar=sz/oo(1).textSize;
            Screen('TextSize',window,sz);
            % Draw text.
            Screen('TextBackgroundColor',window,white); % Set background.
            % Request response.
            DrawFormattedText(window,double(string),...
                x,y,black,...
                oo(oi).textLineLength/scalar,[],[],1.3);
            string='';
            n=length(letterStruct); % Number of letters to display.
            w=RectWidth(screenRect)-2*2*oo(oi).textSize; % Usable width of display.
            oo(oi).responseTextWidth=round(w/(n+(n-1)/2)); % Width of letter to fill usable width, assuming a half-letter-width between letters.
            oo(oi).responseTextWidth=min(oo(oi).responseTextWidth,oo(oi).textSize); % But no bigger than our information text.
            Screen('TextSize',window,oo(oi).responseTextWidth);
            % Create response alphabet.\n',MFileLineNr);
            % [letterStruct,alphabetBounds]=CreateLetterTextures(oi,oo(oi),window); % Takes 2 s.
            % letterStruct,alphabetBounds and won't be exactly the right size, so we scale it to be
            % exactly the size we want.
            alphabetBounds=round(alphabetBounds*oo(oi).responseTextWidth/RectWidth(alphabetBounds));
            x=2*oo(oi).textSize;
            y=oo(oi).stimulusRect(4)-0.3*RectHeight(alphabetBounds);
            if oo(oi).labelAnswers
                labelTextSize=oo(oi).textSize;
                Screen('TextSize',window,labelTextSize);
            end
            for i=1:length(oo(oi).alphabet)
                dstRect=OffsetRect(alphabetBounds,x,y-RectHeight(alphabetBounds));
                % Draw the i-th letter in o.alphabet.
                for j=1:length(letterStruct)
                    if oo(oi).alphabet(i)==letterStruct(j).letter
                        Screen('DrawTexture',window,letterStruct(j).texture,[],dstRect);
                    end
                end
                if oo(oi).labelAnswers
                    % We center each label above the corresponding answer.
                    % We roughly estimate label width to be about
                    % 0.5*labelTextSize, so horizontal midpoint is roughly
                    % 0.25*labelTextSize.
                    labelRect=OffsetRect(dstRect,RectWidth(dstRect)/2-0.25*labelTextSize,-RectHeight(dstRect)-0.4*labelTextSize);
                    Screen('DrawText',window,...
                        double(oo(oi).validResponseLabels(i)),labelRect(1),labelRect(4),black,white,1);
                end
                x=x+1.5*RectWidth(dstRect);
            end
            Screen('TextSize',window,oo(oi).textSize);
            Screen('TextFont',window,oo(oi).textFont,0);
            if ~oo(oi).repeatedTargets && oo(oi).useFixation
                if ~isempty(fixationLines)
                    Screen('DrawLines',window,fixationLines,min(7,3*fixationLineWeightPix),white);
                    Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
                end
            end
            if oo(1).showCounter
                DrawCounter(oo);
            end
            Screen('Flip',window,[],1); % Display fixation & response instructions.
            % Don't clear screen back buffer until after we've called
            % GetKeypressWithHelp, because it needs it.
            % Screen('FillRect',window,white,oo(oi).stimulusRect);
        end % if isfinite(oo(oi).durationSec) && ~ismember(oo(oi).task,{'read'})
        if oo(oi).takeSnapshot
            TakeSnapshot(oo);
        end
        switch oo(oi).task
            case 'read'
                % The excerpt will be 12 lines of (up to) 50 characters
                % each. That's about ten words per line.
                assert(streq(corpusFilename,oo(oi).readFilename) ...
                    && ~isempty(corpusLineEndings),...
                    'The text is not ready to be read.');
                oo(oi).readMethod=sprintf(...
                    ['Random block of text from %s, ' ...
                    'beginning at beginning of a sentence.\n' ...
                    '%d lines of up to %d chars each, ragged right. '...
                    '%.1f deg spacing. \n'...
                    '%s font set to %d point with %d point leading. '...
                    'Viewed from %.0f cm.'],...
                    oo(oi).readFilename,oo(oi).readLines,oo(oi).readCharPerLine,...
                    oo(oi).spacingDeg, ...
                    oo(oi).targetFont,oo(oi).readSize,round(1.5*oo(oi).readSize),...
                    oo(oi).viewingDistanceCm);
                % Pick starting point that leaves enough lines. The
                % newlines will move when we re-wrap, but their density
                % won't change much. n is the largest acceptable line
                % number in the wrapped text for the beginning of our
                % excerpt.
                n=length(corpusLineEndings)-oo(oi).readLines-1;
                % maxBegin is the largest acceptable character position in
                % the not-yet-wrapped text for the beginning of our
                % excerpt. Discount the newlines added by wrapping.
                maxBegin=corpusLineEndings(n)-n;
                % corpusSentenceBegins lists the character positions where
                % sentences begin. Restrict that list to exclude beginnings
                % that are too near the end.
                sentenceBegins=corpusSentenceBegins(corpusSentenceBegins<=maxBegin);
                preface='';
                while true % Repeat until we get reasonable reading speed.
                    while true % Repeat until observer types SPACE.
                        % Randomly pick one of the acceptable first sentences.
                        begin=sentenceBegins(randi(end));
                        % Grab some of the corpus, beginning at the selected
                        % sentence. We take twice what we roughly need, because
                        % taking the whole remainder can take a long time to wrap.
                        last=min(begin+2*oo(oi).readLines*oo(oi).readCharPerLine,length(corpusText));
                        string=corpusText(begin:last);
                        string=WrapString(string,oo(oi).readCharPerLine); % Wrap it.
                        lineEndings=find(string==newline);
                        % Keep just the desired number, oo(oi).readLines, of lines,
                        % omitting the (superfluous) final newline.
                        string=string(1:lineEndings(oo(oi).readLines)-1);
                        oo(oi).readString{end+1}=string;
                        
                        % There are three ways to get here:
                        % 1. ordinary flow to display reading
                        % instrucitions.
                        % 2. observer hit ESC SPACE after last reading
                        % stimulus.
                        % 3. Reading spead was impossibly high, so re start
                        % trial again with fresh text.
                        Screen('FillRect',window,[],clearRect);
                        Screen('TextFont',window,oo(oi).textFont);
                        % Press SPACE to reveal story.
                        DrawFormattedText(window,...
                            [preface readInstructions],...
                            oo(1).textSize,1.5*oo(1).textSize,black,...
                            oo(1).textLineLength,[],[],1.3);
                        Screen('Flip',window);
                        
                        % ffprintf(ff,'Dead time %.2f s since asking for SPACE before ready to sense it.\n',...
                        %      GetSecs-stimulusFlipSecs); % XYZ
                        % Time the interval from press to release of spacebar.
                        oldEnableKeyCodes=RestrictKeysForKbCheck([spaceKeyCode escapeKeyCode graveAccentKeyCode]);
                        [beginSecs,keyCode]=KbPressWait(oo(oi).deviceIndex);
                        answer=KbName(keyCode);
                        if ismember(answer,{'ESCAPE' '`~'})
                            [oo,tryAgain]=ProcessEscape(oo);
                            if tryAgain
                                % Screen('FillRect',window,white);
                                % Press SPACE to reveal text.
                                % DrawFormattedText(window,...
                                %     [preface readInstructions],...
                                %     2*oo(oi).textSize,2.5*oo(oi).textSize,black,...
                                %     oo(oi).textLineLength,[],[],1.3);
                                % preface='';
                                % Screen('Flip',window);
                                continue
                            else
                                oo=SortFields(oo);
                                return
                            end % if tryAgain
                        else % if is SPACE.
                            break
                        end % if ismember
                    end % while true, repeat until SPACE.
                    Screen('TextFont',window,oo(oi).targetFont);
                    Screen('TextSize',window,oo(oi).readSize);
                    Screen('FillRect',window);
                    % Display page of text to be read.
                    [~,y]=DrawFormattedText(window,double(string),...
                        2*oo(oi).textSize,1.5*oo(oi).textSize,black,...
                        oo(oi).readCharPerLine,[],[],1.5);
                    Screen('Flip',window,[],1);
                    if false
                        cmPerDeg=0.1/atand(0.1/oo(oi).viewingDistanceCm); % 1 mm subtense.
                        fprintf('%.2f cm/deg at %.1f cm, size %.0f.\n',...
                            cmPerDeg,oo(oi).viewingDistanceCm,oo(oi).readSize);
                    end
                    if ~IsInRect(0,y,oo(oi).stimulusRect)
                        warning('The text extends below the screen. %d lines of %d chars.',...
                            oo(oi).readLines,oo(oi).readCharPerLine);
                        ffprintf(ff,'y %.0f, stimulusRect [%.0f %.0f %.0f %.0f], screenRect [%.0f %.0f %.0f %.0f]\n',...
                            y,oo(oi).stimulusRect,screenRect);
                        oo(oi).readError='The text does not fit on screen.';
                    end
                    Screen('TextSize',window,oo(1).textSize);
                    Screen('TextFont',window,oo(1).textFont);
                    endSecs=KbReleaseWait(oo(oi).deviceIndex);
                    RestrictKeysForKbCheck(oldEnableKeyCodes); % Restore.
                    Screen('FillRect',window,white,oo(oi).stimulusRect);
                    Screen('Flip',window,[],1);
                    i=length(oo(oi).readString);
                    oo(oi).readSecs(i)=endSecs-beginSecs;
                    oo(oi).readChars(i)=length(oo(oi).readString{i});
                    oo(oi).readWords(i)=length(strsplit(oo(oi).readString{i}));
                    oo(oi).readCharPerSec(i)=oo(oi).readChars(i)/oo(oi).readSecs(i);
                    oo(oi).readWordPerMin(i)=60*oo(oi).readWords(i)/oo(oi).readSecs(i);
                    ffprintf(ff,'%d: Read text with %.1f deg letter spacing (%.1f deg size) at %.0f char/s %.0f word/min.\n',...
                        oi,oo(oi).spacingDeg,oo(oi).targetDeg,...
                        oo(oi).readCharPerSec(i),oo(oi).readWordPerMin(i));
                    if oo(oi).readWordPerMin(i)>3000
                        preface=['Oops. '...
                            'That wasn''t long enough to read the page. '...
                            'Please try again. '...
                            'This time please hold the space bar down '...
                            'until you''ve read to the end of the page. '];
                        continue;
                    end
                    break;
                end % while true % Until reading speed is reasonable.
                % Test recall.
                % Query about words shown to test comprehension.
                for iQuestion=1:oo(oi).readQuestions
                    if iQuestion==1
                        % Page stats. pageWord{i} lists all words on the
                        % page in order of ascending frequency on the page.
                        % pageFrequency(i) is frequency on the page.
                        [pageWord,pageFrequency]=WordFrequency(string);
                        iUsed=[]; % Clear list of words not be be reused.
                    end
                    % The reading comprehension test will show three words
                    % (matched in corpus frequency) only one of which was
                    % present in the text read. Thus knowledge of corpus
                    % frequency won't help assess which is present in the
                    % page, so it's a more pure test of recall from the
                    % page. I've got the corpus words sorted by frequency.
                    % So I randomly pick a word that appeared exactly once
                    % in the page and find it in the corpus list. As the
                    % two foils, I pick the nearest neighbors (randomly
                    % higher or lower) in the list sorted by frequency.
                    iiNotUsed=~ismember(pageWord,corpusWord(iUsed));
                    freq=pageFrequency(find(iiNotUsed,1));
                    words=pageWord(pageFrequency==freq & iiNotUsed); % Unused words with right frequency.
                    assert(~isempty(words),'Oops. Failed to find words with right frequency.');
                    word=words{randi(length(words))}; % Random choice.
                    % iPresent is index in corpusWord of a word that appeared
                    % in page. iAbsent(1:2) are indices in corpusWord of
                    % similar frequency words that did not appear in page.
                    % We use them as foils for the word that was present.
                    iPresent=find(ismember(corpusWord,word),1);
                    if isempty(iPresent)
                        error('Word "%s" not in corpus.\n',word);
                    end
                    % Find nearest neighbors in list that are absent from the page.
                    clear seq
                    seq=1;
                    for i=2:2:length(corpusWord)-1
                        seq(i)=-seq(i-1);
                        seq(i+1)=seq(i-1)+1;
                    end
                    % Unbiased direction, so that relative frequency of the
                    % words is not a clue to which was present in page.
                    if rand>0.5
                        seq=-seq;
                    end
                    iAbsent=[];
                    for i=1:length(seq)
                        iCandidate=iPresent+seq(i);
                        if iCandidate<1 || iCandidate>length(corpusWord)
                            continue
                        end
                        if ~ismember(corpusWord(iCandidate),pageWord) && ~ismember(iCandidate,iUsed)
                            % This word is present in corpus, absent from
                            % page, and unused.
                            iAbsent(end+1)=iCandidate;
                        end
                        if length(iAbsent)>=2
                            break
                        end
                    end
                    assert(length(iAbsent)>=2);
                    % Ask the observer.
                    iTest=[iPresent iAbsent(1:2)];
                    iUsed=[iUsed iTest]; % Don't reuse for recent page.
                    iTest=Shuffle(iTest);
                    msg=sprintf(['Which of these three words was present on the page you just read?\n'...
                        '1. %s\n2. %s\n3. %s\n\n'...
                        'Type 1, 2 or 3.\n\n\n'...
                        '(The words can include contractions and proper names. '...
                        'Upper/lower case matters.)'],...
                        corpusWord{iTest});
                    while true
                        Screen('FillRect',window);
                        % Comprehension question.
                        DrawFormattedText(window,msg,...
                            2*oo(oi).textSize,1.5*oo(oi).textSize,black,...
                            oo(oi).textLineLength,[],[],1.5);
                        DrawCounter(oo);
                        Screen('Flip',window);
                        choiceKeycodes=[KbName('1!') KbName('2@') KbName('3#') escapeKeyCode graveAccentKeyCode];
                        response=GetKeypress(choiceKeycodes);
                        if ismember(response,[escapeChar graveAccentChar])
                            [oo,tryAgain]=ProcessEscape(oo);
                            if tryAgain
                                continue
                            else
                                oo=SortFields(oo);
                                return
                            end
                        end
                        break
                    end
                    msg='';
                    if ismember(response,{'1' '2' '3'})
                        response=str2num(response);
                        answer=iTest(response); % Observer chose corpusWord{answer}.
                        right=answer==iPresent;
                        if iQuestion==1
                            oo(oi).readNumberOfResponses=1;
                            oo(oi).readNumberCorrect=double(right);
                        else
                            oo(oi).readNumberOfResponses=oo(oi).readNumberOfResponses+1;
                            oo(oi).readNumberCorrect=oo(oi).readNumberCorrect+double(right);
                        end
                        if right
                            if oo(oi).beepPositiveFeedback
                                Snd('Play',rightBeep);
                            end
                        end
                    else
                        msg=sprintf('Invalid word choice ''%c'' char(%d) in read task.',...
                            response,double(response));
                        warning(msg);
                        ffprintf(ff,'%s\n',msg);
                        oo(oi).readError=[oo(oi).readError msg];
                        oo(1).quitBlock=true;
                        oo=SortFields(oo);
                        return;
                    end
                    if false
                        % Print question words in Command Window
                        ffprintf(ff,'Present  <strong>%10s</strong>,  corpus freq %d/%d\n',...
                            corpusWord{iPresent},corpusFrequency(iPresent),sum(corpusFrequency));
                        for i=1:length(iAbsent)
                            ffprintf(ff,'Absent   <strong>%10s</strong>,  corpus freq %d/%d\n',...
                                corpusWord{iAbsent(i)},corpusFrequency(iAbsent(i)),sum(corpusFrequency));
                        end
                        ffprintf(ff,'Response %10s\n',corpusWord{answer});
                    end
                end % for iQuestion= ...
            case 'identify'
                responseString='';
                skipping=false;
                flipSecs=GetSecs;
                trueFalse={'false' 'true'};
                for i=1:length(targets)
                    if oo(oi).simulateObserver
                        assert(length(targets)==1);
                        switch oo(oi).thresholdParameter
                            case 'spacing'
                                oo(oi).spacingDeg=spacingPix/pixPerDeg;
                                intensity=log10(oo(oi).spacingDeg);
                            case 'size'
                                oo(oi).targetDeg=oo(oi).targetPix/pixPerDeg;
                                intensity=log10(oo(oi).targetDeg);
                        end
                        if intensity>oo(oi).simulatedLogThreshold
                            answer=targets(i);
                            fprintf('%d: intensity 10^%.2f=%.2f=%.2f, right: ''%s''\n',...
                                oi,intensity,10^intensity,oo(oi).spacingDeg,targets);
                        else
                            answer=shuffle(oo(oi).alphabet);
                            answer=answer(1);
                            fprintf('%d: intensity 10^%.2f=%.2f=%.2f, %s guess from ''%s'' is ''%s'' vs ''%s'' is target.\n',...
                                oi,intensity,10^intensity,oo(oi).spacingDeg,trueFalse{1+streq(answer,targets)},oo(oi).alphabet,answer,targets);
                        end
                        secs=GetSecs;
                    else
                        [answer,secs]=GetKeypressWithHelp( ...
                            [spaceKeyCode escapeKeyCode graveAccentKeyCode oo(oi).responseKeyCodes], ...
                            oo(oi),window,oo(oi).stimulusRect,letterStruct,responseString);
                    end
                    trialData.reactionTimes(i)=secs-flipSecs;
                    if ismember(answer,[escapeChar graveAccentChar])
                        [oo,skipTrial]=ProcessEscape(oo);
                        if oo(1).quitBlock || oo(1).quitExperiment
                            break
                        end
                        if skipTrial
                            continue
                        end
                    end
                    if streq(upper(answer),' ')
                        responsesNumber=length(responseString);
                        if GetSecs-stimulusFlipSecs>oo(oi).secsBeforeSkipCausesGuess
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
                        skipping=true;
                        skipCount=skipCount+1;
                        easeRequest=easeRequest+1;
                        ffprintf(ff,'*** Typed <space>. Skipping to next trial. Observer gave %d responses, and we added %d guesses.\n',responsesNumber,guesses);
                        break;
                    end % if streq(upper(answer),' ')
                    % GetKeypressWithHelp returns only one character.
                    if oo(oi).labelAnswers
                        reportedTarget = oo(oi).alphabet(ismember(upper(oo(oi).validResponseLabels),upper(answer)));
                    else
                        reportedTarget = oo(oi).alphabet(ismember(upper(oo(oi).alphabet),upper(answer)));
                    end
                    if oo(oi).speakEachLetter && oo(oi).useSpeech
                        % Speak the observer's typed response, e.g 'a'.
                        Speak(answer);
                    end
                    if ismember(upper(reportedTarget),upper(targets))
                        %                 fprintf('reportedTarget %s, targets %s, right\n',reportedTarget,targets);
                        if oo(oi).beepPositiveFeedback
                            Snd('Play',rightBeep);
                        end
                    else
                        %                 fprintf('reportedTarget %s, targets %s, wrong\n',reportedTarget,targets);
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
        end % switch oo(oi).task
        if oo(oi).speakEncouragement && oo(oi).useSpeech && ~oo(1).quitBlock && ~skipping
            switch randi(3)
                case 1
                    Speak('Good!');
                case 2
                    Speak('Nice');
                case 3
                    Speak('Very good');
            end
        end
        if oo(1).quitBlock
            break;
        end
        if ismember(oo(oi).task,{'read'})
            responseString=[];
            targets=[];
        end
        responseScores=ismember(responseString,targets);
        %         fprintf('responseString %s, targets %s, responseScores %d\n',responseString,targets,responseScores);
        oo(oi).spacingDeg=spacingPix/pixPerDeg;
        
        trialData.targetDeg=oo(oi).targetDeg;
        trialData.spacingDeg=oo(oi).spacingDeg;
        trialData.targets=targets;
        trialData.targetScores=ismember(targets,responseString);
        trialData.responses=responseString;
        trialData.responseScores=responseScores;
        % trialData.reactionTimes is computed above.
        %         fprintf('spacingDeg %.2f, targetScores %d, responses %s targets %s\n',...
        %             trialData.spacingDeg, trialData.targetScores, trialData.responses,trialData.targets);
        if oo(oi).practiceCountdown==0
            if isempty(oo(oi).trialData)
                oo(oi).trialData=trialData;
            else
                oo(oi).trialData(end+1)=trialData;
            end
        end
        for responseScore=responseScores
            switch oo(oi).thresholdParameter
                case 'spacing'
                    intensity=log10(oo(oi).spacingDeg);
                    % ffprintf(ff,'presentation %d, condition %d, o.spacingDeg %.2f, o.targetDeg %.2f\n',...
                    %    presentation,oi,oo(oi).spacingDeg,oo(oi).targetDeg);
                case 'size'
                    intensity=log10(oo(oi).targetDeg);
            end
            if oo(oi).practiceCountdown==0
                oo(oi).responseCount=oo(oi).responseCount+1;
                oo(oi).q=QuestUpdate(oo(oi).q,intensity,responseScore);
            end
        end
        %       if oo(oi).practiceCountdown
        %          fprintf('%d: %d: practiceCountdown %d, maxRepetitions %d\n',...
        %             oi,MFileLineNr,oo(oi).practiceCountdown,oo(oi).maxRepetition);
        %       end
        if oo(oi).practiceCountdown>0 && all(responseScores)
            % Decrement the practice counter. practiceCountdown was
            % initially set to o.practicePresentations. We do that many
            % easy practice trials, whose results are discarded, before
            % beginning the block of trials that we record.
            oo(oi).practiceCountdown=oo(oi).practiceCountdown-1;
            if oo(oi).practiceCountdown
                oo(oi).maxRepetition=2*oo(oi).maxRepetition;
            else
                oo(oi).maxRepetition=inf;
            end
        end
        if oo(1).quitBlock
            break;
        end
        if ~all(responseScores) && oo(oi).fixationCheck
            % The observer failed to correctly identify an easy foveal
            % target. Before the next trial, encourage them to always have
            % their eye on the center of the fixation mark when they hit
            % the response key, which initiates the next trial.
            % encourageFixation=true requests showing of a message before
            % the next trial. We insist that the observer get right several
            % (o.fixationCheckMakeupPresentations) consecutive trials of
            % this condition before proceeding with the rest of the
            % condition list.
            encourageFixation=true;
            encourageFixationString=['Oops. Wrong response. '...
                'Perhaps you didn''t have your eye on the center '...
                'of the cross. To finish sooner, '...
                'please always place your eye '...
                'at the center of the cross '...
                'before initiating the next trial. '];
            % Repeat the current condition for several trials.
            assert(oo(oi).fixationCheckMakeupPresentations>=0,...
                'o.fixationCheckMakeupPresentations %.0f must be a nonnegative integer.',...
                oo(oi).fixationCheckMakeupPresentations);
            for i=1:oo(oi).fixationCheckMakeupPresentations
                % Repeat the fixationCheck.
                condList(presentation+1:end+1)=condList(presentation:end);
            end
        else
            encourageFixation=false;
            encourageFixationString='';
        end
    end % while presentation<length(condList)
    blockTrial=[]; % For DrawCounter
    blockTrials=[]; % For DrawCounter
    % Quitting just this block or experiment.
    if oo(1).quitBlock || oo(1).quitExperiment
        oo=SortFields(oo);
        return
    end
    Screen('FillRect',window);
    DrawCounter(oo);
    Screen('Flip',window);
    if oo(1).useSpeech
        if ~oo(1).quitBlock
            Speak('Congratulations.  This block is done.');
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
            case 'spacing'
                ori=oo(oi).flankingDirection;
                ecc=norm(oo(oi).eccentricityXYDeg);
                if ~oo(oi).repeatedTargets && ecc>0
                    switch(oo(oi).flankingDirection)
                        case 'radial'
                            ffprintf(ff,'Radial spacing of far flanker from target.\n');
                        case 'tangential'
                            ffprintf(ff,'Tangential spacing of flankers.\n');
                        case 'horizontal'
                            ffprintf(ff,'Horizontal spacing of flankers.\n');
                        case 'vertical'
                            ffprintf(ff,'Vertical spacing of flankers.\n');
                        otherwise
                            warning('Illegal o.flankingDirection "%s".',oo(oi).flankingDirection)
                    end
                end
                ffprintf(ff,'Threshold log %s spacing deg (mean%csd) is %.2f%c%.2f, which is %.3f deg.\n',...
                    ori,plusMinus,t,plusMinus,sd,10^t);
                if 10^t<oo(oi).minimumSpacingDeg
                    ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed spacing %.3f deg. Please increase viewing distance.\n',10^t,oo(oi).minimumSpacingDeg);
                end
                if oo(oi).responseCount>1
                    trials=QuestTrials(oo(oi).q);
                    if any(~isreal([trials.intensity]))
                        error('trials.intensity returned by Quest should be real, but is complex.');
                    end
                    ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(oi).q,trials.intensity-oo(oi).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
                end
            case 'size'
                if oo(oi).targetSizeIsHeight
                    ori='vertical';
                else
                    ori='horizontal';
                end
                ffprintf(ff,'Threshold log %s size deg (mean%csd) is %.2f%c%.2f, which is %.3f deg.\n',...
                    ori,plusMinus,t,plusMinus,sd,10^t);
                if 10^t<oo(oi).minimumSizeDeg
                    ffprintf(ffError,'WARNING: Estimated threshold %.3f deg is smaller than minimum displayed size %.3f deg. Please increase viewing distance.\n',...
                        10^t,oo(oi).minimumSizeDeg);
                end
                if oo(oi).responseCount>1
                    trials=QuestTrials(oo(oi).q);
                    ffprintf(ff,'Size(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(oi).q,trials.intensity-oo(oi).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
                end
        end % switch oo(oi).thresholdParameter
    end % for oi=1:conditions
    
    for oi=1:conditions
        if oo(oi).measureBeta
            % Reanalyze the data with beta as a free parameter.
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
                    case 'spacing'
                        ffprintf(ff,'\n Spacing(deg)   P fit	P actual Trials\n');
                    case 'size'
                        ffprintf(ff,'\n Size(deg)   P fit	P actual Trials\n');
                end
                ffprintf(ff,'%5.2f           %4.2f    %4.2f     %d\n',[10.^trials.intensity;QuestP(qq,trials.intensity);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
            end
            ffprintf(ff,'o.measureBeta done **********************************\n');
        end % if oo.measureBeta
    end % for oi=1:conditions
    Snd('Close');
    ListenChar;
    ShowCursor;
    a=[];
    for oi=1:conditions
        ffprintf(ff,'%d: duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. Flip\n',...
            oi,oo(oi).durationSec*1000, ...
            1000*mean(oo(oi).actualDurationSec),...
            plusMinus,...
            1000*std(oo(oi).actualDurationSec),...
            1000*min(oo(oi).actualDurationSec),1000*max(oo(oi).actualDurationSec));
        a=[a oo(oi).actualDurationSec];
        if max(oo(oi).actualDurationSec)>oo(oi).durationSec+2/60
            warning('Duration overrun by %.0f ms. Flip.',...
                1000*(max(oo(oi).actualDurationSec)-oo(oi).durationSec));
        end
        if true
            % Report two other measures of timing, to confirm standard
            % measure. DGP August 2019.
            ffprintf(ff,'%d: duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. GetSecs\n',...
                oi,oo(oi).durationSec*1000, ...
                1000*mean(oo(oi).actualDurationGetSecsSec),...
                plusMinus,...
                1000*std(oo(oi).actualDurationGetSecsSec),...
                1000*min(oo(oi).actualDurationGetSecsSec),1000*max(oo(oi).actualDurationGetSecsSec));
            a=[a oo(oi).actualDurationGetSecsSec];
            if max(oo(oi).actualDurationGetSecsSec)>oo(oi).durationSec+2/60
                warning('Duration overrun by %.0f ms. GetSecs',...
                    1000*(max(oo(oi).actualDurationGetSecsSec)-oo(oi).durationSec));
            end
            ffprintf(ff,'%d: duration "%.0f ms" actually %.0f%c%.0f ms, range [%.0f %.0f] ms. VBL\n',...
                oi,oo(oi).durationSec*1000, ...
                1000*mean(oo(oi).actualDurationVBLSec),...
                plusMinus,...
                1000*std(oo(oi).actualDurationVBLSec),...
                1000*min(oo(oi).actualDurationVBLSec),1000*max(oo(oi).actualDurationVBLSec));
            a=[a oo(oi).actualDurationVBLSec];
            if max(oo(oi).actualDurationVBLSec)>oo(oi).durationSec+2/60
                warning('Duration overrun by %.0f ms. VBL',...
                    1000*(max(oo(oi).actualDurationVBLSec)-oo(oi).durationSec));
            end
        end
    end
    ffprintf(ff,':: duration actually %.0f%c%.0f ms, range [%.0f %.0f] ms.\n',...
        1000*mean(a),plusMinus,1000*std(a),1000*min(a),1000*max(a));
    for oi=1:conditions
        if exist('results','var') && oo(oi).responseCount>1
            ffprintf(ff,'%d:',oi);
            trials=QuestTrials(oo(oi).q);
            p=sum(trials.responses(2,:))/sum(sum(trials.responses));
            switch oo(oi).thresholdParameter
                case 'spacing'
                    ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. [%.1f  %.1f] deg, critical spacing %.2f deg.\n',...
                        oo(oi).observer,100*p,oo(oi).targetDeg,oo(oi).eccentricityXYDeg,10^QuestMean(oo(oi).q));
                case 'size'
                    ffprintf(ff,'%s: p %.0f%%, ecc. [%.2f  %.2f] deg, threshold size %.3f deg.\n',...
                        oo(oi).observer,100*p,oo(oi).eccentricityXYDeg,10^QuestMean(oo(oi).q));
            end
        end
    end % for oi=1:conditions
    % The user notes are saved in the first condition of the last block.
    if oo(1).askForPartingComments && (oo(1).isLastBlock || any([oo.quitExperiment]))
        query='Done. Thank you. Any thoughts or suggestions? Click OK when done.';
        if isfield(oo(1),'textSize')
            fontSize=oo(1).textSize;
        else
            fontSize=24;
        end
        fontSize=min(36,fontSize);
        sca; % Close any Psychtoolbox window, which would obscure the input dialog.
        reply=inputdlg2({query},'Comments?',[5 50],{''},'on','FontSize',fontSize);
        [oo.partingComments]=deal('');
        oo(1).partingComments=reply;
    end
    dataFile=fullfile(oo(1).dataFolder,[oo(1).dataFilename '.mat']);
    save(dataFile,'oo');
    if exist('dataFid','var') && dataFid~=-1
        fclose(dataFid);
        dataFid=-1;
    end
    fprintf('Results for all %d conditions saved in %s.txt and "".mat\n',length(oo),oo(1).dataFilename);
    if exist('vidWriter','var')
        close(vidWriter);
        clear cam
        fprintf('Gaze recorded with extension %s\n',videoExtension);
    end
    fprintf('in folder %s\n',oo(1).dataFolder);
catch e
    % One or more of these functions spoils rethrow, so I don't use them.
    %     Snd('Close');
    %     ShowCursor;
    if exist('dataFid','var') && dataFid~=-1
        fclose(dataFid);
        dataFid=-1;
    end
    if exist('vidWriter','var')
        close(vidWriter);
        clear cam
    end
    keepWindowOpen=false;
    rethrow(e);
end
keepWindowOpen=~oo(1).isLastBlock && ~oo(1).quitExperiment;
oo=SortFields(oo);
return
end % function CriticalSpacing

function xyPix=XYPixOfXYDeg(o,xyDeg)
% Convert position from deg (relative to fixation) to integet (x,y) screen
% coordinate. Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. We typically put the target there, but that is not assumed in this
% routine.
xyDeg=xyDeg-o.nearPointXYDeg;
rDeg=norm(xyDeg);
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

function xyDeg=XYDegOfXYPix(o,xyPix)
% Convert position from (x,y) coordinate in o.stimulusRect to deg (relative
% to fixation). Deg increase right and up. Pix are in Apple screen
% coordinates which increase down and right. The perspective transformation
% is relative to location of near point, which is orthogonal to line of
% sight. THe near-point location is specified by o.nearPointXYPix and
% o.nearPointXYDeg. We typically put the target at the near point, but that
% is not assumed in this routine.
xyPix=xyPix-o.nearPointXYPix;
rPix=norm(xyPix);
rDeg=atan2d(rPix/o.pixPerCm,o.viewingDistanceCm);
if rPix>0
    xyPix(2)=-xyPix(2); % Apple y goes down.
    xyDeg=xyPix*rDeg/rPix;
else
    xyDeg=[0 0];
end
xyDeg=xyDeg+o.nearPointXYDeg;
end

function v=shuffle(v)
v=v(randperm(length(v)));
end

%% SET UP FIXATION
function oo=SetUpFixation(window,oo,oi,ff)
% Fixation may be off-screen. Set up o.fixationIsOffscreen,
% o.targetXYPix, fixationOffsetXYCm, o.nearPointXYPix.
% Primary figures out where fixation will be on screen.
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
    oo(oi).fixationIsOffscreen=false;
else
    oo(oi).fixationIsOffscreen=~IsXYInRect(oo(oi).fixationXYPix,oo(oi).stimulusRect);
    if oo(oi).fixationIsOffscreen
        fprintf('%d: Fixation is off screen. fixationXYPix %.0f %.0f, o.stimulusRect [%d %d %d %d]\n',...
            oi,oo(oi).fixationXYPix,oo(oi).stimulusRect);
        % oo(oi).fixationXYPix is in plane of display. Off-screen fixation is
        % not! Instead it is the same distance from the eye as the near point.
        % fixationOffsetXYCm is vector from near point to fixation.
        rDeg=norm(oo(oi).nearPointXYDeg);
        ori=atan2d(-oo(oi).nearPointXYDeg(2),-oo(oi).nearPointXYDeg(1));
        rCm=2*sind(0.5*rDeg)*oo(oi).viewingDistanceCm;
        fixationOffsetXYCm=[cosd(ori) sind(ori)]*rCm;
        if 0
            % Check the geometry.
            oriCheck=atan2d(fixationOffsetXYCm(2),fixationOffsetXYCm(1));
            rCmCheck=norm(fixationOffsetXYCm);
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
        % Set up viewing distance and near point.
        DrawFormattedText(window,string,...
            oo(oi).textSize,1.5*oo(oi).textSize,black,...
            oo(oi).textLineLength,[],[],1.3);
        x=oo(oi).nearPointXYPix(1);
        y=oo(oi).nearPointXYPix(2);
        a=0.1*RectHeight(oo(oi).stimulusRect);
        Screen('DrawLine',window,black,x-a,y,x+a,y,a/20);
        Screen('DrawLine',window,black,x,y-a,x,y+a,a/20);
        DrawCounter(oo);
        Screen('Flip',window); % Display question.
        if false && oo(oi).speakInstructions
            string=strrep(string,'below ','');
            string=strrep(string,'.0','');
            Speak(string);
        end
        string='';
        response=GetKeypress([escapeKeyCode,returnKeyCode,graveAccentKeyCode]);
        answer=[];
        if ismember(response,[escapeChar graveAccentChar])
            answer=0;
        end
        if ismember(response,[returnChar])
            answer=1;
        end
        Screen('FillRect',window,white);
        DrawCounter(oo);
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
    ffprintf(ff,'%d: Fixation cross is blanked during and until %.2f s after target. No selective blanking near target. \n',...
        oi,oo(oi).fixationCrossBlankedUntilSecsAfterTarget);
    ffprintf(ff,'%d: Fixation cross is not blanked.\n');
end
end % function SetUpFixatiom

function [ooOut,skipTrial]=ProcessEscape(oo)
global window keepWindowOpen
skipTrial=false;
switch nargout
    case 2
        [oo(1).quitExperiment,oo(1).quitBlock,skipTrial]=OfferEscapeOptions(window,oo);
    case 1
        [oo(1).quitExperiment,oo(1).quitBlock]=OfferEscapeOptions(window,oo);
    otherwise
        error('ProcessEscape requires 1 or 2 output arguments.');
end
keepWindowOpen=~oo(1).isLastBlock && ~oo(1).quitExperiment;
ooOut=oo;

% if oo(1).quitExperiment
%     ffprintf(ff,'*** User typed ESCAPE twice. Session terminated.\n');
% else
%     ffprintf(ff,'*** User typed ESCAPE. Block terminated.\n');
% end

% Termination of CriticalSpacing will automatically invoke
% CloseWindowsAndCleanup via the onCleanup mechanism.
end

function TakeSnapshot(oo)
% TakeSnapshot(oo)
global window ff
filename=oo(1).dataFilename;
suffixList={''};
for a='a':'z'
    suffixList{end+1}=a;
end
for a='a':'z'
    for b='a':'z'
        suffixList{end+1}=[a b];
    end
end
for suffix=suffixList
    % Has filename already been used?
    snapshotFid=fopen(fullfile(oo(1).snapshotsFolder,[filename suffix{1} '.png']),'rt');
    if snapshotFid==-1
        % No. Use it.
        filename=[filename suffix{1}];
        break
    else
        % Yes. Skip it.
        fclose(snapshotFid);
    end
end
if snapshotFid~=-1
    error('Can''t save file. Already %d PNG files with that name plus short suffixs.',...
        length(suffixList));
end
filename=[filename '.png'];
img=Screen('GetImage',window);
imwrite(img,fullfile(oo(1).snapshotsFolder,filename),'png');
ffprintf(ff,'Saved image to file "%s".\n',filename);
end