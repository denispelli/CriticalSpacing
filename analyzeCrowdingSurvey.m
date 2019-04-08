%% Analyze the data collected by runCrowdingSurvey. April 2019

experiment='CrowdingSurvey';
printFilenames=true;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% dataFolder='/Users/denispelli/Dropbox/MATLAB/CriticalSpacing/data/';
cd(dataFolder);
close all

%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'dataFilename' ... % 'experiment' 
    'experimenter' 'observer' 'localHostName' 'trials' 'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'... 
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm' 'nearPointXYPix' 'beginningTime' 'block' 'blocksDesired' };
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.

%% CLEAN
ok=logical([]);
for oi=1:length(oo)
    switch oo(oi).thresholdParameter
        case 'size'
            oo(oi).spacingDeg=nan;
            oo(oi).flankingDirection='none';
        case 'spacing'
            oo(oi).targetDeg=nan;
    end
    oo(oi).xDeg=oo(oi).eccentricityXYDeg(1);
    oo(oi).experiment=experiment;
    timeVector=datevec(oo(oi).beginningTime);
    % FOR NOW, USE ONLY 2019 DATA
    ok(oi)= timeVector(1)>2018;
end
oo=oo(ok);

%% SELECT CONDITION(S)
if isempty(oo)
    error('No conditions selected.');
end

% Report the relevant fields of each file.
t=struct2table(oo,'AsArray',true);
% t=sortrows(t,{'beginningTime' });
t=sortrows(t,{'observer' 'thresholdParameter'  'xDeg' });
% t(:,{'dataFilename' 'targetDeg' 'trials' 'eccentricityXYDeg' 'observer' 'beginningTime'})
% return
if printFilenames
    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    switch experiment
        case 'CrowdingSurvey'
            disp(t(:,{'observer' 'localHostName' 'thresholdParameter' 'eccentricityXYDeg' ...
                'flankingDirection' 'spacingDeg' 'targetDeg' ...
                'dataFilename'  ...
                }));
    end
end
t=sortrows(t,{'thresholdParameter' 'observer'  'xDeg'});
fprintf('Writing data to ''crowdingSurveyData.xls''.\n');
writetable(t,fullfile(dataFolder,'crowdingSurveyData.xls'));
% return

%% SUMMARIZE WHAT WE HAVE
observers=unique({oo.observer});
s=[];
for i=1:length(observers)
    s(i).observer=observers{i};
    tt=t(ismember(t.observer,observers{i}),:);
    s(i).conditions=height(tt);
    s(i).localHostNames=unique(table2cell(tt(:,'localHostName')));
    s(i).numberOfComputers=length(s(i).localHostNames);
    params={'size' 'spacing'};
    for j=1:length(params)
        param=params{j};
        ttt=tt(ismember(tt.thresholdParameter,param),:);
        ecc=table2array(ttt(:,'xDeg'))';
        s(i).([param 'EccXDeg'])=sprintf('%g ',ecc);
        if height(ttt)>0
            s(i).localHostName=table2array(ttt(1,'localHostName'));
        else
            s(i).localHostName='';
        end
    end
    s(i).beginningTime=min(table2array(tt(:,'beginningTime')));
    s(i).date=datestr(datevec(s(i).beginningTime));
end
sTable=struct2table(s);
sTable=sortrows(sTable,{'date'  });
sTable.beginningTime=[];
sTable(:,{'date' 'observer' 'localHostName' 'conditions' 'spacingEccXDeg' 'sizeEccXDeg'})
% return

%% Compute each observer's mean and SD of deviation from log normal.
% Struct s with fields: observer, meanReLogNormal, sdReLogNorm.
% Assume we are given a huge oo struct, and each row has one threshold, and
% each row can be any observer.

