function [oo,tt]=ReadExperimentData(experiment,vars)
% [oo,tt]=ReadExperimentData(experiment,vars);
% Returns all the thresholds contains in all the MAT files in the data
% folder whose names begin with the string specified in the "experiment"
% argument. The MAT file may contain a whole experiment ooo{}, or a block
% oo(), or a trial o. ooo{} is a cell array of oo. oo is an array of o.
% Each o is a threshold. The thresholds are extracted from all the MAT
% files in the data folder whose names begin with the string in
% "experiment". We add two new fields to each threshold record. "date" is a
% readable string indicating the date and time of measurement.
% "missingField" is a cell list of strings of all the fields that were
% requested in vars, but not available in the threshold record.
% denis.pelli@nyu.edu July 2018

myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(myPath); % We are in the "lib" folder.
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data'); % lib and data folders are in the same folder.
matFiles=dir(fullfile(dataFolder,[experiment '*.mat']));

% Each threshold has a unique identifier: o.dataFilename. It is created
% just before we start running trials. I think that we could read all the
% data files, accumulating both individual threshold files, a "o" struct,
% and summary files which contain a whole experiment "ooo", consisting of
% multiple blocks "oo" each of which contains several thresholds "o".  if
% we first discard instances with zero trials then we can safely discard
% duplicates with the same identifier and neither lose data, nor retain any
% duplcate data.

% The summary file retains the organization of trials into blocks and
% experiments. The individual threshold files do not, but they do have
% "conditionName" "observer" and "experiment" fields that encode the most
% important aspects of the grouping.

%% READ ALL DATA INTO A LIST OF THRESHOLDS "oo".
if nargin<1
    error('You must include the first argument, a string, but it can be an empty string.');
end
if nargin<2
    vars={'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection' ...
        'thresholdParameter' 'task' 'targetFont' 'alphabet' 'borderLetter' ...
        'viewingDistanceCm' 'row'  ...
%         'alphabet' 'borderLetter' 'computer' 'condition' 'conditionName' ...
%         'contrast' 'dataFilename' 'dataFolder' 'durationSec' ...
%         'eccentricityPolarDeg' 'eccentricityXYDeg' 'eccentricityXYPix' ...
%         'experimenter' 'fixationCoreSizeDeg'  ...
%         'fixationCrossBlankedNearTarget' 'fixationCrossDeg' ...
%         'fixationIsOffscreen'  ...
%         'fixationLineWeightDeg' 'fixationOnScreen' 'fixationXYPix'  ...
%         'fixedSpacingOverSize' 'flankerLetter' 'flankingDirection'  ...
%         'flankingPolarDeg' 'flipScreenHorizontally' 'maxLines'  ...
%         'minimumTargetPix' 'nearPointXYDeg' 'nearPointXYInUnitSquare'  ...
%         'nearPointXYPix' 'observer' 'pixPerCm' 'pixPerDeg' 'pThreshold'  ...
%         'readAlphabetFromDisk' 'repeatedTargets' 'scriptName'  ...
%         'spacingGuessDeg' 'spacings' 'targetDeg'  ...
%          'targetFontHeightOverNominalPtSize'  ...
%         'targetFontNumber' 'targetHeightOverWidth' 'targetMargin'  ...
%         'targetPix' 'targetSizeIsHeight' 'targetXYPix' 'task'  ...
%         'textFont' 'textLineLength' 'textSize' 'textSizeDeg'  ...
%         'thresholdParameter' 'totalSecs' 'trialData' 'trials' ...
%         'unknownFields' 'useFixation' 'useFractionOfScreenToDebug'  ...
        };
end
oo=struct([]);
for iFile=1:length(matFiles) % One file per iteration.
    % Each threshold file includes just one "o" threshold struct. Each
    % summary file includes a whole experiment ooo{}, each of whose
    % elements is a block oo(), each of whose elements is a threshold
    % struct o. For each threshold, we extract the desired fields into one
    % element of the "oo" array.
    d=load(matFiles(iFile).name);
    if isfield(d,'ooo')
        % Grab experiment ooo struct from summary file.
        ooo=d.ooo;
    elseif isfield(d,'oo')
        % Grab "oo" struct array from threshold file.
        ooo={d.oo};
    elseif isfield(d,'o')
        % Grab "o" struct from threshold file.
        ooo={d.o};
    else
        continue % Skip unknown file type.
    end
    for k=1:length(ooo) % Iterate through blocks.
        if ~isfield(ooo{k},'dataFilename')
            continue
        end
        for j=1:length(ooo{k}) % Iterate through conditions within a block.
            if isempty(ooo{k}(j).dataFilename)
                continue
            end
            o=ooo{k}(j); % "o" is a threshold struct.
            oo(end+1).missingFields={}; % Create new element.
            usesSecsPlural=isfield(o,'targetDurationSecs');
            for i=1:length(vars)
                field=vars{i};
                if usesSecsPlural
                    oldField=field;
                else
                    oldField=strrep(field,'Secs','Sec');
                end
                if isfield(o,oldField)
                    oo(end).(field)=o.(oldField);
                else
                    oo(end).missingFields{end+1}=field;
                end
            end
        end
    end
end
fprintf('Read %d thresholds from %d files. Now discarding empties and duplicates.\n',length(oo),length(matFiles));
% We've now gotten all the thresholds into oo. 
if ~isfield(oo,'trials')
    error('No data');
end
oo=oo([oo.trials]>0); % Discard empties.
if isempty(oo)
    return;
end
[~,ii]=unique({oo.dataFilename}); % Discard duplicates.
oo=oo(ii);
missingFields=unique(cat(2,oo.missingFields));
if ~isempty(missingFields)
    warning OFF BACKTRACE
    s='Missing fields:';
    s=[s sprintf(' o.%s',missingFields{:})];
    s=sprintf('%s\n',s);
    warning(s);
end
s=sprintf('condition.conditionName(trials):');
for oi=length(oo):-1:1
    if isempty(oo(oi).trials)
        oo(oi)=[];
    end
end
for oi=1:length(oo)
    [y,m,d,h,mi,s] = datevec(oo(oi).beginningTime) ;
    oo(oi).date=sprintf('%02d.%02d.%d, %02d:%02d:%02.0f',d,m,y,h,mi,s);
end
tt=struct2table(oo);
if sum(tt.trials<25)>0
    fprintf('\nWARNING: Discarding %d threshold(s) with fewer than 25 trials:\n',sum(tt.trials<25));
    disp(tt(tt.trials<25,{'date' 'observer' 'thresholdParameter' 'eccentricityXYDeg' 'trials'})) % 'experiment'  'conditionName'
end
for oi=length(oo):-1:1
    if oo(oi).trials<25
        oo(oi)=[];
        tt(oi,:)=[];
    end
end

