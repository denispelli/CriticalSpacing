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
addpath(fullfile(fileparts(mfilename('fullpath')),'lib')); % folder in same directory as this file
if nargin<1 || ~exist('oIn','var')
    oIn.noInputArgument=1;
end
o=[];
% THESE STATEMENTS PROVIDE DEFAULT VALUES FOR ALL THE "o" parameters.
% They are overridden by what you provide in the argument struct oIn.
o.repeatedLetters=1;
o.useFractionOfScreen=0;
o.observer='practice';
% o.observer='Shivam'; % specify actual observer name
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
fix.x=50; % location of fixation
fix.y=RectHeight(screenRect)/2;
o.trials=80; % number of trials for the threshold estimate
o.fixationCrossBlankedNearTarget=1;
o.fixationCrossDeg=inf;
o.fixationLineWeightDeg=0.005;
o.measureBeta=0;
o.task='identify';
o.usePurring=1;
minimumTargetPix=8;
Screen('Preference', 'SkipSyncTests', 1);
o.alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
o.alphabet='DHKNORSVZ'; % for the Sloan alphabet
o.targetFont='Sloan';
o.textFont='Calibri';
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
[dataFid,msg]=fopen([o.dataFilename '.txt'],'wt');
if dataFid==-1
    error('%s. Could not create data file: %s',msg,[o.dataFilename '.txt']);
end
assert(dataFid>-1);
ff=[1 dataFid];
fprintf('\nSaving results in:\n');
ffprintf(ff,'%s\n',o.dataFilename);
ffprintf(ff,'%s %s\n',o.functionNames,datestr(now));

% Replicate o, once per supplied condition.
conds=length(oIn);
oo(1:conds)=o;
% All fields in the user-supplied "oIn" overwrite corresponding fields in "o".
for cond=1:conds
    fields=fieldnames(oIn(cond));
    for i=1:length(fields)
        oo(cond).(fields{i})=oIn(cond).(fields{i});
    end
end
ffprintf(ff,'observer %s\n',o.observer);

% Set up for KbCheck
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]);
Screen('Preference','SkipSyncTests',1);
escapeKey=KbName('ESCAPE');
spaceKey=KbName('space');
for cond=1:conds
    for i=1:length(oo(cond).alphabet)
        oo(cond).responseKeys(i)=KbName(oo(cond).alphabet(i));
    end
end

%Set up for Screen
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',0);
screenWidthCm=screenWidthMm/10;
screenRect=Screen('Rect',0);
if oo(cond).useFractionOfScreen
    screenRect=round(oo(cond).useFractionOfScreen*screenRect);
end