s=[]; % s(i) is an array struct, indexed across observers.
observers=unique({oo.observer});
for i=1:length(observers)
    s(i).observer=observers{i};
    ok=ismember({oo.observer},observers{i}); % list of conditions for this observer.
    ok=ok & ~ismember([oo.xDeg],0);
    oo1=oo(ok); % All conditions for one observer.
    s(i).conditions=length(oo1);
    for oi=1:length(oo1) % Iterate over all conditions for this observer.
        s(i).eccentricityXYDeg(1:2,oi)=oo1(oi).eccentricityXYDeg;
        switch oo1(oi).thresholdParameter
            case 'size'
                s(i).sizeDeg(oi)=oo1(oi).targetDeg;
                s(i).spacingDeg(oi)=nan;
                s(i).sizeReNormal(oi)=oo1(oi).targetDeg/NominalAcuityDeg(oo1(oi).eccentricityXYDeg);
                s(i).spacingReNormal(oi)=nan;
            case 'spacing'
                s(i).sizeDeg(oi)=nan;
                s(i).spacingDeg(oi)=oo1(oi).spacingDeg;
                s(i).sizeReNormal(oi)=nan;
                s(i).spacingReNormal(oi)=...
                    oo1(oi).spacingDeg/NominalCrowdingDistanceDeg(oo1(oi).eccentricityXYDeg);
        end
    end
    s(i).meanLogSizeReNorm=mean(log10(s(i).sizeReNormal),'omitnan');
    s(i).SDLogSizeReNorm=std(log10(s(i).sizeReNormal),'omitnan');
    s(i).meanLogSpacingReNorm=mean(log10(s(i).spacingReNormal),'omitnan');
    s(i).SDLogSpacingReNorm=std(log10(s(i).spacingReNormal),'omitnan');
end
ts=struct2table(s);
ts=sortrows(ts,'meanLogSpacingReNorm');
ts
figure
count=0;
for i=1:length(observers)
    s(i).observer=observers{i};
    if s(i).SDLogSpacingReNorm>0.26
        continue
    end
    if s(i).meanLogSpacingReNorm>-1 && s(i).meanLogSpacingReNorm<0.2
        continue
    end
    ok=ismember({oo.observer},observers{i}); % list of conditions for this observer.
    okSpacing=ok & ismember({oo.thresholdParameter},'spacing');
    oo1=oo(okSpacing); % All conditions for this observer and measure.
    clear x y
    for oi=1:length(oo1)
        x(oi)=abs(oo1(oi).eccentricityXYDeg(1));
        y(oi)=oo1(oi).spacingDeg / NominalCrowdingDistanceDeg(oo1(oi).eccentricityXYDeg);
    end
    [~,ii]=sort(abs(x));
    x=x(ii);
    y=y(ii);
    semilogy(x,y,'-o');
    hold on
    ylabel('Crowding dist re norm');
    xlabel('X eccentrity (deg)');
    title('Crowding vs eccentricity');
    ax=gca;
    ax.FontSize=12;
    count=count+1;
end
text(9,50,sprintf('N = %d',count));
return
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

%% PLOT HISTOGRAMS (ACROSS OBSERVERS) OF SEVERAL KINDS OF THRESHOLD. AT ±10, ±5, ±2.5, 0 DEG.
figure;
graphWidth=25;
graphHeight=50;
set(0,'units','centimeters');
screenSize=get(groot,'Screensize');
set(gcf,'units','centimeters','position',...
    [screenSize(3)-graphWidth,0,graphWidth,graphHeight])
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
            ok=streq(t.thresholdParameter,'spacing') & ...
                (streq(t.flankingDirection,'radial') | streq(t.flankingDirection,'horizontal'));
            x=t{ok,'logSpacingDegMean'};
            name='log Radial or Horizontal crowding distance (deg)';
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
      
%           case 4
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
    xlabel(parameter);
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
return

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
vars={'thresholdParameter' 'observer' 'eccentricityXYDeg' 'flankingDirection' ...
    'experiment' 'experimenter' 'trials' 'contrast'  ...
    'targetDeg' 'spacingDeg' 'durationSec' ...
    'viewingDistanceCm' 'dataFilename'};
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

