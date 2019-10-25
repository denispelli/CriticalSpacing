% TestFlip.m
% Measures timing of Screen Flip on your computer and software, producing a
% detailed report. We use the 'when' argument of Screen Flip to request a
% flip time. Our measurements support the theory (plotted as a red line in
% the graph) that Flip occurs on the first available frame after a fixed
% delay. According to this model, the possible delay of the flip relative
% to the time requested in "when" ranges from the fixed delay to that plus
% a frame. Thus, if all phases are equally likely, the mean time of the
% flip, relative to the time you specify in "when" is the fixed delay plus
% half a frame duration. So, if you want the Flip to occur as near as
% possible to a given time, you should set Flip's "when" argument to a
% value before that time. The decrement should be the fixed delay measured
% here (roughly 5 ms) plus half a frame duration (about 17/2 ms).
% denis.pelli@nyu.edu, August 20, 2019
%
% From discusson on Psychtoolbox forum:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/23963
% Dear Mario and friends
% following up on the helpful feedback, i wrote a test program (included
% below) to document the timing of Screen Flip and asked friends to run it
% on various computers. I've pasted the results below. (They ran slightly
% different versions, as I developed it, so some of the printouts are cut
% off, but the key numbers are visible. Mostly they timed 10,000 calls to
% Screen Flip, with various "when" requests, but one is for 100 calls.)
% Screen Flip works well enough on all machines for most purposes. It runs
% almost perfectly on Dell's Inspiron 5379, under Windows, but less well on
% Dell's Inspiron 13-7359. Among the macs there is quite a variety in
% results. I hope someone will run TestFlip on Linux and post results. The
% pattern of delays is more complicated than I anticipated, which may offer
% clues to what is causing the delays. (I am baffled by the banding which
% appears with some "when" values and not others.) I offer the code for
% everyone to use freely, and for inclusion in the Psychtoolbox. Mario
% works hard to get good timing, despite the ever changing challenges of
% the operating systems. This is intended to aid that effort by
% charactering performance.
% Best
% Denis
% p.s.
% The data collection, fitting, plotting, and saving now seem to work
% robustly on macOS and Windows computers. Fingers crossed, I expect it to
% work fine on Linux too. However, it's important to label the results with
% the computer model name, and I include a subroutine IdentifyComputer to
% get that. This turned out to be much harder than I'd anticipated, and it
% works on most machines but still fails on some. I think it's robust
% enough to proceed without the name, but that's likely where compatibility
% issues will occur.
%
% See also: FlipTest, Screen('Flip?'), IdentifyComputer

% September 24, 2019
% Force native resolution, as requested by Mario Kleiner.

screen=0;
% Don't call IdentifyComputer until after we've set the resolution, 
% because IdentifyComputer should report the actual resolution tested.

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
        fprintf(['(To use native resolution, set permissionToChangeResolution=true in TestFlip.m, \n'...
            'or use System Preferences:Displays to select "Default" resolution.)\n']);
        warning backtrace on
    end
end
resolution=Screen('Resolution',screen);

%% MEASURE TIMING
repetitions=100; % 100
steps=100; % 100
Screen('Preference','SkipSyncTests',1);
periodSec=1/FrameRate;
plusMinus=char(177);
micro=char(181);
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
% machine=IdentifyComputer(window); % Fails with experimental Screen.
machine=IdentifyComputer(0); % Work around.
duration=2.5*periodSec*(0:steps-1)/steps;
when=zeros(repetitions,steps);
actual=zeros(repetitions,steps);
excess=zeros(repetitions,steps);
vsf=zeros(repetitions,steps,3);
for i=1:steps
    % Draw stimulus.
    Screen('TextSize',window,round(50*fractionOfScreenUsed));
    prior=Screen('Flip',window,0);
    for j=1:repetitions
        Screen('FillRect',window);
        msg=sprintf('Now timing request for %.0f ms.  %d of %d.',...
            1000*duration(i),j+(i-1)*repetitions,steps*repetitions);
        Screen('TextBackgroundColor',window,255); % Set background.
        Screen('DrawText',window,double(msg),...
            round(100*fractionOfScreenUsed),round(100*fractionOfScreenUsed));
        when(j,i)=prior+duration(i);
        % Flip to show stimulus.
        [VBLTimestamp,StimulusOnsetTime,FlipTimestamp]=...
            Screen('Flip',window,when(j,i));
        actual(j,i)=VBLTimestamp-prior;
        excess(j,i)=VBLTimestamp-when(j,i);
        prior=VBLTimestamp;
        vsf(j,i,1:3)=[VBLTimestamp, StimulusOnsetTime, FlipTimestamp];
    end
