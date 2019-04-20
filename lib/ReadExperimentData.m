function [oo,tt]=ReadExperimentData(experiment,vars)
% [oo,tt]=ReadExperimentData(experiment,vars); Returns all the thresholds
% contains in all the MAT files in the data folder whose names begin with
% the string specified in the "experiment" argument. The MAT file may
% contain a whole experiment ooo{}, or a block oo(), with one element per
% condition. ooo{} is a cell array of oo. oo is a struct array of o. Each o
% is a condition with a threshold. The thresholds are extracted from all
% the MAT files in the data folder whose names begin with the string in
% "experiment". We add two new fields to each threshold record. "date" is a
% readable string indicating the date and time of measurement.
% "missingField" is a cell list of strings of all the fields that were
% requested in vars, but not available in the threshold record.
%
% NOTE: Thresholds with fewer than minimumTrials (currently 25) are
% ignored.
%
% The original data files group thresholds into blocks of interleaved
% conditions. This routine ignores the blocking, returning just a list of
% conditions (each with a threshold). This offers the convenience of simply
% indexing all the conditions, which simplifies the analysis programming.
% The blocking is important for collecting the data, but is not used in my
% analyses. The blocking is still detectable because every condition within
% a block has the same dataFilename, beginningTime (1 s precision), and
% beginSecs (nanosec precision). Getting all the conditions into one struct
% array is not trivial because every element of a struct array must have
% the same fields, and we often have unique fields in some conditions. The
% solution here is to predefine a list of the fields we'll use, and ignore
% all other fields. Unused fields (in conditions that don't use them) are
% left empty. Alternatively, to retain all fields, it would be necessary
% for the whole array to have the union of all the fields in all the
% conditions. That would have the virtue of not requiring a predefined
% list.
%
% denis.pelli@nyu.edu July 2018

myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(myPath); % We are in the "lib" folder.
% THe lib and data folders are in the same folder.
dataFolder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'data'); 
matFiles=dir(fullfile(dataFolder,['run' experiment '*.mat']));

% Each block has a unique identifier: o.dataFilename. It is created
% just before we start running trials. I think that we could read all the
% data files, accumulating both block files, with an "oo" struct,
% and summary files which contain a whole experiment "ooo", consisting of
% multiple blocks "oo", each of which contains several thresholds "o".  We
% can safely discard duplicate blocks with the same identifier and neither
% lose data, nor retain any duplicate data.

% The summary file retains the organization of trials into blocks and
% experiments. The individual threshold files do not, but they do have
% "conditionName" "observer" and "experiment" fields that encode the most
% important aspects of the grouping.

%% READ ALL DATA INTO A LIST OF CONDITIONS IN STRUCT ARRAY "oo".
if nargin<1
    error('You must include the first argument, a string, but it can be an empty string.');
end
if nargin<2
    vars={'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection' ...
        'thresholdParameter' 'task' 'targetFont' 'alphabet' 'borderLetter' ...
        'viewingDistanceCm' 'row' 'block' 'beginningTime' 'beginSecs' ...
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
%         'getAlphabetFromDisk' 'repeatedTargets' 'scriptName'  ...
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
filenameList={}; % Avoid duplicate data.
for iFile=1:length(matFiles) % One file per iteration.
    % Accumulate all conditions into one long oo struct array. First we
    % read each file into a temporary ooo{} cell array, each of whose
    % elements represents a block. There are two kinds of file: block and
    % summary. Each block file includes an oo() array struct, with one
    % element per condition, all tested during one block, interleaved. Each
    % summary file includes a whole experiment ooo{}, each of whose
    % elements represents a block by an oo() array struct, with one element
    % per condition.
    d=load(matFiles(iFile).name);
    if isfield(d,'ooo')
        % Get ooo struct (a cell array) from summary file.
        ooo=d.ooo;
    elseif isfield(d,'oo')
        % Get "oo" struct array from threshold file.
        ooo={d.oo};
    elseif isfield(d,'o')
        % Get "o" struct from threshold file.
        ooo={d.o};
    else
        continue % Skip unknown file type.
    end
    for block=1:length(ooo) % Iterate through blocks.
        if ~isfield(ooo{block},'dataFilename')
            % Skip any block lacking a dataFilename (undefined).
            continue
        end
        if ismember(ooo{block}(1).dataFilename,filenameList)
            % Skip if we already have this block of data.
            continue
        else
            filenameList{end+1}=ooo{block}(1).dataFilename;
        end
        for oi=1:length(ooo{block}) % Iterate through conditions within a block.
            ooo{block}(oi).localHostName=ooo{block}(oi).cal.localHostName; % Expose computer name, to help identify observer.
            if isempty(ooo{block}(oi).dataFilename)
                % Make sure every condition has this field.
                ooo{block}(oi).dataFilename=ooo{block}(1).dataFilename;
            end
            if isempty(ooo{block}(oi).beginningTime)
                % Make sure every condition has this field.
                ooo{block}(oi).beginningTime=ooo{block}(1).beginningTime;
            end
            if isempty(ooo{block}(oi).beginSecs)
                % Make sure every condition has this field.
                ooo{block}(oi).beginSecs=ooo{block}(1).beginSecs;
            end
            o=ooo{block}(oi); % "o" holds one condition.
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

%% CLEAN UP THE LIST, DISCARDING WHAT WE DON'T WANT.
% We've now gotten all the thresholds into oo. 
if ~isfield(oo,'trials')
    error('No data');
end
oo=oo([oo.trials]>0); % Discard conditions with no data.
if isempty(oo)
    return;
end
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
    oo(oi).date=sprintf('%04d.%02d.%02d, %02d:%02d:%02.0f',y,m,d,h,mi,s);
end
tt=struct2table(oo,'AsArray',true);
minimumTrials=30; % 25 DGP
if sum(tt.trials<minimumTrials)>0
    fprintf('\nWARNING: Discarding %d threshold(s) with fewer than %d trials:\n',sum(tt.trials<minimumTrials),minimumTrials);
    disp(tt(tt.trials<minimumTrials,{'date' 'observer' 'thresholdParameter' 'eccentricityXYDeg' 'trials'})) % 'experiment'  'conditionName'
end
for oi=length(oo):-1:1
    if oo(oi).trials<minimumTrials
        oo(oi)=[];
        tt(oi,:)=[];
    end
end

