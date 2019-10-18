%% Analyze the data collected by runCrowdingSurvey. October 2019
% Assess quality of data collected with new fixation check.
% Project leaders Alexander, Benji, and Ziyi.
% experiment='CrowdingSurvey3';
experiment='CrowdingSurvey';
printFilenames=false;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
cd(dataFolder);
close all

%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'experiment' 'condition' 'conditionName' 'dataFilename' ... % 'experiment'
    'experimenter' 'observer' 'localHostName' 'trialsDesired' 'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'...
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm' 'nearPointXYPix' 'beginningTime'...
    'block' 'blocksDesired' 'brightnessSetting' 'trialData' 'targetFont' 'script' 'task'};
oo1=ReadExperimentData(experiment,vars);
fprintf('%4.0f conditions for experiment %s\n',length(oo1),experiment);
% oo2=ReadExperimentData('CrowdingSurvey2',vars);
% fprintf('%4.0f thresholds in experiment %s\n',length(oo2),'CrowdingSurvey2');
% oo=[oo1 oo2];
oo=oo1;
fprintf('%4.0f conditions all together\n',length(oo));

% Link mating conditions.
% In many conditions every threshold has a mate,
% because we measured each eccentricity with the opposite eccentricity,
% interleaved.
for oi=1:length(oo)
    oo(oi).radialDeg=norm(oo(oi).eccentricityXYDeg);
    if isempty(oo(oi).trialData)
        continue
    end
    switch oo(oi).thresholdParameter
        case 'size'
            oo(oi).spacingDeg=nan;
            oo(oi).flankingDirection='none';
        case 'spacing'
            %             oo(oi).targetDeg=nan;
            oo(oi).spacingDegMaxTested=max([oo(oi).trialData.spacingDeg]);
    end
    mate=[];
    for ii=[oi-1 oi+1]
        if ii<1 || ii>length(oo)
            continue
        end
        if all(oo(oi).eccentricityXYDeg==-oo(ii).eccentricityXYDeg) && ...
                streq(oo(oi).thresholdParameter,oo(ii).thresholdParameter) &&...
                streq(oo(oi).targetFont,oo(ii).targetFont) &&...
                streq(oo(oi).observer,oo(ii).observer)
            mate=ii;
            break
        end
    end
    if isempty(mate)
        %         if oo(oi).radialDeg>0
        %             warning('Block %d. Condition %s. Point %d at (%.1f %.1f) has no mate at -eccentricityXYDeg.',...
        %                 oo(oi).block,oo(oi).conditionName,oi,oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2));
        %             oo(oi)
        %         end
    else
        oo(oi).mate=mate;
        oo(mate).mate=oi;
    end
end

% Compute P.
for oi=1:length(oo)
    if isempty(oo(oi).trialData)
        oo(oi).P=[];
    else
        oo(oi).P=mean([oo(oi).trialData.targetScores]);
    end
end

% Computing ratio of mating conditions.
for oi=1:length(oo)
    if ~isempty(oo(oi).spacingDeg) && ~isempty(oo(oi).mate) && ~isempty(oo(oo(oi).mate).spacingDeg)
        oo(oi).spacingRatio=oo(oi).spacingDeg/oo(oo(oi).mate).spacingDeg;
    end
end

%% REPORT spacingRatio of crowding vs P of 'fixation check' for each block.
b=struct('block',1:oo(end).block);
b(1).fixationP=[];
b(1).P=[];
for oi=1:length(oo)
    block=oo(oi).block;
    if isempty(block)
        continue
    end
    switch oo(oi).conditionName
        case 'fixation check'
            b(block).fixationP=oo(oi).P;
        case 'crowding'
            b(block).P=oo(oi).P;
            b(block).spacingRatio=oo(oi).spacingRatio;
        otherwise
            b(block).P=[];
            b(block).spacingRatio=[];
    end
end
b=b(~isempty([b.fixationP]) & ~isempty([b.spacingRatio]));
t=struct2table(b);
t
plot(b.fixationP,abs(log10(b.spacingRatio)));
return

%% SELECT CONDITION(S)
if isempty(oo)
    error('No conditions selected.');
end

