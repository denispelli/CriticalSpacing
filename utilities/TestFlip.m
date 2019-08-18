% TestFlip.m
% Measures timing of Screen Flip on your computer and software, producing a
% detailed report. We use the 'when' argument of Screen Flip to request a
% flip time. Our measurements support the theory (plotted as a red line in
% the graph) that Flip occurs on the first available frame after a fixed
% delay. So the possible delay of the flip relative to the time requested
% in "when" ranges from the fixed delay to that plus a frame. Thus, if all
% phases are equally likely, the mean time of the flip, relative to the
% time you specify in "when" is the fixed delay plus half a frame duration.
% So, if you want the Flip to occur as near as possible to a given time,
% you should set Flip's "when" argument to a value before that time. The
% decrement should be the fixed delay measured here (roughly 5 ms) plus
% half a frame duration (about 17/2 ms).
% denis.pelli@nyu.edu, August 17, 2019
%
% See also: Screen('Flip?')

%% MEASURE TIMING
Screen('Preference','SkipSyncTests',1);
periodSec=1/FrameRate; 
clear o t
plusMinus=char(177);
screen=0;
actualDurationVBLSec=[];
white=255;
if true
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','General','UseRetinaResolution');
    PsychImaging('AddTask','General','UseVirtualFramebuffer');
    window=PsychImaging('OpenWindow',screen,white);
else
    window=Screen('OpenWindow',screen,white);
end
repetitions=30;
steps=100;
duration=2*periodSec*(0:steps-1)/steps;
when=zeros(repetitions,steps);
actual=zeros(repetitions,steps);
excess=zeros(repetitions,steps);
for i=1:steps
    % Draw stimulus.
    Screen('TextSize',window,50);
    prior=Screen('Flip',window,0);
    for j=1:repetitions
        Screen('FillRect',window);
        msg=sprintf('Now timing request for %.0f ms. %d of %d.',...
            1000*duration(i),j+(i-1)*repetitions,steps*repetitions);
        Screen('DrawText',window,msg,100,100);
        when(j,i)=prior+duration(i);
        % Flip to show stimulus.
        vbl=Screen('Flip',window,when(j,i));
        actual(j,i)=vbl-prior;
        excess(j,i)=vbl-when(j,i);
        prior=vbl;
    end
end
sca;
fprintf(['Across all duration requests, ' ...
    'the excess duration was %.0f%c%.0f ms (mean%csd), '...
    'with range [%.0f %.0f] ms.\n'],...
    1000*mean(excess(:)),plusMinus,1000*std(excess(:)),...
    plusMinus,...
    1000*min(excess(:)),1000*max(excess(:)));

%% PLOT RESULTS
close all
figure(1)
subplot(1,2,1);
hold on
% Use fixed delay as a degree of freedom to fit the delays.
e=zeros(1,repetitions);
% Find best fitting fixed delay with precision of 0.1 ms.
delay=0:0.0001:0.1;
err=zeros(size(delay));
for i=1:length(delay)
    model=periodSec*ceil((duration+delay(i))/periodSec);
    for j=1:repetitions
        e(j)=mean((actual(j,:)-model).^2);
    end
    err(i)=sqrt(mean(e));
end
[err,i]=min(err);
bestDelay=delay(i);
fprintf('Best fitting fixed delay %.1f ms yields rms error %.1f ms.\n',...
    1000*bestDelay,1000*err);
% Plot the data
for i=1:steps
    plot(1000*duration(i),1000*actual(:,i),'.k');
end
g=gca;
g.YLim=[0 1000*3.7*periodSec];
g.XLim=[0 1000*duration(end)];
daspect([1 1 1]);
plot(1000*duration,1000*duration,'-k');
text(18,17,'requested time');
title('Screen Flip time vs when requested');
xlabel('Requested time re prior flip (ms)');
ylabel('Flip time re prior flip (ms)');
text(1,0.98*g.YLim(2),...
    sprintf('Estimated fixed delay %.1f ms.',1000*bestDelay),...
    'FontWeight','bold');
text(1,0.94*g.YLim(2),...
    sprintf('Frame duration %.1f ms (%.1f Hz).',1000*periodSec,1/periodSec));
text(1,0.9*g.YLim(2),...
    sprintf('Median sd of flip time is %.1f ms.',1000*median(std(excess))));
c=Screen('Computer');
computerModelName=c.hw.model;
text(0.39*g.XLim(2),0.11*g.YLim(2),computerModelName,'FontWeight','bold');
system=strrep(c.system,'Mac OS','macOS'); % Modernize the spelling.
text(0.39*g.XLim(2),0.07*g.YLim(2),system);
[~,v]=PsychtoolboxVersion;
s=sprintf('Psychtoolbox %d.%d.%d',v.major,v.minor,v.point);
text(0.39*g.XLim(2),0.03*g.YLim(2),s);
model=periodSec*ceil((duration+bestDelay)/periodSec);
plot(1000*duration,1000*model,'-r');
ii=find(excess(:)>2*periodSec);
times=sort(excess(ii));
s1=sprintf(['Measured Screen Flip times (black dots) are fit by a model (red). '...
    'Measured delay (VBLTimestamp re prior VBLTimestamp) vs. ' ...
    'requested delay ("when" re prior VBLTimestamp). ' ...
    'The model has only one degree of freedom, a fixed delay %.1f ms. '],...
    1000*bestDelay);
s2=sprintf('We call time=Screen(''Flip'',window,when); ');
s3=sprintf([...
    '%d times for each of %d delays (value of "when" re prior flip). ' ...
    'Delay ranges from %.0f to %.0f ms in steps of %.1f ms. '],...
    repetitions,steps,...
    1000*duration(1),1000*duration(end),1000*(duration(2)-duration(1)));
s4=sprintf('%.1f ms median SD for flip time (re prior). ',...
    1000*median(std(excess)));
% Analyze half the second frame duration, far from the transitions.
r=(duration+bestDelay)/periodSec;
ok=r>1.25 & r<1.75;
a=actual(:,ok);
sd=std(a(:));
s5=sprintf(['%.1f ms SD for flip times (re prior) in '...
    'middle half of the second frame duration. '],1000*sd);
s6=[sprintf(['The %d measured flip times include %d outliers exceeding '...
    'the request by two frame durations: '], ...
    repetitions*steps,length(times)) ...
    sprintf('%.0f ',1000*times) ' ms. '];
s7='Measured by TestFlip.m, available from denis.pelli@nyu.edu. ';
str=[s1 s2 s3 s4 s5 s6 s7];
subplot(1,2,2);
g=gca;
g.XTick=[];
g.YTick=[];
g.Visible='off';
annotation('textbox',g.Position,'String',str,'LineStyle','none');

%% SAVE PLOT TO DISK
[~,v]=PsychtoolboxVersion;
psych=sprintf('%d.%d.%d',v.major,v.minor,v.point);
figureTitle=['TestFlip-' computerModelName '-' system '-' psych '.png'];
h=gcf;
h.NumberTitle='off';
h.Name=figureTitle;
graphFile=fullfile(fileparts(mfilename('fullpath')),figureTitle);
saveas(gcf,graphFile,'png');
fprintf('Figure has been saved to disk as file "%s".\n',figureTitle);

