function TestFlip(screenOrFilename,name1,value1,name2,value2)
% TestFlip([screenOrFilename][,'stepsAndReps',stepsAndReps][,'framesPerSec',framesPerSec]);
% Measures timing of Screen Flip on your computer, producing a detailed
% one-page PNG graph with caption. It records the display timing and your
% computer's configuration. Modern displays have multiple frame buffers, so
% you typically write to a hidden buffer and then call "flip" to make it
% visible. TestFlip graphs the relation between the requested and actual
% flip times. Supports macOS, Windows, and Linux.
%
% INPUT ARGUMENTS: 
%% "screenOrFilename" (default 0), if present, can be an integer to specify
% a screen (0 for main screen, 1 for next, etc.), or a filename to
% reanalyze a MAT file of data from a past run of TestFlip. You can
% optionally include one or two name-value pairs. The names can be either
% 'stepsAndReps' or 'framesPerSec'.
%% The name 'stepsAndReps' is followed by a 2-element array [steps repetitions]
% consisting of "steps" (default 100) which is the number of points you
% want along the Request duration axis, and "repetitions" (default 100)
% which is the number of times you want to measure the actual duration for
% each request duration. 100 steps is enough that you won't notice the gaps
% along the horizontal axis. 100 repetitions is enough to clearly show the
% distribution vertically. 100 x 100 takes about 3 minutes. "stepsAndReps"
% only affects the measurements. 
%% The name 'framesPerSec' is followed by a float number representing that
% rate in Hz, e.g. 'frameRate', 60. This locks that parameter in both
% measurement and analysis. When timing is really bad, it is hard for
% TestFlip to estimate the frame rate from the data (or by calling
% FrameRate), and it can help a lot to impose the known frame rate.
%
% DETAILS:
% TestFlip uses the 'when' argument of Screen Flip to request a flip time.
% Our measurements support the theory (plotted as a red line in the graph)
% that flip mostly occurs on the first available frame after a fixed extra
% delay. According to this model, the possible delay of the flip relative
% to the time requested in "when" ranges from the extra delay to that plus
% a frame. Thus, if all phases are equally likely, the mean time of the
% flip, relative to the time you specify in "when" is the extra delay plus
% half a frame duration. ("phase" means the fraction of a period since the
% last frame at the Screen flip is called.) So, if you want the Flip to
% occur as near as possible to a given time, you should set the Screen Flip
% "when" argument to a value before that time. The decrement should be the
% extra delay measured here (roughly 5 ms) plus half a frame period (about
% 17/2=8.5 ms).
% denis.pelli@nyu.edu, October 31, 2019
%
% Related discusson on Psychtoolbox forum:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/23963
%
% See also: VBLSyncTest, FlipTest, "Screen Flip?", IdentifyComputer

% September 24, 2019 DGP. Force native resolution, as requested by Mario
%               Kleiner.
% October 25, 2019. Mario Kleiner. Make it a function (for speed). Set
%               Priority. Get user permission before changing resolution.
%               For accuracy of reported resolution and speed, call
%               IdentifyComputer and FrameRate only after window is open.
% October 25, 2019. DGP. Added "screen" argument. Call "clear Screen" to make a
%               fresh start.
% October 28, 2019. DGP. Enhanced the model fitting to now treat both
%               delaySec and periodSec as degrees of freedom. Formerly we
%               set periodSec=1/FrameRate, but the frame rate was often off
%               by a few percent. (FrameRate is based on much less data
%               than we have in actualSec, so it's better to just fit our
%               data.) We now fit our model to the median actualSec
%               duration at each requestSec, to minimize sensitivity to
%               outliers. Changed argument to be screenOrFilename to allow
%               reanalysis of old data.
% October 29, 2019. Ziyi Zhang. Now evaluate fminsearch on a grid of points
%               to overcome local minima in cost function. After polish,
%               this performs better than simulated annealing.
% October 31, 2019. New input arguments, name-value pairs "stepsAndReps"
%               and "framesPerSec".
% November 5, 2019. Polished the fitting by fminsearch. Introduced 
%               error weighting that deemphasizes times near the flip. 
%               This makes the periodSec still estimates reliable even
%               in the presence of minor temporal jitter that produces
%               random variation of the delay by a full period at times
%               near the flip time.

