function [res] = readAloudHelper(action, option)
% [s] = readAloudHelper('summary');
% readAloudHelper('deleteLastDecisionFile');
% readAloudHelper('deleteLastObserverResponse');
% readAloudHelper('showFig'[, figName]);
% readAloudHelper('clearAllDecisions' | 'clearObserverData');
% This function is used to manipulate the data under 'readAloud' folder.
% Some actions requires a second confirmation.
% Action 'summary' scans all observer response files and all grader
% decision files. The returned table contains a summary of every grader's
% decision.
% Action 'deleteLastDecisionFile' will delete the last experimenter's
% decision file.
% Action 'deleteLastObserverResponse' will find the last stored wav file
% and delete it along with its corresponding fig file and self-rate log.
% Action 'showFig' will open a soundwave file. If no 'figName' is provided,
% a random figure is shown.
% Action 'clearAllDecisions' will delete all experimenter's evaluation of
% observers' audio data.
% Action 'clearObserverData' will delete all observer's audio data, 
% soundwave figures and self-rating logs.
% More options to be implemented.
% Written by Ziyi Zhang, December, 2019.


if nargin < 2
    option = [];
end
action = lower(action); % case insensitive
res = [];

% clearAllDecisions
if streq(action, 'clearalldecisions')

    if ~confirmation(action)
        return;
    end
    res = movefile('Decision-*', [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        disp('Movefile failed.');
    else
        disp('File(s) removed.');
    end

    return;
end

% clearObserverData
if streq(action, 'clearobserverdata')

    if ~confirmation(action)
        return;
    end
    res1 = movefile('*.wav', [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    res2 = movefile('*.fig', [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    res3 = movefile('*.log', [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res1 || ~res2 || res3
        disp('Movefile failed.');
    else
        disp('File(s) removed.');
    end

    return;
end

% showFig
if streq(action, 'showfig')
    
    if ~isempty(option)
        openfig(option, 'visible');
    else
        % show a random fig
        dinfo = dir(fileparts(mfilename('fullpath')));
        files = {dinfo.name};
        index = randperm(length(files));
        for i = 1:length(index)
            
            file = files{index(i)};
            if length(file)>4 && streq(file(end-3:end), '.fig')
            
                disp(file);
                openfig(file, 'visible');
                break;
            end
        end
    end

    return;
end

% deleteLastDecisionFile
if streq(action, 'deletelastdecisionfile')

    timeArray = sortFile('decision');
    if isempty(timeArray)
        fprintf('No decision file exists in this folder: %s\n', fileparts(mfilename('fullpath')));
        return;
    end
    fprintf('Last decision file is %s\n', timeArray(1, 2));
    % delete this file
    res = movefile(timeArray(1, 2), [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        disp('Movefile failed.');
    else
        disp('File removed.');
    end

    return;
end

% deleteLastObserverResponse
if streq(action, 'deletelastobserverresponse')

    timeArray = sortFile('observer');
    if isempty(timeArray)
        fprintf('No wav file exists in this folder: %s\n', fileparts(mfilename('fullpath')));
        return;
    end
    fileName = char(timeArray(1, 2));
    fileName = fileName(1:end-4);
    fprintf('Last observer''s response is %s\n', fileName);
    % delete files with this name
    res = movefile([fileName, '.wav'], [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Movefile failed: %s\n', [fileName, '.wav']);
    else
        fprintf('File removed: %s\n', [fileName, '.wav']);
    end
    res = movefile([fileName, '.fig'], [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Movefile failed: %s\n', [fileName, '.fig']);
    else
        fprintf('File removed: %s\n', [fileName, '.fig']);
    end
    res = movefile([fileName, '*.log'], [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
    if ~res
        fprintf('Movefile failed: %s\n', [fileName, '-?.log']);
    else
        fprintf('File removed: %s\n', [fileName, '-*.log']);
    end

    return;
end

% summary
if streq(action, 'summary')
    
    % 1. scan all observer responses
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    wavFiles = cell(0, 1);
    figFiles = cell(0, 1);
    logFiles = cell(0, 2);
    decFiles = cell(0, 1);
    for i = 1:length(files)
        
        fileName = files{i};
        if length(fileName) < 10
            continue; % skip short file name
        end
        if streq(fileName(end-3:end), '.wav')
            wavFiles{length(wavFiles)+1, 1} = fileName(1:end-4);
        elseif streq(fileName(end-3:end), '.fig')
            figFiles{length(figFiles)+1, 1} = fileName(1:end-4);
        elseif streq(fileName(end-3:end), '.log')
            count = size(logFiles, 1);
            logFiles{count+1, 1} = fileName(1:end-6);
            logFiles{count+1, 2} = str2double(fileName(end-4));
        elseif streq(fileName(1:9), 'Decision-')
            decFiles{length(decFiles)+1, 1} = fileName;
        end
    end
    observerTable = false(length(wavFiles), 4); % wav, fig, log, completeBit
    for i = 1:length(wavFiles) % use wav file as principle identifier
        
        observerTable(i, 1) = true;
        observerTable(i, 2) = nnz(streq(figFiles, wavFiles{i}));
        observerTable(i, 3) = nnz(streq(logFiles, wavFiles{i}));
        observerTable(i, 4) = observerTable(i, 1) & observerTable(i, 2) & observerTable(i, 3);
    end
    if nnz(~observerTable(:, 4)) % discrepency in observer response
        
        warning('The following observer responses are not complete. At least one file is missing for each response.');
        for i = 1:size(observerTable, 1)
            if ~observerTable(i, 4)
                fprintf('- %s [wavFile=1 figFile=%d selfRate=%d]\n', wavFiles{i}, observerTable(i, 2), observerTable(i, 3));
            end
        end
    end
    
    % 2. scan all decision files
    res = cell2table(cell(0, 9), 'VariableNames', {'word', 'onsetValid', 'audioValid', 'selfRating', 'trialTime', 'gradeTime', 'observer', 'grader', 'observerFileName'});
    for i = 1:length(decFiles)
        
        if ~observerTable(i, 4)
            continue; % if not complete
        end
        fileName = decFiles{i};
        t = load(fileName);
        t = t.t;
        for j = 1:height(t)

            observerFileName = t{j, 1}{1};
            if nnz(streq(observerFileName, res{:, 'observerFileName'}))
                % if this observer response has been graded
                
                
            end
            newRow = {t{j, 5}{1}, t{j, 2}, t{j, 3}, logFiles{i, 2}, t{j, 4}{1}, fileName(10:28), t{j, 6}, t{j, 7}, observerFileName};
            res = [res; newRow]; %#ok
        end
    end

    return;
end


% should not reach here
disp('Option not recognized.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res] = confirmation(option)

    answer = questdlg(['Please confirm this option: ', option], 'Confirm', 'Cancel', 'Confirm', 'Cancel');
    switch answer
        case 'Cancel'
            res = 0;
        case 'Confirm'
            res = 1;
    end
end


function res = sortFile(type)

    % read all filenames
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    % retrieve time
    timeArray = strings(length(files), 2);
    count = 0;
    for i = 1:length(files)

        fileName = files{i};
        if streq(type, 'decision')
            % if this is a decision file
            if length(fileName)>9 && streq(fileName(1:9), 'Decision-')

                info = split(fileName, '-');
                count = count + 1;
                timeArray(count, 1) = string([info{2}, '-', info{3}, '-', info{4}, '-', ...
                                       info{5}, '-', info{6}, '-', info{7}]);
                timeArray(count, 2) = fileName;
            end
        elseif streq(type, 'observer')
            % if this is an observer's wav file
            if length(fileName)>4 && streq(fileName(end-3:end), '.wav')

                info = split(fileName, '-');
                count = count + 1;
                timeArray(count, 1) = string([info{1}, '-', info{2}, '-', info{3}, '-', ...
                                       info{4}, '-', info{5}, '-', info{6}]);
                timeArray(count, 2) = fileName;
            end
        end
    end
    timeArray(count+1:end, :) = [];
    % if no decision file
    if count == 0
        res = [];
        return;
    end
    % sort time
    [~, idx] = sort(timeArray(:, 1), 1, 'descend');
    res = timeArray(idx, :);
end
