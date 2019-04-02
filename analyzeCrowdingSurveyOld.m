%% Analyze the data collected by runCrowdingSurvey.

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
    'contrast' 'pixPerCm'  'nearPointXYPix'  'beginningTime' };
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.

%% CLEAN
for oi=1:length(oo)
    if streq(oo(oi).thresholdParameter,'size')
        oo(oi).spacingDeg=nan;
        oo(oi).flankingDirection='none';
    end
    oo(oi).experiment=experiment;
    ok(oi)=~any(ismember(oo(oi).observer,{'','d'}));
end
oo=oo(ok);

%% SELECT CONDITION(S)

if isempty(oo)
    error('No conditions selected.');
end

% Report the relevant fields of each file.
t=struct2table(oo);
t=sortrows(t,{'thresholdParameter' 'observer' 'eccentricityXYDeg' });
if printFilenames
    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    switch experiment
        case 'runCrowdingSurvey'
            disp(t(:,{'thresholdParameter' 'observer' 'eccentricityXYDeg' ...
                'flankingDirection' 'spacingDeg' 'targetDeg' ...
                'dataFilename' ...
                }));
    end
end

%% COMPUTE MEAN FOR EACH OBSERVER FOR EACH MEASURE
% Replace repeated measures by their mean.
% The new table has the mean of each observer, at each location and
% flankingDirection.
% t=sortrows(t,{'eccentricityXYDeg','thresholdParameter','observer'});
tmean=table();
t(:,'n')={1}; % Number of thresholds represented by each row.
i=1;
while ~isempty(t)
    if i>1
        tmean(i,:)=tmean(1,:); % Add a row.
    end
    tmean(i,t.Properties.VariableNames)=t(1,:);
    tmean(:,{'spacingDeg' 'targetDeg'})=[];
    match=ismember(t{:,'observer'},t{1,'observer'}) ...
        & ismember(t.eccentricityXYDeg(:,1),t(1,:).eccentricityXYDeg(:,1)) ...
        & ismember(t.flankingDirection,t(1,:).flankingDirection);
    tmean(i,'n')={sum(match)};
    if sum(match)==0
        error('No match.');
    end
    tmean(i,'logSpacingDegMean')={mean(log10(t{match,'spacingDeg'}))};
    tmean(i,'logSpacingDegSD')={std(log10(t{match,'spacingDeg'}))};
    tmean(i,'logSpacingDegN')={length(log10(t{match,'spacingDeg'}))};
    tmean(i,'logAcuityDegMean')={mean(log10(t{match,'targetDeg'}))};
    tmean(i,'logAcuityDegSD')={std(log10(t{match,'targetDeg'}))};
    tmean(i,'logAcuityDegN')={length(log10(t{match,'targetDeg'}))};
    t(match,:)=[];
    i=i+1;
end
t=tmean;
clear height
fprintf('Repeated measures have been replaced by their means. %d thresholds over %d conditions.\n',sum(t.n),height(t));
disp(t(:,{'thresholdParameter','observer','n','eccentricityXYDeg', ...
                'flankingDirection'}));

%% PLOT HISTOGRAMS (ACROSS OBSERVERS & HEMISPHERES) OF THREE KINDS OF THRESHOLD. AT ±5,0 DEG.
figure;
width=25;
height=50;
set(0,'units','centimeters');
screenSize=get(groot,'Screensize');
set(gcf,'units','centimeters','position',[screenSize(3)-width,0,width,height])
plusMinus=char(177);
for type=1:3
    switch type
        case 1
            ok=streq(t.thresholdParameter,'size');
            x=t(ok,:).logAcuityDegMean;
            name='Acuity (deg)';
            m=mean(x);
            sd=std(x);
            se=mean(t(ok,:).logAcuityDegSD./sqrt(t(ok,:).logAcuityDegN))/sqrt(length(x));
            name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
        case 2
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'radial');
            x=t{ok,'logSpacingDegMean'};
            name='log Radial crowding distance (deg)';
            m=mean(x);
            sd=std(x);
            se=mean(t(ok,:).logSpacingDegSD./sqrt(t(ok,:).logSpacingDegN))/sqrt(length(x));
            name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
        case 3
            ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
            x=t{ok,'logSpacingDegMean'};
            name='log Tangential crowding distance (deg)';
            m=mean(x);
            sd=std(x);
            okPositive=ok & t.logSpacingDegSD>0;
            se=mean(t(okPositive,:).logSpacingDegSD./sqrt(t(okPositive,:).logSpacingDegN))/sqrt(length(x));
            name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