% Report the relevant fields of each file.
t=struct2table(oo,'AsArray',true);
t=sortrows(t,{'observer' 'thresholdParameter' 'radialDeg' 'spacingRatio' 'P'});
if printFilenames
    fprintf('Ready to analyze %d thresholds:\n',length(oo));
    switch experiment
        case {'CrowdingSurvey3'}
            disp(t(:,{'experiment' 'observer' 'localHostName' 'experimenter'...
                'thresholdParameter' 'eccentricityXYDeg' ...
                'flankingDirection' 'spacingDeg' 'targetDeg' ...
                'spacingDegMaxTested' 'P' 'targetFont' ...
                'dataFilename' ...
                }));
        case {'CrowdingSurvey'}
            disp(t(:,{'experiment' 'observer' 'localHostName' 'experimenter'...
                'thresholdParameter' 'eccentricityXYDeg' ...
                'flankingDirection' 'spacingDeg' 'targetDeg' ...
                'spacingDegMaxTested' 'spacingRatio' 'P' 'targetFont' ...
                'dataFilename' ...
                }));
    end
end
t=sortrows(t,{'thresholdParameter' 'observer' 'radialDeg'});
filename=sprintf('%sData.xls',oo(1).experiment);
fprintf('<strong>Writing data to ''%s''.\n</strong>',filename);
writetable(t,fullfile(dataFolder,filename));
% return

%% SUMMARIZE WHAT WE HAVE FOR EACH OBSERVER
observers=unique({oo.observer});
s=[];
for si=1:length(observers)
    s(si).observer=observers{si};
    tt=t(ismember(t.observer,{observers{si}}),:);
    s(si).conditions=height(tt);
    s(si).experimenter=unique(table2cell(tt(:,'experimenter')));
    s(si).experiment=unique(table2cell(tt(:,'experiment')));
    s(si).localHostName=unique(table2cell(tt(:,'localHostName')));
    s(si).numberOfComputers=length(s(si).localHostName);
    params={'size' 'spacing'};
    for j=1:length(params)
        ttt=tt(ismember(tt.thresholdParameter,{params{j}}),:);
        ecc=table2array(ttt(:,'radialDeg'))';
        s(si).([params{j} 'EccDeg'])=sprintf('%g ',ecc);
        if height(ttt)>0
            s(si).localHostName=table2array(ttt(1,'localHostName'));
        else
            s(si).localHostName='';
        end
    end
    s(si).beginningTime=min(table2array(tt(:,'beginningTime')));
    s(si).date=datestr(datevec(s(si).beginningTime));
end
sTable=struct2table(s);
sTable=sortrows(sTable,{'beginningTime'});
sTable.beginningTime=[];
fprintf('\n<strong>%.0f rows. One row per observer, sorted by date:</strong>\n',height(sTable));
disp(sTable(:,{'date' 'conditions' 'observer' 'localHostName' ...
    'experimenter' 'experiment'...
    'spacingEccDeg' 'sizeEccDeg'}));

%% Compute each observer's mean and SD of deviation from log normal.
% Struct s with fields: observer, meanReLogNormal, sdReLogNorm.
% Assume we are given a huge oo struct, and each row has one threshold, and
% each row can be any observer.

