function oo=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. CriticalSpacing may adjust some of
% your parameters to satisfy physical constraints. Constraints include the
% screen size and the maximum possible contrast.
%
% MATLAB: To run this program you need a computer, preferably a Macintosh
% laptop, with MATLAB and the Psychtoolbox installed. You must install the
% Sloan.otf font file in one of your computer OS font folders.
%
% MACINTOSH (or Windows or Linux) LAPTOP  This program should run with
% little or no modification on any computer with MATLAB and Psychtoolbox.
% However, I developed it on a Mac, so there may be wrinkles to iron out on
% Windows or Linux. A Macintosh laptop is ideal. On a Mac laptop, the
% software automatically reads the screen size.
%
% WIRELESS OR LONG-CABLE KEYBOARD. A wireless keyboard or long keyboard
% cable is highly desirable as the viewing distance will be 3 m or more. If
% you must use the laptop keyboard then have the experimenter type the
% observer's verbal answers. I like this $86 solar-powered wireless, for
% which the batteries never run out: Logitech Wireless Solar Keyboard K760
% for Mac/iPad/iPhone http://www.amazon.com/gp/product/B007VL8Y2C
%
% SLOAN FONT. Please copy the font file "Sloan.otf" from the
% CriticalSpacing folder to one of your computer OS font folders. Once
% you've installed the font, quit and restart MATLAB to get it to notice
% the newly available font.
%
% CriticalSpacing.m is meant to be driven by a brief user-written script. I
% have provided runCriticalSpacing as a example. Many parameters
% controlling the behavior of CriticalSpacing are specifed in the fields of
% a struct called "o". If you provide several, as an o array, then
% CriticalSpacing runs all the conditions interleaved.
% CriticalSpacing asks for the observer's name and presents a page of
% instructions. The rest is just eye charts. Adults find it easy and
% intuitive. I don't know whether it's yet ready for children. I welcome
% suggestions. The targets are currently drawn from 9 letters of the Sloan
% font: DHKNORSVZ.
%
% ESCAPE. Try running runCriticalSpacing. It will measure four thresholds.
% You can always terminate the current run by hitting Escape.
% CriticalSpacing will then print out results so far and begin the next
% run.
%
% RESPONSE PAGE. Inside the CriticalSpacing folder you'll find a file
% "Response page.pdf" that should be printed and given to the observer. It
% shows the possible letters: DHKNORSVZ. Adults will find it helpful to
% consult this page while choosing an answer when they have little idea
% what letter the target(s) might be. Children may prefer to point at the
% target letters, one by one, on the response page.
%
% ILLITERATE FONT: I imagine that we might find a set of icons for an
% illiterate font. I can easily modify the program to use them instead of
% Sloan.
%
% CriticalSpacing measures threshold spacing or size (i.e. acuity). This
% program measures the critical spacing of crowding in either of two
% directions, selected by the variable "o.radialOrTangential". Target size
% can be made proportional to spacing, allowing measurement of critical
% spacing without knowing what the acuity, because we use the largest
% possible letter for each spacing. When the flankers are radial, the
% specified spacing refers to the inner flanker, between target and
% fixation. We define scaling eccentricity as eccentricity plus 0.45 deg.
% The critical spacing of crowding is proportional to the scaling
% eccentricity. The outer-flanker is at scaling eccentricity that has the
% same ratio to the target scaling eccentricity, as the target scaling
% eccentricity does to the inner-flanker scaling eccentricity.
%
% Copyright 2015, Denis Pelli, denis.pelli@nyu.edu
if nargin<1 || ~exist('oIn','var')
    oIn.noInputArgument=1;
end
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this file
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','SkipSyncTests',1);
Screen('Preference','SuppressAllWarnings',1);

% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.negativeFeedback=1;
o.encouragement=0;
o.repeatedTargets=1;
o.useFractionOfScreen=0;
% o.observer='junk';
% o.observer='Shivam'; % specify actual observer name
o.observer=''; % Name is requested at beginning of run.
o.useScreenCopyWindow=0; % Faster, but doesn't work on all Macs.
o.quit=0;
o.viewingDistanceCm=300;
o.flipScreenHorizontally=0;
o.thresholdParameter='spacing';
o.useQuest=1; % true(1) or false(0)
% o.thresholdParameter='size';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
% o.sizeProportionalToSpacing=0; % Requests size proportional to spacing.
o.eccentricityDeg=0; % location of target, relative to fixation, in degrees
% o.eccentricityDeg=16;
% o.radialOrTangential='tangential'; % values 'radial', 'tangential'
o.radialOrTangential='radial'; % values 'radial', 'tangential'
o.durationSec=inf; % duration of display of target and flankers
screenRect= Screen('Rect',0);
o.fixationLocation='center'; % 'left', 'right'
o.trials=40; % number of trials for the threshold estimate
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf;
o.fixationLineWeightDeg=0.005;
o.measureBeta=0;
o.task='identify';
o.announceDistance=0;
o.usePurring=1;
o.minimumTargetPix=8;
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o.textSizeDeg=0.4;
o.deviceIndex=-3; % all keyboard and keypad devices
if o.measureBeta
    o.trials=200;
    o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
