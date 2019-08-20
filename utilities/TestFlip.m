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
repetitions=100; % 100
steps=100; % 100
Screen('Preference','SkipSyncTests',1);
periodSec=1/FrameRate;
plusMinus=char(177);
micro=char(181);
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
duration=2.5*periodSec*(0:steps-1)/steps;
when=zeros(repetitions,steps);
actual=zeros(repetitions,steps);
excess=zeros(repetitions,steps);
vsf=zeros(repetitions,steps,3);
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
        [VBLTimestamp,StimulusOnsetTime,FlipTimestamp]=Screen('Flip',window,when(j,i));
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

%% FOR DEBUGGING, SAVE DATA TO DISK
machine=ComputerModelName;
c=Screen('Computer');
os=strrep(c.system,'Mac OS','macOS'); % Modernize the spelling.
[~,v]=PsychtoolboxVersion;
psych=sprintf('%d.%d.%d',v.major,v.minor,v.point);
saveTitle=['TestFlip-' machine.Model '-' os '-' psych '.mat'];
folder=fileparts(mfilename('fullpath'));
close all
save([folder filesep saveTitle]);
fprintf('Data have been saved to disk as file "%s" alongside TestFlip.m.\n',saveTitle);

%% PLOT RESULTS
close all
f=figure(1);
f.Position(3)=1.5*f.Position(3);

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
bestDelay=delay(i);
fprintf('Best fitting fixed delay %.1f ms yields rms error %.1f ms.\n',...
    1000*bestDelay,1000*err);
% Analyze half the second frame duration, far from the transitions.
r=(duration+bestDelay)/periodSec;
ok=1.25<r & r<1.75;
a=actual(:,ok);
sd=std(a(:));
% Plot the data
for i=1:length(duration)
    % One point for each repetition.
    plot(1000*duration(i),1000*actual(:,i),'.k');
end
g=gca;
g.YLim=[0 1000*4.5*periodSec];
g.XLim=[0 1000*duration(end)];
daspect([1 1 1]);
plot(1000*duration,1000*duration,'-k');
text(23,22,'requested time');
title('Screen Flip time vs when requested');
xlabel('Requested time re prior flip (ms)');
ylabel('Flip time re prior flip (ms)');
text(1,0.95*g.YLim(2),...
    sprintf('Estimated fixed delay %.1f ms.',1000*bestDelay),...
    'FontWeight','bold');
text(1,0.91*g.YLim(2),...
    sprintf('Frame duration %.1f ms (%.1f Hz).',...
    1000*periodSec,1/periodSec));
text(1,0.87*g.YLim(2),...
    sprintf('Median sd of flip time is %.1f ms.',...
    1000*median(std(excess))));
text(1,0.83*g.YLim(2),...
    sprintf('Flip SD is %.1f ms in middle half',1000*sd));
text(1,0.79*g.YLim(2),'of the second frame duration. ');
machine=ComputerModelName;
if ~isempty(machine.ModelLong)
    model=machine.ModelLong;
else
    model=machine.Model;
end
i=strfind(model,' (');
if length(model)>25 && ~isempty(i)
    i=i(1);
    model1=model(1:i);
    model2=model(i+1:end);
    text(0.99*g.XLim(2),0.19*g.YLim(2),model1,'FontWeight','bold','HorizontalAlignment','right');
    text(0.99*g.XLim(2),0.15*g.YLim(2),model2,'FontWeight','bold','HorizontalAlignment','right');
else
    text(0.99*g.XLim(2),0.15*g.YLim(2),model,'FontWeight','bold','HorizontalAlignment','right');
end
text(0.99*g.XLim(2),0.11*g.YLim(2),machine.Manufacturer,'HorizontalAlignment','right');
text(0.99*g.XLim(2),0.07*g.YLim(2),os,'HorizontalAlignment','right');
[~,v]=PsychtoolboxVersion;
psych=sprintf('%d.%d.%d',v.major,v.minor,v.point);
text(0.99*g.XLim(2),0.03*g.YLim(2),['Psychtoolbox ' psych],'HorizontalAlignment','right');
model=periodSec*ceil((duration+bestDelay)/periodSec);
plot(1000*duration,1000*model,'-r');

% Panel 2
subplot(1,3,2);
ii=find(excess(:)>2*periodSec);
times=sort(excess(ii));
s1=sprintf(['CAPTION: Measured Screen Flip times (black dots) are fit by a model (red). '...
    'The model has only one degree of freedom, a fixed delay %.1f ms. '...
    'The data are measured delay (VBLTimestamp re prior VBLTimestamp) vs. ' ...
    'requested delay ("when" re prior VBLTimestamp). '], ...
    1000*bestDelay);
s2=sprintf('We call \ntime=Screen(''Flip'',window,when);\n');
s3=sprintf([...
    '%d times for each of %d delays (value of "when" re prior flip). ' ...
    'Delay ranges from %.0f to %.0f ms in steps of %.1f ms. '],...
    repetitions,steps,...
    1000*duration(1),1000*duration(end),1000*(duration(2)-duration(1)));
