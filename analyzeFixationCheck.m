%
% analyzeFixationCheck.m
%

function [] = analyzeFixationCheck()
%% This function is used to analyze the 'fixation check' data 

    % Read raw data
    oo = ReadData();
    % Pre-process data
    dataTable = Preprocess(oo);
    % load('/Users/ziyizhang/Downloads/dataTable.mat');  % Debug use, save time
    % Assess data quality
    DataQualityAssessment(dataTable);
    
    % Prepare variables used by fixation check and spacing ratio analysis
    [X, N, R, T, observerName] = ModelData(dataTable);

    % Fit Empirical Bayesian Model
    [alpha, beta] = EmpiricalBayesianModel(X, N);
    % Posterior interpreter functions
    PLargerThan = @(p, i) 1-cdf('Beta', p, alpha(i), beta(i));
    % Record model indicator
    fixationIndicator = zeros(length(observerName), 1);
    for i = 1:length(observerName)
        fixationIndicator(i) = PLargerThan(0.85, i);
    end
    % As requested, also calculate fixation check percent
    fixationPercent = CalcFixationPercent(X, N);

    % Record spacing ratio indicator
    [sratioIndicator, sratioZScore] = CalcSratioIndicator(R, T);

    % Print analysis result
    PrintSummary(observerName, fixationPercent, fixationIndicator, sratioIndicator, sratioZScore);

    % Debug mode
    % Store some auxiliary variables
    if true

        fixationTable = dataTable(dataTable.conditionName == 'fixation check', :);
        crowdingTable = dataTable(dataTable.conditionName == 'crowding', :);
    end
end


function [oo] = ReadData()
%% Call function 'ReadExperimentData' to read all records as 'struct'

    experiment='CrowdingSurvey';
    myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
    addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
    dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
    cd(dataFolder);
    close all

    % READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
    vars={'experiment' 'condition' 'conditionName' 'dataFilename' ... % 'experiment'
        'experimenter' 'observer' 'localHostName' 'trialsDesired' 'thresholdParameter' ...
        'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'...
        'viewingDistanceCm' 'durationSec'  ...
        'contrast' 'pixPerCm' 'nearPointXYPix' 'beginningTime'...
        'block' 'blocksDesired' 'brightnessSetting' 'trialData' 'targetFont' 'script' 'task'};
    oo = ReadExperimentData(experiment, vars);
    fprintf('Raw data contains %4.0f conditions for experiment ''%s''\n', length(oo), experiment);
end