end
Screen('Close',window);
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

%% OPTIONALLY, SAVE DATA TO DISK
if 1
    % This saves all the measurements as a MAT file, so that the data can
    % be analyzed later or remotely.
    saveTitle=['TestFlip-' machine.model '-' machine.system ...
        '-' machine.psychtoolbox '.mat'];
    saveTitle=strrep(saveTitle,'Windows','Win');
    saveTitle=strrep(saveTitle,'Psychtoolbox','Psy');
    saveTitle=strrep(saveTitle,' ','-');
    folder=fileparts(which('TestFlip'));
    close all
    save([folder filesep saveTitle]);
    fprintf(['<strong>Data have been saved to disk as file "%s", '...
        'next to TestFlip.m.</strong>\n'],saveTitle);
end

%% RESTORE RESOLUTION
if permissionToChangeResolution && ...
        (oldResolution.width~=resolution.width || ...
        oldResolution.height~=resolution.height)
    Screen('Resolution',screen,oldResolution.width,oldResolution.height);
end

%% PLOT RESULTS
% This can run on saved data from any machine. Just LOAD the saved MAT
% file.
close all
f=figure(1);
screenRect=Screen('Rect',0);
r=[0 0 819 557]; % Works well on MacBook so exporting to all computers.
r=CenterRect(r,screenRect);
r=OffsetRect(r,0,-r(2));
% Convert Apple rect to MATLAB Position.
f.Position=[r(1) screenRect(4)-r(4) RectWidth(r) RectHeight(r)];

% Panel 1
subplot(1,3,1);
hold on
% Use fixed delay as a degree of freedom to fit the delays.
% Find best fitting fixed delay with precision of 0.1 ms.
e=zeros(1,repetitions);
delay=0:0.0001:0.1;
err=zeros(size(delay));
for i=1:length(delay)
    % Compute model for this fixed delay.
    model=periodSec*ceil((duration+delay(i))/periodSec);
    for j=1:repetitions
        % Each iteration of j combines all durations.
        e(j)=mean((actual(j,:)-model).^2);
    end
    % RMS error of model of our data.
    err(i)=sqrt(mean(e));
end
[err,i]=min(err);
bestFixedDelay=delay(i);
fprintf('Best fitting fixed delay %.1f ms yields rms error %.1f ms.\n',...
    1000*bestFixedDelay,1000*err);
% Analyze mid half of second frame duration, far from the transitions.
r=(duration+bestFixedDelay)/periodSec;
% ok=(r>0.25 & r<0.75) | (r>1.25 & r<1.75) | (r>2.25 & r<2.75);
ok=1.25<r & r<1.75;
a=actual(:,ok);
sdMidHalfFrame=std(a(:));

% Assuming the frame frequency is stable, we estimate the true frame times
% and assess the sd of VBLTimestamp relative to that.
tMeasured=cumsum(actual);
tEst=zeros(size(tMeasured));
for i=1:length(duration)
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
if 0
    % Show more detail than just the one-number summary
    % sdMidHalfFrameRePeriodic.
    % Plot error re better estimate of actual frame time.
    sd=std(dt);
    plot(1000*duration,1000*sd,'-r');
    ylabel('SD re estimated true frame time (ms)','FontSize',12);
    xlabel('Requested flip time re previous (ms)','FontSize',12);
end
r=(duration+bestFixedDelay)/periodSec;
% Select only the data that are far from the vertical transitions.
% ok=(r>0.25 & r<0.75) | (r>1.25 & r<1.75) | (r>2.25 & r<2.75);
ok=(r>1.25 & r<1.75) ;
dtOk=dt(:,ok);
sdMidHalfFrameRePeriodic=std(dtOk(:));
fprintf('%.1f ms SD re periodic times.\n',1000*sdMidHalfFrameRePeriodic);

% Plot the data
for i=1:length(duration)
    % One point for each repetition.
    plot(1000*duration(i),1000*actual(:,i),'.k');