%
% Calling MATLAB's onCleanup requests that our cleanup routine (sca,
% "Screen Close All") be run whenever TestFlip terminates for any reason,
% whether by reaching the end, the posting of an error here (or in any
% function called from here), or the user hits control-C. Alas, the program
% ignores control-C while running. The only way I know to stop TestFlip
% before it's done is SHIFT-CMD-OPTION-ESCAPE, which kills MATLAB. Ideally,
% the program would periodically check for keyboard input, to allow it to
% be interrupted by control-C.
global deemphasizeSteps
deemphasizeSteps=true;
cleanup=onCleanup(@() sca);
if nargin<1
    screenOrFilename=0; % 0 for main screen, 1 for next screen, etc.
end
stepsAndReps=[100 100];
framesPerSec=[];
if nargin>2
    switch name1
        case {'stepsAndReps' 'stepsandreps'}
            stepsAndReps=value1;
        case {'framesPerSec' 'framespersec'}
            framesPerSec=value1;
        otherwise
            error('The name must be either ''stepsAndReps'' or ''framesPerSec''.');
    end
end
if nargin>4
    switch name2
        case {'stepsAndReps' 'stepsandreps'}
            stepsAndReps=value2;
        case {'framesPerSec' 'framespersec'}
            framesPerSec=value2;
        otherwise
            error('The name must be either ''stepsAndReps'' or ''framesPerSec''.');
    end
end
if ismember(nargin,[2 4])
    error('Illegal number of arguments.');
end
if ~all(size(stepsAndReps)==[1 2])
    error('If present, the value for ''stepsAndReps'' should be a two-element array [steps repetition].');
end
if ~isempty(framesPerSec)
    if ~isfloat(framesPerSec) || ~isfloat(framesPerSec)
        error('framesPerSec must be a float number like 60.');
    end
end
steps=stepsAndReps(1);
repetitions=stepsAndReps(2);
clear Screen % Make sure we use fresh copy from disk. 
screens=Screen('Screens');
if isfloat(screenOrFilename)
    dataFilename='';
    screen=screenOrFilename;
    if ~ismember(screen,screens)
        error('Sorry the requested screen number %d is not valid on this computer.',screen);
    end
elseif ischar(screenOrFilename)
    screen=0;
    dataFilename=screenOrFilename; % Name of MAT file with old data.
    if isempty(which(dataFilename))
        error('Sorry, your data file ''%s'' cannot be found.',dataFilename);
    end
else
    error('Illegal "screenOrFilename" argument. It''s optional.');
