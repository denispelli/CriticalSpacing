%% Analyze the data collected by runCrowdingSurvey3. May 2019
% Ignore data whose thresholds suggest poor fixation.

% All on one plot.
% different symbols for Sloan vs Pelli
% different colors for observers
% dash vs solid line for acuity vs crowding


experiment='CrowdingFonts';
% xScale='logRadialEccentricity';
xScale='radialEccentricity';

printFilenames=false;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
if isempty(mfilename)
    dataFolder='~/MATLAB/CriticalSpacing/data/';
else
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
end
cd(dataFolder);
close all

%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'experiment' 'condition' 'conditionName' 'dataFilename' ... % 'experiment'
    'experimenter' 'observer' 'localHostName' 'trialsDesired' 'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'targetSizeIsHeight' 'targetHeightOverWidth'...
    'relationOfSpacingToSize' 'spacingDeg' 'flankingDirection'...
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm' 'nearPointXYPix' 'beginningTime'...
    'block' 'blocksDesired' 'brightnessSetting' 'trialData' 'targetFont' 'script' 'task'...
    'responseCount'};
oo1=ReadExperimentData(experiment,vars);
fprintf('%4.0f thresholds in experiment %s\n',length(oo1),experiment);
% oo2=ReadExperimentData('CrowdingSurvey2',vars);
% fprintf('%4.0f thresholds in experiment %s\n',length(oo2),'CrowdingSurvey2');
% oo=[oo1 oo2];
oo=oo1;
fprintf('%4.0f thresholds all together\n',length(oo));

%% CLEAN
nanCounter=0;
for oi=1:length(oo)
    oo(oi).P=mean([oo(oi).trialData.targetScores]);
    switch oo(oi).thresholdParameter
        case 'size'
            oo(oi).spacingDeg=nan;
            oo(oi).flankingDirection='none';
        case 'spacing'
            oo(oi).targetDeg=nan;
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
        warning('Found point %d at (%.1f %.1f) with no mate at -eccentricityXYDeg.',...
            oi,oo(oi).eccentricityXYDeg(1),oo(oi).eccentricityXYDeg(2));
        list=oi;
    else
        list=[oi mate];
        oo(oi).mate=mate;
        oo(mate).mate=oi;
    end
    if ismember(oo(oi).observer,{'Delisia Cuebas'})
        if ismember(oo(oi).thresholdParameter,{'spacing'})
            % Foveal crowding collected with wrong font.
            if all(oo(oi).eccentricityXYDeg==[0 0])
                oo(oi).spacingDeg=nan;
                fprintf('Setting to nan, %s crowding at (%.0f %.0f) deg with %s font.\n',...
                    oo(oi).observer,oo(oi).eccentricityXYDeg,oo(oi).targetFont);
            end
            % Crowding at (0 5) with Pelli performed badly.
            if all(abs(oo(oi).eccentricityXYDeg)==[5 0]) && ismember(oo(oi).targetFont,{'Pelli'})
                oo(oi).spacingDeg=nan;
                fprintf('Setting to nan, %s crowding at (%.0f %.0f) deg with %s font.\n',...
                    oo(oi).observer,oo(oi).eccentricityXYDeg,oo(oi).targetFont);
            end
        end
    end
    oo(oi).radialDeg=norm(oo(oi).eccentricityXYDeg);
    oo(oi).P=mean([oo(oi).trialData.targetScores]);
end

% Exclusion criteria. In many conditions every threshold has a mate,
% because we measured each eccentricity with the opposite eccentricity,
% interleaved. When we exclude a threshold we also exclude its mate, if it
% has one. We exclude any point with proportion correct less that 0.55
% (about 20% of data), and we exclude any pair of points (point and its
% mate) for which the absolute log ratio exceeds 0.2. 10^0.2=1.6.
bad=false(size(oo));
for oi=1:length(oo)
    bad(oi)=bad(oi) || oo(oi).P<0.55;
    if ~isempty(oo(oi).spacingDeg) && ~isempty(oo(oi).mate) && ~isempty(oo(oo(oi).mate).spacingDeg)
        % If has mate, then ratio must not be extreme.
        badPair=abs(log10(oo(oi).spacingDeg/oo(oo(oi).mate).spacingDeg))>0.2;
        % If either is bad, then mark mate bad too.
        bad(oi)=bad(oi)|bad(oo(oi).mate)|badPair;
        bad(oo(oi).mate)=bad(oo(oi).mate)|bad(oi);
    end
end
for oi=find(bad)
    if ~isempty(oo(oi).spacingDeg) && ~isempty(oo(oi).mate) && ~isempty(oo(oo(oi).mate).spacingDeg)
        logRatio=abs(log10(oo(oi).spacingDeg/oo(oo(oi).mate).spacingDeg));
    else
        logRatio=[];
    end
    fprintf('%d: P %.2f, log ratio %.1f, setting to nan, %s %s at %c(%.0f %.0f) deg with %s font.\n',...
        oi,oo(oi).P,logRatio,...
        oo(oi).observer,oo(oi).thresholdParameter,...
        char(177),oo(oi).eccentricityXYDeg,oo(oi).targetFont);