end
g=gca;
g.YLim=[0 1000*4.5*periodSec];
g.XLim=[0 1000*duration(end)];
g.Position(2)=g.Position(2)+0.05*g.Position(4);
g.Position([3 4])=1.3*g.Position([3 4]);
g.Position([1 2])=g.Position([1 2])-0.15*g.Position([3 4]);
daspect([1 1 1]);
plot(1000*duration,1000*duration,'-k');
text(28,27,'req. time','FontSize',12);
title('Stimulus duration vs requested','FontSize',16);
xlabel('Requested duration (ms)','FontSize',16);
ylabel('Duration (ms)','FontSize',16);
y=0.97*g.YLim(2);
dy=0.035*g.YLim(2);
text(1,y,...
    sprintf('Estimated fixed delay %.1f ms.',1000*bestFixedDelay),...
    'FontSize',12);
y=y-dy;
text(1,y,...
    sprintf('Frame period %.1f ms (%.1f Hz).',...
    1000*periodSec,1/periodSec),'FontSize',12);
y=y-dy;
text(1,y,'SD of flip time re prior flip:','FontSize',12);
y=y-dy;
text(1,y,...
    sprintf('mean %.1f ms, median %.1f ms, ',...
    1000*mean(std(excess)),1000*median(std(excess))),'FontSize',12);
y=y-dy;
text(1,y,...
    sprintf('%.1f ms in mid half of frame.',1000*sdMidHalfFrame),...
    'FontSize',12);
y=y-dy;
text(1,y,'SD of flip re periodic est.:','FontSize',12);
y=y-dy;
text(1,y,...
    sprintf('%.1f ms in mid half of frame. ',...
    1000*sdMidHalfFrameRePeriodic),'FontSize',12);
if ~isempty(machine.modelDescription)
    model=machine.modelDescription;
else
    model=machine.model;
end
y=0.02*g.YLim(2);
x=0.99*g.XLim(2);
dy=0.03*g.YLim(2);
if ~isempty(machine.openGLVersion)
    text(x,y,machine.openGLVersion,...
        'HorizontalAlignment','right','FontSize',10); y=y+dy;
end
if ~isempty(machine.openGLVendor)
    text(x,y,machine.openGLVendor,...
        'HorizontalAlignment','right','FontSize',10); y=y+dy;
end
if ~isempty(machine.openGLRenderer)
    text(x,y,machine.openGLRenderer,...
        'HorizontalAlignment','right','FontSize',10); y=y+dy;
end
text(x,y,sprintf('screen %d, %d x %d',screen,resolution.height,resolution.width),...
            'HorizontalAlignment','right','FontSize',10); y=y+dy;
text(x,y,machine.system,...
    'HorizontalAlignment','right','FontSize',10); y=y+dy;
if ~isempty(machine.psychtoolboxKernelDriver)
    text(x,y,machine.psychtoolboxKernelDriver,...
        'HorizontalAlignment','right','FontSize',10); y=y+dy;
end
text(x,y,machine.psychtoolbox,...
    'HorizontalAlignment','right','FontSize',10); y=y+dy;
if ~isempty(machine.manufacturer)
    text(x,y,machine.manufacturer,...
        'HorizontalAlignment','right','FontSize',10); y=y+dy;
end
i=strfind(model,' (');
if length(model)>25 && ~isempty(i)
    i=i(1);
    model2=model(i+1:end);
    model=model(1:i-1); % Omit the space.
    text(x,y,model2,...
        'HorizontalAlignment','right','FontSize',10);
    y=y+dy;
end
text(x,y,model,...
    'FontWeight','bold','HorizontalAlignment','right','FontSize',14);
y=y+dy;
model=periodSec*ceil((duration+bestFixedDelay)/periodSec);
plot(1000*duration,1000*model,'-r','LineWidth',1.0);
g.Units='normalized';
g.Position=[.09 0 .28 1];
panelOnePosition=g.Position;

% Panel 2
subplot(1,3,2);
ii=find(excess(:)>2*periodSec);
times=sort(excess(ii));
s1=sprintf(['CAPTION: Measured durations (black dots) are fit by a model (red). '...
    'The model has only one degree of freedom, a fixed delay %.1f ms. '...
    'The data are measured duration (VBLTimestamp re prior VBLTimestamp) vs. ' ...
    'requested duration ("when" re prior VBLTimestamp). We call '], ...
    1000*bestFixedDelay);
