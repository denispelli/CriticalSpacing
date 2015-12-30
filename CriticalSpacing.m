function oo=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. CriticalSpacing may adjust some of
% your parameters to satisfy physical constraints. Constraints include the
% screen size and the maximum possible contrast.
%
% MATLAB: To run this program, you need a computer with MATLAB and the
% Psychtoolbox installed.
%
% COMPUTER: Apple Macintosh, Windows, or Linux computer with a digital
% screen. CriticalSpacing.m runs on any computer with MATLAB and
% Psychtoolbox. The software automatically reads the screen resolution in
% pixels and size in cm. That won't work with an analog display, but we
% could add code to allow you to measure it manually. Let me know.
%
% WIRELESS OR LONG-CABLE KEYBOARD. A wireless keyboard or long keyboard
% cable is highly desirable as the viewing distance will be 3 m or more. If
% you must use the laptop keyboard then have the experimenter type the
% observer's verbal answers. I like this $86 solar-powered wireless, for
% which the batteries never run out: Logitech Wireless Solar Keyboard K760
% for Mac/iPad/iPhone http://www.amazon.com/gp/product/B007VL8Y2C
%
% MIRROR. You might want to use a mirror to achieve a long viewing distance
% in a small room. In that case, add a line to your running script,
% o.flipScreenHorizontally=0; so the observer sees all the letters normally
% oriented.
%
% FONTS. If you use o.readAlphabetFromDisk=1 then your computer can be
% Macintosh, Windows, or Linux and you don't need to install any fonts. If
% you have a Macintosh, you can render fonts live by setting
% o.readAlphabetFromDisk=0, and installing the fonts you need from the
% CriticalSpacing/fonts folder into your computer's font folder. You can
% just double-click the font file and say "yes" when your computer offers
% to install it for you. Once you've installed the font, quit and restart
% MATLAB to get it to notice the newly available font.
%
% RUN SCRIPT. CriticalSpacing.m is meant to be driven by a brief
% user-written script. I have provided runCriticalSpacing as a example.
% Many parameters controlling the behavior of CriticalSpacing are specifed
% in the fields of a struct called "o". That defines a condition for which
% a threshold will be measured. If you provide several conditions, as an o
% array, then CriticalSpacing runs all the conditions interleaved,
% measuring a threshold for each. CriticalSpacing initially asks for the
% observer's name and presents a page of instructions. The rest is just one
% eye chart after another, each showing one or two targets (with or without
% repetitions). Adults find it easy and intuitive. I don't know whether
% it's yet ready for children. I welcome suggestions. The targets are
% currently drawn from 9 letters of the Sloan font: DHKNORSVZ.
%
% ESCAPE TO QUIT. Try running runCriticalSpacing. It will measure four
% thresholds. You can always terminate the current run by hitting Escape.
% CriticalSpacing will then print out results so far and begin the next
% run.
%
% RESPONSE PAGE. Inside the CriticalSpacing folder you'll find a file
% "Response page FONT.pdf" (where FONT is the name of the font you're
% using) that should be printed and given to the observer. It shows the
% nine possible letters. Adults will find it helpful to consult this page
% while choosing an answer when they have little idea what letter the
% target(s) might be. Children may prefer to point at the target letters,
% one by one, on the response page. Patients who have trouble directing
% their attention may be better off without the response page, so they can
% maintain their undivided attention on the display.
%
% THRESHOLD. CriticalSpacing measures threshold spacing or size (i.e.
% acuity). This program measures the critical spacing of crowding in either
% of two directions, selected by the variable
% o.measureThresholdVertically, 1 for vertically, and 0 for
% horizontally. Target size can be made proportional to spacing, allowing
% measurement of critical spacing without knowing the acuity, because
% we use the largest possible letter for each spacing.
%
% ECCENTRICITY 0. Current testing is focussed on eccentricity 0.
%
% ECCENTRICITY>0. When the flankers are radial, the specified spacing
% refers to the inner flanker, between target and fixation. We define
% scaling eccentricity as eccentricity plus 0.45 deg. The critical spacing
% of crowding is proportional to the scaling eccentricity. The
% outer-flanker is at scaling eccentricity that has the same ratio to the
% target scaling eccentricity, as the target scaling eccentricity does to
% the inner-flanker scaling eccentricity.
%
% VIEWING DISTANCE. The minimum viewing distance depends on
% minimumTargetPix and pixPerCm. At that distance a minimumTargetPix-size
% letter is half the normal acuity, so we can measure acuity on people who
% are slightly better than normal. Normal acuity is 0.1 deg. Thus, if
% minimumTargetPix=8, then we want 8 pixels to be less than 0.05 deg =
% 0.05/57 radians. Thus
% 0.05/57 <= 8/pixPerCm/distanceCm
% solving for distanceCm
% distanceCm >= (57/0.05)*8/pixPerCm = 9120/pixPerCm

% Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
if nargin<1 || ~exist('oIn','var')
   oIn.noInputArgument=1;
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this file
Screen('Preference','VisualDebugLevel',0);
Screen('Preference', 'Verbosity', 0); % mute Psychtoolbox's INFOs and WARNINGs
Screen('Preference','SkipSyncTests',1);
Screen('Preference','SuppressAllWarnings',1);

% Sound
o.beepPositiveFeedback=1;
o.beepNegativeFeedback=0;
o.usePurring=0;
o.useSpeech=1;
o.speakEachLetter=1;
o.speakEncouragement=0;
o.speakViewingDistance=0;

% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.repeatedTargets=1;
o.useFractionOfScreen=0;
o.readAlphabetFromDisk=1;
o.saveLettersToDisk=0;
o.showProgressBar=1;
o.fractionEasyTrials=0.2; % Add extra easy trials.
% o.observer='junk';
% o.observer='Shivam'; % specify actual observer name
o.observer=''; % Name is requested at beginning of run.
o.quit=0;
o.viewingDistanceCm=300;
o.flipScreenHorizontally=0;
o.useQuest=1; % true(1) or false(0)
o.thresholdParameter='spacing';
% o.thresholdParameter='size';
o.fixedSpacingOverSize=1.4; % Requests size proportional to spacing, horizontally and vertically.
% o.fixedSpacingOverSize=0; % Disconnect size & spacing.
o.measureThresholdVertically=nan; % depends on parameter
o.setTargetHeightOverWidth=0;
o.targetHeightOverWidth=nan;
o.minimumTargetPix=8; % Minimum viewing distance depends soley on this & pixPerCm.
o.eccentricityDeg=0; % location of target, relative to fixation, in degrees
% o.eccentricityDeg=16;
% o.radialOrTangential='tangential'; % values 'radial', 'tangential'
o.radialOrTangential='radial'; % values 'radial', 'tangential'
o.durationSec=inf; % duration of display of target and flankers
screenRect=Screen('Rect',0);
o.fixationLocation='center'; % 'left', 'right'
o.trials=40; % number of trials for the threshold estimate
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf;
o.fixationLineWeightDeg=0.005;
o.measureBeta=0;
o.task='identify';
% This produces the standard adult condition:
o.alphabet='DHKNORSVZ'; % Sloan alphabet, excluding C
o.validKeys = {'D','H','K','N','O','R','S','V','Z'}; % valid key codes ('4$') corresponding to alphabet
o.borderLetter='X';
% And this produces the HOTVX condition:
% o.alphabet='HOTVX'; % alphabet of Cambridge Crowding Cards
% o.borderLetter='N';
%oo.alphabet='!7ij:()[]/|'; % bar-symbol alphabet
%oo.validKeys = {'1!','7&','i','j',';:','9(','0)','[{',']}','/?','\|'};
%oo.borderLetter='!';
o.simulateGetChar=0; %if 1, only output single char for keypress, instead of true keycode like '4$'
o.targetFont='Sloan';
o.targetFontNumber=[];
o.textFont='Trebuchet MS';
o.textSizeDeg=0.4;
o.deviceIndex=-3; % all keyboard and keypad devices
if o.measureBeta
   o.trials=200;
   o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
end
% DEBUGGING AIDS
o.displayAlphabet=0;
o.frameTheTarget=0;
o.printSizeAndSpacing=0;
o.printScreenResolution=0;
o.showLineOfLetters=0;
o.showBounds=0;
o.speakSizeAndSpacing=0;

if IsWindows
   o.textFontHeightOverNominal=1.336;
   textYOffset=0.75;
else
   o.textFontHeightOverNominal=1.0;
   textYOffset=0;
end

% Replicate o, once per supplied condition.
conditions=length(oIn);
oo(1:conditions)=o;

% All fields in the user-supplied "oIn" overwrite corresponding fields in
% "o". o is a single struct, and oIn may be an array of structs.
for condition=1:conditions
   fields=fieldnames(oIn(condition));
   for i=1:length(fields)
      oo(condition).(fields{i})=oIn(condition).(fields{i});
   end
end
for condition=1:conditions
   switch oo(condition).thresholdParameter
      case 'size',
         oo(condition).measureThresholdVertically=1;
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
Screen('Preference','SkipSyncTests',1);
escapeKey=KbName('ESCAPE');
spaceKey=KbName('space');
for condition=1:conditions
   for i=1:length(oo(condition).validKeys)
      oo(condition).responseKeys(i)=KbName(oo(condition).validKeys{i}); % this returns keyCode as integer
   end
end

% Set up for Screen
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',0);
screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',0);
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

