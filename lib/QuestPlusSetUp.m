function oo=QuestPlusSetUp(oo)
% oo=QuestPlusSetUp(oo);
% Set parameters for QUESTPlus.
% To avoid distortion, o.questPlusLogIntensitiest should include the
% stimulus intensities actually used. The fitting makes continuous
% estimates of parameters, but I believe it can only consider stimuli that
% are on its domain list.
for oi=1:length(oo)
    if oo(oi).questPlusEnable
        oo(oi).targetKind='letter';
        oo(oi).targetDurationSecs=oo(oi).durationSec;
        oo(oi).LBackground=500;
        oo(oi).eyes=2;
        oo(oi).trials=oo(oi).trialsDesired; % CHANGE TO NUMBER DONE.
        steepnesses=oo(oi).questPlusSteepnesses;
        guessingRates=oo(oi).questPlusGuessingRates;
        lapseRates=oo(oi).questPlusLapseRates;
        contrastDB=20*oo(oi).questPlusLogIntensities;
        switch oo(oi).thresholdParameter
            case 'flankerContrast'
                psychometricFunction=@qpPFCrowding;
            otherwise
                psychometricFunction=@qpPFWeibull;
        end
        oo(oi).questPlusData=qpParams('stimParamsDomainList', ...
            {contrastDB},'psiParamsDomainList',...
            {contrastDB, steepnesses, guessingRates, lapseRates},...
            'qpPF',psychometricFunction);
        oo(oi).questPlusData=qpInitialize(oo(oi).questPlusData);
    end
    switch oo(oi).thresholdParameter
        case 'contrast'
            oo(oi).contrastPolarity=sign(oo(oi).contrast);
        case 'flankerContrast'
            oo(oi).contrastPolarity=sign(oo(oi).flankerContrast);
        case 'spacing'
            oo(oi).contrastPolarity=1;
    end
end

 