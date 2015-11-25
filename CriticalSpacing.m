function o=CriticalSpacing(oIn)
% o=CriticalSpacing(o);
% Pass all your parameters in the "o" struct, which will be returned with
% all the results as additional fields. CriticalSpacing may adjust some of
% your parameters to satisfy physical constraints. Constraints include the
% screen size and the maximum possible contrast.
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
% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.repeatedLetters=1;
o.useFractionOfScreen=0;
o.observer='junk';
% o.observer='Shivam'; % specify actual observer name
o.useScreenCopyWindow=0; % Faster, but doesn't work on all Macs.
o.quit=0;
o.viewingDistanceCm=125;
o.thresholdParameter='spacing';
% o.thresholdParameter='size';
o.sizeProportionalToSpacing=1/1.4; % Requests size proportional to spacing.
% o.sizeProportionalToSpacing=0; % Requests size proportional to spacing.
o.eccentricityDeg=0; % location of target, relative to fixation, in degrees
% o.eccentricityDeg=16;
% IMPORTANT: WE WANT TO MEASURE CRITICAL SPACING BOTH RADIALLY AND
% TANGENTIALLY, IN RANDOM ORDER.
o.radialOrTangential='tangential'; % values 'radial', 'tangential'
% o.radialOrTangential='radial'; % values 'radial', 'tangential'
o.durationSec=inf; % duration of display of target and flankers
screenRect= Screen('Rect',0);
o.fixationLocation='center'; % 'left', 'right'
o.trials=80; % number of trials for the threshold estimate
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf;
o.fixationLineWeightDeg=0.005;
o.measureBeta=0;
o.task='identify';
o.announceDistance=0;
o.usePurring=1;
minimumTargetPix=8;
Screen('Preference', 'SkipSyncTests', 1);
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
o.textSizeDeg=0.4;
if o.measureBeta
    o.trials=200;
    o.offsetToMeasureBeta=-0.4:0.1:0.2; % offset of t, i.e. log signal intensity
end
o.beginningTime=now;
t=datevec(o.beginningTime);
stack=dbstack;
if length(stack)==1;
    o.functionNames=stack.name;
else
    o.functionNames=[stack(2).name '-' stack(1).name];
end
o.dataFilename=sprintf('%s-%s.%d.%d.%d.%d.%d.%d',o.functionNames,o.observer,round(t));
o.dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
if ~exist(o.dataFolder,'dir')
    success=mkdir(o.dataFolder);
    if ~success
        error('Failed attempt to create data folder: %s',o.dataFolder);
    end
end
dataFid=fopen(fullfile(o.dataFolder,[o.dataFilename '.txt']),'rt');
if dataFid~=-1
    error('Oops. There''s already a file called "%s.txt". Try again.',o.dataFilename);
end
[dataFid,msg]=fopen(fullfile(o.dataFolder,[o.dataFilename '.txt']),'wt');
if dataFid==-1
    error('%s. Could not create data file: %s',msg,[o.dataFilename '.txt']);
end
assert(dataFid>-1);
ff=[1 dataFid];
ffprintf(ff,'%s %s\n',o.functionNames,datestr(now));
ffprintf(ff,'Saving results in:\n');
ffprintf(ff,'%s .txt and .mat\n',o.dataFilename);

% Replicate o, once per supplied condition.
conditions=length(oIn);
oo(1:conditions)=o;
% All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
for condition=1:conditions
    fields=fieldnames(oIn(condition));
    for i=1:length(fields)
        oo(condition).(fields{i})=oIn(condition).(fields{i});
    end
end
switch o.fixationLocation
    case 'left',
        fix.x=50+screenRect(1);
    case 'center',
        fix.x=(screenRect(1)+screenRect(3))/2; % location of fixation
    case 'right',
        fix.x=screenRect(3)-50;
    otherwise
        error('Unknown o.fixationLocation %s',o.fixationLocation);
end
fix.y=RectHeight(screenRect)/2;

ffprintf(ff,'observer %s\n',oo(1).observer);

% Set up for KbCheck
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

%Set up for Screen
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',0);
screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',0);
if oo(condition).useFractionOfScreen
    screenRect=round(oo(condition).useFractionOfScreen*screenRect);
end