%         case 4
%             ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'radial');
%             x=t{ok,'logSpacingDegMean'};
%             ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
%             y=t{ok,'logSpacingDegMean'};
%             x=x-y;
%             name='log Radial:Tangential ratio';
%             m=mean(x);
%             sd=std(x);
%             name=sprintf('%s, mean %.1f%c%.1f',name,m,plusMinus,sd);
%        case 5
%             ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
%             x=t{ok,'logSpacingDegMean'};
%             ok=streq(t.thresholdParameter,'size');
%             y=t(ok,:).logAcuityDegMean;
%             x=x-y;
%             name='log Tangential crowding:Acuity ratio';
%             m=mean(x);
%             sd=std(x);
%             name=sprintf('%s, mean %.1f%c%.1f',name,m,plusMinus,sd);
    end
    if sum(ok)==0
        continue
    end
    i=find(ok);
    parameter=name;
    subplot(3,1,type)
    histogram(x,'BinWidth',0.1);
    ylabel('Count');
    xlabel([parameter]);
    title(sprintf('Histogram of %d hemispheres at (%c%.0f,%.0f) deg',length(x),plusMinus,abs(t{i(1),'eccentricityXYDeg'})));
    ax=gca;
    ax.FontSize=12;
    yticks(unique(round(ax.YTick)));
    if ax.YLim(2)>4
        ax.YMinorTick='on';
    end
end
if true
    % Align x axes of radial and tangential histograms.
    subplot(3,1,2)
    ax=gca;
    radialXLim=ax.XLim;
    subplot(3,1,3)
    ax=gca;
    tangentialXLim=ax.XLim;
    ax.XLim(1)=min([radialXLim(1) tangentialXLim(1)]);
    ax.XLim(2)=max([radialXLim(2) tangentialXLim(2)]);
    subplot(3,1,2)
    ax=gca;
    ax.XLim(1)=min([radialXLim(1) tangentialXLim(1)]);
    ax.XLim(2)=max([radialXLim(2) tangentialXLim(2)]);
end

%% SAVE PLOT TO DISK
figureTitle='Histograms';
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.fig']);
saveas(gcf,graphFile)
fprintf('Figure saved as ''/data/%s.eps'' and ''/data/%s.fig''\n',figureTitle,figureTitle);

%% SAVE TO DISK AS CSV AND FIG FILES
printConditions=true;
saveSpreadsheet=true;
vars={'thresholdParameter'  'observer' 'eccentricityXYDeg' 'flankingDirection' ...
    'experiment' 'experimenter' 'trials' 'contrast'  ...
    'targetDeg' 'spacingDeg' 'durationSec' ...
    'viewingDistanceCm'  ...
     'dataFilename'};
t=struct2table(oo,'AsArray',true);
t=sortrows(t,{'thresholdParameter' 'observer' 'eccentricityXYDeg' });
dataFilename=[experiment '.csv'];
if saveSpreadsheet
    spreadsheet=fullfile(fileparts(mfilename('fullpath')),'data',dataFilename);
    writetable(t,spreadsheet);
    fprintf('Spreadsheet saved as: /data/%s\n',dataFilename);
end
if printConditions
    disp(t(:,vars));
end
