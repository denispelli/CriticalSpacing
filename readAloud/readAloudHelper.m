function [res] = readAloudHelper(operation, option)
% [data] = readAloudHelper('data');
% readAloudHelper('deleteLastDecisionFile');
% readAloudHelper('deleteLastObserverResponse');
% readAloudHelper('showWave' | 'showSpec' [, fileName]);
% readAloudHelper('play'[, fileName]);
% readAloudHelper('clearAllDecisions' | 'clearObserverData');
% This function is used to process, retrieve and manipulate the records under 
% 'readAloud' folder.
% Operation 'data' scans all observer response files and all grader
% decision files. The returned table contains a summary of every grader's
% decision and the graded response's information.
% Operation 'deleteLastDecisionFile' will delete the last grader's decision 
% file.
% Operation 'deleteLastObserverResponse' will find the last stored observer
% response file and delete it along with the corresponding self-rating log.
% Operation 'showWave' and 'showSpec' will display a waveform and spectrum figure. 
% If no 'fileName' is provided, a random observer response is chosen.
% Operation 'play' will play the audio of the specified file. If no 'fileName'
% is provided, a random observer response is chosen.
% Operation 'clearAllDecisions' will delete all grader's evaluation of
% observers' audio data.
% Operation 'clearObserverData' will delete all observer's audio data, and 
% self-rating logs.
% More options to be implemented.
% Written by Ziyi Zhang, December, 2019.


if nargin < 2
    option = [];
end
operation = lower(operation); % case insensitive
res = [];