end
clf;
plusMinus=char(177);
micro=char(181);
if isempty(dataFilename)
    %% SET RESOLUTION TO NATIVE
    % Are we using the screen at its maximum native resolution?
    permissionToChangeResolution=true;
    res=Screen('Resolutions',screen);
    nativeWidth=0;
    nativeHeight=0;
    for i=1:length(res)
        if res(i).width>nativeWidth
            nativeWidth=res(i).width;
            nativeHeight=res(i).height;
        end
    end
    actualScreenRect=Screen('Rect',screen,1);
    oldResolution=Screen('Resolution',screen);
    if nativeWidth==oldResolution.width
        fprintf('Your screen resolution is at its native maximum %d x %d. Excellent!\n',nativeWidth,nativeHeight);
    else
        warning backtrace off
        if permissionToChangeResolution
            s=GetSecs;
            fprintf('WARNING: Trying to use native screen resolution for this test. ... ');
            Screen('Resolution',screen,nativeWidth,nativeHeight);
            res=Screen('Resolution',screen);
            fprintf('Done (%.1f s). ',GetSecs-s);
            if res.width==nativeWidth
                fprintf('SUCCESS!\n');
            else
                warning('FAILED.');
                res
            end
            actualScreenRect=Screen('Rect',screen,1);
        end
        if nativeWidth==RectWidth(actualScreenRect)
            fprintf('Using native screen resolution %d x %d. Good.\n',nativeWidth,nativeHeight);
        else
            if RectWidth(actualScreenRect)<nativeWidth
                warning('Your screen resolution %d x %d is less that its native maximum %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
            else
                warning('Your screen resolution %d x %d exceeds its native resolution %d x %d.\n',...
                    RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
            end
            fprintf(['(To use native resolution, set permissionToChangeResolution=true in %s.m, \n'...
                'or use System Preferences:Displays to select "Default" resolution.)\n'],mfilename);
            warning backtrace on
        end
    end
    resolution=Screen('Resolution',screen);
    
    %% MEASURE TIMING
    Screen('Preference','SkipSyncTests',1); % Needed to run on many computers.
    steps=round(steps);
    repetitions=round(repetitions);
    white=255;
    fractionOfScreenUsed=1; % Set less than 1 only for debugging.
    screenBufferRect=Screen('Rect',screen);
    r=round(fractionOfScreenUsed*screenBufferRect);
    r=AlignRect(r,screenBufferRect,'right','bottom');
    if true
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','UseRetinaResolution');
        PsychImaging('AddTask','General','UseVirtualFramebuffer');
        window=PsychImaging('OpenWindow',screen,white,r);
    else
        window=Screen('OpenWindow',screen,white,r);
    end
    % We call IdentifyComputer only after the possible change in
    % resolution, so it correctly reports the final resolution.
    machine=IdentifyComputer(window);
    if isempty(framesPerSec)
        % We call FrameRate only after our window is open so FrameRate can
        % use the open window instead of opening its own.
        periodSec=1/FrameRate(window);
    else
        periodSec=1/framesPerSec;
    end
    % I have the impression that FrameRate is unreliable at high Priority,
    % so we raise Priority only after calling FrameRate.
    Priority(MaxPriority(0)); % Minimize interruptions.
    requestSec=2.5*periodSec*(0:steps-1)/steps;
    when=zeros(repetitions,steps);
    actualSec=zeros(repetitions,steps);
    excess=zeros(repetitions,steps);
    vsf=zeros(repetitions,steps,3);
    for i=1:steps
        % Draw stimulus.
        Screen('TextSize',window,round(50*fractionOfScreenUsed));
        prior=Screen('Flip',window,0);
        for j=1:repetitions
            Screen('FillRect',window);
            msg=sprintf('Now timing request for %.0f ms.  %d of %d.',...
                1000*requestSec(i),j+(i-1)*repetitions,steps*repetitions);
            Screen('TextBackgroundColor',window,255); % Set background.
            Screen('DrawText',window,double(msg),...
                round(100*fractionOfScreenUsed),...
                round(100*fractionOfScreenUsed));
            if fractionOfScreenUsed~=1
                Screen('DrawText',window,...
                    double('Warning: Use of less-than-full-screen window impairs timing.'),...
                    round(100*fractionOfScreenUsed),...
                    round(180*fractionOfScreenUsed),[255 100 0]);
                Screen('TextColor',window,[0 0 0]);
            end
            when(j,i)=prior+requestSec(i);
            % Flip to show stimulus.
            [VBLTimestamp,StimulusOnsetTime,FlipTimestamp]=...
                Screen('Flip',window,when(j,i));
            actualSec(j,i)=VBLTimestamp-prior;
            excess(j,i)=VBLTimestamp-when(j,i);
            prior=VBLTimestamp;
            vsf(j,i,1:3)=[VBLTimestamp, StimulusOnsetTime, FlipTimestamp];
        end
    end
    Screen('Close',window);
    Priority(0);
    fprintf(['Across all duration requests, ' ...
        'the excess duration was %.0f%c%.0f ms (mean%csd), '...
        'with range [%.0f %.0f] ms.\n'],...
        1000*mean(excess(:)),plusMinus,1000*std(excess(:)),...
        plusMinus,...
        1000*min(excess(:)),1000*max(excess(:)));
    vsfDelay=vsf-vsf(:,:,1);
    s=vsfDelay(:,:,2);
    stimulusMean=mean(s(:));
    stimulusSD=std(s(:));
    s=vsfDelay(:,:,3);
    flipMean=mean(s(:));
    flipSD=std(s(:));
    fprintf(['Relative to VBLTimestamp, '...
        'StimulusOnsetTime is %.0f%c%.0f %cs (mean%csd), '...
        'and FlipTimestamp is %.0f%c%.0f %cs.\n'],...
        1e6*stimulusMean,plusMinus,1e6*stimulusSD,micro,plusMinus,...
        1e6*flipMean,plusMinus,1e6*flipSD,micro);
    
    %% RESTORE RESOLUTION
    if permissionToChangeResolution && ...
            (oldResolution.width~=resolution.width || ...
            oldResolution.height~=resolution.height)
        Screen('Resolution',screen,oldResolution.width,oldResolution.height);
    end
    
    %% OPTIONALLY, SAVE DATA TO DISK
    if true
        % This saves all the measurements as a MAT file, so that the data
        % can be analyzed later or remotely.
        saveTitle=[mfilename '-' machine.summary '.mat'];
        folder=fileparts(mfilename('fullpath'));
        close all
        save(fullfile(folder,saveTitle));
        fprintf('Data saved as <strong>''%s''</strong> with %s.m.\n',...
            saveTitle,mfilename);
    end
end % if isempty(useSavedData)

% To analyze saved data, from any computer, just call TestFlip with the
% full .mat filename as an argument.
if ~isempty(dataFilename)
    fprintf('Now loading your old TestFlip data: ''%s''.\n',...
        dataFilename);
    load(dataFilename,'requestSec','actualSec','excess','machine',...
        'fractionOfScreenUsed','stimulusMean','stimulusSD',...
        'flipMean','flipSD','steps','repetitions');
end

%% ANALYZE AND PLOT RESULTS
close all
f=figure(1);
screenRect=Screen('Rect',0);
r=[0 0 819 600]; % Works well on MacBook so exporting to all computers.
r=CenterRect(r,screenRect);
r=OffsetRect(r,0,-r(2));
% Convert Apple rect to MATLAB Position.
f.Position=[r(1) screenRect(4)-r(4) RectWidth(r) RectHeight(r)];

%% PANEL 1
subplot(1,3,1);
hold on

%% ONE- OR TWO-PARAMETER FIT: delaySec and periodSec
% There may be very late outliers which cannot be fit by our model. We
% discount them by fitting just the median actual duration at each
% requested duration.
actualMedian=median(actualSec);
delaySec=0.004; % Initial guess, 4 ms.
if isempty(framesPerSec)
    periodSec=1/60; % Initial guess, 60 Hz frame rate.
else
    periodSec=1/framesPerSec; % User-specified frame rate.
end
b=[delaySec periodSec];
% Two-parameter search: 
% delaySec and periodSec. b has length 2.
fun2=@(b) Cost(requestSec,actualMedian,b(1),b(2));
% One-parameter search: 
% delaySec. b has length 1.
fun1=@(b) Cost(requestSec,actualMedian,b,1/framesPerSec);
% These min and max values allow an extra delay of 0 to 50 ms, and a frame
% rate of 10 to 1000 Hz.
bMin=[0.0  0.001];
bMax=[0.05 0.1  ];
% We use a grid to cover the whole space and use fminsearch locally. Thanks
% to Ziyi Zhang and Omkar Kumbhar. November 5, 2019.
b1=linspace(bMin(1),bMax(1),3);
options=optimset('fminsearch');
if isempty(framesPerSec)
    numberString='Two';
    b2=linspace(bMin(2),bMax(2),10);
    b2=[b2 1/50 1/60]; % Add common display frame rates.
    % I increased these limits to avoid getting warnings that it quit
    % early because it exceeded one of these limits.
    options.MaxFunEvals=800; % Default is 200*numberofvariables.
    options.MaxIter=800; % Default is 200*numberofvariables.
else
    numberString='One';
    b2=1/framesPerSec;
end
bestCost=inf;
bestB=[];
for i=1:length(b1)
    for j=1:length(b2)
        if isempty(framesPerSec)
            [b,cost]=fminsearch(fun2,[b1(i) b2(j)],options);
        else
            [b(1),cost]=fminsearch(fun1,b1(i),options);
            b(2)=b2;
        end
        if cost<bestCost
            bestCost=cost;
            bestB=b;
        end
    end
end
cost=bestCost;
b=bestB;
delaySec=b(1);
periodSec=b(2);
printFit=true;
if printFit
    fprintf(['%s-parameter fit by fminsearch: ' ...
        'delaySec %.1f ms, periodSec %.1f ms (%.1f Hz), rms error %.1f ms.\n'],...
        numberString,...
        1000*delaySec,1000*periodSec,1/periodSec,...
        1000*Cost(requestSec,actualMedian,delaySec,periodSec));
    % figure(2)
    % Plot residual.
    % model=periodSec*ceil((requestSec+delaySec)/periodSec);
    % plot(1000*requestSec,1000*(model-actualMedian));
    % ylabel('Model error (ms)');
    % xlabel('Request (ms)');
    % figure(3)
    % Plot just the median and the model, without the data.
    % hold on
    % plot(1000*requestSec,1000*model,'-r');
    % plot(1000*requestSec,1000*actualMedian,'-g');
    % ylabel('Duration (ms)');
    % xlabel('Request (ms)');
    % figure(1)
end

%% Analyze mid half of second frame duration, far from the transitions.
r=(requestSec+delaySec)/periodSec;
% ok=(r>0.25 & r<0.75) | (r>1.25 & r<1.75) | (r>2.25 & r<2.75);
ok=1.25<r & r<1.75;
a=actualSec(:,ok);
sdMidHalfFrame=std(a(:));

% Assuming the frame frequency is stable, we estimate the true frame times
% and assess the sd of VBLTimestamp relative to that.
tMeasured=cumsum(actualSec);
tEst=zeros(size(tMeasured));
for i=1:length(requestSec)
    % Assume frames are periodic, no jitter. The best estimate of true
    % period is the average of the measured period. We don't bother to
    % estimate true phase, because that will only affect mean, not SD of
    % the deviance, and we only report SD. Thus after many repetitions
    % (frames) we assume the measured times are correct for first and last
    % frame, and uniformly interpolate the reat.
    tEst(:,i)=linspace(tMeasured(1,i),tMeasured(end,i),size(tMeasured,1));
end
% Now compute deviance of measured times from estimate of periodic frame
% time. We care only about SD, not mean.
dt=tMeasured-tEst;
if false
    % Show more detail than just the one-number summary
    % sdMidHalfFrameRePeriodic.
    % Plot error re better estimate of actual frame time.
    sd=std(dt);
    plot(1000*requestSec,1000*sd,'-r');
    ylabel('SD re estimated true frame time (ms)','FontSize',12);
    xlabel('Requested flip time re previous (ms)','FontSize',12);
end
r=(requestSec+delaySec)/periodSec;
% Select only the data that are far from the vertical transitions.
% ok=(r>0.25 & r<0.75) | (r>1.25 & r<1.75) | (r>2.25 & r<2.75);
ok=(r>1.25 & r<1.75) ;
dtOk=dt(:,ok);
sdMidHalfFrameRePeriodic=std(dtOk(:));
% fprintf('%.1f ms SD re periodic times.\n',1000*sdMidHalfFrameRePeriodic);

% Plot the median.
% plot(1000*requestSec,1000*actualMedian,'-g','LineWidth',4); % Plot median.
plot(1000*requestSec,1000*actualMedian,'xg','MarkerSize',16,'LineWidth',2); % Plot median.

% Plot the data.
for i=1:length(requestSec)
    % One point for each repetition.
    plot(1000*requestSec(i),1000*actualSec(:,i),'.k','MarkerSize',1.5); % Plot data.
end

% Plot the model.
model=periodSec*ceil((requestSec+delaySec)/periodSec);
if true
    reqK=linspace(requestSec(1),requestSec(end),1000);
    modelK=periodSec*ceil((reqK+delaySec)/periodSec);
    plot(1000*reqK,1000*modelK,'-r','LineWidth',1.5); % Plot model.
else
    plot(1000*requestSec,1000*model,'-r','LineWidth',1.5); % Plot model.
end

g=gca;
g.XLim=[0 1000*requestSec(end)];
g.YLim=2*g.XLim; % Leave room at top for text.
g.Position(2)=g.Position(2)+0.05*g.Position(4);
g.Position([3 4])=1.3*g.Position([3 4]);
g.Position([1 2])=g.Position([1 2])-0.15*g.Position([3 4]);
daspect([1 1 1]);
% The plot width is stable (across computers), and the data aspect ratio is
% 1:1, so if the X or Y range changes, then the height will change. When
% the height is reduced, we need to proportionally reduce the font size,
% which was designed to work when the height/width ratio was 2:1.
fontScalar=0.95; 
plot(1000*requestSec,1000*requestSec,'-k'); % Plot equality line
text(0.75*g.XLim(2),0.73*g.XLim(2),'Request','FontSize',fontScalar*10);
title('Actual vs requested duration','FontSize',16);
xlabel('Requested duration (ms)','FontSize',16);
ylabel('Duration (ms)','FontSize',16);
y=0.97*g.YLim(2);
dy=0.025*g.YLim(2)*fontScalar*12/10;
text(1,y,...
    sprintf('Estimated extra delay %.1f ms.',1000*delaySec),...
    'FontSize',fontScalar*12);
y=y-dy;
text(1,y,...
    sprintf('Frame period %.1f ms (%.1f Hz).',...
    1000*periodSec,1/periodSec),'FontSize',fontScalar*12);
y=y-dy;
text(1,y,'SD of flip time re prior flip:','FontSize',fontScalar*12);
y=y-dy;
text(1,y,...
    sprintf('mean %.1f ms, median %.1f ms, ',...
    1000*mean(std(excess)),1000*median(std(excess))),'FontSize',fontScalar*12);
y=y-dy;
text(1,y,...
    sprintf('%.1f ms in mid half of frame.',1000*sdMidHalfFrame),...
    'FontSize',fontScalar*12);
y=y-dy;
text(1,y,'SD of flip re periodic est.:','FontSize',fontScalar*12);
y=y-dy;
text(1,y,...
    sprintf('%.1f ms in mid half of frame. ',...
    1000*sdMidHalfFrameRePeriodic),'FontSize',fontScalar*12);
if ~isempty(machine.modelDescription)
    model=machine.modelDescription;
else
    model=machine.model;
end
y=0.02*g.YLim(2);
x=0.99*g.XLim(2);
dy=0.025*g.YLim(2)*fontScalar*10/10;
if ~isempty(machine.openGLVersion)
    text(x,y,machine.openGLVersion,...
        'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
end
if ~isempty(machine.openGLVendor)
    text(x,y,machine.openGLVendor,...
        'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
end
if ~isempty(machine.openGLRenderer)
    text(x,y,machine.openGLRenderer,...
        'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
end
text(x,y,sprintf('screen %d, %d x %d, %.0f x %.0f mm',...
    screen,machine.size,machine.mm),...
    'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
text(x,y,machine.system,...
    'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
text(x,y,machine.screenMex,...
    'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
if ~isempty(machine.psychtoolboxKernelDriver)
    text(x,y,machine.psychtoolboxKernelDriver,...
        'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
end
text(x,y,machine.psychtoolbox,...
    'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
if ~isempty(machine.manufacturer)
    text(x,y,machine.manufacturer,...
        'HorizontalAlignment','right','FontSize',fontScalar*10); y=y+dy;
end
i=strfind(model,' (');
if length(model)>25 && ~isempty(i)
    i=i(1);
    model2=model(i+1:end);
    model=model(1:i-1); % Omit the space.
    text(x,y,model2,...
        'HorizontalAlignment','right','FontSize',fontScalar*10);
    y=y+dy;
end
y=y+dy/4; % Extra space below title.
text(x,y,model,...
    'FontWeight','bold','HorizontalAlignment','right','FontSize',fontScalar*16);
y=y+dy;
g.Units='normalized';
g.Position=[.09 0 .28 1];
panelOnePosition=g.Position;

%% PANEL 2
subplot(1,3,2);
ii=excess(:)>2*periodSec;
times=sort(excess(ii));
if fractionOfScreenUsed~=1
    s0=sprintf('WARNING: Use of less-than-full-screen window may have impaired timing.\n');
else
    s0='';
end
if deemphasizeSteps
    weighted='weighted';
else
    weighted='';
end
s0a='EXPLANATION: We called ';
s0b=['\bf' 'time=Screen(''Flip'',window,when);' '\rm'];
s0c=sprintf('%d times for each of %d requested durations. ',...
    repetitions,steps);
s1a=sprintf(['The median (green Xs) '...
    'of measured duration (black dots) is fit '...
    '(with ' weighted ' rms error %.1f ms) by a model (red line). '...
    'The model assumes the frames are periodic, and the flip occurs '...
    'at the first frame after an extra delay after the requested time. '],...
    1000*cost);
if deemphasizeSteps
    s1aa=['The error weighting deemphasizes times near the vertical steps. '];
else
    s1aa='';
end
if ~isempty(framesPerSec)
    s1b=sprintf('The model has only one degree of freedom: the extra delay %.1f ms. ',...
        1000*delaySec);
else
    s1b=sprintf(['The model has two degrees of freedom: the extra delay %.1f ms and the '...
        'period %.1f ms (%.1f Hz). '],1000*delaySec,1000*periodSec,1/periodSec);
end
s1c=sprintf(['The data are measured duration (VBLTimestamp re prior VBLTimestamp) vs. ' ...
    'requested duration ("when" re prior VBLTimestamp). ']);
s6=[sprintf(['The %d measured durations include %d outliers exceeding '...
    'the request by at least two frames: '], ...
    repetitions*steps,length(times)) ...
    sprintf('%.0f ',1000*times) ' ms. '];
s7='Measured by TestFlip.m, available from denis.pelli@nyu.edu. ';
s8=sprintf(['\n\nJITTER: Flip times on some computer displays show '...
    'half a ms of jitter (for requests far from a vertical step, '...
    'much more when near a step), '...
    'while others shown practically none. The red-line model has no jitter. '...
    'We believe that there is essentially no jitter in the '...
    'display frame times (generated by the graphics chip) and the '...
    'system time (generated by the clock oscillator in the CPU). These '...
    'autonomous devices should be immune to most things, including unix timesharing. '...
    'Thus the %.1f ms vertical jitter seen in the reported duration, '...
    'and the sometimes-similar horizontal jitter (in the request time '...
    'at which the duration '...
    'increases suddenly by a whole frame), '],1000*sdMidHalfFrame);
str={[s0 s0a] s0b [s0c s1a s1aa s1b s1c s6 s7 s8]};
g=gca;
g.Visible='off';
position=[g.Position(1) 0 panelOnePosition(3) 1];
annotation('textbox',position,'String',str,...
    'LineStyle','none','FontSize',12);

%% PANEL 3.
subplot(1,3,3);
s8=sprintf([...
    'must arise in the software reports of '...
    'when flips occur and the implementation '...
    'of the "when" timer.\n\n'...
    'ISOLATING ONE JITTER: Our plotted duration is the interval between '...
    'two reported flip times. Its jitter is the difference between the  '...
    'jitters of two successive flip reports. If these successive '...
    'jitters are perfectly correlated then they will cancel in the '...
    'difference. If they are independent then the '...
    'variance of the difference will be twice the jitter variance. '...
    'In that case, for duration requests that are far from the '...
    'vertical steps, we can reduce the jitter in our estimates by using the '...
    'known periodicity of the frames to make a low-noise estimate '...
    'of the true flip time (across our %d repetitions) and use that as '...
    'our reference, instead of the prior flip times. '...
    'This isolates one jitter. '...
    'Correlation predicts that isolation will increase SD. '...
    'Independence predicts reduction of jitter SD, by sqrt(2), '...
    'i.e. 1.4:1. In fact, isolation here changes the SD from '...
    '%.3f to %.3f ms, a ratio of %.2f:1.\n'],...
    repetitions,...
    1000*sdMidHalfFrame,1000*sdMidHalfFrameRePeriodic,...
    sdMidHalfFrame/sdMidHalfFrameRePeriodic);
s9=sprintf([...
    'OTHER OUTPUT TIMES: Screen ''Flip'' returns three similar time '...
    'values: VBLTimestamp, StimulusOnsetTime, and FlipTimestamp. '...
    'Typically StimulusOnsetTime is identical to VBLTimestamp. '...
    'On this computer, relative to VBLTimestamp, '...
    'StimulusOnsetTime is %.0f%c%.0f %cs (mean%csd), '...
    'and FlipTimestamp is %.0f%c%.0f %cs.\n'],...
    1e6*stimulusMean,plusMinus,1e6*stimulusSD,micro,plusMinus,...
    1e6*flipMean,plusMinus,1e6*flipSD,micro);
str={s8 s9};
g=gca;
g.Visible='off';
position=[g.Position(1) 0 panelOnePosition(3) 1];
a=annotation('textbox',position,'String',str,'LineStyle','none',...
    'FontSize',12);

if false
    % Not quite working.
    % Estimate the horizontal jitter.
    figure(2)
    % Fit the horizontal jitter.
    e=zeros(1,repetitions);
    sd=0.0001:0.0001:0.003;
    for i=1:length(sd)
        % Compute model for this horizontal jitter.
        gauss=exp(-(requestSec-mean(requestSec)).^2/(2*sd(i)^2));
        gauss=gauss/sum(gauss);
        model=periodSec*ceil((requestSec+delay(i))/periodSec);
        modelg=conv(gauss,model,'same');
        plot(1000*requestSec,1000*model,'-k',1000*requestSec,1000*modelg,'-g',...
            'LineWidth',2);
        e=mean(actualSec)-modelg;
        err(i)=sqrt(mean(e(20:end-20).^2));
    end
    [err,i]=min(err);
    bestSD=sd(i);
    gauss=exp(-(requestSec-mean(requestSec)).^2/(2*sd(i)^2));
    gauss=gauss/sum(gauss);
    hold on
    plot(1000*requestSec,1000*gauss,'-r');
    fprintf('Best fitting horizontal SD %.1f ms yields rms error %.1f ms.\n',...
        1000*bestSD,1000*err);
    % Plot the data
    hold on
    plot(1000*requestSec,1000*mean(actualSec),'.k'); % Plot mean data.
    plot(1000*requestSec,1000*model,'-k',1000*requestSec,1000*modelg,'-g',...
        'LineWidth',2); % Plot model.
    g=gca;
    % g.YLim=[0 1000*4*periodSec];
    g.XLim=[0 1000*requestSec(end)];
    daspect([1 1 1]);
end

%% SAVE PLOT TO DISK
if exist('machine','var') && isfield(machine,'summary')
    figureTitle=[mfilename '-' machine.summary '.png'];
else
    figureTitle=[mfilename '.png'];
end
h=gcf;
h.NumberTitle='off';
h.Name=figureTitle;
folder=fileparts(mfilename('fullpath'));
saveas(gcf,fullfile(folder,figureTitle),'png');
fprintf('Figure saved as <strong>''%s''</strong> with %s.m.\n',...
    figureTitle,mfilename);
end

function cost=Cost(requestSec,actualSec,delaySec,periodSec)
% Compute RMS error in predicting actual duration. Non-negative values of
% periodSec and delaySec are enforced by returning infinite cost if either
% is negative.
if periodSec<0 || delaySec<0
    cost=inf;
    return
end
global deemphasizeSteps
model=periodSec*ceil((requestSec+delaySec)/periodSec);
if deemphasizeSteps
    % Frame changes when t=(requestSec+delaySec)/periodSec is integer. Next
    % frame at next integer: ceil. Last frame at last integer: floor. Time
    % till frame is (ceil(t)-t)*periodSec. Time since frame is
    % (t-floor(t))*periodSec. Nearest is
    % min(ceil(t)-t,t-floor(t))*periodSec. Furthest possible is
    % periodSec/2. Nearness (range 0 to 1) is 2*min(ceil(t)-t,t-floor(t)).
    % Give weight 1.1 at time furthest from transition, and weight 0.1 at
    % time of transition. Weight is 0.1+2*min(ceil(t)-t,t-floor(t)). 
    %
    % That seems too abrupt, since the jitter may extend several ms before
    % and after the frame time. So I create a raised sinusoid with the same
    % period as the frame rate that is minimum 0.1 at the frame transition,
    % and maximum 1.1 half a period before or after. Then I normalize it to
    % have a mean of 1.
    t=(requestSec+delaySec)/periodSec;
    w=0.1+(1-cos(t*2*pi))/2;
    w=w/mean(w);
    % plot(requestSec,model,'-r');
    % hold on
    % plot(requestSec,w,'-k');
else
    w=ones(size(requestSec));
end
% RMS error of model of our data.
cost=sqrt(mean(mean((w.^2).*(actualSec-model).^2)));
% fprintf('cost %.1f ms, delaySec %.1f ms, periodSec %.1f ms.\n',...
%     1000*[cost delaySec periodSec]);
end