try
   black=0;
   white=255;
   %     white=WhiteIndex(window);
   %     black=BlackIndex(window);
   oo(1).screen=max(Screen('Screens'));
   screenBufferRect=Screen('Rect',oo(1).screen);
   screenRect=Screen('Rect',oo(1).screen,1);
   % Detect HiDPI mode, e.g. on a Retina display.
   oo(1).hiDPIMultiple=RectWidth(screenRect)/RectWidth(screenBufferRect);
   if 1
      PsychImaging('PrepareConfiguration');
      if oo(1).flipScreenHorizontally
         PsychImaging('AddTask','AllViews','FlipHorizontal');
      end
      if oo(1).hiDPIMultiple~=1
         PsychImaging('AddTask','General','UseRetinaResolution');
      end
      if ~oo(1).useFractionOfScreen
         [window,r]=PsychImaging('OpenWindow',oo(1).screen,white);
      else
         [window,r]=PsychImaging('OpenWindow',oo(1).screen,white,round(oo(1).useFractionOfScreen*screenBufferRect));
      end
   else
      window=Screen('OpenWindow',0,white,screenBufferRect);
   end
   if oo(1).printScreenResolution
      screenBufferRect=Screen('Rect',oo(1).screen)
      screenRect=Screen('Rect',oo(1).screen,1)
      resolution=Screen('Resolution',oo(1).screen)
   end
   
   if ~oo(1).readAlphabetFromDisk
      for condition=1:conditions
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
            [font,number]=Screen('TextFont',window);
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
            warning('The o.textFont "%s" is not available. Using %s instead.',oo(condition).textFont,font);
         end
      end
   end % if ~oo(1).readAlphabetFromDisk
   
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
      instructionalTextLine='Please slowly type your name followed by RETURN. xxxx';
      boundsRect=Screen('TextBounds',window,instructionalTextLine);
      fraction=RectWidth(boundsRect)/(screenWidth-2*instructionalMargin);
      oo(condition).textSize=round(oo(condition).textSize/fraction);
      % The TextBounds seem to be wrong on Windows, so we explicitly set
      % a reasonable textSize.
      %       if IsWindows
      %          oo(condition).textSize=round((screenWidth-100)/22/oo(condition).textFontHeightOverNominal);
      %       end
   end
   if IsWindows && ~oo(1).readAlphabetFromDisk
      % The high-quality text renderer on Windows clips the Sloan font.
      % So we select the low-quality renderer instead.
      Screen('Preference','TextRenderer',0);
   end
   ListenChar(0); % flush
   ListenChar(2); % no echo
   
   % Observer name
   if length(oo(1).observer)==0
      Screen('TextSize',window,oo(1).textSize);
      Screen('TextFont',window,oo(1).textFont,0);
      Screen('DrawText',window,'Hi.',instructionalMargin,screenRect(4)/2-4.5*oo(1).textSize,black,white);
      Screen('DrawText',window,'Please slowly type your name followed by RETURN.',instructionalMargin,screenRect(4)/2-3*oo(1).textSize,black,white);
      %       Screen('DrawText',window,'[The viewing distance %.0f cm can be changed (to at least ',instructionalMargin,screenRect(4)/2+2*oo(1).textSize,black,white);
      %       Screen('DrawText',window,'%.0f cm) only by quitting and editing the program.]',instructionalMargin,screenRect(4)/2+3*oo(1).textSize,black,white);
      Screen('TextSize',window,round(oo(1).textSize*0.4));
      Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2015, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
      Screen('TextSize',window,oo(1).textSize);
      name=GetEchoString(window,'Name:',instructionalMargin,screenRect(4)/2,black,white,1,oo(1).deviceIndex);
      for i=1:conditions
         oo(i).observer=name;
      end
      Screen('FillRect',window);
   end
   
   oo(1).beginSecs=GetSecs;
   oo(1).beginningTime=now;
   timeVector=datevec(oo(1).beginningTime);
   stack=dbstack;
   if length(stack)==1;
      oo(1).functionNames=stack.name;
   else
      oo(1).functionNames=[stack(2).name '-' stack(1).name];
   end
   oo(1).dataFilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d',oo(1).functionNames,oo(1).observer,round(timeVector));
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
   ffprintf(ff,'\n%s %s\n',oo(1).functionNames,datestr(now));
   ffprintf(ff,'Saving results in:\n');
   ffprintf(ff,'/data/%s.txt and "".mat\n',oo(1).dataFilename);
   resolution=Screen('Resolution',oo(1).screen);
   %     ffprintf(ff,'Screen resolution %d x %d pixels.\n',resolution.width,resolution.height);
   
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
      %         if ~oo(condition).repeatedTargets
      %             Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
      %         end
      
      oo(condition).responseCount=1; % When we have two targets we get two responses for each displayed screen.
      oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
      oo(condition).targetDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
      oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(stimulusRect)-oo(condition).fix.x-pixPerDeg*oo(condition).targetDeg)); % target fits on screen, with half-target margin.
      oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
      oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
      oo(condition).targetDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
      oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
      if oo(condition).eccentricityDeg==0
         oo(condition).nominalCriticalSpacingDeg=0.05;
      end
      addonDeg=0.45;
      addonPix=pixPerDeg*addonDeg;
      oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
      oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
      oo(condition).targetDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
      if streq(oo(condition).thresholdParameter,'spacing') && streq(oo(condition).radialOrTangential,'radial')
         oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(stimulusRect)-oo(condition).fix.x-pixPerDeg*(oo(condition).spacingDeg+oo(condition).targetDeg/2))); % flanker fits on screen.
         oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
         oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
         oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
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
      oo(condition).targetPix=oo(condition).targetDeg*pixPerDeg;
      
      % prepare to draw fixation cross
      oo(condition).fix.targetHeightPix=oo(condition).targetPix;
      fixationLines=ComputeFixationLines(oo(condition).fix);
      
      if ~oo(condition).readAlphabetFromDisk
         % calibrate font size
         sizePix=100;
         scratchWindow=Screen('OpenOffscreenWindow',window,[],[0 0 4*sizePix 4*sizePix],8,0);
         if ~isempty(oo(condition).targetFontNumber)
            Screen('TextFont',scratchWindow,oo(condition).targetFontNumber);
            [font,number]=Screen('TextFont',scratchWindow);
            assert(number==oo(condition).targetFontNumber);
         else
            Screen('TextFont',scratchWindow,oo(condition).targetFont);
            font=Screen('TextFont',scratchWindow);
            assert(streq(font,oo(condition).targetFont));
         end
         Screen('TextSize',scratchWindow,sizePix);
         for i=1:length(oo(condition).alphabet)
            lettersInCells{i}=oo(condition).alphabet(i);
         end
         bounds=TextBounds(scratchWindow,lettersInCells,1);
         Screen('Close',scratchWindow);
         oo(condition).targetHeightOverWidth=RectHeight(bounds)/RectWidth(bounds);
         if oo(conditions).showBounds
            % Currently useless, because you can't see the letters.
            % They are drawn with color 1, alas. Could change
            % TextBounds to use color 255.
            bounds=TextBounds(window,lettersInCells,1);
            %                 Screen('DrawText',window,lettersInCells{1},0,0,0,255,1);
            Screen('FrameRect',window,[255 0 0],bounds+100);
            Screen('Flip',window);
            Speak('Bounds. Click to continue.');
            GetClicks;
         end
         oo(condition).targetFontHeightOverNominal=RectHeight(bounds)/sizePix;
      else % if ~oo(condition).readAlphabetFromDisk
         alphabetsFolder=fullfile(fileparts(mfilename('fullpath')),'lib','alphabets');
         if ~exist(alphabetsFolder,'dir')
            error('Folder missing: "%s"',alphabetsFolder);
         end
         folder=fullfile(alphabetsFolder,urlencode(oo(condition).targetFont));
         if ~exist(folder,'dir')
            error('Folder missing: "%s". Target font "%s" has not been saved.',folder,oo(condition).targetFont);
         end
         d=dir(folder);
         ok=~[d.isdir];
         d=d(ok);
         if length(d)<length(oo(condition).alphabet)
            error('Sorry. Saved %s alphabet has only %d letters, and you requested %d letters.',oo(condition).targetFont,length(d),length(oo(condition).alphabet));
         end
         savedAlphabet.letters=[];
         savedAlphabet.images={};
         savedAlphabet.rect=[];
         for i=1:length(d)
            filename=fullfile(folder,d(i).name);
            savedAlphabet.images{i}=imread(filename,'png');
            savedAlphabet.letters(i)=urldecode(d(i).name);
            if isempty(savedAlphabet.images{i})
               error('Cannot read file "%s".',filename);
            end
            savedAlphabet.bounds{i}=RectOfMatrix(savedAlphabet.images{i});
            if isempty(savedAlphabet.rect)
               savedAlphabet.rect=savedAlphabet.bounds{i};
            else
               savedAlphabet.rect=UnionRect(savedAlphabet.rect,savedAlphabet.bounds{i});
            end
         end
         oo(condition).targetFontHeightOverNominal=1; % NAN should work, but doesn't yet.
         oo(condition).targetHeightOverWidth=RectHeight(savedAlphabet.rect)/RectWidth(savedAlphabet.rect);