% clearAllDecisions
if strcmp(operation, 'clearalldecisions')

    if ~confirmation(operation)
        return;
    end
    [res, msg, msgID] = movefile('Decision-*', [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        disp('At least one file was not successfully moved.');
        fprintf('Error Code %d: %s\n', msgID, msg);
    else
        disp('File(s) removed.');
    end

    return;
end

% clearObserverData
if strcmp(operation, 'clearobserverdata')

    if ~confirmation(operation)
        return;
    end
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    for i = 1:length(files)
    
        file = files{i};
        if isResponse(file) || (length(file)>4 && strcmp(file(end-3:end), '.log'))
            
            [res, msg, msgID] = movefile(file, [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
            if ~res
                fprintf('Operation failed with errCode %d when removing file %s: %s\n', msgID, file, msg);
            else
                fprintf('File removed: %s\n', file);
            end
        end
    end

    return;
end

% showWave / showSpec / play
if strcmp(operation, 'showwave') || strcmp(operation, 'showspec') || strcmp(operation, 'play')

    if ~isempty(option)
        % show specified waveform
        fileName = option;
        if ~isResponse(fileName)
            fileName = [fileName, '.mat']; % may be helpful
        end
        if strcmp(operation, 'showwave')
            showWave(fileName);
        elseif strcmp(operation, 'showspec')
            showSpec(fileName);
        elseif strcmp(operation, 'play')
            playAudio(fileName);
        end
    else
        % show a random waveform
        dinfo = dir(fileparts(mfilename('fullpath')));
        files = {dinfo.name};
        index = randperm(length(files));
        for i = 1:length(index)
            
            file = files{index(i)};
            if isResponse(file)
            
                disp(file);
                if strcmp(operation, 'showwave')
                    showWave(file);
                elseif strcmp(operation, 'showspec')
                    showSpec(file);
                elseif strcmp(operation, 'play')
                    playAudio(file);
                end
                break;
            end
        end
    end

    return;
end

% deleteLastDecisionFile
if strcmp(operation, 'deletelastdecisionfile')

    timeArray = sortFile('decision');
    if isempty(timeArray)
        fprintf('No decision file exists in this folder: %s\n', fileparts(mfilename('fullpath')));
        return;
    end
    fprintf('Last decision file is %s\n', timeArray(1, 2));
    % delete this file
    file = timeArray(1, 2);
    [res, msg, msgID] = movefile(file, [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Operation failed with errCode %d when removing file %s: %s\n', msgID, file, msg);
    else
        fprintf('File removed: %s\n', file);
    end

    res = [];
    return;
end

% deleteLastObserverResponse
if strcmp(operation, 'deletelastobserverresponse')

    timeArray = sortFile('response');
    if isempty(timeArray)
        fprintf('No observer response mat file exists in this folder: %s\n', fileparts(mfilename('fullpath')));
        return;
    end
    file = char(timeArray(1, 2));
    fprintf('Last observer''s response is %s\n', file);
    % delete this response mat
    [res, msg, msgID] = movefile(file, [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Operation failed with errCode %d when removing file %s: %s\n', msgID, file, msg);
    else
        fprintf('File removed: %s\n', file);
    end
    % delete this log file
    file = [file(1:end-4), '*.log'];
    [res, msg, msgID] = movefile(file, [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Operation failed with errCode %d when removing file %s: %s\n', msgID, file, msg);
    else
        fprintf('File removed: %s\n', file);
    end

    res = [];
    return;
end

% summary
if strcmp(operation, 'data')

    % 1. scan all observer responses
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    resFiles = cell(0, 1);
    logFiles = cell(0, 2);
    decFiles = cell(0, 1);
    for i = 1:length(files)
        
        fileName = files{i};
        if length(fileName) < 10
            continue; % skip short file name
        end
        if isResponse(fileName)
            resFiles{length(resFiles)+1, 1} = fileName(1:end-4);
        elseif strcmp(fileName(end-3:end), '.log')
            count = size(logFiles, 1);
            logFiles{count+1, 1} = fileName(1:end-6);
            logFiles{count+1, 2} = str2double(fileName(end-4));
        elseif strcmp(fileName(1:9), 'Decision-')
            decFiles{length(decFiles)+1, 1} = fileName;
        end
    end
    observerTable = false(length(resFiles), 3); % res mat, log, completeBit
    for i = 1:length(resFiles) % use res mat file as principle identifier
        
        observerTable(i, 1) = true;
        observerTable(i, 2) = nnz(strcmp(logFiles, resFiles{i}));
        observerTable(i, 3) = observerTable(i, 1) & observerTable(i, 2);
    end
    if nnz(~observerTable(:, 3)) % discrepency in observer response
        
        warning('The following observer responses are not complete. Observer''s self rating result is missing.');
        for i = 1:size(observerTable, 1)
            if ~observerTable(i, 3)
                fprintf('- %s [matFile=1 selfRate=%d]\n', resFiles{i}, observerTable(i, 2));
            end
        end
    end
    
    % 2. scan all decision files
    res = cell2table(cell(0, 16), 'VariableNames', ...
        {'word', 'audioValid', 'onsetType', 'reactionTime', 'observer', 'grader', ...
        'selfRating', 'trialTime', 'gradingTime', 'beginSec', 'endSec', ...
        'idxOnset', 'idxLength', 'frequency', 'thresholdValue', 'observerFileName'});
    for i = 1:length(decFiles)
        
        fileName = decFiles{i};
        t = load(fileName);
        t = t.t;
        for j = 1:height(t)

            observerFileName = t{j, 1}{1};
            logFilesIndex = find(contains(logFiles(:, 1), observerFileName));
            if isempty(logFilesIndex)
                % this response does not have self rating record 
                continue;
            end
            if nnz(strcmp(observerFileName, res{:, 'observerFileName'}))
                % if this observer response has been graded
                
                
            end
            newRow = {t{j, 4}{1}, t{j, 3}, t{j, 2}, t{j, 8}-t{j, 7}, t{j, 5}{1}, t{j, 6}{1}, ...
                logFiles{logFilesIndex, 2}, observerFileName(1:19), t{j, 9}{1}, t{j, 7}, t{j, 8}, ...
                t{j, 10}, t{j, 11}, t{j, 12}, t{j, 13}, observerFileName};
            res = [res; newRow]; %#ok
        end
    end

    return;
end


% should not reach here
disp('Operation not recognized.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ask for confirmation
function [res] = confirmation(option)

    answer = questdlg(['Please confirm this operation:  ', option], 'Confirm', 'Cancel', 'Confirm', 'Cancel');
    switch answer
        case 'Cancel'
            res = 0;
        case 'Confirm'
            res = 1;
    end
end


% is this file an observer's response record
function [res] = isResponse(fileName)

    if length(fileName)>9 && ~strcmp(fileName(1:9), 'Decision-') && strcmp(fileName(end-3:end), '.mat')
        res = true;
    else
        res = false;
    end
end


% display the waveform of this file
function [] = showWave(fileName)

    [plotData, idxTotal, freq, voiceTrigger, ~, ~] = retrieveResponseInfo(fileName);
    % calculate local variables
    onsetTime = idxTotal / freq;
    totalTime = length(plotData) / freq;
    % waveform
    figure;
    hold on
    plot((1:size(plotData, 2)) ./ freq, plotData(1, :), 'b');
    % mark onset point
    xlim([0, totalTime]);
    ylim([min(min(plotData)), max(max(plotData))]);
    xl = xlim();
    yl = ylim();
    ydisplacement = voiceTrigger;
    xdisplacement = ydisplacement * (xl(2)-xl(1)) / (yl(2)-yl(1));
    plot([onsetTime, onsetTime-xdisplacement], [ydisplacement/100.0, ydisplacement], 'r', 'LineWidth', 0.5);
    scatter(onsetTime, 0, 5, 'r', 'Marker', 'x');
    text(onsetTime-xdisplacement, ydisplacement*1.05, 'threshold onset', 'FontSize', 8);
end


% display the spectrum of this file
function [] = showSpec(fileName)

    [plotData, idxTotal, freq, ~, ~, ~] = retrieveResponseInfo(fileName);
    % calculate local variables
    onsetTime = idxTotal / freq;
    totalTime = length(plotData) / freq;
    % spectrogram
    fig = myspectrogram(plotData, freq);
    f = figure;
    hold on;
    newax = gca;
    copyobj(fig, newax);
    delete(fig);
    xlim([0, totalTime]);
    ylim([0, freq]);
    xl = xlim();
    yl = ylim();
    xdisplacement = (xl(2) - xl(1)) * 0.01;
    plot([onsetTime, onsetTime], yl, 'r', 'LineWidth', 1.0);
    text(onsetTime+xdisplacement, yl(2), 'threshold onset', 'FontSize', 8);
end


% play audio of the specified file
function [] = playAudio(fileName)

    [plotData, ~, freq, ~, ~, ~] = retrieveResponseInfo(fileName);
    sound(plotData, freq);
end


% retrieve information from one observer response mat file
function [plotData, idxTotal, freq, voiceTrigger, captureStartSec, beginSec] = retrieveResponseInfo(fileName)

    if ~isResponse(fileName)
        fileName = [fileName, '.mat'];
    end
    t = load(fileName);
    plotData = t.info{1};
    idxTotal = t.info{2};
    freq = t.info{3};
    voiceTrigger = t.info{4};
    captureStartSec = t.info{5};
    beginSec = t.info{6};
end


% sort file in chronological order, type can be 'decision'/'response'
% return timeArray as n*2 [time | fileName]
function [res] = sortFile(type)

    % read all filenames
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    % retrieve time
    timeArray = strings(length(files), 2); % time | fileName
    count = 0;
    for i = 1:length(files)

        fileName = files{i};
        if strcmp(type, 'decision')
            % if this is a decision file
            if length(fileName)>9 && strcmp(fileName(1:9), 'Decision-')

                info = split(fileName, '-');
                count = count + 1;
                timeArray(count, 1) = string([info{2}, '-', info{3}, '-', info{4}, '-', ...
                                       info{5}, '-', info{6}, '-', info{7}]);
                timeArray(count, 2) = fileName;
            end
        elseif strcmp(type, 'response')
            % if this is an observer's response mat file
            if isResponse(fileName)

                info = split(fileName, '-');
                count = count + 1;
                timeArray(count, 1) = string([info{1}, '-', info{2}, '-', info{3}, '-', ...
                                       info{4}, '-', info{5}, '-', info{6}]);
                timeArray(count, 2) = fileName;
            end
        end
    end
    timeArray(count+1:end, :) = [];
    % if no decision/response file
    if count == 0
        res = [];
        return;
    end
    % sort time
    [~, idx] = sort(timeArray(:, 1), 1, 'descend');
    res = timeArray(idx, :);
end

% END OF READALOUDHELPER
