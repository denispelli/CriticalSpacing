function oo=QuestPlusEstimateThresholdAndSteepness(oo)
% oo=QuestPlusEstimateThresholdAndSteepness(oo)
% QUESTPlus: Estimate steepness and threshold contrast.
if oo(oi).questPlusEnable && isfield(oo(oi).questPlusData,'trialData')
    psiParamsIndex=qpListMaxArg(oo(oi).questPlusData.posterior);
    psiParamsBayesian=oo(oi).questPlusData.psiParamsDomain(psiParamsIndex,:);
    if oo(oi).questPlusPrint
        ffprintf(ff,'Quest: Max posterior est. of threshold: log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
            oo(oi).questMean,oo(oi).steepness,oo(oi).guess,oo(oi).lapse);
        %          ffprintf(ff,'QuestPlus: Max posterior estimate:      log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
        %             psiParamsBayesian(1)/20,psiParamsBayesian(2),psiParamsBayesian(3),psiParamsBayesian(4));
    end
    psiParamsFit=qpFit(oo(oi).questPlusData.trialData,oo(oi).questPlusData.qpPF,psiParamsBayesian,oo(oi).questPlusData.nOutcomes,...,
        'lowerBounds', [min(contrastDB) min(steepnesses) min(guessingRates) min(lapseRates)],...
        'upperBounds',[max(contrastDB) max(steepnesses) max(guessingRates) max(lapseRates)]);
    if oo(oi).questPlusPrint
        ffprintf(ff,'QuestPlus: Max likelihood estimate:     log c %0.2f, steepness %0.1f, guessing %0.2f, lapse %0.2f\n', ...
            psiParamsFit(1)/20,psiParamsFit(2),psiParamsFit(3),psiParamsFit(4));
    end
    oo(oi).qpThreshold=oo(oi).contrastPolarity*10^(psiParamsFit(1)/20);	% threshold contrast
    switch oo(oi).thresholdParameter
        case 'contrast'
            oo(oi).contrast=oo(oi).qpThreshold;
        case 'flankerContrast'
            oo(oi).flankerContrast=oo(oi).qpThreshold;
    end
    oo(oi).qpSteepness=psiParamsFit(2);          % steepness
    oo(oi).qpGuessing=psiParamsFit(3);
    oo(oi).qpLapse=psiParamsFit(4);
    
    %% Plot trial data with maximum likelihood fit
    if oo(oi).questPlusPlot
        figure('Name',[oo(oi).experiment ':' oo(oi).conditionName],'NumberTitle','off');
        title(oo(oi).conditionName,'FontSize',14);
        hold on
        stimCounts=qpCounts(qpData(oo(oi).questPlusData.trialData),oo(oi).questPlusData.nOutcomes);
        stim=[stimCounts.stim];
        stimFine=linspace(-40,0,100)';
        plotProportionsFit=qpPFWeibull(stimFine,psiParamsFit);
        for cc=1:length(stimCounts)
            nTrials(cc)=sum(stimCounts(cc).outcomeCounts);
            pCorrect(cc)=stimCounts(cc).outcomeCounts(2)/nTrials(cc);
        end
        legendString=sprintf('%.2f %s',oo(oi).noiseSD,oo(oi).observer);
        semilogx(10.^(stimFine/20),plotProportionsFit(:,2),'-','Color',[0 0 0],'LineWidth',3,'DisplayName',legendString);
        scatter(10.^(stim/20),pCorrect,100,'o','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',...
            [0 0 0],'MarkerEdgeAlpha',.1,'MarkerFaceAlpha',.1,'DisplayName',legendString);
        set(gca,'xscale','log');
        set(gca,'XTickLabel',{'0.01' '0.1' '1'});
        xlabel('Contrast');
        ylabel('Proportion correct');
        xlim([0.01 1]); ylim([0 1]);
        set(gca,'FontSize',12);
        oo(oi).targetCyclesPerDeg=oo(oi).targetGaborCycles/oo(oi).targetHeightDeg;
        noteString{1}=sprintf('%s: %s %.1f c/deg, ecc %.0f deg, %.1f s\n%.0f cd/m^2, eyes %s, trials %d',...
            oo(oi).conditionName,oo(oi).targetKind,oo(oi).targetCyclesPerDeg,oo(oi).eccentricityXYDeg(1),oo(oi).targetDurationSecs,oo(oi).LBackground,oo(oi).eyes,oo(oi).trials);
        noteString{2}=sprintf('%8s %7s %5s %9s %8s %5s','observer','noiseSD','log c','steepness','guessing','lapse');
        noteString{end+1}=sprintf('%-8s %7.2f %5.2f %9.1f %8.2f %5.2f', ...
            oo(oi).observer,oo(oi).noiseSD,log10(oo(oi).qpThreshold),oo(oi).qpSteepness,oo(oi).qpGuessing,oo(oi).qpLapse);
        text(0.4,0.4,'noiseSD observer');
        legend('show','Location','southeast');
        legend('boxoff');
        annotation('textbox',[0.14 0.11 .5 .2],'String',noteString,...
            'FitBoxToText','on','LineStyle','none',...
            'FontName','Monospaced','FontSize',9);
        drawnow;
        
        %% SAVE PLOT TO DISK
        figureTitle='Psychometric';
        graphFile=fullfile(oo(oi).dataFolder,[figureTitle '.png']);
        saveas(gcf,graphFile,'png')
        fprintf('Figure saved as ''/data/%s.png''\n',figureTitle);
    end % if oo(oi).questPlusPlot
end % if oo(oi).questPlusEnable