try
    window=Screen('OpenWindow',0,255,screenRect);
    for cond=1:conds
        Screen('TextFont',window,oo(cond).textFont);
        screenRect= Screen('Rect', window);
        screenWidth=RectWidth(screenRect);
        screenHeight=RectHeight(screenRect);
        pixPerDeg=screenWidth/(screenWidthCm*57/oo(cond).viewingDistanceCm);
        oo(cond).eccentricityPix=round(oo(cond).eccentricityDeg*pixPerDeg);
        oo(cond).nominalAcuityDeg=0.029*(oo(cond).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(cond).targetHeightDeg=2*oo(cond).nominalAcuityDeg; % initial guess for threshold size.
        oo(cond).eccentricityPix=round(min(oo(cond).eccentricityPix,RectWidth(screenRect)-fix.x-pixPerDeg*oo(cond).targetHeightDeg)); % target fits on screen, with half-target margin.
        oo(cond).eccentricityDeg=oo(cond).eccentricityPix/pixPerDeg;
        oo(cond).nominalAcuityDeg=0.029*(oo(cond).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
        oo(cond).targetHeightDeg=2*oo(cond).nominalAcuityDeg; % initial guess for threshold size.
        oo(cond).nominalCriticalSpacingDeg=0.3*(oo(cond).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
        addonDeg=0.45;
        addonPix=pixPerDeg*addonDeg;
        oo(cond).spacingDeg=oo(cond).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        if streq(oo(cond).thresholdParameter,'spacing') && streq(oo(cond).radialOrTangential,'radial')
            oo(cond).eccentricityPix=round(min(oo(cond).eccentricityPix,RectWidth(screenRect)-fix.x-pixPerDeg*(oo(cond).spacingDeg+oo(cond).targetHeightDeg/2))); % flanker fits on screen.
            oo(cond).eccentricityDeg=oo(cond).eccentricityPix/pixPerDeg;
            oo(cond).nominalAcuityDeg=0.029*(oo(cond).eccentricityDeg+2.72); % Eq. 13 from Song, Levi and Pelli (2014).
            oo(cond).targetHeightDeg=2*oo(cond).nominalAcuityDeg; % initial guess for threshold size.
            oo(cond).nominalCriticalSpacingDeg=0.3*(oo(cond).eccentricityDeg+0.45); % Eq. 14 from Song, Levi, and Pelli (2014).
            oo(cond).spacingDeg=oo(cond).nominalCriticalSpacingDeg; % initial guess for distance from center of middle letter
        end
        oo(cond).spacings=oo(cond).spacingDeg*2.^[-1 -.5 0 .5 1]; % five spacings logarithmically spaced, centered on the guess, spacingDeg.
        oo(cond).spacingsSequence=repmat(oo(cond).spacings,1,ceil(oo(cond).trials/length(oo(cond).spacings))); % make a random list, repeating the set of spacingsSequence enough to achieve the desired number of trials.
        fixationCrossPix=round(oo(cond).fixationCrossDeg*pixPerDeg);
        fixationCrossPix=min(fixationCrossPix,2*screenWidth); % full width and height, can extend off screen
        fixationLineWeightPix=round(oo(cond).fixationLineWeightDeg*pixPerDeg);
        fixationLineWeightPix=max(1,fixationLineWeightPix);
        fixationLineWeightPix=min(fixationLineWeightPix,7); % Max width supported by video driver.
        oo(cond).fixationLineWeightDeg=fixationLineWeightPix/pixPerDeg;
        useQuest=1; % true(1) or false(0)
        if useQuest
            ffprintf(ff,'Using QUEST to estimate threshold %s.\n',oo(cond).thresholdParameter);
        else
            ffprintf(ff,'Using "method of constant stimuli" fixed list of spacings.');
        end
        oo(cond).textSize=20; % text size in pixels
        oo(cond).targetHeightPix=round(oo(cond).targetHeightDeg*pixPerDeg);
        oo(cond).targetHeightDeg=oo(cond).targetHeightPix/pixPerDeg;
        terminate=0;
        switch oo(cond).thresholdParameter
            case 'spacing',
                oo(cond).tGuess=log10(oo(cond).spacingDeg);
            case 'size',
                oo(cond).tGuess=log10(oo(cond).targetHeightDeg);
                if oo(cond).nominalAcuityDeg*pixPerDeg<0.5*minimumTargetPix
                    ratio=0.5*minimumTargetPix/(oo(cond).nominalAcuityDeg*pixPerDeg); % too big
                    Speak('You are too close to the screen.');
                    msg=sprintf('Please increase viewing distance to at least %.0f cm.',ceil(ratio*oo(cond).viewingDistanceCm));
                    Speak(msg);
                    error(msg);
                end
        end
        oo(cond).tGuessSd=2;
        oo(cond).pThreshold=0.7;
        oo(cond).beta=3;
        delta=0.01;
        gamma=1/length(oo(cond).alphabet);
        grain=0.01;
        range=6;
    end % for cond=1:conds
    if ~oo(1).repeatedLetters
        Speak(sprintf('Please make sure that your eye is %.0f centimeters from the screen.',oo(cond).viewingDistanceCm));
    end
    
    computer=Screen('Computer');
    cal.processUserLongName=computer.processUserLongName;
    cal.machineName=computer.machineName;
    cal.macModelName=MacModelName;
    cal.screen=max(Screen('Screens'));
    if cal.screen>0
        ffprintf(ff,'Using external monitor.\n');
    end
    for cond=1:conds
        ffprintf(ff,'observer %s, task %s, measure threshold %s, alternatives %d,  beta %.1f,\n',oo(cond).observer,oo(cond).task,oo(cond).thresholdParameter,length(oo(cond).alphabet),oo(cond).beta);
        if streq(oo(cond).thresholdParameter,'spacing')
            ffprintf(ff,'Measuring threshold spacing of flankers\n');
            ffprintf(ff,'Orientation %s\n',oo(cond).radialOrTangential);
        end
        ffprintf(ff,'Target eccentricityPix %.1f deg in right visual field.\n',oo(cond).eccentricityDeg);
        if oo(cond).sizeProportionalToSpacing
            ffprintf(ff,'Target scales with spacing: spacing= %.2f * size.\n',1/oo(cond).sizeProportionalToSpacing);
            ffprintf(ff,'Minimum spacing is %.0f pixels, %.3f deg.\n',minimumTargetPix/oo(cond).sizeProportionalToSpacing,minimumTargetPix/pixPerDeg/oo(cond).sizeProportionalToSpacing);
        else
            if streq(oo(cond).thresholdParameter,'size')
                ffprintf(ff,'Measuring threshold size, with no flankers.\n');
            else
                ffprintf(ff,'Target size %.2f deg, %.1f pixels.\n',oo(cond).targetHeightDeg,oo(cond).targetHeightDeg*pixPerDeg);
            end
        end
        ffprintf(ff,'Minimum letter size is %.0f pixels, %.3f deg.\n',minimumTargetPix,minimumTargetPix/pixPerDeg);
        ffprintf(ff,'%s font\n',oo(cond).targetFont);
        ffprintf(ff,'Duration %.2f s\n',oo(cond).durationSec);
        ffprintf(ff,'%.0f trials.\n',oo(cond).trials);
    end % for cond=1:conds
    ffprintf(ff,'Viewing distance %.0f cm. ',oo(cond).viewingDistanceCm);
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
    Screen('FillRect', window,white);
    Screen('TextSize',window,oo(cond).textSize);
    Screen('TextFont',window,oo(cond).textFont);
    Screen('DrawText',window,sprintf('Observer %s',oo(cond).observer),100,30,black,0,1);
    Screen('DrawText',window,sprintf('Please make sure your eye is %.0f cm from the screen.',oo(cond).viewingDistanceCm),100,60,black,0,1);
    Screen('DrawText',window,'After each presentation, please type the target letter, ignoring any flankers that might appear to right and left.',100,90,black,0,1);
    Screen('DrawText',window,'It is very important that you be fixating the center of the crosshairs while the letters are presented.',100,120,black,0,1);
    Screen('DrawText',window,'Once you are fixating the crosshairs below, then type the spacebar to begin',100,150,black,0,1);
    fix.eccentricityPix=oo(cond).eccentricityPix;
    fix.clipRect=screenRect;
    fix.fixationCrossPix=fixationCrossPix;
    for cond=1:conds
        fix.oo(cond).fixationCrossBlankedNearTarget=oo(cond).fixationCrossBlankedNearTarget;
        fix.targetHeightPix=oo(cond).targetHeightPix;
        fixationLines=ComputeFixationLines(fix);
        if ~oo(cond).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        oo(cond).count=1;
    end % for cond=1:conds
    Screen('Flip',window);
    SetMouse(screenRect(3),screenRect(4),window);
    input=GetKeypress(0,[spaceKey escapeKey]);
    if streq(input,'ESCAPE')
        Speak('Escape. Done.');
        ffprintf(ff,'*** Observer typed escape. Run terminated.\n');
        terminate=1;
        return
    end
    condList=[];
    for cond=1:conds
        % Run the specified number of trials of each condition, in random
        % order
        condList = [condList repmat(cond,1,oo(cond).trials)];
        oo(cond).trial=0;
        oo(cond).spacingsSequence=Shuffle(oo(cond).spacingsSequence);
        oo(cond).q=QuestCreate(oo(cond).tGuess,oo(cond).tGuessSd,oo(cond).pThreshold,oo(cond).beta,delta,gamma,grain,range);
        xT=fix.x+oo(cond).eccentricityPix; % target
        yT=fix.y; % target
    end
    condList=Shuffle(condList);
    for trial=1:length(condList)
        cond=condList(trial);
        if useQuest
            intensity=QuestQuantile(oo(cond).q);
            if oo(cond).measureBeta
                offsetToMeasureBeta=Shuffle(offsetToMeasureBeta);
                intensity=intensity+offsetToMeasureBeta(1);
            end
            switch oo(cond).thresholdParameter
                case 'spacing',
                    oo(cond).spacingDeg=10^intensity;
                case 'size',
                    oo(cond).targetHeightDeg=10^intensity;
            end
        else
            oo(cond).spacingDeg=oo(cond).spacingsSequence(oo(cond).count/2);
        end
        if oo(cond).sizeProportionalToSpacing
            oo(cond).targetHeightDeg=oo(cond).spacingDeg*oo(cond).sizeProportionalToSpacing;
        end
        oo(cond).targetHeightPix=round(oo(cond).targetHeightDeg*pixPerDeg);
        oo(cond).targetHeightPix=max(minimumTargetPix,oo(cond).targetHeightPix);
        oo(cond).targetHeightDeg=oo(cond).targetHeightPix/pixPerDeg;
        if oo(cond).sizeProportionalToSpacing
            oo(cond).spacingDeg=max(oo(cond).spacingDeg,oo(cond).targetHeightDeg/oo(cond).sizeProportionalToSpacing);
        else
            oo(cond).spacingDeg=max(oo(cond).spacingDeg,oo(cond).targetHeightDeg*1.2);
        end
        spacing=oo(cond).spacingDeg*pixPerDeg;
        spacing=min(spacing,screenHeight/3);
        spacing=max(spacing,0);
        spacing=round(spacing);
        switch oo(cond).radialOrTangential
            case 'tangential'
                % requestedSpacing=spacing;
                % flanker must fit on screen
                if oo(cond).sizeProportionalToSpacing
                    spacing=min(spacing,(screenHeight-yT)/(1+oo(cond).sizeProportionalToSpacing/2));
                    spacing=min(spacing,yT/(1+oo(cond).sizeProportionalToSpacing/2));
                else
                    spacing=min(spacing,screenHeight-yT-oo(cond).targetHeightPix/2);
                    spacing=min(spacing,yT-oo(cond).targetHeightPix/2);
                end
                assert(spacing>=0);
                xF=xT;
                xFF=xT;
                yF=yT-spacing;
                yFF=yT+spacing;
                % ffprintf(ff,'spacing reduced from %.0f to %.0f pixels (%.1f to %.1f deg)\n',requestedSpacing,spacing,requestedSpacing/pixPerDeg,spacing/pixPerDeg);
                spacingOuter=0;
            case 'radial'
                if oo(cond).eccentricityPix==0
                    error('Cannot test radial crowding at zero eccentricity. Make o.eccentricityDeg greater than zero.');
                end
                spacing=min(oo(cond).eccentricityPix,spacing); % Inner flanker must be between fixation and target.
                if oo(cond).sizeProportionalToSpacing
                    spacing=min(spacing,xT/(1+oo(cond).sizeProportionalToSpacing/2)); % Inner flanker is on screen.
                    assert(spacing>=0);
                    for i=1:100
                        spacingOuter=(oo(cond).eccentricityPix+addonPix)^2/(oo(cond).eccentricityPix+addonPix-spacing)-(oo(cond).eccentricityPix+addonPix);
                        assert(spacingOuter>=0);
                        if spacingOuter<=screenWidth-xT-spacing*oo(cond).sizeProportionalToSpacing/2; % Outer flanker is on screen.
                            break;
                        else
                            spacing=0.9*spacing;
                        end
                    end
                    if i==100
                        ffprintf(ff,'ERROR: spacingOuter %.1f pix exceeds max %.1f pix.\n',spacing,spacingOuter,screenWidth-xT-spacing*oo(cond).sizeProportionalToSpacing/2)
                        error('Could not make spacing small enough. Right flanker will be off screen. If possible, try using off-screen fixation.');
                    end
                else
                    spacing=min(spacing,xT-oo(cond).targetHeightPix/2); % inner flanker on screen
                    spacingOuter=(oo(cond).eccentricityPix+addonPix)^2/(oo(cond).eccentricityPix+addonPix-spacing)-(oo(cond).eccentricityPix+addonPix);
                    spacingOuter=min(spacingOuter,screenWidth-xT-oo(cond).targetHeightPix/2); % outer flanker on screen
                end
                assert(spacingOuter>=0);
                spacing=oo(cond).eccentricityPix+addonPix-(oo(cond).eccentricityPix+addonPix)^2/(oo(cond).eccentricityPix+addonPix+spacingOuter);
                assert(spacing>=0);
                spacing=round(spacing);
                xF=xT-spacing; % inner flanker
                yF=yT; % inner flanker
                xFF=xT+round(spacingOuter); % outer flanker
                yFF=yT; % outer flanker
        end
        oo(cond).spacingDeg=spacing/pixPerDeg;
        if oo(cond).sizeProportionalToSpacing
            oo(cond).targetHeightDeg=oo(cond).spacingDeg*oo(cond).sizeProportionalToSpacing;
        end
        oo(cond).targetHeightPix=round(oo(cond).targetHeightDeg*pixPerDeg);
        oo(cond).targetHeightPix=min(oo(cond).targetHeightPix,RectHeight(screenRect));
        oo(cond).targetHeightDeg=oo(cond).targetHeightPix/pixPerDeg;
        fix.targetHeightPix=oo(cond).targetHeightPix;
        fix.bouma=max(0.5,(spacingOuter+oo(cond).targetHeightPix/2)/oo(cond).eccentricityPix);
        fixationLines=ComputeFixationLines(fix);
        if ~oo(cond).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        Screen('Flip',window); % display fixation
        WaitSecs(1); % duration of fixation display
        if ~oo(cond).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        stimulus=Shuffle(oo(cond).alphabet);
        stimulus=stimulus(1:3); % three random letters, all different.
        Screen('textSize',window,oo(cond).targetHeightPix);
        Screen('TextFont',window,oo(cond).targetFont);
        %             rect=Screen('TextBounds',window,'N');
        %             ffprintf(ff,'TextSize %.1f, "N" width %.0f pix, height %.0f pix\n',targetHeightPix,RectWidth(rect),RectHeight(rect));
        if ~oo(cond).repeatedLetters
            Screen('DrawText',window,stimulus(2),xT-oo(cond).targetHeightPix/2,yT+oo(cond).targetHeightPix/2,black,0,1);
            if streq(oo(cond).thresholdParameter,'spacing')
                Screen('DrawText',window,stimulus(1),xF-oo(cond).targetHeightPix/2,yF+oo(cond).targetHeightPix/2,black,0,1);
                Screen('DrawText',window,stimulus(3),xFF-oo(cond).targetHeightPix/2,yFF+oo(cond).targetHeightPix/2,black,0,1);
            end
        else
            xMin=xT-spacing*ceil((xT-0)/spacing);
            xMax=xT+spacing*ceil((screenRect(3)-xT)/spacing);
            yMin=yT-spacing*ceil((yT-0)/spacing);
            yMax=yT+spacing*ceil((screenRect(4)-yT)/spacing);
            for y=yMin:spacing:yMax
                whichTarget=mod(round((y-yMin)/spacing),2);
                if 0 && y>=yMin+4*spacing && y<=yMax-2*spacing
                    dstRect=screenRect;
                    dstRect(2)=0;
                    dstRect(4)=spacing;
                    dstRect=OffsetRect(dstRect,0,y-round(spacing/2));
                    srcRect=OffsetRect(dstRect,0,-2*spacing);
                    Screen('CopyWindow',window,window,srcRect,dstRect);
                else
                    for x=xMin:spacing:xMax
                        whichTarget=mod(whichTarget+1,2);
                        if streq(oo(cond).thresholdParameter,'size')
                            whichTarget=x>mean([xMin xMax]);
                        end
                        if ismember(x,[xMin xMin+spacing xMax-spacing xMax]) || ismember(y,[yMin yMin+spacing yMax-spacing yMax])
                            letter='X';
                        else
                            letter=stimulus(1+whichTarget);
                        end
                        Screen('DrawText',window,letter,x-oo(cond).targetHeightPix/2,y+oo(cond).targetHeightPix/2,black,0,1);
                    end
                end
            end
        end
        Screen('TextFont',window,oo(cond).textFont);
        if oo(cond).usePurring
            Snd('Play',purr);
        end
        Screen('Flip',window); % show target and flankers
        if oo(cond).repeatedLetters
            targets=stimulus(1:2);
        else
            targets=stimulus(2);
        end
        if ~oo(cond).repeatedLetters
            Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
        end
        if isfinite(oo(cond).durationSec)
            WaitSecs(oo(cond).durationSec); % display of letters
            Screen('Flip',window); % remove letters
            WaitSecs(0.2); % pause before response screen
            if ~oo(cond).repeatedLetters
                Screen('DrawLines',window,fixationLines,fixationLineWeightPix,black);
            end
            Screen('TextFont',window,oo(cond).textFont);
            Screen('TextSize',window,oo(cond).textSize);
            Screen('DrawText',window,'Type your response, or escape to quit.',100,100,black,0,1);
            Screen('DrawText',window,sprintf('Trial %d of %d. Run %d of %d',trial,length(condList),run,runs),screenRect(3)-300,100,black,0,1);
            Screen('TextFont',window,oo(cond).targetFont);
            x=100;
            y=screenRect(4)-50;
            for a=oo(cond).alphabet
                [x,y]=Screen('DrawText',window,a,x,y,black,0,1);
                x=x+oo(cond).textSize/2;
            end
            Screen('TextFont',window,oo(cond).textFont);
            Screen('Flip',window); % display response screen
        end
        FlushEvents('keyDown');
        responseString='';
        for i=1:length(targets)
            while(1)
                input=upper(GetKeypress(0,[escapeKey oo(cond).responseKeys]));
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
        oo(cond).spacingDeg=spacing/pixPerDeg;
        for response=responses
            switch oo(cond).thresholdParameter
                case 'spacing',
                    oo(cond).results(oo(cond).count,1)=oo(cond).spacingDeg;
                    oo(cond).results(oo(cond).count,2)=response;
                    oo(cond).count=oo(cond).count+1;
                    intensity=log10(oo(cond).spacingDeg);
                case 'size'
                    oo(cond).results(oo(cond).count,1)=oo(cond).targetHeightDeg;
                    oo(cond).results(oo(cond).count,2)=response;
                    oo(cond).count=oo(cond).count+1;
                    intensity=log10(oo(cond).targetHeightDeg);
            end
            oo(cond).q=QuestUpdate(oo(cond).q,intensity,response);
        end
    end % for trial=1:length(condList)
    
    Speak('Congratulations.  You are done.');
    for cond=1:conds
        % Ask Quest for the final estimate of threshold.
        t=QuestMean(oo(cond).q);
        sd=QuestSd(oo(cond).q);
        switch oo(cond).thresholdParameter
            case 'spacing',
                switch(oo(cond).radialOrTangential)
                    case 'radial'
                        ffprintf(ff,'Radial spacing of far flanker from target.\n');
                    case 'tangential'
                        ffprintf(ff,'Tangential spacing up and down.\n');
                end
                ffprintf(ff,'Threshold log spacing deg (mean±sd) is %.2f ± %.2f, which is %.2f deg\n',t,sd,10^t);
                if oo(cond).count>1
                    t=QuestTrials(oo(cond).q);
                    if any(~isreal(t.intensity))
                        error('t.intensity returned by Quest should be real, but is complex.');
                    end
                    ffprintf(ff,'Spacing(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.1f             %.2f    %.2f    %d\n',[10.^t.intensity;QuestP(oo(cond).q,t.intensity-oo(cond).tGuess);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
                end
            case 'size',
                ffprintf(ff,'Threshold log size deg (mean±sd) is %.2f ± %.2f, which is %.3f deg\n',t,sd,10^t);
                if oo(cond).count>1
                    t=QuestTrials(oo(cond).q);
                    ffprintf(ff,'Size(deg)	P fit	P       Trials\n');
                    ffprintf(ff,'%.2f             %.2f    %.2f    %d\n',[10.^t.intensity;QuestP(oo(cond).q,t.intensity-oo(cond).tGuess);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
                end
        end
        Screen('DrawText',window,'Run completed',100,750,black,0,1);
        Screen('Flip',window);
        if oo(cond).measureBeta
            % reanalyze the data with beta as a free parameter.
            ffprintf(ff,'o.measureBeta **************************************\n');
            ffprintf(ff,'offsetToMeasureBeta %.1f to %.1f\n',min(offsetToMeasureBeta),max(offsetToMeasureBeta));
            bestBeta=QuestBetaAnalysis(oo(cond).q);
            qq=oo(cond).q;
            qq.beta=bestBeta;
            qq=QuestRecompute(qq);
            ffprintf(ff,'thresh %.2f deg, log thresh %.2f, beta %.1f\n',10^QuestMean(qq),QuestMean(qq),qq.beta);
            ffprintf(ff,' deg     t     P fit\n');
            tt=QuestMean(qq);
            for offset=sort(offsetToMeasureBeta)
                t=tt+offset;
                ffprintf(ff,'%5.2f   %5.2f  %4.2f\n',10^t,t,QuestP(qq,t));
            end
            if oo(cond).count>1
                t=QuestTrials(qq);
                switch oo(cond).thresholdParameter
                    case 'spacing',
                        ffprintf(ff,'\n Spacing(deg)   P fit	P actual Trials\n');
                    case 'size',
                        ffprintf(ff,'\n Size(deg)   P fit	P actual Trials\n');
                end
                ffprintf(ff,'%5.2f           %4.2f    %4.2f     %d\n',[10.^t.intensity;QuestP(qq,t.intensity);t.responses(2,:)./sum(t.responses);sum(t.responses)]);
            end
            ffprintf(ff,'o.measureBeta done **********************************\n');
        end
        if terminate
            break;
        end
    end
    ListenChar; % reenable keyboard echo
    Snd('Close');
    Screen('CloseAll');
    ShowCursor;
    for cond=1:conds
        if exist('results','var') && oo(cond).count>1
            t=QuestTrials(oo(cond).q);
            p=sum(t.responses(2,:))/sum(sum(t.responses));
            switch oo(cond).thresholdParameter
                case 'spacing',
                    ffprintf(ff,'%s: p %.0f%%, size %.2f deg, ecc. %.1f deg, critical spacing %.2f deg.\n',oo(cond).observer,100*p,oo(cond).targetHeightDeg,oo(cond).eccentricityDeg,10^QuestMean(oo(cond).q));
                case 'size',
                    ffprintf(ff,'%s: p %.0f%%, ecc. %.1f deg, threshold size %.3f deg.\n',oo(cond).observer,100*p,oo(cond).eccentricityDeg,10^QuestMean(oo(cond).q));
            end
        end
    end
    save(fullfile(oo(1).dataFolder,[oo(1).dataFilename '.mat']),'oo');
    ffprintf(ff,'Results saved in %s with extensions .txt and .mat\nin folder %s\n',oo(1).dataFilename,oo(1).dataFolder);
    if exist('dataFid','file')
        fclose(dataFid);
        dataFid=-1;
    end
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