s2=['\bf' 'time=Screen(''Flip'',window,when);' '\rm'];
s3=sprintf([...
    '%d times for each of %d requested durations. ' ...
    'Requests range from %.0f to %.0f ms in steps of %.1f ms. '],...
    repetitions,steps,...
    1000*duration(1),1000*duration(end),1000*(duration(2)-duration(1)));
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
    'at which the duration increases suddenly by a whole frame), '...
    'must arise in the software reports of '],1000*sdMidHalfFrame);
str={[s1 s2] [s3  s6 s7 s8]};
g=gca;
g.Visible='off';
position=[g.Position(1) 0 panelOnePosition(3) 1];
annotation('textbox',position,'String',str,'LineStyle','none','FontSize',12);

% Panel 3.
subplot(1,3,3);
s8=sprintf(['when flips occur and the implementation '...
    'of the "when" timer.\n\n'...
    'ISOLATING ONE JITTER: Our plotted duration is the interval between '...
    'two reported flip times. Its jitter is the difference between the  '...
    'jitters of two successive flip reports. If these successive '...
    'jitters are perfectly correlated then they will cancel in the '...
    'difference. If they are independent then the '...
    'variance of the difference will be twice the jitter variance. '...
    'In that case, for duration requests that are far from the '...
    'vertical lines, we can reduce our duration jitter by using the '...
    'known periodicity of the frames to make a low-noise estimate '...
    'of the true flip time (across our %d repetitions) and use that as '...
    'our reference, instead of the prior flip time. '...
    'This isolates one jitter. '...
    'Correlation predicts that isolation will increase SD. '...
    'Independence predicts reduction of jitter SD, by sqrt(2), '...
    'i.e. 1.4:1. In fact, isolation here changes the SD from '...
    '%.2f to %.2f ms, a ratio of %.2f:1.\n'],...
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

if 0
    % Not quite working.
    % Estimate the horizontal jitter.
    figure(2)
    % Fit the horizontal jitter.
    e=zeros(1,repetitions);
    sd=0.0001:0.0001:0.003;
    for i=1:length(sd)
        % Compute model for this horizontal jitter.
        gauss=exp(-(duration-mean(duration)).^2/(2*sd(i)^2));
        gauss=gauss/sum(gauss);
        model=periodSec*ceil((duration+delay(i))/periodSec);
        modelg=conv(gauss,model,'same');
        plot(1000*duration,1000*model,'-k',1000*duration,1000*modelg,'-g',...
            'LineWidth',2);
        e=mean(actual)-modelg;
        err(i)=sqrt(mean(e(20:end-20).^2));
    end
    [err,i]=min(err);
    bestSD=sd(i);
    gauss=exp(-(duration-mean(duration)).^2/(2*sd(i)^2));
    gauss=gauss/sum(gauss);
    hold on
    plot(1000*duration,1000*gauss,'-r');
    fprintf('Best fitting horizontal SD %.1f ms yields rms error %.1f ms.\n',...
        1000*bestSD,1000*err);
    % Plot the data
    hold on
    plot(1000*duration,1000*mean(actual),'.k');
    plot(1000*duration,1000*model,'-k',1000*duration,1000*modelg,'-g',...
        'LineWidth',2);
    g=gca;
    % g.YLim=[0 1000*4*periodSec];
    g.XLim=[0 1000*duration(end)];
    daspect([1 1 1]);
end

%% SAVE PLOT TO DISK
figureTitle=['TestFlip-' machine.model '-' machine.system ...
    '-' machine.psychtoolbox '.png'];
figureTitle=strrep(figureTitle,'Windows','Win');
figureTitle=strrep(figureTitle,'Psychtoolbox','Psy');
figureTitle=strrep(figureTitle,' ','-');
h=gcf;
h.NumberTitle='off';
h.Name=figureTitle;
folder=fileparts(which('TestFlip'));
saveas(gcf,[folder filesep figureTitle],'png');
fprintf(['<strong>Figure has been saved to disk as file "%s", '...
    'next to TestFlip.m.</strong>\n'],figureTitle);

