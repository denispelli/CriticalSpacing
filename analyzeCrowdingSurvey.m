%% Analyze the data collected by runCrowdingSurvey. April 2019

experiment='CrowdingSurvey'; % And CrowdingSurvey2.
printFilenames=false;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% dataFolder='/Users/denispelli/Dropbox/MATLAB/CriticalSpacing/data/';
cd(dataFolder);
close all

%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'experiment' 'condition' 'conditionName' 'dataFilename' ... 
    'experimenter' 'observer' 'localHostName' ...
    'trialsDesired' 'responseCount' ...
    'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'...
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm' 'nearPointXYPix' 'beginningTime' 'block' 'blocksDesired' ...
    'task' 'readWordPerMin' 'readFilename' ...
    'readNumberOfResponses' 'readNumberCorrect' 'targetFont'...
    'simulateObserver' 'simulatedLogThreshold' ...
    };
oo=ReadExperimentData(experiment,vars); 
fprintf('%4.0f conditions in experiment %s\n',length(oo),experiment);

%% CLEAN
ok=logical([]);
for oi=1:length(oo)
    switch oo(oi).task
        case 'identify'
            switch oo(oi).thresholdParameter
                case 'size'
                    oo(oi).spacingDeg=nan;
                    oo(oi).flankingDirection='none';
                case 'spacing'
                    oo(oi).targetDeg=nan;
            end
        case 'read'
    end
    oo(oi).xDeg=oo(oi).eccentricityXYDeg(1);
    oo(oi).experiment=experiment;
    % USE ONLY 2019 DATA
    timeVector=datevec(oo(oi).beginningTime);
    ok(oi)= timeVector(1)>2018;
end
oo=oo(ok);

%% SELECT CONDITION(S)
if isempty(oo)
    error('No conditions selected.');
end

% Report the relevant fields of each file.
t=struct2table(oo,'AsArray',true);
t=sortrows(t,{'task' 'observer' 'thresholdParameter'  'xDeg' });
% t(:,{'dataFilename' 'targetDeg' 'trialsDesired' 'eccentricityXYDeg' 'observer' 'beginningTime'})
% return
if printFilenames
    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    switch experiment
        case {'CrowdingSurvey' 'CrowdingSurvey2'}
            disp(t(:,{'experiment' 'observer' 'localHostName' 'experimenter'...
                'task' 'readWordPerMin' 'thresholdParameter' 'eccentricityXYDeg' ...
                'flankingDirection' 'spacingDeg' 'targetDeg' ...
                'dataFilename'...
                'trialsDesired' 'responseCount' ...
                'readFilename' ...
                'readNumberOfResponses' 'readNumberCorrect' 'targetFont'}));
    end
end
t=sortrows(t,{'task' 'experimenter' 'thresholdParameter' 'observer' 'xDeg'});
fprintf('<strong>Writing data to ''%sData.xls''.\n</strong>',oo(1).experiment);
writetable(t,fullfile(dataFolder,'crowdingSurveyData.xls'));
% return

%% SUMMARIZE WHAT WE HAVE FOR EACH OBSERVER
observers=unique({oo.observer});
s=[];
for i=1:length(observers)
    s(i).observer=observers{i};
    tt=t(ismember(t.observer,{observers{i}}),:);
    s(i).conditions=height(tt);
    s(i).experimenter=unique(table2cell(tt(:,'experimenter')));
    s(i).experimenter=s(i).experimenter{1};
    s(i).experiment=unique(table2cell(tt(:,'experiment')));
    s(i).localHostName=unique(table2cell(tt(:,'localHostName')));
    s(i).numberOfComputers=length(s(i).localHostName);
    s(i).task=unique(table2cell(tt(:,'task')));
    s(i).task=s(i).task{1};
    params={'size' 'spacing'};
    for j=1:length(params)
        ttt=tt(ismember(tt.thresholdParameter,{params{j}}),:);
        ecc=table2array(ttt(:,'xDeg'))';
        s(i).([params{j} 'EccXDeg'])=sprintf('%g ',ecc);
        if height(ttt)>0
            s(i).localHostName=table2array(ttt(1,'localHostName'));
        else
            s(i).localHostName='';
        end
    end
    s(i).beginningTime=min(table2array(tt(:,'beginningTime')));
    s(i).date=datestr(datevec(s(i).beginningTime));
   readWordPerMin=table2array(tt(:,'readWordPerMin'));
   readWordPerMin=[readWordPerMin{:}];
   s(i).readWordPerMinMean=mean(readWordPerMin,'omitnan');
   s(i).readWordPerMinSD=std(readWordPerMin,'omitnan');