%          oo(condition).letters=savedAlphabet.letters;
%          oo(condition).images=savedAlphabet.images;
         for cd=1:conditions
            for i=1:length(oo(cd).validKeys)
               oo(cd).responseKeys(i)=KbName(oo(cd).validKeys{i}); % this returns keyCode as integer
            end
         end
      end
      
      % Set o.targetHeightOverWidth
      if oo(condition).setTargetHeightOverWidth
         oo(condition).targetHeightOverWidth=oo(condition).setTargetHeightOverWidth
      end
      
      terminate=0;
      nominalOverMinimumSize=oo(condition).nominalAcuityDeg*pixPerDeg/oo(condition).minimumTargetPix;
      if streq(oo(condition).thresholdParameter,'spacing') && oo(condition).fixedSpacingOverSize
         nominalOverMinimumSize=min(nominalOverMinimumSize,oo(condition).nominalCriticalSpacingDeg*pixPerDeg/oo(condition).fixedSpacingOverSize/oo(condition).minimumTargetPix);
      end
      oo(condition).minimumViewingDistanceCm=10*ceil((2/nominalOverMinimumSize)*oo(condition).viewingDistanceCm/10);
      if nominalOverMinimumSize<2
         msg=sprintf('Please increase your viewing distance to at least %.0f cm. This is called "o.viewingDistanceCm" in your script.',oo(condition).minimumViewingDistanceCm);
         if oo(condition).useSpeech
            Speak('You are too close to the screen.');
            Speak(msg);
         end
         error(msg);
      end
      
      switch oo(condition).thresholdParameter
         case 'spacing',
            oo(condition).tGuess=log10(oo(condition).spacingDeg);
         case 'size',
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
   
   if oo(1).speakViewingDistance && oo(1).useSpeech
      Speak(sprintf('Please move the screen to be %.0f centimeters from your eye.',oo(condition).viewingDistanceCm));
   end
   
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
      ffprintf(ff,'%d: Viewing distance %.0f cm. (Must exceed %.0f cm.)\n',condition,oo(condition).viewingDistanceCm,oo(condition).minimumViewingDistanceCm);
   end
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
      ffprintf(ff,'%d: %s font. Alphabet ''%s'' and borderLetter ''%s''. o.targetHeightOverWidth %.2f\n',condition,oo(condition).targetFont,oo(condition).alphabet,oo(condition).borderLetter,oo(condition).targetHeightOverWidth);
   end % for condition=1:conditions
   for condition=1:conditions
      ffprintf(ff,'%d: Duration %.2f s.\n',condition,oo(condition).durationSec);
   end
   ffprintf(ff,'Viewing distance %.0f cm. ',oo(1).viewingDistanceCm);
   ffprintf(ff,'Screen width %.1f cm. ',screenWidthCm);
   ffprintf(ff,'pixPerDeg %.1f\n',pixPerDeg);
   
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
   ffprintf(ff,'%s, %s, %s, screen %d, %dx%d pixels, %.1fx%.1f cm\n',cal.processUserLongName,cal.machineName,cal.macModelName,cal.screen,RectWidth(stimulusRect),RectHeight(screenRect),screenWidthMm/10,screenHeightMm/10);
   assert(cal.screenWidthCm==screenWidthMm/10);
   ffprintf(ff,'(You can use System Preferences or Switch Res X, http://www.madrau.com/, to change resolution.)\n');
   %     ffprintf(ff,'%s %s\n',cal.machineName,cal.macModelName);
   %     ffprintf(ff,'cal.ScreenConfigureDisplayBrightnessWorks=%.0f;\n',cal.ScreenConfigureDisplayBrightnessWorks);
   %
   if computer.osx || computer.macintosh
      AutoBrightness(cal.screen,0);
   end
   cal.ScreenConfigureDisplayBrightnessWorks=1;
   if cal.ScreenConfigureDisplayBrightnessWorks
      cal.brightnessSetting=1;
      %         ffprintf(ff,'Turning autobrightness off. Setting "brightness" to %.2f, on a scale of 0.0 to 1.0;\n',cal.brightnessSetting);
      % Psychtoolbox Bug. Screen ConfigureDisplay claims that it will
      % silently do nothing if not supported. But when I used it on my
      % video projector, Screen gave a fatal error. That's ok, but how do
      % I figure out when it's safe to use?
      
      if computer.osx || computer.macintosh
         Screen('ConfigureDisplay','Brightness',cal.screen,cal.screenOutput,cal.brightnessSetting);
      end
   end
   for condition=1:conditions
      oo(condition).cal=cal;
   end
   
   rightBeep=MakeBeep(2000,0.05,44100);
   rightBeep(end)=0;
   wrongBeep=MakeBeep(500,0.5,44100);
   wrongBeep(end)=0;
   purr=MakeBeep(140,1.0,44100);
   purr(end)=0;
   Snd('Open');
   
   % Instructions
   Screen('FillRect',window,white);
   string=[sprintf('Hello %s,\n',oo(condition).observer)];
   string=[string sprintf('Please move the screen to be %.0f cm from your eye. Turn the computer sound on. ',oo(condition).viewingDistanceCm)];
   string=[string sprintf('You should have a piece of paper showing all the possible letters that can appear on the screen. You can respond by typing, speaking, or pointing to a letter on your piece of paper. ')];
   for condition=1:conditions
      if ~oo(condition).repeatedTargets && streq(oo(condition).thresholdParameter,'size')
         string=[string 'When you see one letter, please report it. '];
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
      string=[string 'When you see many letters, they are all repetitions of just two letters. Please report both. '];
   end
   string=[string '(Type slowly. Quit anytime by pressing ESCAPE.) Look in the middle of the screen, ignoring the edges of the screen. '];
   if any(isfinite([oo.durationSec]))
      string=[string 'It is very important that you be fixating the center of the crosshairs when the letters appear. '];
      string=[string 'To begin, please fixate the crosshairs below, and, while fixating, press the SPACEBAR. '];
   else
      string=[string 'Now, to begin, please press the SPACEBAR. '];
   end
   Screen('TextFont',window,oo(condition).textFont,0);
   Screen('TextSize',window,round(oo(condition).textSize*0.4));
   Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2015, Denis Pelli. All rights reserved.'),instructionalMargin,screenRect(4)-0.5*instructionalMargin,black,white,1);
   Screen('TextSize',window,oo(condition).textSize);
   DrawFormattedText(window,string,instructionalMargin,instructionalMargin-0.5*oo(1).textSize,black,length(instructionalTextLine)+3,[],[],1.1);
   Screen('Flip',window);
   SetMouse(screenRect(3),screenRect(4),window);
   answer=GetKeypress([spaceKey escapeKey],oo(condition).deviceIndex, oo(condition).simulateGetChar);
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
   condList=[];
   for condition=1:conditions
      % Run the specified number of presentations of each condition, in random
      % order
      condList = [condList repmat(condition,1,oo(condition).presentations)];
      oo(condition).spacingsSequence=Shuffle(oo(condition).spacingsSequence);
      oo(condition).q=QuestCreate(oo(condition).tGuess,oo(condition).tGuessSd,oo(condition).pThreshold,oo(condition).beta,delta,gamma,grain,range);
      xT=oo(condition).fix.x+oo(condition).eccentricityPix; % target
      yT=oo(condition).fix.y; % target
   end
   condList=Shuffle(condList);
   for presentation=1:length(condList)
      easyModulus=ceil(1/oo(condList(presentation)).fractionEasyTrials-1);
      if mod(presentation-1,easyModulus)==0
         % do this trial twice: hard then easy.
         easyList=0:1;
      else
         % do it once: hard.
         easyList=0;
      end
      for easyPresentation=easyList
         condition=condList(presentation);
         if oo(condition).useQuest
            intensity=QuestQuantile(oo(condition).q);
            if oo(condition).measureBeta
               offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
               intensity=intensity+offsetToMeasureBeta(1);
            end
            if easyPresentation
               intensity=intensity+1.0;