function [dataTable] = Preprocess(oo)
%% Preprocess data and return a table structure of cleaned data

    dataTable = struct2table(oo, 'AsArray', true);

    % Field "conditionName" should only contain 'fixation check' or 'crowding'
    % dont care 'acuity' or 'reading'
    % convert to catogorical for comparison purpose
    dataTable.conditionName = categorical(dataTable.conditionName);
    mask = (dataTable.conditionName == 'fixation check') ...
         | (dataTable.conditionName == 'crowding');
    dataTable = dataTable(mask, :);

    % Clear rows with "experimenter" field as 'junk'
    dataTable.experimenter = categorical(dataTable.experimenter);
    mask = dataTable.experimenter == 'junk';
    dataTable = dataTable(~mask, :);

    % Convert more fields to catogorical for further manipulation
    dataTable.observer = categorical(dataTable.observer);
    dataTable.thresholdParameter = categorical(dataTable.thresholdParameter);

    % Clear rows with empty "trialData" field
    emptyCells = cellfun(@isempty, dataTable.trialData);
    dataTable(emptyCells, :) = [];

    % Link mating conditions and their corresponding 'fixation check' row
    % initialize new columns to zero to avoid empty check
    dataTable.mate = zeros(height(dataTable), 1);
    dataTable.jumpTable = zeros(height(dataTable), 1);
    % 'mate' indicates the row number of the mating condition, 0 if not found
    % 'jumpTable' indicates the row number of 'fixation check' row for 
    % corresponding 'crowding' rows, and vice versa
    for i = 1:height(dataTable)
        for j = [i-2, i-1, i+1, i+2]

            if (j < 1) || (j > height(dataTable)) 
                continue;
            end
            % update 'jumpTable' when i-th is 'fixation check'
            % update 'mate' when i-th is 'crowding'
            switch dataTable{i, 'conditionName'}
                case 'fixation check'
                    if (dataTable{j, 'conditionName'} == "crowding"...
                     && dataTable{i, 'observer'} == dataTable{j, 'observer'}...
                     && dataTable{i, 'thresholdParameter'} == dataTable{j, 'thresholdParameter'}...
                     && dataTable{i, 'block'} == dataTable{j, 'block'})

                        dataTable{i, 'jumpTable'} = j;
                        dataTable{j, 'jumpTable'} = i;
                    end
                case 'crowding'
                    if (dataTable{j, 'conditionName'} == "crowding"...
                     && isequal(dataTable{i, 'eccentricityXYDeg'}, -dataTable{j, 'eccentricityXYDeg'})...
                     && dataTable{i, 'observer'} == dataTable{j, 'observer'}...
                     && dataTable{i, 'thresholdParameter'} == dataTable{j, 'thresholdParameter'}...
                     && dataTable{i, 'block'} == dataTable{j, 'block'})

                        dataTable{i, 'mate'} = j;
                        dataTable{j, 'mate'} = i;
                    end
            end
        end
        if (mod(i, 100) == 0)
            % report progress in command window
            TextProgressBar('Linking mate and jumpTable', i/height(dataTable));
        end
    end
    TextProgressBar('Linking mate and jumpTable', 0, true);

    % Check this in run time
    % Clear rows whose "conditionName" are 'fixation check' but do not have
    % "jumpTable", that is, not linked with any 'crowding' data
    % mask = (dataTable.conditionName == 'fixation check')...
    %     & (dataTable.jumpTable == 0);
    % dataTable = dataTable(~mask, :);

    % Computing P
    dataTable.P = zeros(height(dataTable), 1);
    for i = 1:height(dataTable)

        dataTable{i, 'P'} = mean([dataTable{i, 'trialData'}{1}.targetScores]);
        if (mod(i, 100) == 0)
            % report progress in command window
            TextProgressBar('Computing P', i/height(dataTable));
        end
    end
    TextProgressBar('Computing P', 0, true);

    % Computing ratio of mating conditions
    dataTable.spacingRatio = zeros(height(dataTable), 1);
    for i = 1:height(dataTable)

        if (dataTable{i, 'conditionName'} == "crowding" && dataTable{i, 'mate'} > 0)

            dataTable{i, 'spacingRatio'} = dataTable{i, 'spacingDeg'} / dataTable{dataTable{i, 'mate'}, 'spacingDeg'};
        end
        if (mod(i, 100) == 0)
            % report progress in command window
            TextProgressBar('Computing ratio of mating conditions', i/height(dataTable));
        end
    end
    TextProgressBar('Computing ratio of mating conditions', 0, true);
end