end
sTable=struct2table(s);
sTable=sortrows(sTable,{'experimenter' 'observer'});
sTable.beginningTime=[];
fprintf('\n<strong>%.0f rows. One row per observer, sorted by experimenter:</strong>\n',height(sTable));
disp(sTable(:,{'date' 'conditions' 'observer' 'localHostName' ...
    'experimenter' 'experiment' 'task'...
    'spacingEccXDeg' 'sizeEccXDeg' 'readWordPerMinMean' 'readWordPerMinSD'}));

%% Compute each observer's mean and SD of deviation from log normal.
% Struct s with fields: observer, meanReLogNormal, sdReLogNorm.
% Assume we are given a huge oo struct, and each row has one threshold, and
% each row can be any observer.

s=[]; % s(i) is an array struct, indexed across observers.
observers=unique({oo.observer});
for i=1:length(observers)
    s(i).observer=observers{i};
    ok=ismember({oo.observer},observers{i}); % list of conditions for this observer.
    oo1=oo(ok); % All conditions for one observer.
    s(i).conditions=length(oo1);
    for oi=1:length(oo1) % Iterate over all conditions for this observer.
        s(i).eccentricityXYDeg(1:2,oi)=oo1(oi).eccentricityXYDeg;
        s(i).beginningTime=oo1(1).beginningTime;
        s(i).localHostName=oo1(1).localHostName;
        s(i).experimenter=oo1(1).experimenter;
        s(i).experiment=oo1(1).experiment;
        s(i).date=datestr(datevec(s(i).beginningTime));
        switch oo1(oi).thresholdParameter
            case 'size'
                s(i).sizeDeg(oi)=oo1(oi).targetDeg;
                s(i).spacingDeg(oi)=nan;
                s(i).sizeReNominal(oi)=oo1(oi).targetDeg/NominalAcuityDeg(oo1(oi).eccentricityXYDeg);
                s(i).spacingReNominal(oi)=nan;
            case 'spacing'
                s(i).sizeDeg(oi)=nan;
                s(i).spacingDeg(oi)=oo1(oi).spacingDeg;
                s(i).sizeReNominal(oi)=nan;
                s(i).spacingReNominal(oi)=...
                    oo1(oi).spacingDeg/NominalCrowdingDistanceDeg(oo1(oi).eccentricityXYDeg);
        end
%        s(i).readWordPerMin=oo1(oi).readWordPerMin;
    end
    ok=isfinite(s(i).eccentricityXYDeg(1,:));
    s(i).meanLogSizeReNominal=mean(log10(s(i).sizeReNominal(ok)),'omitnan');
    s(i).SDLogSizeReNominal=std(log10(s(i).sizeReNominal(ok)),'omitnan');
    ok=s(i).eccentricityXYDeg(1,:)~=0;
    s(i).meanLogPeripheralSpacingReNominal=mean(log10(s(i).spacingReNominal(ok)),'omitnan');
    s(i).SDLogPeripheralSpacingReNominal=std(log10(s(i).spacingReNominal(ok)),'omitnan');
    sortX=-10;
    ii=find(s(i).eccentricityXYDeg(1,:)==sortX);
    if isempty(ii)
        s(i).sort=nan;
    else
        ii=ii(1);
        s(i).sort=s(i).meanLogPeripheralSpacingReNominal;
    end
end
t=struct2table(s);
t=sortrows(t,'sort');
s=table2struct(t);
if 1
    fprintf('\n<strong>%.0f observers, sorted by MeanLogPeripheralSpacing.\n</strong>',...
        height(t));
    disp(t);
    tableTitle='List of observers, sorted by peripheral crowding';
    tableFile=fullfile(fileparts(mfilename('fullpath')),'data',[tableTitle '.csv']);
    writetable(t(:,{'observer' 'conditions' 'date' 'beginningTime' 'localHostName' ...
        'experimenter' 'experiment' 'meanLogPeripheralSpacingReNominal' ...
        'SDLogPeripheralSpacingReNominal'}),tableFile);