end
nanCounter=0;
for oi=find(bad)
    nanCounter=nanCounter+1;
    oo(oi).spacingDeg=nan;
    oo(oi).targetDeg=nan;
end
fprintf('<strong>Replaced %d of %d data points (%.0f%%) by nan.</strong>\n',nanCounter,length(oo),100*nanCounter/length(oo));

%% DISCARD FOVEAL DATA WITH o.viewingDistanceCm<100
bad=false([1 length(oo)]);
for oi=1:length(oo)
    bad(oi)=norm(oo(oi).eccentricityXYDeg)==0 && oo(oi).viewingDistanceCm<100;
end
oo=oo(~bad);

%% ASSEMBLE DATA INTO "aa".
% Compute mean and se of repeat measures.
observers=unique({oo.observer});
fonts=unique({oo.targetFont});
parameters=unique({oo.thresholdParameter});
durations=unique({oo.thresholdParameter});
for oi=1:length(oo)
    oo(oi).eccX=oo(oi).eccentricityXYDeg(1);
end
eccXs=unique([oo.eccX]);
radialDegs=unique([oo.radialDeg]);
conditionNames=unique({oo.conditionName});
aa=struct([]);
for iConditionName=1:length(conditionNames)
    for iObserver=1:length(observers)
        for iFont=1:length(fonts)
            for iParameter=1:length(parameters)
                % for iEccX=1:length(eccXs)
                for iRadialDeg=1:length(radialDegs)
                    oii=ismember({oo.conditionName},conditionNames{iConditionName}) & ...
                        ismember({oo.observer},observers(iObserver)) & ...
                        ismember({oo.targetFont},fonts{iFont}) & ...
                        ismember({oo.thresholdParameter},parameters{iParameter}) & ...
                        ismember([oo.radialDeg],radialDegs(iRadialDeg));
                    %ismember([oo.eccX],eccXs(iEccX));
                    if ~any(oii)
                        continue
                    end
                    aa(end+1).n=sum(oii);
                    aa(end).spacingDeg=[oo(oii).spacingDeg];
                    aa(end).meanSpacingDeg=mean(aa(end).spacingDeg);
                    aa(end).seSpacingDeg=std(aa(end).spacingDeg)/sqrt(length(aa(end).spacingDeg));
                    width=[];
                    for i=1:sum(oii)
                        ii=find(oii);
                        oi=ii(i);
                        if oo(oi).targetSizeIsHeight
                            width(i)=oo(oi).targetDeg/oo(oi).targetHeightOverWidth;
                        else
                            width(i)=oo(oi).targetDeg;
                        end
                    end
                    aa(end).targetDeg=width;
                    aa(end).meanTargetDeg=mean(aa(end).targetDeg);
                    aa(end).seTargetDeg=std(aa(end).targetDeg)/sqrt(length(aa(end).targetDeg));
                    aa(end).targetSizeIsHeight=unique([oo(oi).targetSizeIsHeight]);
                    aa(end).targetHeightOverWidth=unique([oo(oii).targetHeightOverWidth]);
                    aa(end).targetFont=fonts{iFont};
                    aa(end).observer=observers{iObserver};
                    aa(end).conditionName=conditionNames{iConditionName};
                    aa(end).thresholdParameter=parameters{iParameter};
                    aa(end).radialDeg=radialDegs(iRadialDeg);
                    %aa(end).eccX=eccXs(iEccX);
                end
            end
        end
    end
end

%% PLOT aa, Size and spacing vs. radial eccentricity.
cyan        = [0.2 0.8 0.8];
brown       = [0.2 0 0];
orange      = [1 0.5 0];
blue        = [0 0.5 1];
green       = [0 0.6 0.3];
red         = [1 0.2 0.2];
colors={[0.5 0.5 0.5] green red brown blue cyan orange };
markers={'^' 's' 'o'   'd' '>' '<' 'x' };
styles={'-' '--'};
width=500;
figureHandle=figure('Name',experiment,...
    'NumberTitle','off','pos',[10 10 width 900]);