function [] = DataQualityAssessment(dataTable)
%% Assess data quality and give warning
% 'inconsistency check' and 'fixation passing rate check':
% (1) 'Fixation check' may contradict with 'spacing ratio'. 'Inconcsistency
% check' detects blocks with high 'fixation check' P value with unbalanced 
% spacing ratio or low 'fixation check' P value with well-balanced spacing 
% ratio.
% (2) 'Learning check' plots figures to see whether observers are getting
% better in fixating. 
% (3) 'Fixation passing rate check' detects low passing rate in blocks with
% 'fixation check'. [NOT IMPLEMENTED]

    % Detect inconsistency
    inconsistencyIndex = [];
    fixationP_upper = 0.95;
    fixationP_lower = 0.8;
    spacingRatio_upper = 3.5;
    spacingRatio_lower = 1. / spacingRatio_upper;
    for i = 1:height(dataTable)

        if (dataTable{i, 'conditionName'} ~= "fixation check")
            continue;
        end
        if (dataTable{i, 'jumpTable'} == 0)
            % there exist blocks with only 'fixation check' and no 'crowding'
            continue;
        end

        abnormal = (dataTable{i, 'P'} > fixationP_upper && dataTable{dataTable{i, 'jumpTable'}, 'spacingRatio'} < spacingRatio_lower)...
                || (dataTable{i, 'P'} > fixationP_upper && dataTable{dataTable{i, 'jumpTable'}, 'spacingRatio'} > spacingRatio_upper)...
                || (dataTable{i, 'P'} < fixationP_lower && dataTable{dataTable{i, 'jumpTable'}, 'spacingRatio'} < spacingRatio_upper ...
                && dataTable{dataTable{i, 'jumpTable'}, 'spacingRatio'} > spacingRatio_lower);

        if abnormal

            jumpIndex = dataTable{i, 'jumpTable'};
            otherIndex = dataTable{jumpIndex, 'mate'};
            inconsistencyIndex = [inconsistencyIndex; i; jumpIndex; otherIndex];
        end
    end
    inconsistencyTable = dataTable(inconsistencyIndex, :);
    if ~isempty(inconsistencyTable)
        warning('Fixation check trials contradict with crowding trials in at least %d blocks.\n', height(inconsistencyTable)/3);
    end
    
    % Learning
    plotLearning = true;
    if plotLearning

        f1 = figure('Name', 'Learning (block)');
        f1(1) = subplot(1, 2, 1);
        title('Fixation check accuracy vs. block number for each observer');
        f1(2) = subplot(1, 2, 2);
        title('Mean fixation check accuracy vs. block number');
        set(f1, 'Nextplot', 'add');
        set(f1, 'XMinorGrid', 'on')
        set(f1, 'YMinorGrid', 'on')
        fixationTable = dataTable(dataTable.conditionName == 'fixation check', :);
        fixationTable = fixationTable(fixationTable.jumpTable > 0, :);  % Junk data
        % Per observer (block)
        observerName = unique(fixationTable.observer);
        for i = 1:length(observerName)

            focusTable = fixationTable(fixationTable.observer == observerName(i), :);
            focusTable = sortrows(focusTable, 'block');
            blockArray = [focusTable.block];
            PArray = [focusTable.P];
            if (length(blockArray) ~= length(unique(blockArray)))
                warning('Duplicate experiments for the same observer.\n');
            end
            if (nnz(PArray < 0.5) > 0)
                % does not make sense to have P < 0.5
                continue;
            end
            plot(f1(1), blockArray, PArray, 'o-');
        end
        % Mean across block
        blockIndexArray = unique(fixationTable.block);
        avgAcrossBlockArray = zeros(length(blockIndexArray), 1);
        for i = 1:length(blockIndexArray)
            avgAcrossBlockArray(i) = mean([fixationTable{fixationTable.block == blockIndexArray(i), 'P'}]);
            text(f1(2), blockIndexArray(i)+0.15, avgAcrossBlockArray(i), sprintf('%d', length([fixationTable{fixationTable.block == blockIndexArray(i), 'P'}])));
        end
        plot(f1(2), blockIndexArray, avgAcrossBlockArray, 'o-');
        % Per block (trial)
        f2 = figure('Name', 'Learning (trials)');
        colNumber = 10;
        rowNumber = ceil(height(fixationTable) / colNumber);
        colCount = 1;
        rowCount = 1;
        windowLength = 12;
        for i = 1:height(fixationTable)
            
            movingMeanArray = movmean([fixationTable{i, 'trialData'}{1}.targetScores], [0, windowLength]);
            if (length(movingMeanArray) < windowLength)
                continue;
            end
            % cut the tail
            movingMeanArray = movingMeanArray(1:length(movingMeanArray)-windowLength);
            if (length(movingMeanArray) > 50)
                % does not make sense to have too amy fixation check trials in a block
                movingMeanArray = [];
            end
            f2(i) = subplot(rowNumber, colNumber, i);
            plot(f2(i), 1:length(movingMeanArray), movingMeanArray, '-');
            title(char(fixationTable{i, 'observer'}));
            colCount = colCount + 1;
            if (colCount > colNumber)
                rowCount = rowCount + 1;
                colCount = 1;
            end
        end
        set(f2, 'XMinorGrid', 'on')
        set(f2, 'YMinorGrid', 'on')
        ylim(f2, [0.5, 1.2]);
        text(0, -1.5, 'Moving average of fixation check accuracy for each block')
    end
end


function [X, N, R, T, observerName] = ModelData(dataTable)
%% Organize the data to the format used by analysis
% m is the number of distinguish observers.
% X is a cell array of size m. X(i, j) represents observer i correctly
% responded the fixation check trials X(i, j) times in the j-th block.
% N is a cell array of size m. N(i, j) represents the total number of 
% fixation check trials for i-th observer in j-th block.
% R is a cell array of size m. R(i, j) represents the spacing ratio of i-th
% observer in j-th block.
% T is an array consisted of all spacing ratio larger than 1.

    observerName = unique(dataTable.observer);
    X = cell(length(observerName), 1);
    N = cell(length(observerName), 1);
    R = cell(length(observerName), 1);
    spacingRatioArray = [];
    for i = 1:length(observerName)

        mask = dataTable.observer == observerName(i);
        focusTable = dataTable(mask, :);
        countF = 0;  % count block number for fixation check
        countR = 0;  % count block number for spacing ratio
        XArray = [];
        NArray = [];
        RArray = [];
        for j = 1:height(focusTable)

            if (focusTable{j, 'conditionName'} == "fixation check"...
             && focusTable{j, 'jumpTable'} > 0)
                
                countF = countF + 1;
                XArray = [XArray, nnz([focusTable{j, 'trialData'}{1}.targetScores])];
                NArray = [NArray, length([focusTable{j, 'trialData'}{1}.targetScores])];
            end
            
            if (focusTable{j, 'conditionName'} == "crowding"...
             && focusTable{j, 'spacingRatio'} > 1)

                countR = countR + 1;
                RArray = [RArray, focusTable{j, 'spacingRatio'}];
                spacingRatioArray = [spacingRatioArray, focusTable{j, 'spacingRatio'}];
            end
        end
        X{i, 1} = XArray;
        N{i, 1} = NArray;
        R{i, 1} = RArray;
    end
    T = spacingRatioArray;