try
    window=Screen('OpenWindow',0,255,screenRect);
    for condition=1:conditions
        ffprintf(ff,'%d: ',condition);
        Screen('TextFont',window,oo(condition).textFont);
        screenRect= Screen('Rect', window);
        screenWidth=RectWidth(screenRect);
        screenHeight=RectHeight(screenRect);
        pixPerDeg=screenWidth/(screenWidthCm*57/oo(condition).viewingDistanceCm);
        oo(condition).eccentricityPix=round(oo(condition).eccentricityDeg*pixPerDeg);
        oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
        oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(screenRect)-fix.x-pixPerDeg*oo(condition).targetHeightDeg)); % target fits on screen, with half-target margin.
        oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
        oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
        oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
        addonDeg=0.45;
        addonPix=pixPerDeg*addonDeg;
        oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        if streq(oo(condition).thresholdParameter,'spacing') && streq(oo(condition).radialOrTangential,'radial')
            oo(condition).eccentricityPix=round(min(oo(condition).eccentricityPix,RectWidth(screenRect)-fix.x-pixPerDeg*(oo(condition).spacingDeg+oo(condition).targetHeightDeg/2))); % flanker fits on screen.
            oo(condition).eccentricityDeg=oo(condition).eccentricityPix/pixPerDeg;
            oo(condition).nominalAcuityDeg=0.029*(oo(condition).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
            oo(condition).targetHeightDeg=2*oo(condition).nominalAcuityDeg; % initial guess for threshold size.
            oo(condition).nominalCriticalSpacingDeg=0.3*(oo(condition).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
            oo(condition).spacingDeg=oo(condition).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        end
        oo(condition).spacings=oo(condition).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
        oo(condition).spacingsSequence=repmat(oo(condition).spacings,1,ceil(oo(condition).trials/length(oo(condition).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of trials.
        fixationCrossPix=round(oo(condition).fixationCrossDeg*pixPerDeg);
        fixationCrossPix=min(fixationCrossPix,2*screenWidth); % full width and height, can extend off screen
        fixationLineWeightPix=round(oo(condition).fixationLineWeightDeg*pixPerDeg);
        fixationLineWeightPix=max(1,fixationLineWeightPix);
        fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
        oo(condition).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
        useQuest=1; % true(1) or false(0)
        if useQuest
            ffprintf(ff,'Using QUEST to estimate threshold %s.\n',oo(condition).thresholdParameter);
        else
            ffprintf(ff,'Using "method of constant stimuli" fixed list of spacings.');
        end
        oo(condition).textSize=round(oo(condition).textSizeDeg*pixPerDeg);
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        terminate=0;
        switch oo(condition).thresholdParameter
            case 'spacing',
                oo(condition).tGuess=log10(oo(condition).spacingDeg);
            case 'size',
                oo(condition).tGuess=log10(oo(condition).targetHeightDeg);
                if oo(condition).nominalAcuityDeg*pixPerDeg<0.5*minimumTargetPix
                    ratio=0.5*minimumTargetPix/(oo(condition).nominalAcuityDeg*pixPerDeg); % too big
                    Speak('You are too close to the screen.');
                    msg=sprintf('Please increase viewing distance to at least %.0f cm.',ceil(ratio*oo(condition).viewingDistanceCm));
                    Speak(msg);
                    error(msg);
                end
        end
        oo(condition).tGuessSd=2;
        oo(condition).pThreshold=0.7;
        oo(condition).beta=3;
        delta=0.01;
        gamma=1/length(oo(condition).alphabet);
        grain=0.01;
        range=6;
    end % for condition=1:conditions
    if oo(1).announceDistance
        Speak(sprintf('Please make sure that your eye is %.0f centimeters from the screen.',oo(condition).viewingDistanceCm));
    end
    
    computer=Screen('Computer');
    cal.processUserLongName=computer.processUserLongName;
    cal.machineName=computer.machineName;
    cal.macModelName=MacModelName;
    cal.screen=max(Screen('Screens'));
    if cal.screen>0
        ffprintf(ff,'Using external monitor.\n');
    end
    for condition=1:conditions
        ffprintf(ff,'%d: ',condition);
        ffprintf(ff,'observer %s, task %s, measure threshold %s, alternatives %d,  beta %.1f,\n',oo(condition).observer,oo(condition).task,oo(condition).thresholdParameter,length(oo(condition).alphabet),oo(condition).beta);
    end
    for condition=1:conditions
        if streq(oo(condition).thresholdParameter,'spacing')
            ffprintf(ff,'%d: Measuring threshold spacing of flankers\n',condition);
            if ~oo(condition).repeatedLetters
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
            ffprintf(ff,'%d: Target scales with spacing: spacing= %.2f * size.\n',condition,1/oo(condition).sizeProportionalToSpacing);
            ffprintf(ff,'%d: Minimum spacing is %.0f pixels, %.3f deg.\n',condition,minimumTargetPix/oo(condition).sizeProportionalToSpacing,minimumTargetPix/pixPerDeg/oo(condition).sizeProportionalToSpacing);
        else
            if streq(oo(condition).thresholdParameter,'size')
                ffprintf(ff,'%d: Measuring threshold size, with no flankers.\n',condition);
            else
                ffprintf(ff,'%d: Target size %.2f deg, %.1f pixels.\n',condition,oo(condition).targetHeightDeg,oo(condition).targetHeightDeg*pixPerDeg);
            end
        end
    end
    for condition=1:conditions
        ffprintf(ff,'%d: Minimum letter size is %.0f pixels, %.3f deg.\n',condition,minimumTargetPix,minimumTargetPix/pixPerDeg);
    end % for condition=1:conditions
    for condition=1:conditions
        ffprintf(ff,'%d: %s font\n',condition,oo(condition).targetFont);
    end % for condition=1:conditions
    for condition=1:conditions
        ffprintf(ff,'%d: Duration %.2f s\n',condition,oo(condition).durationSec);
    end
    for condition=1:conditions
        ffprintf(ff,'%d: %.0f trials.\n',condition,oo(condition).trials);
    end
    ffprintf(ff,'Viewing distance %.0f cm. ',oo(1).viewingDistanceCm);
    ffprintf(ff,'Screen width %.1f cm. ',screenWidthCm);
    ffprintf(ff,'pixPerDeg %.1f\n',pixPerDeg);
    white=WhiteIndex(window);
    black=BlackIndex(window);
    rightBeep=MakeBeep(2000,0.05,44100);
    rightBeep(end)=0;
    wrongBeep=MakeBeep(500,0.5,44100);
    wrongBeep(end)=0;
    purr=MakeBeep(300,0.6,44100);
    purr(end)=0;
    Snd('Open');
    Screen('FillRect',window,white);
    Screen('TextSize',window,oo(condition).textSize);
    Screen('TextFont',window,oo(condition).textFont);
if 1
    string='Denis Pelli''s Crowding and Acuity Test © 2015\n\n';
    string=[string sprintf('Observer: %s\n\n',oo(condition).observer)];
    string=[string sprintf('Move this screen to be %.0f cm from your eye.\n',oo(condition).viewingDistanceCm)];
    if any([oo.repeatedLetters])
        string=[string 'When the screen is covered with letters, whether \nmixed or segregated, please type both letters.\n']
    end
    if ~all([oo.repeatedLetters])
        string=[string 'After each presentation of a few letters, please \ntype the target letter in the middle, ignoring any flankers.\n'];
    end
    if any(isfinite([oo.durationSec]))
        string=[string 'It is very important that you be fixating the center of the crosshairs when the letters appear. '];
        string=[string 'Please type the spacebar to begin, while you fixate the crosshairs below. '];
    else
        string=[string 'Type the spacebar to begin. '];
    end
    string=[string '\n\n(At any time, press ESCAPE to quit early.) '];
    DrawFormattedText(window,string,oo(1).textSize*3,oo(1).textSize*3,black,80);
else
    y=oo(1).textSize*3;
    x=oo(1).textSize*2.5;
    Screen('DrawText',window,sprintf('Observer: %s',oo(condition).observer),x,y,black,0,1); y=y+oo(1).textSize*3;
    Screen('DrawText',window,sprintf('Please make sure your eye is %.0f cm from the screen.',oo(condition).viewingDistanceCm),x,y,black,0,1); y=y+oo(1).textSize*1.5;
    if any([oo.repeatedLetters])
        Screen('DrawText',window,'When the screen is covered with letters, whether mixed or segregated, please type both letters.',x,y,black,0,1); y=y+oo(1).textSize*1.5;
    end
    if ~all([oo.repeatedLetters])
        Screen('DrawText',window,'After a presentation of just a few letters, please type the target letter in the middle, ignoring any flankers.',x,y,black,0,1); y=y+oo(1).textSize*1.5;
    end
    if any(isfinite([oo.durationSec]))
        Screen('DrawText',window,'It is very important that you be fixating the center of the crosshairs when the letters appear.',x,y,black,0,1); y=y+oo(1).textSize*1.5;
        Screen('DrawText',window,'Please type the spacebar to begin, while you fixate the crosshairs below.',x,y,black,0,1); y=y+oo(1).textSize*1.5;
    else
        Screen('DrawText',window,'Type the spacebar to begin.',x,y,black,0,1); y=y+oo(1).textSize*1.5;
    end
    y=y+oo(1).textSize*1.5;
    Screen('DrawText',window,'(At any time, press ESCAPE to quit early.)',x,y,black,0,1); y=y+oo(1).textSize*1.5;
end
    fix.eccentricityPix=oo(condition).eccentricityPix;
    fix.clipRect=screenRect;
    fix.fixationCrossPix=fixationCrossPix;
    for condition=1:conditions
        fix.oo(condition).fixationCrossBlankedNearTarget=oo(condition).fixationCrossBlankedNearTarget;
        fix.targetHeightPix=oo(condition).targetHeightPix;
        fixationLines=ComputeFixationLines(fix);
        if ~oo(condition).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        oo(condition).count=1;
    end % for condition=1:conditions
    Screen('Flip',window);
    SetMouse(screenRect(3),screenRect(4),window);
    input=GetKeypress(0,[spaceKey escapeKey]);
    if streq(input,'ESCAPE')
        Speak('Escape. Done.');
        ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
        o.quit=1;
        ShowCursor;
        sca;
        return
    end
    condList=[];
    for condition=1:conditions
        % Run the specified number of trials of each condition, in random
        % order
        condList = [condList repmat(condition,1,oo(condition).trials)];
        oo(condition).trial=0;
        oo(condition).spacingsSequence=Shuffle(oo(condition).spacingsSequence);
        oo(condition).q=QuestCreate(oo(condition).tGuess,oo(condition).tGuessSd,oo(condition).pThreshold,oo(condition).beta,delta,gamma,grain,range);
        xT=fix.x+oo(condition).eccentricityPix; % target
        yT=fix.y; % target
    end
    condList=Shuffle(condList);
    for trial=1:length(condList)
        condition=condList(trial);
        if useQuest
            intensity=QuestQuantile(oo(condition).q);
            if oo(condition).measureBeta
                offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
                intensity=intensity+offsetToMeasureBeta(1);
            end
            switch oo(condition).thresholdParameter
                case 'spacing',
                    oo(condition).spacingDeg=10^intensity;
                case 'size',
                    oo(condition).targetHeightDeg=10^intensity;
            end
        else
            oo(condition).spacingDeg=oo(condition).spacingsSequence(oo(condition).count/2);
        end
        if oo(condition).sizeProportionalToSpacing
            oo(condition).targetHeightDeg=oo(condition).spacingDeg*oo(condition).sizeProportionalToSpacing;
        end
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightPix=max(minimumTargetPix,oo(condition).targetHeightPix);
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        if oo(condition).sizeProportionalToSpacing
            oo(condition).spacingDeg=max(oo(condition).spacingDeg,oo(condition).targetHeightDeg/oo(condition).sizeProportionalToSpacing);
        else
            oo(condition).spacingDeg=max(oo(condition).spacingDeg,oo(condition).targetHeightDeg*1.2);
        end
        spacing=oo(condition).spacingDeg*pixPerDeg;
        spacing=min(spacing,screenHeight/3);
        spacing=max(spacing,0);
        spacing=round(spacing);
        switch oo(condition).radialOrTangential
            case 'tangential'
                % requestedSpacing=spacing;
                % flanker must fit on screen
                if oo(condition).sizeProportionalToSpacing
                    spacing=min(spacing,(screenHeight-yT)/(1+oo(condition).sizeProportionalToSpacing/2));
                    spacing=min(spacing,yT/(1+oo(condition).sizeProportionalToSpacing/2));
                else
                    spacing=min(spacing,screenHeight-yT-oo(condition).targetHeightPix/2);
                    spacing=min(spacing,yT-oo(condition).targetHeightPix/2);
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
                    error('Cannot test radial crowding at zero eccentricity. Make o.eccentricityDeg greater than zero.');
                end
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
        oo(condition).spacingDeg=spacing/pixPerDeg;
        if oo(condition).sizeProportionalToSpacing
            oo(condition).targetHeightDeg=oo(condition).spacingDeg*oo(condition).sizeProportionalToSpacing;
        end
        oo(condition).targetHeightPix=round(oo(condition).targetHeightDeg*pixPerDeg);
        oo(condition).targetHeightPix=min(oo(condition).targetHeightPix,RectHeight(screenRect));
        oo(condition).targetHeightDeg=oo(condition).targetHeightPix/pixPerDeg;
        fix.targetHeightPix=oo(condition).targetHeightPix;
        fix.bouma=max(0.5,(spacingOuter+oo(condition).targetHeightPix/2)/oo(condition).eccentricityPix);
        fixationLines=ComputeFixationLines(fix);
        if ~oo(condition).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        Screen('Flip',window); % display fixation
        WaitSecs(1); % duration of fixation display
        if ~oo(condition).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        stimulus=Shuffle(oo(condition).alphabet);
        stimulus=stimulus(1:3); % three random letters, all different.
        Screen('textSize',window,oo(condition).targetHeightPix);
        Screen('TextFont',window,oo(condition).targetFont);
        %             rect=Screen('TextBounds',window,'N');
        %             ffprintf(ff,'TextSize %.1f, "N" width %.0f pix, height %.0f pix\n',targetHeightPix,RectWidth(rect),RectHeight(rect));
        if ~oo(condition).repeatedLetters
            Screen('DrawText',window,stimulus(2),xT-oo(condition).targetHeightPix/2,yT+oo(condition).targetHeightPix/2,black,0,1);
            if streq(oo(condition).thresholdParameter,'spacing')
                Screen('DrawText',window,stimulus(1),xF-oo(condition).targetHeightPix/2,yF+oo(condition).targetHeightPix/2,black,0,1);
                Screen('DrawText',window,stimulus(3),xFF-oo(condition).targetHeightPix/2,yFF+oo(condition).targetHeightPix/2,black,0,1);
            end
        else
            xMin=xT-spacing*ceil((xT-0)/spacing);
            xMax=xT+spacing*ceil((screenRect(3)-xT)/spacing);
            yMin=yT-spacing*ceil((yT-0)/spacing);
            yMax=yT+spacing*ceil((screenRect(4)-yT)/spacing);
            for y=yMin:spacing:yMax
                whichTarget=mod(round((y-yMin)/spacing),2);
                if oo(condition).useScreenCopyWindow && y>=yMin+4*spacing && y<=yMax-2*spacing
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
                        if ismember(x,[xMin xMin+spacing xMax-spacing xMax]) || ismember(y,[yMin yMin+spacing yMax-spacing yMax])
                            letter='X';
                        else
                            letter=stimulus(1+whichTarget);
                        end
                        Screen('DrawText',window,letter,x-oo(condition).targetHeightPix/2,y+oo(condition).targetHeightPix/2,black,0,1);
                    end
                end
            end
        end
        Screen('TextFont',window,oo(condition).textFont);
        if oo(condition).usePurring
            Snd('Play',purr);
        end
        Screen('Flip',window); % show target and flankers
        if oo(condition).repeatedLetters
            targets=stimulus(1:2);
        else
            targets=stimulus(2);
        end
        if ~oo(condition).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        if isfinite(oo(condition).durationSec)
            WaitSecs(oo(condition).durationSec); % display of letters
            Screen('Flip',window); % remove letters
            WaitSecs(0.2); % pause before response screen
            if ~oo(condition).repeatedLetters
                Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
            end
            Screen('TextFont',window,oo(condition).textFont);
            Screen('TextSize',window,oo(condition).textSize);
            Screen('DrawText',window,'Type your response, or escape to quit.',100,100,black,0,1);
            Screen('DrawText',window,sprintf('Trial %d of %d. Run %d of %d',trial,length(condList),run,runs),screenRect(3)-300,100,black,0,1);
            Screen('TextFont',window,oo(condition).targetFont);
            x=100;
            y=screenRect(4)-50;
            for a=oo(condition).alphabet
                [x,y]=Screen('DrawText',window,a,x,y,black,0,1);
                x=x+oo(condition).textSize/2;
            end
            Screen('TextFont',window,oo(condition).textFont);
            Screen('Flip',window); % display response screen
        end
        FlushEvents('keyDown');
        responseString='';
        for i=1:length(targets)
            while(1)
                input=upper(GetKeypress(0,[escapeKey oo(condition).responseKeys]));
                if ~ismember(input,responseString)
                    break
                end
            end
            ListenChar(2);
            Speak(input);
            ListenChar(0);
            if streq(input,'ESCAPE')
                ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
                terminate=1;
                break;
            end
            ListenChar(2);
            if ismember(input,targets)
                Snd('Play',rightBeep);
            else
                Snd('Play',wrongBeep);
            end
            ListenChar(0);
            responseString=[responseString input];
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
                    oo(condition).results(oo(condition).count,1)=oo(condition).spacingDeg;
                    oo(condition).results(oo(condition).count,2)=response;
                    oo(condition).count=oo(condition).count+1;
                    intensity=log10(oo(condition).spacingDeg);
                case 'size'
                    oo(condition).results(oo(condition).count,1)=oo(condition).targetHeightDeg;
                    oo(condition).results(oo(condition).count,2)=response;
                    oo(condition).count=oo(condition).count+1;
                    intensity=log10(oo(condition).targetHeightDeg);
            end
            oo(condition).q=QuestUpdate(oo(condition).q,intensity,response);
        end
    end % for trial=1:length(condList)
    
    Screen('FillRect',window);
    %         Screen('DrawText',window,'Run completed',100,750,black,0,1);
    Screen('Flip',window);
    Speak('Congratulations.  You are done.');
    ListenChar; % reenable keyboard echo
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
                if ~oo(condition).repeatedLetters
                    switch(oo(condition).radialOrTangential)
                        case 'radial'
                            ffprintf(ff,'Radial spacing of far flanker from target.\n');
                        case 'tangential'
                            ffprintf(ff,'Tangential spacing up and down.\n');
                    end
                end
                ffprintf(ff,'Threshold log spacing deg (mean±sd) is %.2f ± %.2f, which is %.2f deg\n',t,sd,10^t);
                if oo(condition).count>1
                    t=QuestTrials(oo(condition).q);
                    if any(~isreal(t.intensity))
                        error('t.intensity returned by Quest should be real, but is complex.');
                    end
                    ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.1f             %.2f    %.2f    %d\n',[10.^t.intensity;QuestP(oo(condition).q,t.intensity-oo(condition).tGuess);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
                end
            case 'size',
                ffprintf(ff,'Threshold log size deg (mean±sd) is %.2f ± %.2f, which is %.3f deg\n',t,sd,10^t);
                if oo(condition).count>1
                    t=QuestTrials(oo(condition).q);
                    ffprintf(ff,'Size(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.2f             %.2f    %.2f    %d\n',[10.^t.intensity;QuestP(oo(condition).q,t.intensity-oo(condition).tGuess);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
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
                if oo(condition).count>1
                    t=QuestTrials(qq);
                    switch oo(condition).thresholdParameter
                        case 'spacing',
                            ffprintf(ff,'\n Spacing(deg)   P fit	P actual Trials\n');
                        case 'size',
                            ffprintf(ff,'\n Size(deg)   P fit	P actual Trials\n');
                    end
                    ffprintf(ff,'%5.2f           %4.2f    %4.2f     %d\n',[10.^t.intensity;QuestP(qq,t.intensity);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
                end
                ffprintf(ff,'o.measureBeta done **********************************\n');
            end
        end
    end
    for condition=1:conditions
        if exist('results','var') && oo(condition).count>1
            ffprintf(ff,'%d:',condition);
            t=QuestTrials(oo(condition).q);
            p=sum(t.responses(2,:))/sum(sum(t.responses));
            switch oo(condition).thresholdParameter
                case 'spacing',
                    ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',oo(condition).observer,100*p,oo(condition).targetHeightDeg,oo(condition).eccentricityDeg,10^QuestMean(oo(condition).q));
                case 'size',
                    ffprintf(ff,'%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',oo(condition).observer,100*p,oo(condition).eccentricityDeg,10^QuestMean(oo(condition).q));
            end
        end
    end
    save(fullfile(oo(1).dataFolder,[oo(1).dataFilename '.mat']),'oo');
    if exist('dataFid','file')
        fclose(dataFid);
        dataFid=-1;
    end
    fprintf('Results saved in %s with extensions .txt and .mat\nin folder %s\n',oo(1).dataFilename,oo(1).dataFolder);
catch
    sca; % screen close all. This cleans up without canceling the error message.
    ListenChar;
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