end
% DEBUGGING AIDS
o.frameTheTarget=0;
o.printSizeAndSpacing=0;
o.printScreenResolution=0;

o.beginningTime=now;
timeVector=datevec(o.beginningTime);
stack=dbstack;
if length(stack)==1;
    o.functionNames=stack.name;
else
    o.functionNames=[stack(2).name '-' stack(1).name];
end

% Replicate o, once per supplied condition.
conditions=length(oIn);
oo(1:conditions)=o;

% All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
% o is a single struct, and oIn may be an array of structs.
for condition=1:conditions
    fields=fieldnames(oIn(condition));
    for i=1:length(fields)
        oo(condition).(fields{i})=oIn(condition).(fields{i});
    end
end

% Set up for KbCheck
% we can safely use this mode AND collect kb responses without worrying
% about writing to MATLAB console/editor
ListenChar(2); % no echo
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]);
Screen('Preference','SkipSyncTests',1);
escapeKey=KbName('ESCAPE');
spaceKey=KbName('space');
for condition=1:conditions
    for i=1:length(oo(condition).alphabet)
        oo(condition).responseKeys(i)=KbName(oo(condition).alphabet(i));
    end
end

% Set up for Screen
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',0);
screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',0);
if oo(condition).useFractionOfScreen
    screenRect=round(oo(condition).useFractionOfScreen*screenRect);
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
    
    screenRect=Screen('Rect',window);
    screenWidth=RectWidth(screenRect);
    screenHeight=RectHeight(screenRect);
    pixPerDeg=screenWidth/(screenWidthCm*57/oo(condition).viewingDistanceCm);
    for condition=1:conditions
        % Adjust textSize so our string fits on screen.
        oo(condition).textSize=round(oo(condition).textSizeDeg*pixPerDeg);
        Screen('TextSize',window,oo(condition).textSize);
        Screen('TextFont',window,oo(condition).textFont);
        boundsRect=Screen('TextBounds',window,'Hi. Please slowly type your name followed by RETURN.');
        fraction=RectWidth(boundsRect)/(screenWidth-100);
        oo(condition).textSize=round(oo(condition).textSize/fraction);
        % The TextBounds seem to be wrong on Windows, so we enforce a
        % reasonable textSize.
        oo(condition).textSize=min(oo(condition).textSize,round((screenWidth-100)/25)); % For Windows
    end
    if IsWindows
        % The high-quality text renderer on Windows clips the Sloan font.
        % So we select the low-quality renderer instead.
        Screen('Preference','TextRenderer',0);
    end
    
    % Observer name
    if length(oo(1).observer)==0
        ListenChar(0); % flush
        ListenChar(2);
        %         ListenChar;
        Screen('TextSize',window,oo(1).textSize);
        Screen('TextFont',window,oo(1).textFont);
        Screen('DrawText',window,'Hi. Please slowly type your name followed by RETURN.',50,screenRect(4)/2-1.5*oo(1).textSize,black,white,1);
        name=GetEchoString(window,'Name:',50,screenRect(4)/2,black,white,1, o.deviceIndex);
        ListenChar(0);
        for i=1:conditions
            oo(i).observer=name;
        end
        Screen('FillRect',window);
    end
    ListenChar(2); % no echo
    
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
    ffprintf(ff,'%s %s\n',oo(1).functionNames,datestr(now));
    ffprintf(ff,'Saving results in:\n');
    ffprintf(ff,'%s.txt and "".mat\n',oo(1).dataFilename);
    
    if oo(1).hiDPIMultiple~=1
        ffprintf(ff,'HiDPI: ');
        if ismac
            str='Your Retina display';
        else
            str='Your display';
        end
        ffprintf(ff,'%s has a dual-resolution HiDPI mode.\n',str);
        resolution=Screen('Resolution',oo(1).screen);
        ffprintf(ff,'We are using a %d x %d buffer to drive %d x %d pixels.\n',screenBufferRect(3),screenBufferRect(4),resolution.width,resolution.height);
        ffprintf(ff,'You can use Switch Res X (http://www.madrau.com/) to select a pure resolution (not HiDPI).\n');
    end
    
    for condition=1:conditions
        %         screenRect=Screen('Rect',window);
        %         screenWidth=RectWidth(screenRect);
        %         screenHeight=RectHeight(screenRect);
        %         pixPerDeg=screenWidth/(screenWidthCm*57/oo(condition).viewingDistanceCm);
        %         oo(condition).textSize=round(oo(condition).textSizeDeg*pixPerDeg);
        %         Screen('TextSize',window,oo(condition).textSize);
        %         Screen('TextFont',window,oo(condition).textFont);
        %         boundsRect=Screen('TextBounds',window,'Hi. Please slowly type your name followed by RETURN.');
        %         fraction=RectWidth(boundsRect)/(screenWidth-100);
        %         if fraction>1
        %             oo(condition).textSize=round(oo(condition).textSize/fraction);
        %             Screen('TextSize',window,oo(condition).textSize);
        %         end
        
        if oo(condition).repeatedTargets
            oo(condition).presentations=ceil(oo(condition).trials/2);
            oo(condition).trials=2*oo(condition).presentations;
        else
            oo(condition).presentations=oo(condition).trials;
        end
        
        % prepare to draw fixation cross
        fixationCrossPix=round(oo(condition).fixationCrossDeg*pixPerDeg);
        fixationCrossPix=min(fixationCrossPix,2*screenWidth); % full width and height, can extend off screen
        fixationLineWeightPix=round(oo(condition).fixationLineWeightDeg*pixPerDeg);
        fixationLineWeightPix=max(1,fixationLineWeightPix);
        fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
        oo(condition).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
        switch oo(condition).fixationLocation
            case 'left',
                oo(condition).fix.x=50+screenRect(1);
            case 'center',
                oo(condition).fix.x=(screenRect(1)+screenRect(3))/2; % location of fixation
            case 'right',
                oo(condition).fix.x=screenRect(3)-50;
            otherwise
                error('Unknown o.fixationLocation %s',oo(condition).fixationLocation);
        end
        oo(condition).fix.x=round(oo(condition).fix.x);
        oo(condition).fix.y=round(RectHeight(screenRect)/2);
        oo(condition).eccentricityPix=round(oo(condition).eccentricityDeg*pixPerDeg);
        oo(condition).fix.eccentricityPix=oo(condition).eccentricityPix;
        oo(condition).fix.clipRect=screenRect;
        oo(condition).fix.fixationCrossPix=fixationCrossPix;
        oo(condition).fix.fixationCrossBlankedNearTarget=oo(condition).fixationCrossBlankedNearTarget;
        %         if ~oo(condition).repeatedTargets
        %             Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        %         end
        
        oo(condition).responseCount=1; % When we have two targets we get two responses for each displayed screen.
        oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
        oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(screenRect)-oo(condition).fix.x-pixPerDeg*oo(condition).targetHeightDeg)); % target fits on screen, with half-target margin.
        oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
        oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
        oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
        addonDeg=0.45;
        addonPix=pixPerDeg*addonDeg;
        oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
        if streq(oo(condition).thresholdParameter,'spacing') && streq(oo(condition).radialOrTangential,'radial')
            oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(screenRect)-oo(condition).fix.x-pixPerDeg*(oo(condition).spacingDeg+oo(condition).targetHeightDeg/2))); % flanker fits on screen.
            oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
            oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
            oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        end
        oo(condition).spacings=oo(condition).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
        oo(condition).spacingsSequence=repmat(oo(condition).spacings,1,ceil(oo(condition).presentations/length(oo(condition).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of presentations.
        if oo(condition).useQuest
            ffprintf(ff,'%d: Using QUEST to estimate threshold %s.\n',condition,oo(condition).thresholdParameter);
        else
            ffprintf(ff,'%d: Using "method of constant stimuli" fixed list of spacings.\n',condition);
        end
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        
        % prepare to draw fixation cross
        oo(condition).fix.targetHeightPix=oo(condition).targetHeightPix;
        fixationLines=ComputeFixationLines(oo(condition).fix);
        
        terminate=0;
        nominalOverPossibleSize=oo(condition).nominalAcuityDeg*pixPerDeg/oo(condition).minimumTargetPix;
        switch oo(condition).thresholdParameter
            case 'spacing',
                oo(condition).tGuess=log10(oo(condition).spacingDeg);
                if oo(1).sizeProportionalToSpacing
                    nominalOverPossibleSize=min(nominalOverPossibleSize,oo(1).sizeProportionalToSpacing*oo(1).nominalCriticalSpacingDeg*pixPerDeg/oo(condition).minimumTargetPix);
                end
            case 'size',
                oo(condition).tGuess=log10(oo(condition).targetHeightDeg);
        end
        if nominalOverPossibleSize<2
            Speak('You are too close to the screen.');
            msg=sprintf('Please increase your viewing distance to at least %.0f cm. This is called "viewingDistanceCm" in your script.',10*ceil((2/nominalOverPossibleSize)*oo(condition).viewingDistanceCm/10));
            Speak(msg);
            error(msg);
        end
        oo(condition).tGuessSd=2;
        oo(condition).pThreshold=0.7;
        oo(condition).beta=3;
        delta=0.01;
        gamma=1/length(oo(condition).alphabet);
        grain=0.01;
        range=6;
    end % for condition=1:conditions
    
    for condition=1:conditions
        if oo(condition).repeatedTargets
            ffprintf(ff,'%d: Two targets, repeated many times.\n',condition);
        else
            ffprintf(ff,'%d: One target.\n',condition);
        end
    end
    
    if oo(1).announceDistance
        Speak(sprintf('Please move the screen to be %.0f centimeters from your eye.',oo(condition).viewingDistanceCm));
    end
    
    cal.screen=max(Screen('Screens'));
    if cal.screen>0
        ffprintf(ff,'Using external monitor.\n');
    end
    for condition=1:conditions
        ffprintf(ff,'%d: ',condition);
        ffprintf(ff,'Observer %s, task %s, measure threshold %s, alternatives %d,  beta %.1f,\n',oo(condition).observer,oo(condition).task,oo(condition).thresholdParameter,length(oo(condition).alphabet),oo(condition).beta);
    end
    for condition=1:conditions
        if streq(oo(condition).thresholdParameter,'spacing')
            %             ffprintf(ff,'%d: Measuring threshold spacing of flankers\n',condition);
            if ~oo(condition).repeatedTargets
                if oo(condition).eccentricityDeg~=0
                    ffprintf(ff,'%d: Orientation %s\n',condition,oo(condition).radialOrTangential);
                else
                    switch oo(condition).radialOrTangential
                        case 'radial',
                            ffprintf(ff,'%d: Orientation %s\n',condition,'horizontal');
                        case 'tangential',
                            ffprintf(ff,'%d: Orientation %s\n',condition,'vertical');
                    end
                end
            end
        end
    end
    for condition=1:conditions
        if oo(condition).sizeProportionalToSpacing
            ffprintf(ff,'%d: Target scales with spacing: spacing is %.2f*size.\n',condition,1/oo(condition).sizeProportionalToSpacing);
        else
            if streq(oo(condition).thresholdParameter,'size')
                ffprintf(ff,'%d: Measuring threshold size, with no flankers.\n',condition);
            else
                ffprintf(ff,'%d: Target size %.2f deg, %.1f pixels.\n',condition,oo(condition).targetHeightDeg,oo(condition).targetHeightDeg*pixPerDeg);
            end
        end
    end
    for condition=1:conditions
        if oo(condition).sizeProportionalToSpacing
            ffprintf(ff,'%d: Minimum spacing is %.0f pixels, %.3f deg.\n',condition,oo(condition).minimumTargetPix/oo(condition).sizeProportionalToSpacing,oo(condition).minimumTargetPix/pixPerDeg/oo(condition).sizeProportionalToSpacing);
        end
    end % for condition=1:conditions
    for condition=1:conditions
        ffprintf(ff,'%d: Minimum letter size is %.0f pixels, %.3f deg.\n',condition,oo(condition).minimumTargetPix,oo(condition).minimumTargetPix/pixPerDeg);
    end % for condition=1:conditions
    for condition=1:conditions
        ffprintf(ff,'%d: %s font. Alphabet ''%s''.\n',condition,oo(condition).targetFont,oo(condition).alphabet);
    end % for condition=1:conditions
    for condition=1:conditions
        ffprintf(ff,'%d: Duration %.2f s.\n',condition,oo(condition).durationSec);
    end
    for condition=1:conditions
        ffprintf(ff,'%d: %.0f trials.\n',condition,oo(condition).trials);
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
    ffprintf(ff,'Computer: %s, %s, screen %d, %dx%d, %.1fx%.1f cm\n',cal.machineName,cal.macModelName,cal.screen,RectWidth(screenRect),RectHeight(screenRect),screenWidthMm/10,screenHeightMm/10);
    assert(cal.screenWidthCm==screenWidthMm/10);
    ffprintf(ff,'Computer account: %s.\n',cal.processUserLongName);
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
    purr=MakeBeep(300,0.6,44100);
    purr(end)=0;
    Snd('Open');
    
    % Instructions
    Screen('FillRect',window,white);
    string=[sprintf('Hello %s,\n\n',oo(condition).observer)];
    string=[string sprintf('Please move the screen to be %.0f cm from your eye.\n',oo(condition).viewingDistanceCm)];
    if any([oo.repeatedTargets])
        string=[string 'When you see many letters, they are all repetitions of just two letters. Please type both. '];
    end
    if ~all([oo.repeatedTargets])
        string=[string 'After each presentation of a few letters, please type the middle letter, ignoring any flankers. '];
    end
    string=[string 'Type slowly. Look in the middle area, ignoring the the edges of the screen. (Quit anytime by pressing ESCAPE.) '];
    string=[string 'Please be patient when waiting for letters to appear. '];
    if any(isfinite([oo.durationSec]))
        string=[string 'It is very important that you be fixating the center of the crosshairs when the letters appear. '];
        string=[string 'Please press the SPACEBAR to begin, while you fixate the crosshairs below. '];
    else
        string=[string 'Now, please press the SPACEBAR to begin. '];
    end
    Screen('TextFont',window,oo(condition).textFont);
    Screen('TextSize',window,round(oo(condition).textSize*0.7));
    Screen('DrawText',window,double('Crowding and Acuity Test, Copyright 2015, Denis Pelli'),50,screenRect(4)-oo(1).textSize,black,white,1); % ?shows up as garbage in MATLAB 2015a Linux 64-bit; Octave 4.0 Linux 64-bit, OSX 64bit MATLAB is okay though
    Screen('TextSize',window,oo(condition).textSize);
    DrawFormattedText(window,string,50,50-0.5*oo(1).textSize,black,52);
    Screen('Flip',window);
    SetMouse(screenRect(3),screenRect(4),window);
    answer=GetKeypress(0,[spaceKey escapeKey],o.deviceIndex);
    if streq(answer,'ESCAPE')
        Speak('Escape. This run is done.');
        ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
        o.quit=1;
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
        condition=condList(presentation);
        if oo(condition).useQuest
            intensity=QuestQuantile(oo(condition).q);
            if oo(condition).measureBeta
                offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
                intensity=intensity+offsetToMeasureBeta(1);
            end
            switch oo(condition).thresholdParameter
                case 'spacing',
                    oo(condition).spacingDeg=10^intensity;
                    if oo(condition).sizeProportionalToSpacing
                        oo(condition).targetHeightDeg=oo(condition).sizeProportionalToSpacing*oo(condition).spacingDeg;
                    end
                case 'size',
                    oo(condition).targetHeightDeg=10^intensity;
            end
        else
            oo(condition).spacingDeg=oo(condition).spacingsSequence(oo(condition).responseCount/2);
        end
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightPix=max(oo(condition).minimumTargetPix,oo(condition).targetHeightPix);
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        if streq(oo(condition).thresholdParameter,'size') && oo(condition).sizeProportionalToSpacing
            oo(condition).spacingDeg=oo(condition).targetHeightDeg/oo(condition).sizeProportionalToSpacing;
        end
        spacing=oo(condition).spacingDeg*pixPerDeg;
        if oo(condition).sizeProportionalToSpacing
            spacing=max(spacing,oo(condition).minimumTargetPix/oo(condition).sizeProportionalToSpacing);
        end
        if oo(condition).printSizeAndSpacing; fprintf('%d: targetPix %.0f, targetDeg %.1f, spacing %.0f, spacing deg %.1f\n',MFileLineNr,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,oo(condition).spacingDeg); end;
        if oo(condition).repeatedTargets
            if oo(condition).sizeProportionalToSpacing
                spacing=min(spacing,min(screenHeight,screenWidth)/(4+oo(condition).sizeProportionalToSpacing));
                oo(condition).targetHeightPix=oo(condition).sizeProportionalToSpacing*spacing;
            else
                spacing=min(spacing,(min(screenHeight,screenWidth)-oo(condition).targetHeightPix)/4);
            end
        end
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        if oo(condition).printSizeAndSpacing; fprintf('%d: targetPix %.0f, targetDeg %.1f, spacing %.0f, spacing deg %.1f\n',MFileLineNr,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,oo(condition).spacingDeg); end; 
        spacing=round(spacing);
        switch oo(condition).radialOrTangential
            case 'tangential'
                % flanker must fit on screen
                if oo(condition).sizeProportionalToSpacing
                    spacing=min(spacing,screenHeight/(2+oo(condition).sizeProportionalToSpacing));
                else
                    spacing=min(spacing,(screenHeight-oo(condition).targetHeightPix)/2);
                end
                assert(spacing>=0);
                xF=xT;
                xFF=xT;
                yF=yT-spacing;
                yFF=yT+spacing;
                % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacing,requestedSpacing/pixPerDeg,spacing/pixPerDeg);
                spacingOuter=0;
            case 'radial'
                if oo(condition).eccentricityPix==0
                    % flanker must fit on screen
                    if oo(condition).sizeProportionalToSpacing
                        spacing=min(spacing,screenWidth/(2+oo(condition).sizeProportionalToSpacing));
                    else
                        spacing=min(spacing,(screenWidth-oo(condition).targetHeightPix)/2);
                    end
                    assert(spacing>=0);
                    yF=yT;
                    yFF=yT;
                    xF=xT-spacing;
                    xFF=xT+spacing;
                    % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacing,requestedSpacing/pixPerDeg,spacing/pixPerDeg);
                    spacingOuter=0;
                    if oo(condition).printSizeAndSpacing; fprintf('%d: targetPix %.0f, targetDeg %.1f, spacing %.0f, spacing deg %.1f\n',MFileLineNr,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,oo(condition).spacingDeg); end; 
                else % eccentricity not zero
                    spacing=min(oo(condition).eccentricityPix,spacing); % Inner flanker must be between fixation and target.
                    if oo(condition).sizeProportionalToSpacing
                        spacing=min(spacing,xT/(1+oo(condition).sizeProportionalToSpacing/2)); % Inner flanker is on screen.
                        assert(spacing>=0);
                        for i=1:100
                            spacingOuter=(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix-spacing)-(oo(condition).eccentricityPix+addonPix);
                            assert(spacingOuter>=0);
                            if spacingOuter<=screenWidth-xT-spacing*oo(condition).sizeProportionalToSpacing/2; % Outer flanker is on screen.
                                break;
                            else
                                spacing=0.9*spacing;
                            end
                        end
                        if i==100
                            ffprintf(ff,'ERROR: spacingOuter %.1f pix exceeds max %.1f pix.\n',spacing,spacingOuter,screenWidth-xT-spacing*oo(condition).sizeProportionalToSpacing/2)
                            error('Could not make spacing small enough. Right flanker will be off screen. If possible, try using off-screen fixation.');
                        end
                    else
                        spacing=min(spacing,xT-oo(condition).targetHeightPix/2); % inner flanker on screen
                        spacingOuter=(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix-spacing)-(oo(condition).eccentricityPix+addonPix);
                        spacingOuter=min(spacingOuter,screenWidth-xT-oo(condition).targetHeightPix/2); % outer flanker on screen
                    end
                    assert(spacingOuter>=0);
                    spacing=oo(condition).eccentricityPix+addonPix-(oo(condition).eccentricityPix+addonPix)^2/(oo(condition).eccentricityPix+addonPix+spacingOuter);
                    assert(spacing>=0);
                    spacing=round(spacing);
                    xF=xT-spacing; % inner flanker
                    yF=yT; % inner flanker
                    xFF=xT+round(spacingOuter); % outer flanker
                    yFF=yT; % outer flanker
                end
        end
        oo(condition).spacingDeg=spacing/pixPerDeg;
        if streq(oo(condition).thresholdParameter,'spacing') && oo(condition).sizeProportionalToSpacing
            oo(condition).targetHeightDeg=oo(condition).sizeProportionalToSpacing*oo(condition).spacingDeg;
        end
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightPix=min(oo(condition).targetHeightPix,screenWidth);
        oo(condition).targetHeightPix=min(oo(condition).targetHeightPix,screenHeight);
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        if oo(condition).printSizeAndSpacing; fprintf('%d: targetPix %.0f, targetDeg %.1f, spacing %.0f, spacing deg %.1f\n',MFileLineNr,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,oo(condition).spacingDeg); end; 
        oo(condition).fix.targetHeightPix=oo(condition).targetHeightPix;
        oo(condition).fix.bouma=max(0.5,(spacingOuter+oo(condition).targetHeightPix/2)/oo(condition).eccentricityPix);
        fixationLines=ComputeFixationLines(oo(condition).fix);
        if ~oo(condition).repeatedTargets
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        Screen('Flip',window); % blank display, except perhaps fixation
        if ~oo(condition).repeatedTargets
            WaitSecs(1); % duration of fixation display
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        stimulus=Shuffle(oo(condition).alphabet);
        stimulus=stimulus(1:3); % three random letters, all different.
        %         ffprintf(ff,'%d: targetHeightPix %d, %.3f deg; spacing %d, %.3f deg\n',condition,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,spacing/pixPerDeg);
        if IsWindows
            textSizeScalar=1.336;
            textYOffset=0.75;
        else
            textYOffset=0;
            textSizeScalar=1.0;
        end
        Screen('textSize',window,round(oo(condition).targetHeightPix/textSizeScalar));
        Screen('TextFont',window,oo(condition).targetFont);
        %             rect=Screen('TextBounds',window,'N');
        %             ffprintf(ff,'TextSize %.1f, "N" width %.0f pix, height %.0f pix\n',targetHeightPix,RectWidth(rect),RectHeight(rect));
        if ~oo(condition).repeatedTargets
            Screen('DrawText',window,stimulus(2),xT-oo(condition).targetHeightPix/2,yT+(0.5-textYOffset)*oo(condition).targetHeightPix,black,white,1);
            if streq(oo(condition).thresholdParameter,'spacing')
                Screen('DrawText',window,stimulus(1),xF-oo(condition).targetHeightPix/2,yF+(0.5-textYOffset)*oo(condition).targetHeightPix,black,white,1);
                Screen('DrawText',window,stimulus(3),xFF-oo(condition).targetHeightPix/2,yFF+(0.5-textYOffset)*oo(condition).targetHeightPix,black,white,1);
            end
        else
            spacing=round(spacing);
            xMin=xT-spacing*floor((xT-0.5*oo(condition).targetHeightPix)/spacing);
            xMax=xT+spacing*floor((screenWidth-xT-0.5*oo(condition).targetHeightPix)/spacing);
            yMin=yT-spacing*floor((yT-0.5*oo(condition).targetHeightPix)/spacing);
            yMax=yT+spacing*floor((screenHeight-yT-0.5*oo(condition).targetHeightPix)/spacing);
            if oo(condition).printSizeAndSpacing; fprintf('%d: targetPix %.0f, targetDeg %.1f, spacing %.0f, spacing deg %.1f\n',MFileLineNr,oo(condition).targetHeightPix,oo(condition).targetHeightDeg,spacing,oo(condition).spacingDeg); end; 
            fprintf('x %d %d, y %d %d, screenRect %d %d %d %d, target %d, spacing %d\n', xMin,xMax,yMin,yMax,screenRect,oo(condition).targetHeightPix,spacing);
            for y=yMin:spacing:yMax
                whichTarget=mod(round((y-yMin)/spacing),2);
                if ~IsWindows && oo(condition).useScreenCopyWindow && y>=yMin+4*spacing && y<=yMax-2*spacing
                    dstRect=screenRect;
                    dstRect(2)=0;
                    dstRect(4)=spacing;
                    dstRect=OffsetRect(dstRect,0,y-round(spacing/2));
                    srcRect=OffsetRect(dstRect,0,-2*spacing);
                    Screen('CopyWindow',window,window,srcRect,dstRect);
                else
                    for x=xMin:spacing:xMax
                        whichTarget=mod(whichTarget+1,2);
                        if streq(oo(condition).thresholdParameter,'size')
                            whichTarget=x>mean([xMin xMax]);
                        end
                        if ismember(x,[xMin xMax]) || ismember(y,[yMin yMax])
                            letter='X';
                        else
                            letter=stimulus(1+whichTarget);
                        end
                        Screen('DrawText',window,letter,x-oo(condition).targetHeightPix/2,y+(0.5-textYOffset)*oo(condition).targetHeightPix,black,white,1);
                    end
                end
            end
        end
        if oo(condition).frameTheTarget
            letterRect=OffsetRect([-0.5 -0.5 0.5 0.5]*oo(condition).targetHeightPix,xT,yT);
            Screen('FrameRect',window,[255 0 0],letterRect);
            fprintf('screenHeight %d, letterRect height %d, targetHeightPix %d, textSize %d\n',screenHeight,RectHeight(letterRect),oo(condition).targetHeightPix,Screen('TextSize',window));
        end
        Screen('TextFont',window,oo(condition).textFont);
        if oo(condition).usePurring
            Snd('Play',purr);
        end
        Screen('Flip',window); % show target and flankers
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
            Screen('TextFont',window,oo(condition).textFont);
            Screen('TextSize',window,oo(condition).textSize);
            Screen('DrawText',window,'Type your response, or ESCAPE to quit.',100,100,black,white,1);
            Screen('DrawText',window,sprintf('Presentation %d of %d. Run %d of %d',presentation,length(condList),run,runs),screenRect(3)-300,100,black,white,1);
            Screen('TextFont',window,oo(condition).targetFont);
            x=100;
            y=screenRect(4)-50;
            for a=oo(condition).alphabet
                [x,y]=Screen('DrawText',window,a,x,y,black,white,1);
                x=x+oo(condition).textSize/2;
            end
            Screen('TextFont',window,oo(condition).textFont);
            Screen('Flip',window); % display response screen
        end
        responseString='';
        for i=1:length(targets)
            while(1)
                answer=GetKeypress(0,[escapeKey oo(condition).responseKeys],o.deviceIndex);
                answer=upper(answer);
                if ~ismember(answer,responseString)
                    break
                end
            end
            Speak(answer);
            if streq(answer,'ESCAPE')
                ListenChar(0);
                ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
                terminate=1;
                break;
            end
            if ismember(answer,targets)
                Snd('Play',rightBeep);
            else
                if oo(condition).negativeFeedback
                    Snd('Play',wrongBeep);
                end
            end
            responseString=[responseString answer];
        end
        %FlushEvents('keyDown');
        %ListenChar(0);
        if oo(condition).encouragement && ~terminate
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
        oo(condition).spacingDeg=spacing/pixPerDeg;
        for response=responses
            switch oo(condition).thresholdParameter
                case 'spacing',
                    oo(condition).results(oo(condition).responseCount,1:2)=[oo(condition).spacingDeg response];
                    %                     oo(condition).results(oo(condition).responseCount,2)=response;
                    oo(condition).responseCount=oo(condition).responseCount+1;
                    intensity=log10(oo(condition).spacingDeg);
                case 'size'
                    oo(condition).results(oo(condition).responseCount,1:2)=[oo(condition).targetHeightDeg response];
                    %                     oo(condition).results(oo(condition).responseCount,2)=response;
                    oo(condition).responseCount=oo(condition).responseCount+1;
                    intensity=log10(oo(condition).targetHeightDeg);
            end
            %             ffprintf(ff,'QuestUpdate %.3f deg\n',oo(condition).targetHeightDeg);
            oo(condition).q=QuestUpdate(oo(condition).q,intensity,response);
        end
    end % for presentation=1:length(condList)
    
    Screen('FillRect',window);
    %         Screen('DrawText',window,'Run completed',100,750,black,white,1);
    Screen('Flip',window);
    Speak('Congratulations.  This run is done.');
    ListenChar(0); % reenable keyboard echo
    Snd('Close');
    Screen('CloseAll');
    ShowCursor;
    for condition=1:conditions
        ffprintf(ff,'CONDITION %d **********\n',condition);
        % Ask Quest for the final estimate of threshold.
        t=QuestMean(oo(condition).q);
        sd=QuestSd(oo(condition).q);
        switch oo(condition).thresholdParameter
            case 'spacing',
                if ~oo(condition).repeatedTargets
                    switch(oo(condition).radialOrTangential)
                        case 'radial'
                            ffprintf(ff,'Radial spacing of far flanker from target.\n');
                        case 'tangential'
                            ffprintf(ff,'Tangential spacing up and down.\n');
                    end
                end
                ffprintf(ff,'Threshold log spacing deg (mean+-sd) is %.2f +-%.2f, which is %.3f deg.\n',t,sd,10^t);
                if oo(condition).responseCount>1
                    trials=QuestTrials(oo(condition).q);
                    if any(~isreal(trials.intensity))
                        error('trials.intensity returned by Quest should be real, but is complex.');
                    end
                    ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.3f           %.2f    %.2f    %d\n',[10.^trials.intensity;QuestP(oo(condition).q,trials.intensity-oo(condition).tGuess);trials.responses(2,:)./sum(trials.responses);sum(trials.responses)]);
                end
            case 'size',
                ffprintf(ff,'Threshold log size deg (mean+-sd) is %.2f +-%.2f, which is %.3f deg.\n',t,sd,10^t);
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
                    ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',oo(condition).observer,100*p,oo(condition).targetHeightDeg,oo(condition).eccentricityDeg,10^QuestMean(oo(condition).q));
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
    %     ListenChar(0); % flush
    %     ListenChar;
    %     Screen('CloseAll');
    %     Snd('Close');
    %     ShowCursor;
    if exist('dataFid','file') && dataFid~=-1
        fclose(dataFid);
        dataFid=-1;
    end
    psychrethrow(psychlasterror);
end
end
