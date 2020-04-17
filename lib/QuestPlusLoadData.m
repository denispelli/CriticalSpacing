function oo=QuestPlusLoadData(oo)
% oo=QuestPlusLoadData(oo);
% Load our data into QuestPlus.
for oi=1:length(oo)
    if ~oo(oi).questPlusEnable
        warning('Condition %d: o.questPlusEnable must be true. Skipping to next.',oi);
        continue
    end
    if isfield(oo(oi),'data')
        % For NoiseDiscrimination.m
        for trial=1:size(oo(oi).data,1)
            for i=2:size(oo(oi).data,2)
                tTest=oo(oi).data(trial,1);
                isRight=oo(oi).data(trial,i);
                stim=20*tTest;
                outcome=isRight+1;
                oo(oi).questPlusData=qpUpdate(oo(oi).questPlusData,stim,outcome);
            end
        end
    elseif isfield(oo(oi),'q')
        % For CriticalSpacing.m
        t=QuestTrials(oo(oi).q);
        if length(t.intensity)~=size(t.responses,2)
            error(sprintf('Must have equal number of columns in t.intensity [%d %d] and t.responses [%d %d].',...
                size(t.intensity),size(t.responses)));
        end
        if false
            tTest=t.intensity;
        else
            % RESTRICT tTest TO LEGAL VALUE IN QUESTPLUS
            % Select the nearest available intensity on the fixed
            % contrastDB list used by QuestPlus.
            ii=knnsearch(oo(oi).questPlusLogIntensities',t.intensity');
            tTest=oo(oi).questPlusLogIntensities(ii);
        end
        if length(unique(tTest))<length(unique(t.intensity))
            warning('Limited range and resolution of QuestPlus domain reduced the number of unique %ss from %d to %d.',...
                oo(oi).thresholdParameter,length(unique(t.intensity)),length(unique(tTest)));
            warning('You can avoid this distortion of your data by including all tested intensities in o.questPlusLogIntensities.');
        end
        for i=1:length(tTest)
            for response=1:size(t.responses,1)
                for n=1:t.responses(response,i)
                    oo(oi).questPlusData=qpUpdate(oo(oi).questPlusData,20*tTest(i),response);
                end
            end
        end
    else
        error('Sorry can''t find your data.');
    end
end