s=[]; % s(si) is an array struct, indexed across observers.
observers=unique({oo.observer});
for si=1:length(observers)
    s(si).observer=observers{si};
    ok=ismember({oo.observer},observers{si}); % list of conditions for this observer.
    oo1=oo(ok); % All conditions for one observer.
    s(si).conditions=length(oo1);
    for oi=1:length(oo1) % Iterate over all conditions for this observer.
        s(si).eccentricityXYDeg(1:2,oi)=oo1(oi).eccentricityXYDeg;
        s(si).radialDeg(oi)=norm(oo1(oi).eccentricityXYDeg);
        s(si).beginningTime=oo1(1).beginningTime;
        s(si).localHostName=oo1(1).localHostName;
        s(si).experimenter=oo1(1).experimenter;
        s(si).experiment=oo1(1).experiment;
        s(si).date=datestr(datevec(s(si).beginningTime));
        s(si).targetFont{oi}=oo1(oi).targetFont;
        s(si).script{oi}=oo1(oi).script;
        s(si).task{oi}=oo1(oi).task;
        s(si).thresholdParameter{oi}=oo1(oi).thresholdParameter;
        switch oo1(oi).thresholdParameter
            case 'size'
                s(si).sizeDeg(oi)=oo1(oi).targetDeg;
                s(si).spacingDeg(oi)=nan;
                s(si).sizeReNominal(oi)=oo1(oi).targetDeg/NominalAcuityDeg(oo1(oi).eccentricityXYDeg);
                s(si).spacingReNominal(oi)=nan;
            case 'spacing'
                s(si).sizeDeg(oi)=nan;
                s(si).spacingDeg(oi)=oo1(oi).spacingDeg;
                s(si).sizeReNominal(oi)=nan;
                s(si).spacingReNominal(oi)=...
                    oo1(oi).spacingDeg/NominalCrowdingDistanceDeg(oo1(oi).eccentricityXYDeg);
        end
    end
    ok=isfinite(s(si).eccentricityXYDeg(1,:));
    s(si).meanLogSizeReNominal=mean(log10(s(si).sizeReNominal(ok)),'omitnan');
    s(si).SDLogSizeReNominal=std(log10(s(si).sizeReNominal(ok)),'omitnan');
    ok=s(si).eccentricityXYDeg(1,:)~=0;
    s(si).meanLogPeripheralSpacingReNominal=mean(log10(s(si).spacingReNominal(ok)),'omitnan');
    s(si).SDLogPeripheralSpacingReNominal=std(log10(s(si).spacingReNominal(ok)),'omitnan');
    sortX=-10;
    ii=find(s(si).eccentricityXYDeg(1,:)==sortX);
    if isempty(ii)
        s(si).sort=nan;
    else
        ii=ii(1);
        s(si).sort=s(si).meanLogPeripheralSpacingReNominal;
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
% return

% Plot crowding function for each observer.
figureTitle=sprintf('%d-crowding-functions',length(s));
r=Screen('Rect',0);
r(3)=r(3)/2;
r=r*0.8;
figure('Position',r,'DefaultAxesFontSize',6,'DefaultFigurePaperPositionMode','auto')
h=gcf;
h.Name=figureTitle;
% h.PaperOrientation='landscape';
h.Units='inches';
h.PaperPosition=[0.25 .25 8 10.5];
ratio=r(3)/r(4);
m=ceil(sqrt(length(s)/ratio));
n=ceil(length(s)/m);
p=[];
% si indexs through the observers.
for si=1:length(s)
    subplot(m,n,si);
    [~,jj]=sort(s(si).radialDeg);
    ecc=s(si).radialDeg(jj);
    eccXY=s(si).eccentricityXYDeg(:,jj);
    spacing=s(si).spacingDeg(jj);
    pelli=ismember(s(si).targetFont(jj),{'Pelli'});
    color={'r' 'b'};
    name={'vertical' 'horizontal'};
    for k=1:length(color)
        hv=eccXY(k,:)==0 & isfinite(spacing);
        if sum(hv)==0
            continue
        end
        ec=ecc(hv);
        sp=spacing(hv);
        hold on
        clear medsp
        for j=1:length(ec)
            medsp(j)=median(sp(ec==ec(j)));
        end
        p(k)=plot(ec,medsp,[color{k} '-'],'DisplayName',name{k});
        plot(ecc(hv & ~pelli),spacing(hv & ~pelli),[color{k} 'x']);
        if any(hv & pelli)
            pe=plot(ecc(hv & pelli),spacing(hv & pelli),'gx');
        end
        hold off
    end
    title(s(si).observer)
    xlabel('Ecc (deg)');
    ylabel('Spacing (deg)');
    %     legend(p);
    %     legend('boxoff');
    %     legend('Location','northwest');
    ylim([0 4]);
    xlim([0 10]);
end
set(findall(gcf,'-property','FontSize'),'FontSize',7);
annotation('textbox','String','x',...
    'Position',[0.75 .9 .1 .1],'Color','green',...
    'LineStyle','none','FontSize',10);
annotation('textbox','String','   indicates Pelli font',...
    'Position',[0.75 .9 .1 .1],...
    'LineStyle','none','FontSize',10);
annotation('textbox','String','--',...
    'Position',[.1 0.88 .1 .1],'Color','blue',...
    'LineStyle','none','FontSize',10);
annotation('textbox','String','   horizontal',...
    'Position',[.1 0.88 .1 .1],...
    'LineStyle','none','FontSize',10);
annotation('textbox','String','--',...
    'Position',[.1 0.9 .1 .1],'Color','red',...
    'LineStyle','none','FontSize',10);