figure(1)
for iObserver=1:length(observers)
    for iParameter=1:length(parameters)
        for iFont=1:length(fonts)
            ii=ismember({aa.observer},observers{iObserver}) & ...
                ismember({aa.targetFont},fonts{iFont}) & ...
                ismember({aa.thresholdParameter},parameters(iParameter)) &...
                ismember({aa.conditionName},{'crowding' 'acuity'});
            if ~any(ii)
                continue
            end
            color=colors{iObserver};
            faceColor=color;
            i=find(ii,1);
            switch aa(i).targetFont
                case 'Sloan'
                   assert(all(round([aa(ii).targetHeightOverWidth])==1));
                case 'Pelli'
                   assert(all(round([aa(ii).targetHeightOverWidth])==5));
                otherwise
                    error('Unknown font ''%s''.',aa(i).targetFont);
            end
            switch parameters{iParameter}
                case 'spacing'
                    faceColor=[1 1 1];
                    y=[aa(ii).meanSpacingDeg];
                    se=[aa(ii).seSpacingDeg];
                case 'size'
                    y=[aa(ii).meanTargetDeg];
                    se=[aa(ii).seTargetDeg];
                otherwise
                    error('Unknown thresholdParameter ''%s''.',parameters{iParameter});
            end
            x=sort([aa.radialDeg]);
            xRange=x([1 end]);
            x=[aa(ii).radialDeg];
            [x,ix]=sort(x);
            y=y(ix);
            i=find(ii,1);
            marker=markers{iFont};
            style=styles{iParameter};
            iOffset=(iObserver-1)*2+(iFont-1);
            switch xScale
                case 'radialEccentricity'
                    dx=diff(xRange)/80;
                    xShifted=x+iOffset*dx;
                    h=semilogy(xShifted,y,style);
                case 'logRadialEccentricity'
                    dlogx=diff(log10(xRange+0.015))/80;
                    xShifted=(x+0.015)*10^(iOffset*dlogx);
                    h=loglog(xShifted,y,style);
                otherwise
                    error('Unknown xScale ''%s''.',xScale);
            end
            h.Color=color;
            h.Marker=marker;
            h.MarkerSize=10;
            h.MarkerFaceColor=faceColor;
            h.MarkerEdgeColor=color;
            h.LineWidth=1.5;
            legendText=sprintf('%s, %s, %s, %.0f',aa(i).observer,...
                aa(i).thresholdParameter,...
                aa(i).targetFont,...
                mean([aa(ii).n]));
            h.DisplayName=legendText;
            fprintf('%s\n',legendText);
            fprintf('x:');
            fprintf(' %4.0f',x);
            fprintf('\n');
            fprintf('y:');
            fprintf(' %4.2f',y);
            fprintf('\n');
            fprintf('se:');
            fprintf(' %4.2f',se);
            fprintf('\n\n');
            hold on
            for i=1:length(x)
                % Error bars, +/- SE
                % e=errorbar(x,y,se,'Color',color,'LineWidth',3);
                switch xScale
                    case 'radialEccentricity'
                        e=semilogy([xShifted(i) xShifted(i)],y(i)+[-1 1]*se(i),'-','Color',color,'LineWidth',3);
                    case 'logRadialEccentricity'
                        e=loglog([xShifted(i) xShifted(i)],y(i)+[-1 1]*se(i),'-','Color',color,'LineWidth',3);
                end
                e.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
        end
    end
end
set(gca,'FontSize',14); % Axis numbers
title([upper(experiment(1)) experiment(2:end)],'FontSize',14)
switch xScale
    case 'radialEccentricity'
        xlabel('Radial eccentricity (deg)','FontSize',18);
    case 'logRadialEccentricity'
        xlabel('Radial eccentricity+0.015 (deg)','FontSize',18);
end
ylabel('Spacing or width (deg)','FontSize',18);
ax=gca;
ax.TickLength=[0.01 0.025]*2;
% ax.XLim=[0.5 32];
lgd=legend('Location','northwest','Box','off');
title(lgd,' observer, threshold, font, reps','FontSize',10);
lgd.FontName='Monaco';
lgd.FontSize=8;
annotation('textbox',[0.35, 0.1, 0.6, 0.1],'String', ...
    ["Crowding distance = empty symbols and dashed line", ...
    "Acuity = filled symbols and solid line",...
    "Pelli font = triangle",...
    "Sloan font = square",...
    "Observer indicated by color.",...
    "Observers and fonts shifted horizontally to avoid overlap."],...
    'HorizontalAlignment','left',...
    'VerticalAlignment','bottom',...
    'LineStyle','none');
% Make room for the legend.
ax=gca;
ax.YLim(2)=ax.YLim(2)*3;

%% SAVE PLOT TO DISK
figureTitle='Size and Spacing Thresholds';
graphFile=fullfile(dataFolder,[figureTitle '.eps']);
saveas(gcf,graphFile,'epsc')
fprintf('Figure saved as ''/data/%s.eps''\n',figureTitle);

%% SAVE DATA TO DISK AS CSV FILE
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
    spreadsheet=fullfile(dataFolder,dataFilename);
    writetable(t,spreadsheet);
    fprintf('Spreadsheet saved as: /data/%s\n',dataFilename);
end
