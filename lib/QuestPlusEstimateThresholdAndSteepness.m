function oo=QuestPlusEstimateThresholdAndSteepness(oo)
% oo=QuestPlusEstimateThresholdAndSteepness(oo)
% QUESTPlus: Estimate steepness and threshold contrast.
onlyOneConditionPerFigure=true;
for oi=1:length(oo)
    if oo(oi).questPlusEnable && isfield(oo(oi).questPlusData,'trialData')
        steepnesses=oo(oi).questPlusSteepnesses;
        guessingRates=oo(oi).questPlusGuessingRates;
        lapseRates=oo(oi).questPlusLapseRates;
        contrastDB=20*oo(oi).questPlusLogIntensities;
        
        psiParamsIndex=qpListMaxArg(oo(oi).questPlusData.posterior);
        psiParamsBayesian=oo(oi).questPlusData.psiParamsDomain(psiParamsIndex,:);
        if oo(oi).questPlusPrint
            fprintf('%s, block %d, condition %d %s, trialsDesired %d.\n',...
                oo(oi).experiment,oo(oi).block,oo(oi).condition,oo(oi).conditionName,oo(oi).trialsDesired);
            fprintf('model:     log %s %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.3f\n', ...
                oo(oi).thresholdParameter,...
                oo(oi).simulatedLogThreshold,oo(oi).q.beta,oo(oi).q.gamma,oo(oi).q.delta);
        end
        psiParamsFit=qpFit(oo(oi).questPlusData.trialData,oo(oi).questPlusData.qpPF,psiParamsBayesian,oo(oi).questPlusData.nOutcomes,...,
            'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],...
            'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
        if oo(oi).questPlusPrint
            fprintf('QuestPlus: log %s %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.3f\n', ...
                oo(oi).thresholdParameter,...
                psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
        end
        oo(oi).qpThreshold=oo(oi).contrastPolarity*10^(psiParamsFit(1)/20);	% threshold
        switch oo(oi).thresholdParameter
            case 'contrast'
                oo(oi).contrast=oo(oi).qpThreshold;
            case 'flankerContrast'
                oo(oi).flankerContrast=oo(oi).qpThreshold;
            case 'spacing'
                oo(oi).spacing=oo(oi).qpThreshold;
        end
        oo(oi).qpSteepness=psiParamsFit(2);          % steepness
        oo(oi).qpGuessing=psiParamsFit(3);
        oo(oi).qpLapse=psiParamsFit(4);
        
        %% Plot trial data with maximum likelihood fit
        if oo(oi).questPlusPlot
            dotColor=.5;
            if onlyOneConditionPerFigure
                % New plot for each condition.
                figure('Name',[oo(oi).experiment ':' oo(oi).conditionName]); %,'NumberTitle','off');
                title(oo(oi).conditionName,'FontSize',14);
                hold on
            end
            stimCounts=qpCounts(qpData(oo(oi).questPlusData.trialData),oo(oi).questPlusData.nOutcomes);
            stim=[stimCounts.stim];
            stimFine=linspace(-60,20,100)'; % x range 0.001 to 100.
            plotProportionsFit=qpPFWeibull(stimFine,psiParamsFit);
            nTrials=zeros(size(stimCounts));
            pCorrect=zeros(size(stimCounts));
            for cc=1:length(stimCounts)
                nTrials(cc)=sum(stimCounts(cc).outcomeCounts);
                pCorrect(cc)=stimCounts(cc).outcomeCounts(2)/nTrials(cc);
            end
            if ~isfield(oo(oi),'noiseSD')
                oo(oi).noiseSD=0;
            end
            legendString=sprintf('%.2f %s',oo(oi).noiseSD,oo(oi).observer);
            semilogx(10.^(stimFine/20),plotProportionsFit(:,2),'-','Color',[0 0 0],'LineWidth',2,'DisplayName',legendString);
            if length(stim)~=length(pCorrect)
                error('Unequal lengths of stim (%d) and pCorrect (%d).',length(stim),length(pCorrect));
            end
            scatter(10.^(stim/20),pCorrect,100,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',...
                [0 0 0],'MarkerEdgeAlpha',dotColor,'MarkerFaceAlpha',dotColor,'DisplayName',legendString);
            set(gca,'xscale','log');
            % set(gca,'XTickLabel',{'0.01' '0.1' '1' '10' '100' '1000'});
            switch oo(oi).thresholdParameter
                case 'spacing'
                    xlabel('Spacing (deg)');
                case 'contrast'
                    xlabel('Contrast');
            end
            ylabel('Proportion correct');
            xlim([0.001 10]);
            ylim([0 1]);
            set(gca,'FontSize',12);
            if ~isfield(oo(oi),'targetGaborCycles')
                oo(oi).targetGaborCycles=nan;
            end
            if ~isfield(oo(oi),'targetHeightDeg') || isempty(oo(oi).targetHeightDeg) || ~isfinite(oo(oi).targetHeightDeg) || oo(oi).targetHeightDeg==0
                oo(oi).targetHeightDeg=oo(oi).targetDeg;
            end
            oo(oi).targetCyclesPerDeg=oo(oi).targetGaborCycles/oo(oi).targetHeightDeg;
            switch oo(oi).targetKind
                case 'gabor'
                    spec=sprintf('%.1f c/deg',oo(oi).targetCyclesPerDeg);
                case 'letter'
                    spec=sprintf('%.1f deg',oo(oi).targetHeightDeg);
                otherwise
                    error('Unknown targetKind.');
            end
            noteString={};
            noteString{1}=sprintf('%s',oo(oi).dataFilename);
            noteString{2}=sprintf('%s, block %.0f, condition %.0f, %s',oo(oi).experiment,oo(oi).block,oo(oi).condition);
            noteString{3}=sprintf('%s: %s %s, ecc [%.1f %.1f] deg, %.2f s\n%.0f cd/m^2, %s eye(s), %d trials',...
                oo(oi).conditionName,oo(oi).targetKind,spec,oo(oi).eccentricityXYDeg,oo(oi).targetDurationSecs,oo(oi).LBackground,oo(oi).eyes,oo(oi).trials);
            noteString{4}=sprintf('%8s   %7s %5s %9s %8s %5s','observer','noiseSD','log threshold','steepness','guessing','lapse');
            noteString{end+1}=sprintf('%10s %7.2f %13.2f %9.1f %8.2f %5.3f', ...
                oo(oi).observer,oo(oi).noiseSD,log10(oo(oi).qpThreshold),oo(oi).qpSteepness,oo(oi).qpGuessing,oo(oi).qpLapse);
            if oo(oi).simulateObserver
                noteString{end+1}=sprintf('%10s %7.2f %13.2f %9.1f %8.2f %5.3f', ...
                    'model',oo(oi).noiseSD,oo(oi).simulatedLogThreshold,oo(oi).q.beta,oo(oi).q.gamma,oo(oi).q.delta);
            end
            legend('show','Location','southeast');
            legend('boxoff');
            annotation('textbox',[0.14 0.7 .5 .2],'String',noteString,...
                'FitBoxToText','on','LineStyle','none',...
                'FontName','Monospaced','FontSize',9);
            drawnow;
            if onlyOneConditionPerFigure
                hold off
            end
            
            %% SAVE PLOT TO DISK
            figureTitle=sprintf('%s-psychometric-%d:%d-%s',...
                oo(oi).experiment,oo(oi).block,oo(oi).condition,...
                oo(oi).conditionName);
            mainFolder=fileparts(fileparts(mfilename('fullpath')));
            dataFolder=fullfile(mainFolder,'data');
            graphFile=fullfile(dataFolder,[figureTitle '.png']);
            saveas(gcf,graphFile,'png')
            fprintf('Figure saved as ''/data/%s.png''\n',figureTitle);
        end % if oo(oi).questPlusPlot
    end % if oo(oi).questPlusEnable
end