end
if 1
    fprintf('\n<strong>%.0f observers, sorted by name.\n</strong>',...
        height(t));
    t.observerLower=lower(t.observer);
    t=sortrows(t,{'observerLower'});
    disp(t(:,{'observer' 'conditions' 'localHostName' 'date' 'experimenter'}));
    tableTitle='List of observers, alphabetical';
    tableFile=fullfile(fileparts(mfilename('fullpath')),'data',[tableTitle '.csv']);
    writetable(t(:,{'observer' 'conditions' 'localHostName' 'date' 'beginningTime' ...
        'experimenter' }),tableFile);
end
return
figure
count=0;
for i=1:length(s)
    s(i).quantile=i/length(s);
    s(i).color=[1 0 0]*s(i).quantile+[0 1 0]*(1-s(i).quantile);
    if s(i).SDLogPeripheralSpacingReNominal>0.26
        %         continue
    end
    if s(i).meanLogPeripheralSpacingReNominal>-1 && s(i).meanLogPeripheralSpacingReNominal<0.2
        % Plot only the extremes of crowding distance.
        %         continue
    end
    
    % Spacing
    ok=ismember({oo.observer},s(i).observer); % list of conditions for this observer.
    ok=ok & ismember({oo.thresholdParameter},'spacing');
    oo1=oo(ok); % All conditions for this observer and measure.
    clear x y y2
    for oi=1:length(oo1)
        %         x(oi)=abs(oo1(oi).eccentricityXYDeg(1));
        x(oi)=oo1(oi).eccentricityXYDeg(1);
        y(oi)=oo1(oi).spacingDeg / NominalCrowdingDistanceDeg(oo1(oi).eccentricityXYDeg);
        y2(oi)=oo1(oi).targetDeg / NominalAcuityDeg(oo1(oi).eccentricityXYDeg);
    end
    [~,ii]=sort(x);
    x=x(ii);
    y=y(ii);
    y2=y2(ii);
    subplot(2,1,1)
    semilogy(x,y,'-o','Color',s(i).color);
    hold on
    ylabel('Crowding dist re nominal');
    xlabel('X eccentrity (deg)');
    title('Crowding vs eccentricity');
    text(-9.8,.015,'Nominal crowding distance = 0.3*(ecc+0.15)');
    coloringMessage=sprintf('Color indicates quantile of crowding distance at (%d,0) deg.',...
        sortX);
    text(-9.8,60,coloringMessage);
    ax=gca;
    ax.FontSize=12;
    count=count+1;
    
    % Acuity
    ok=ismember({oo.observer},s(i).observer); % list of conditions for this observer.
    ok=ok & ismember({oo.thresholdParameter},'size');
    oo1=oo(ok); % All conditions for this observer and measure.
    if ~isempty(oo1)
        clear x y
        for oi=1:length(oo1)
            %         x(oi)=abs(oo1(oi).eccentricityXYDeg(1));
            x(oi)=oo1(oi).eccentricityXYDeg(1);
            y(oi)=oo1(oi).targetDeg / NominalAcuityDeg(oo1(oi).eccentricityXYDeg);
        end
        [~,ii]=sort(x);
        x=x(ii);
        y=y(ii);
        subplot(2,1,2)
        semilogy(x,y,'-o','Color',s(i).color);
        hold on
        xlim([-10 10]);
        ylim([.001 10]);
        ylabel('Acuity re nominal');
        xlabel('X eccentrity (deg)');
        title('Acuity vs eccentricity');
        text(-9.8,.015/10,'Nominal acuity = 0.029*(ecc+2.72)');
        text(-9.8,6,coloringMessage);
        ax=gca;
        ax.FontSize=12;
    end
end
subplot(2,1,1)
text(8.5,.015,sprintf('N = %d',count));
subplot(2,1,2)
text(8.5,.015/10,sprintf('N = %d',count));
% SAVE PLOT TO DISK
figureTitle='Crowding & acuity vs eccentricity';
% graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.eps']);
% saveas(gcf,graphFile,'epsc')
fprintf('<strong>Writing ''%s.pdf'' to disk.</strong>\n',figureTitle);
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.pdf']);
saveas(gcf,graphFile,'pdf')
return

%% COMPUTE MEAN FOR EACH OBSERVER FOR EACH MEASURE
% Replace repeated measures by their mean.
% The new table has the mean of each observer, at each location and
% flankingDirection.
% t=sortrows(t,{'eccentricityXYDeg','thresholdParameter','observer'});
tmean=table();
t(:,'n')={1}; % Number of thresholds represented by each row.
i=1; % row index
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

if false % SKIP HISTOGRAMS
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
        'experiment' 'experimenter' 'trialsDesired' 'contrast'  ...
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
end