s6=[sprintf(['The %d measured flip times include %d outliers exceeding '...
    'the request by two frame durations: '], ...
    repetitions*steps,length(times)) ...
    sprintf('%.0f ',1000*times) ' ms. '];
s7='Measured by TestFlip.m, available from denis.pelli@nyu.edu. ';
str=[s1 s2 s3  s6 s7];
g=gca;
g.Visible='off';
position=g.Position;
position(3)=position(3)*1.3; % Widen text box.
annotation('textbox',position,'String',str,'LineStyle','none');

% Panel 3.
subplot(1,3,3);
s8=sprintf(['JITTER: The red-line model ignores the jitter. '...
    'We believe that there is essentially no jitter in the '...
    'display frame rate (generated by the graphics chip) and the '...
    'system time (generated by the clock oscillator in the CPU). These '...
    'autonomous devices should be immune to unix timesharing. '...
    'Thus the %.1f ms vertical jitter seen in the reported frame time, '...
    'and the sometimes similar horizontal jitter in the data, '...
    'must arise in the software reporting of when '...
    'the current and prior frames occurred and the implementation '...
    'of the when timer. \n'],1000*sd);
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
position=g.Position;
position(3)=position(3)*1.3; % Widen text box.
annotation('textbox',position,'String',str,'LineStyle','none');

% Assuming the frame frequency is stable, we estimate the true
% frame times and assess the sd of VBLTimestamp relative to that.
tMeasured=cumsum(actual);
tEst=zeros(size(tMeasured));
for i=1:length(duration)
    % Assume all frames have average length.
    % This is optimal period. Might not be quite optimal phase, but that
    % will only affect mean, not SD of the deviance.
    tEst(:,i)=linspace(tMeasured(1,i),tMeasured(end,i),size(tMeasured,1));
end
dt=tMeasured-tEst;
sdT=std(dt);
% plot(1000*duration,1000*sdT,'-r');
ylabel('SD re estimated true frame time (ms)');
xlabel('Requested flip time re previous (ms)');
r=(duration+bestDelay)/periodSec;
ok=(r>0.25 & r<0.75) | (r>1.25 & r<1.75) | (r>2.25 & r<2.75);
sdT=std(dt(ok));
fprintf('%.1f ms SD of times re periodic times.\n',1000*sdT);

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
c=Screen('Computer');
os=strrep(c.system,'Mac OS','macOS'); % Modernize the spelling.
figureTitle=['TestFlip-' machine.Model '-' os '-' psych '.png'];
h=gcf;
h.NumberTitle='off';
h.Name=figureTitle;
folder=fileparts(mfilename('fullpath'));
saveas(gcf,[folder filesep figureTitle],'png');
fprintf(['<strong>Figure has been saved to disk as file "%s", '...
    'next to TestFlip.m.</strong>\n'],figureTitle);

%% GET COMPUTER'S MODEL NAME
function machine=ComputerModelName
clear machine
machine.Model='';
machine.ModelLong='';
machine.Manufacturer='';
c=Screen('Computer');
os=strrep(c.system,'Mac OS','macOS'); % Modernize the spelling.
if isfield(c,'hw') && isfield(c.hw,'model')
    machine.Model=c.hw.model;
end
switch computer
    case 'MACI64'
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        s = evalc(['!'...
            'curl -s https://support-sp.apple.com/sp/product?cc=$('...
            'system_profiler SPHardwareDataType '...
            '| awk ''/Serial/ {print $4}'' '...
            '| cut -c 9- '...
            ') | sed ''s|.*<configCode>\(.*\)</configCode>.*|\1|''']);
        s=strrep(s,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        if s(end)==' '
            s=s(1:end-1); % Remove trailing space.
        end
        machine.ModelLong=s;
        machine.Manufacturer='Apple Inc.';
    case 'PCWIN64'
        wmicString = evalc('!wmic computersystem get manufacturer, model');
        % Here's a typical result:
        %         wmicString=sprintf(['    ''Manufacturer  Model            \r'...
        %         '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(wmicString,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Change run of 2+ spaces to a tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9));
        clear ok
        for i=1:length(fields)
            ok(i)=~isempty(fields{i});
        end
        fields=fields(ok); % Discard empty fields.
        % The original had two columns: category and value. We've now got
        % one long column with n categories followed by n values.
        % We asked for Manufacturer and Model so n should be 2.
        n=length(fields)/2;
        for i=1:n
            % Grab each field's name and value.
            machine.(fields{i})=fields{i+n};
        end
        if ~isfield(machine,'Manufacturer') || isempty(machine.Manufacturer)...
                || ~isfield(machine,'Model') || isempty(machine.Model)
            wmicString
            warning('Failed to retrieve Manufacturer and Model from WMIC.');
        end
    case 'GLNXA64'
        machine.Manufacturer='';
        machine.Model='linux';
end
end