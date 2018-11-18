%% Analyze the data collected by EvsNRun.

experiment='runCrowdingSurvey';
printFilenames=true;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
close all

%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'dataFilename' ... % 'experiment' 
    'experimenter' 'observer' 'trials' 'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'... %'targetHeightDeg' 'targetKind'
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm'  'nearPointXYPix'  'beginningTime' 'row'};
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.

%% CLEAN
for oi=1:length(oo)
    if streq(oo(oi).thresholdParameter,'size')
        oo(oi).spacingDeg=nan;
        oo(oi).flankingDirection='none';
    end
    oo(oi).experiment=experiment;
end

%% SELECT CONDITION(S)

if isempty(oo)
    error('No conditions selected.');
end

% Report the relevant fields of each file.
t=struct2table(oo);
if printFilenames
    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    switch experiment
        case 'runCrowdingSurvey'
            disp(t(:,{'observer','eccentricityXYDeg', ...
                'thresholdParameter','flankingDirection','spacingDeg','targetDeg', ...
                'dataFilename' ...
                }));
    end
end

%% COMPUTE MEAN FOR EACH OBSERVER FOR EACH MEASURE
% Replace repeated measures by their mean.
% The new table has the mean of each observer, at each location and
% flankingDirection.
t=sortrows(t,{'eccentricityXYDeg','thresholdParameter','observer'});
i=1;
tmean=table();
t(:,'n')={1}; % Number of observers represented by this row.
while ~isempty(t)
    tmean(i,:)=t(1,:);
    match=ismember(t{:,'observer'},t{1,'observer'}) ...
        & ismember(t.eccentricityXYDeg(:,1),t(1,:).eccentricityXYDeg(:,1)) ...
        & ismember(t.flankingDirection,t(1,:).flankingDirection);
    tmean(i,'n')={sum(match)};
    if sum(match)==0
        error('No match.');
    end
    tmean(i,'spacingDeg')={mean(t{match,'spacingDeg'})};
    tmean(i,'targetDeg')={mean(t{match,'targetDeg'})};
    t(match,:)=[];
    i=i+1;
end
t=tmean;

%% PLOT HISTOGRAMS (ACROSS OBSERVERS & HEMISPHERES) OF THREE KINDS OF THRESHOLD. AT ±5,0 DEG.
for type=1:5
    switch type
        case 1
            ok=streq(t.thresholdParameter,'size');
            x=t(ok,:).targetDeg;
            name='Acuity (deg)';
        case 2
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'radial');
            x=t{ok,'spacingDeg'};
            name='Radial crowding distance (deg)';
        case 3
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
            x=t{ok,'spacingDeg'};
            name='Tangential crowding distance (deg)';
        case 4
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'radial');
            x=t{ok,'spacingDeg'};
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
            y=t{ok,'spacingDeg'};
            x=x./y;
            name='Radial:Tangential ratio';
        case 5
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
            x=t{ok,'spacingDeg'};
            ok=streq(t.thresholdParameter,'size');
            y=t(ok,:).targetDeg;
            x=x./y;
            name='Tangential crowding:Acuity ratio';
    end
    if sum(ok)==0
        continue
    end
    i=find(ok);
    parameter=name;
    subplot(5,2,(type-1)*2+1)
    histogram(x,8);
    ylabel('Count');
    xlabel(parameter);
    plusMinus=177;
    title(sprintf('Histogram at (%c%.0f,%.0f) deg',plusMinus,abs(t{i(1),'eccentricityXYDeg'})));
    ax=gca;
    ax.FontSize=12;
    yticks(round(ax.YLim(1)):ax.YLim(2));
    subplot(5,2,(type-1)*2+2)
    histogram(log10(x),'BinWidth',0.25);
    ylabel('Count');
    xlabel(['log ' parameter]);
    title(sprintf('Histogram at (%c%.0f,%.0f) deg',plusMinus,abs(t{i(1),'eccentricityXYDeg'})));
    ax=gca;
    ax.FontSize=12;
    yticks(round(ax.YLim(1)):ax.YLim(2));
end

x0=1;
y0=1;
width=25;
height=50;
set(gcf,'units','centimeters','position',[x0,y0,width,height])

%% SAVE PLOT TO DISK
figureTitle='Histograms';
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.fig']);
saveas(gcf,graphFile)
fprintf('Figure saved as ''%s.eps'' and ''%s.fig''\n',figureTitle,figureTitle);

%% SAVE TO DISK AS CSV AND FIG FILES
printConditions=true;
saveSpreadsheet=true;
vars={'experiment' ...
    'experimenter' 'observer' 'trials' 'contrast'  ...
     'eccentricityXYDeg' 'flankingDirection' 'thresholdParameter' ...
    'targetDeg' 'spacingDeg' 'durationSec' ...
    'viewingDistanceCm'  ...
     'dataFilename'};
t=struct2table(oo,'AsArray',true);
dataFilename=[experiment '.csv'];
if printConditions
    disp(t(:,vars));
end
if saveSpreadsheet
    spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',dataFilename);
    writetable(t,spreadsheet);
    fprintf('All selected fields have been saved in spreadsheet: /data/%s\n',dataFilename);
end