annotation('textbox','String','   vertical',...
    'Position',[.1 0.9 .1 .1],...
    'LineStyle','none','FontSize',10);

figureTitle=sprintf('%d-crowding-functions',length(s));
graphFile=fullfile(fileparts(mfilename('fullpath')),'data',[figureTitle '.pdf']);
saveas(gcf,graphFile,'pdf')
return

figure
count=0;
for si=1:length(s)
    s(si).quantile=si/length(s);
    s(si).color=[1 0 0]*s(si).quantile+[0 1 0]*(1-s(si).quantile);
    if s(si).SDLogPeripheralSpacingReNominal>0.26
        %         continue
    end
    if s(si).meanLogPeripheralSpacingReNominal>-1 && s(si).meanLogPeripheralSpacingReNominal<0.2
        % Plot only the extremes of crowding distance.
        %         continue
    end
    
    % Spacing
    ok=ismember({oo.observer},s(si).observer); % list of conditions for this observer.
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
    semilogy(x,y,'-o','Color',s(si).color);
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
    ok=ismember({oo.observer},s(si).observer); % list of conditions for this observer.
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
        semilogy(x,y,'-o','Color',s(si).color);
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
ti=1; % row index
while ~isempty(t)
    if ti>1
        tmean(ti,:)=tmean(1,:); % Add a row.
    end
    tmean(ti,t.Properties.VariableNames)=t(1,:);
    tmean(:,{'spacingDeg' 'targetDeg'})=[];
    match=ismember(t{:,'observer'},t{1,'observer'}) ...
        & ismember(t.eccentricityXYDeg(:,1),t(1,:).eccentricityXYDeg(:,1)) ...
        & ismember(t.flankingDirection,t(1,:).flankingDirection);
    tmean(ti,'n')={sum(match)};
    if sum(match)==0
        error('No match.');
    end
    v=log10(t{match,'spacingDeg'});
    v=vector(isfinite(v));
    tmean(ti,'logSpacingDegMean')={mean(v)};
    tmean(ti,'logSpacingDegSD')={std(v)};
    tmean(ti,'logSpacingDegN')={length(v)};
    v=log10(t{match,'targetDeg'});
    v=vector(isfinite(v));
    tmean(ti,'logAcuityDegMean')={mean(v)};
    tmean(ti,'logAcuityDegSD')={std(v)};
    tmean(ti,'logAcuityDegN')={length(v)};
    t(match,:)=[];
    ti=ti+1;
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
                x=x(isfinite(x)); % Remove nans.
                m=mean(x);
                sd=std(x);
                se=mean(t(ok,:).logAcuityDegSD./sqrt(t(ok,:).logAcuityDegN))/sqrt(length(x));
                name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
            case 2
                ok=streq(t.thresholdParameter,'spacing') & ...
                    (streq(t.flankingDirection,'radial') | streq(t.flankingDirection,'horizontal'));
                x=t{ok,'logSpacingDegMean'};
                name='log Radial or Horizontal crowding distance (deg)';
                x=x(isfinite(x)); % Remove nans.
                m=mean(x);
                sd=std(x);
                se=mean(t(ok,:).logSpacingDegSD./sqrt(t(ok,:).logSpacingDegN))/sqrt(length(x));
                name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
            case 3
                ok=streq(t.thresholdParameter,'spacing') & streq(t.flankingDirection,'tangential');
                x=t{ok,'logSpacingDegMean'};
                name='log Tangential crowding distance (deg)';
                x=x(isfinite(x)); % Remove nans.
                m=mean(x);
                sd=std(x);
                okPositive=ok & t.logSpacingDegSD>0;
                se=mean(t(okPositive,:).logSpacingDegSD ./ sqrt(t(okPositive,:).logSpacingDegN))/sqrt(length(x));
                name=sprintf('%s, mean %.1f%c%.1f, Retest SE %.2f',name,m,plusMinus,sd,se);
        end
        if sum(ok)==0
            continue
        end
        ti=find(ok);
        parameter=name;
        subplot(3,1,type)
        histogram(x,'BinWidth',0.1);
        ylabel('Count');
        xlabel(parameter);
        title(sprintf('Histogram of %d hemispheres at (%c%.0f,%.0f) deg',length(x),plusMinus,abs(t{ti(1),'eccentricityXYDeg'})));
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