end


function [alpha, beta] = EmpiricalBayesianModel(X, N)
%% Calculate model parameters
% alpha is an array of size m*1, representing the alpha for i-th observer.
% beta is an array of size m*1, representing the beta for i-th observer.
% Using the method of moments (MoM), the empirical bayesian model
% parameters should be:
%                pbar(1-pbar)
% alpha = pbar ( ------------  - 1)
%                   s_p^2
%                     pbar(1-pbar)
% beta = (1 - pbar) ( ------------  - 1)
%                        s_p^2
    
    alpha = zeros(length(X), 1);
    beta = zeros(length(X), 1);

    for i = 1:length(X)
    
        if isempty(N{i})
            % beta distribution requires alpha and beta both positive
            % so zero means no data
            continue;
        end
        XArray = X{i};
        NArray = N{i};
        PArray = XArray ./ NArray;
        pbar = mean(PArray);
        sp2 = std(PArray)^2;
        alpha(i) = pbar * (pbar*(1-pbar)/sp2 - 1);
        beta(i) = (1-pbar) * (pbar*(1-pbar)/sp2 - 1);
    end
end


function [fixationPercent] = CalcFixationPercent(X, N)
%% Calculate fixation check percent for each observer

    fixationPercent = NaN(length(X), 1);
    for i = 1:length(X)

        XArray = X{i};
        NArray = N{i};
        if ~isempty(XArray)
            fixationPercent(i) = sum(XArray) / sum(NArray);
        end
    end
end


function [sratioIndicator, sratioZScore] = CalcSratioIndicator(R, T)
%% Calculate how extreme this observer's spacing ratio is

    Tmean = mean(T);
    Tsd = std(T);
    sigmf_ = @(x, a, c) 1 / (1+exp(-a*(x-c)));
    sratioIndicator = NaN(length(R), 1);
    RbarArray = zeros(length(R), 1);
    for i = 1:length(R)
        
        if isempty(R{i})
            continue;
        end
        RArray = R{i};
        Rbar = mean(RArray);
        RbarArray(i) = Rbar;
        sratioIndicator(i) = 1 - abs(0.5 - sigmf_(Rbar, Tsd, Tmean)) * 2;
    end
    sratioZScore = zscore(RbarArray);
end


function [] = PrintSummary(observerName, fixationPercent, fixationIndicator,...
                           sratioIndicator, sratioZScore)
%% Print the summary

    fprintf('''---'' stands for ''No Data''\n');
    fprintf('''acc'' stands for fixation check accuracy, ''z'' stands for z-score.\n')
    fprintf('Other indicators please see code comments.\n');
    fprintf('       Observer Name            Fixation       Spacing Ratio\n');
    fprintf('=========================== ================   ================\n');
    for i = 1:length(observerName)

        if isnan(fixationPercent(i))
            fstrAcc = " --- ";
        else
            fstrAcc = sprintf('%5.2f', fixationPercent(i));
        end
        if isnan(fixationIndicator(i))
            fstr = " --- ";
        else
            fstr = sprintf('%5.3f', fixationIndicator(i));
        end
        sstrZ = sprintf('%4.2f', sratioZScore(i));
        if isnan(sratioIndicator(i))
            sstr = " --- ";
        else
            sstr = sprintf('%5.3f', sratioIndicator(i));
        end

        fprintf('%26s   acc=%s %s    z=%s  %s\n', observerName(i), fstrAcc, fstr, sstrZ, sstr);
    end
    fprintf('=========================== ================   ================\n');
end


function [] = TextProgressBar(str, percent, reset)
%% Implements progress bar in command window

    persistent len

    if isempty(len)
        len = 0;
    end
    if (nargin > 2 && reset == true)
        reverseStr = repmat(sprintf('\b'), 1, len);
        msg = sprintf('%s progress 100', str);
        len = 0;
        fprintf([reverseStr, msg, '%%', '\n']);
        return;
    end

    reverseStr = repmat(sprintf('\b'), 1, len);
    msg = sprintf('%s progress %4.1f', str, percent * 100.0);
    fprintf([reverseStr, msg, '%%']);
    len = length(msg) + 1;  % plus percentage sign
end

% End of analyzeFixationCheck.m