%                fprintf('**EASY intensity %.1f\n',intensity);
            else
%                fprintf('*HARD intensity %.1f\n',intensity);
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
            oo(condition).spacingDeg=oo(condition).spacingsSequence(oo(condition).responseCount/2);
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
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetFontHeightOverNominal %.2f, targetPix %.0f, targetDeg %.1f, spacingPix %.0f, spacingDeg %.1f\n',condition,MFileLineNr,oo(condition).targetFontHeightOverNominal,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
         if oo(condition).repeatedTargets
            if RectHeight(stimulusRect)/RectWidth(stimulusRect) > oo(condition).targetHeightOverWidth;
               minSpacesY=4;
               minSpacesX=2;
            else
               minSpacesY=2;
               minSpacesX=4;
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
         end
         oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.1f, spacingPix %.0f, spacingDeg %.1f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
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
                  if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.1f, spacingPix %.0f, spacingDeg %.1f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
               else % eccentricity not zero
                  spacingPix=min(oo(condition).eccentricityPix,spacingPix); % Inner flanker must be between fixation and target.
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
         if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.1f, spacingPix %.0f, spacingDeg %.1f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
         oo(condition).fix.targetHeightPix=oo(condition).targetPix;
         oo(condition).fix.bouma=max(0.5,(spacingOuter+oo(condition).targetPix/2)/oo(condition).eccentricityPix);
         fixationLines=ComputeFixationLines(oo(condition).fix);
         if ~oo(condition).repeatedTargets
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
         end
         Screen('Flip',window); % blank display, except perhaps fixation
         if isfinite(oo(condition).durationSec)
            WaitSecs(1); % duration of fixation display
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
         end
         stimulus=Shuffle(oo(condition).alphabet);
         stimulus=stimulus(1:3); % three random letters, all different.
         if oo(condition).measureThresholdVertically
            sizePix=round(oo(condition).targetPix/oo(condition).targetFontHeightOverNominal);
            oo(condition).targetPix=sizePix*oo(condition).targetFontHeightOverNominal;
         else
            sizePix=round(oo(condition).targetPix/oo(condition).targetFontHeightOverNominal*oo(condition).targetHeightOverWidth);
            oo(condition).targetPix=sizePix*oo(condition).targetFontHeightOverNominal/oo(condition).targetHeightOverWidth;
         end
         oo(condition).targetDeg=oo(condition).targetPix/pixPerDeg;
         
         % Create textures, one per letter
         letters=[oo(condition).alphabet oo(condition).borderLetter];
         if oo(condition).measureThresholdVertically
            canvasRect=[0 0 oo(condition).targetPix oo(condition).targetPix];
         else
            canvasRect=[0 0 oo(condition).targetPix oo(condition).targetPix]*oo(condition).targetHeightOverWidth;
         end
         black=0;
         white=255;
         if oo(condition).readAlphabetFromDisk
            letters=[oo(condition).alphabet oo(condition).borderLetter];
            for i=1:length(letters)
               which=strfind([savedAlphabet.letters],letters(i));
               if length(which)~=1
                  error('Letter %c is not in saved "%s" alphabet "%s".',letters(i),oo(condition).targetFont,savedAlphabet.letters);
               end
               assert(length(which)==1);
               letterImage=savedAlphabet.images{which};
               letterStruct(i).texture=Screen('MakeTexture',window,letterImage);
               letterStruct(i).rect=Screen('Rect',letterStruct(i).texture);
               % Screen DrawTexture will scale and stretch, as needed.
            end
         else
            % Get bounds of font
            scratchWindow=Screen('OpenOffscreenWindow',window,[],canvasRect*4,8,0);
            if ~isempty(oo(condition).targetFontNumber)
               Screen('TextFont',scratchWindow,oo(condition).targetFontNumber);
               [font,number]=Screen('TextFont',scratchWindow);
               assert(number==oo(condition).targetFontNumber);
            else
               Screen('TextFont',scratchWindow,oo(condition).targetFont);
               font=Screen('TextFont',scratchWindow);
               assert(streq(font,oo(condition).targetFont));
            end
            Screen('TextSize',scratchWindow,sizePix);
            for i=1:length(letters)
               lettersInCells{i}=letters(i);
               letterStruct(i).bounds=TextBounds(scratchWindow,letters(i),1);
            end
            bounds=TextBounds(scratchWindow,lettersInCells,1);
            for i=1:length(letters)
               desiredBounds=CenterRect(letterStruct(i).bounds,bounds);
               letterStruct(i).dx=desiredBounds(1)-letterStruct(i).bounds(1);
               letterStruct(i).width=RectWidth(letterStruct(i).bounds);
            end
            oo(condition).meanOverMaxTargetWidth=mean([letterStruct.width])/RectWidth(bounds);
            Screen('Close',scratchWindow);
            
            % Create texture for each letter
            canvasRect=bounds;
            canvasRect=OffsetRect(canvasRect,-canvasRect(1),-canvasRect(2));
            fprintf('%d: textSize %.0f, "%s" height %.0f, width %.0f, bounds %.0f %.0f %.0f %.0f\n',condition,sizePix,letters,RectHeight(bounds),RectWidth(bounds),bounds);
            for i=1:length(letters)
               [letterStruct(i).texture,letterStruct(i).rect]=Screen('OpenOffscreenWindow',window,[],canvasRect,8,0);
               if ~isempty(oo(condition).targetFontNumber)
                  Screen('TextFont',letterStruct(i).texture,oo(condition).targetFontNumber);
                  [font,number]=Screen('TextFont',letterStruct(i).texture);
                  assert(number==oo(condition).targetFontNumber);
               else
                  Screen('TextFont',letterStruct(i).texture,oo(condition).targetFont);
                  font=Screen('TextFont',letterStruct(i).texture);
                  assert(streq(font,oo(condition).targetFont));
               end
               Screen('TextSize',letterStruct(i).texture,sizePix);
               Screen('FillRect',letterStruct(i).texture,white);
               Screen('DrawText',letterStruct(i).texture,letters(i),-bounds(1)+letterStruct(i).dx,-bounds(2)-textYOffset,black,white,1);
            end
         end
         if oo(condition).displayAlphabet
            for i=1:length(letters)
               r=[0 0 RectWidth(letterStruct(i).rect) RectHeight(letterStruct(i).rect)];
               Screen('DrawTexture',window,letterStruct(i).texture,[],OffsetRect(r,i*RectWidth(r),RectHeight(r)));
               Screen('FrameRect',window,0,OffsetRect(r,i*RectWidth(r),RectHeight(r)));
            end
            Screen('Flip',window);
            Speak('Click to continue');
            GetClicks;
         end
         
         % Create texture for each line, for first 3 lines. The rest are the
         % copies.
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
         if ~oo(condition).repeatedTargets
            xStimulus=[xF xT xFF];
            yStimulus=[yF yT yFF];
            clear textures dstRects
            
            
            for textureIndex=1:3
               which=strfind(letters,stimulus(textureIndex));
               assert(length(which)==1)
               textures(textureIndex)=letterStruct(which).texture;
               r=round(letterStruct(which).rect);
               oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
               if oo(condition).setTargetHeightOverWidth
                  r=round(ScaleRect(letterStruct(which).rect,oo(condition).targetHeightOverWidth/oo(condition).setTargetHeightOverWidth,1));
                  oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
                  %                      dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
               end
               if oo(condition).measureThresholdVertically
                  heightPix=oo(condition).targetPix;
               else
                  heightPix=oo(condition).targetHeightOverWidth*oo(condition).targetPix;
               end
               r=round((heightPix/RectHeight(letterStruct(which).rect))*letterStruct(which).rect);
               dstRects(1:4,textureIndex)=OffsetRect(r,round(xStimulus(textureIndex)-xPix/2),round(yStimulus(textureIndex)-yPix/2));
               if oo(condition).printSizeAndSpacing
                  fprintf('xPix %.0f, yPix %.0f, RectWidth(r) %.0f, RectHeight(r) %.0f\n',xPix,yPix,RectWidth(r),RectHeight(r));
               end
            end
            if ~streq(oo(condition).thresholdParameter,'spacing')
               % Show only the target, omitting both flankers.
               textures=textures(2);
               dstRects=dstRects(1:4,2);
            end
         else
            xMin=xT-xSpacing*floor((xT-0.5*xPix)/xSpacing);
            xMax=xT+xSpacing*floor((RectWidth(stimulusRect)-xT-0.5*xPix)/xSpacing);
            yMin=yT-ySpacing*floor((yT-0.5*yPix)/ySpacing);
            yMax=yT+ySpacing*floor((RectHeight(stimulusRect)-yT-0.5*yPix)/ySpacing);
            if oo(condition).speakSizeAndSpacing; Speak(sprintf('%.0f rows and %.0f columns',1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing));end
            if oo(condition).printSizeAndSpacing; fprintf('%d: %.1f rows and %.1f columns, target xT %.0f, yT %.0f\n',MFileLineNr,1+(yMax-yMin)/ySpacing,1+(xMax-xMin)/xSpacing,xT,yT); end;
            if oo(condition).printSizeAndSpacing; fprintf('%d: %d: targetPix %.0f, targetDeg %.1f, spacingPix %.0f, spacingDeg %.1f\n',condition,MFileLineNr,oo(condition).targetPix,oo(condition).targetDeg,spacingPix,oo(condition).spacingDeg); end;
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
                  which=strfind(letters,letter);
                  assert(length(which)==1)
                  textures(textureIndex)=letterStruct(which).texture;
                  % fprintf('textureIndex %d,x %d, whichTarget %d, letter %c, which %d, texture %d\n',textureIndex,x,whichTarget,letter,which,textures(textureIndex));
                  xPos=round(x-xPix/2);
                  
                  % Compute o.targetHeightOverWidth, and, if requested,
                  % o.setTargetHeightOverWidth
                  r=round(letterStruct(which).rect);
                  oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
                  if oo(condition).setTargetHeightOverWidth
                     r=round(ScaleRect(letterStruct(which).rect,oo(condition).targetHeightOverWidth/oo(condition).setTargetHeightOverWidth,1));
                     oo(condition).targetHeightOverWidth=RectHeight(r)/RectWidth(r);
                     dstRects(1:4,textureIndex)=OffsetRect(round(r),xPos,0);
                  else
                     if oo(condition).measureThresholdVertically
                        heightPix=oo(condition).targetPix;
                     else
                        heightPix=oo(condition).targetHeightOverWidth*oo(condition).targetPix;
                     end
                     dstRects(1:4,textureIndex)=OffsetRect(round((heightPix/RectHeight(letterStruct(which).rect))*letterStruct(which).rect),xPos,0);
                  end
                  % One dst rect for each letter in the line.
                  if oo(condition).showLineOfLetters
                     r=Screen('Rect',textures(textureIndex));
                     Screen('DrawTexture',window,textures(textureIndex),r,dstRects(1:4,textureIndex));
                     Screen('FrameRect',window,0,dstRects(1:4,textureIndex));
                     fprintf('x %.0f, xPos %.0f, dstRects(1:4,%d) %.0f %.0f %.0f %.0f\n',x,xPos,textureIndex,dstRects(1:4,textureIndex));
                  end
                  textureIndex=textureIndex+1;
               end
               if oo(condition).showLineOfLetters
                  Screen('Flip',window);
                  Speak('Line of letters. Click to continue.');
                  GetClicks;
               end
               % Create a texture holding one line of letters.
               [lineTexture(lineIndex),lineRect{lineIndex}]=Screen('OpenOffscreenWindow',window,[],[0 0 RectWidth(stimulusRect) RectHeight(canvasRect)],8,0);
               Screen('FillRect',lineTexture(lineIndex),white);
               r=Screen('Rect',textures(1));
               Screen('DrawTextures',lineTexture(lineIndex),textures,r,dstRects);
            end
            clear textures dstRects
            lineIndex=1;
            for y=yMin:ySpacing:yMax
               if ismember(y,[yMin yMax])
                  which=1;
               else
                  which=2+mod(lineIndex,2);
               end
               textures(lineIndex)=lineTexture(which);
               dstRects(1:4,lineIndex)=OffsetRect(lineRect{1},0,round(y-RectHeight(lineRect{1})/2));
               %                 fprintf('line %d, which %d, texture %d, dstRect %d %d %d %d\n',lineIndex,which,lineTexture(which),dstRects(1:4,lineIndex));
               lineIndex=lineIndex+1;
            end
         end
         Screen('DrawTextures',window,textures,[],dstRects);
         if oo(condition).frameTheTarget
            letterRect=OffsetRect([-0.5*xPix -0.5*yPix 0.5*xPix 0.5*yPix],xT,yT);
            Screen('FrameRect',window,[255 0 0],letterRect);
            fprintf('%d: screenHeight %d, letterRect height %.0f, targetPix %.0f, textSize %.0f, xPix %.0f, yPix %.0f\n',condition,RectHeight(stimulusRect),RectHeight(letterRect),oo(condition).targetPix,Screen('TextSize',window),xPix,yPix);
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
         Screen('Flip',window); % show target and flankers
         % Discard all the textures, to free graphics memory.
         for i=1:length(letterStruct)
            Screen('Close',letterStruct(i).texture);
         end
         if exist('lineTexture','var')
            for i=1:length(lineTexture)
               Screen('Close',lineTexture(i));
            end
         end
         if oo(condition).repeatedTargets
            targets=stimulus(1:2);
         else
            targets=stimulus(2);
         end
         if ~oo(condition).repeatedTargets
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
         end
         if isfinite(oo(condition).durationSec)
            WaitSecs(oo(condition).durationSec); % display of letters
            Screen('Flip',window); % remove letters
            WaitSecs(0.2); % pause before response screen
            if ~oo(condition).repeatedTargets
               Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
            end
            Screen('TextFont',window,oo(condition).textFont,0);
            Screen('TextSize',window,oo(condition).textSize);
            Screen('DrawText',window,'Type your response, or ESCAPE to quit.',100,100,black,white,1);
            Screen('DrawText',window,sprintf('Presentation %d of %d. Run %d of %d',presentation,length(condList),run,runs),screenRect(3)-300,100,black,white,1);
            if ~isempty(oo(condition).targetFontNumber)
               Screen('TextFont',window,oo(condition).targetFontNumber);
               [font,number]=Screen('TextFont',window);
               assert(number==oo(condition).targetFontNumber);
            else
               Screen('TextFont',window,oo(condition).targetFont);
               font=Screen('TextFont',window);
               assert(streq(font,oo(condition).targetFont));
            end
            x=100;
            y=stimulusRect(4)-50;
            for a=oo(condition).alphabet
               [x,y]=Screen('DrawText',window,a,x,y,black,white,1);
               x=x+oo(condition).textSize/2;
            end
            Screen('TextFont',window,oo(condition).textFont,0);
            Screen('Flip',window); % display response screen
         end
         responseString='';
         for i=1:length(targets)
            while(1)
               answer=GetKeypress([escapeKey oo(condition).responseKeys],oo(condition).deviceIndex,oo(condition).simulateGetChar); % no filtering!
               % If already recorded, then wait for press for the next target!
               if ~ismember(answer,responseString);break;end
            end
            if streq(answer,'ESCAPE')
               ListenChar(0);
               ffprintf(ff,'*** Observer typed <escape>. Run terminated.\n');
               terminate=1;
               break;
            end
            reportedTarget = oo(condition).alphabet(ismember(upper(oo(condition).alphabet),upper(answer)));
            if oo(condition).speakEachLetter && oo(condition).useSpeech
               % speak the target 1 observer saw, not the keyCode '1!'
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
         if oo(condition).speakEncouragement && oo(condition).useSpeech && ~terminate
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
         assert(length(targets)==length(responseString))
         responses=sort(targets)==sort(responseString);
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
      end
      if terminate
         break;
      end
   end % for presentation=1:length(condList)
   
   Screen('FillRect',window);
   %         Screen('DrawText',window,'Run completed',100,750,black,white,1);
   Screen('Flip',window);
   if oo(1).useSpeech
      Speak('Congratulations.  This run is done.');
   end
   ListenChar(0); % flush and reenable keyboard
   Snd('Close');
   Screen('CloseAll');
   ShowCursor;
   trials=0;
   oo(1).totalSecs=GetSecs-oo(1).beginSecs;
   for condition=1:conditions
      trials=trials+oo(condition).responseCount;
   end
   ffprintf(ff,'Took %.0f s for %.0f trials, or %.0f s/trial.\n',oo(1).totalSecs,trials,oo(1).totalSecs/trials);
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
   sca; % screen close all. This cleans up without canceling the error message.
   ListenChar(0);
   % Some of these functions spoil psychlasterror, so i don't use them.
   %     Snd('Close');
   %     ShowCursor;
   if exist('dataFid','file') && dataFid~=-1
      fclose(dataFid);
      dataFid=-1;
   end
   psychrethrow(psychlasterror);
end
end
