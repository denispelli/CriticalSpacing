% Script to fix overwritten observer name.
% In data collected from March 29 to April 2, the first block is saved with
% the correct experimenter and observer names. Subsequent blocks still have
% the right experimenter name, but the observer name is overwritten by the
% experimenter name. I'd like to fix this.
% It should be easy because the blocks are saved in chronological order and
% they are numbered by o.block and o.blocksDesired. The only fields to fix
% are o.observer and o.dataFilename. Qihan ran herself, and Darshan ran
% several people, not himself. For each data file, I can detect the problem
% as a match between o.experimenter 'Darshan' (ignoring case) and
% o.observer. Qihan was both experimenter and observer, so her data were
% unnaffected by the bug. If the observer name is suspect, I can replace it
% with the o.observer field from the earlier .mat file correponding to the
% first block. The next one back in time should have a o.block value that
% is one less, and the file o.block-1 back should be the first block, which
% will have the correct o.observer.
%
% Looking at the data files, I discover that not all blocks were run. And
% in one case block 1 has Darshan as both experimenter and observer. FIX 1:
% For 2019 files before April 3, when observer is Darshan or Sam Coleman,
% then set observer to Sam Colman and experimenter to Darshan. FIX 2: When
% I found a valid observer (i.e. not Darshan) followed by a block within
% 1000 s with an invalid observer (i.e. Darshan), then I copied the valid
% observer to the new block. I repeated this iteratively, and happily all
% observers are now valid.
experiment='CrowdingSurvey';
printFilenames=true;
makePlotLinear=false;
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
addpath(fullfile(myPath,'lib')); % Folder in same directory as this M file.
dataFolder=fullfile(fileparts(mfilename('fullpath')),'data');
% dataFolder='/Users/denispelli/Dropbox/MATLAB/CriticalSpacing/data/';
cd(dataFolder);
close all
%% READ ALL DATA OF EXPERIMENT FILES INTO A LIST OF THRESHOLDS "oo".
vars={'condition' 'conditionName' 'dataFilename' ... % 'experiment' 
    'experimenter' 'observer' 'localHostName' 'trials' 'thresholdParameter' ...
    'eccentricityXYDeg' 'targetDeg' 'spacingDeg' 'flankingDirection'... 
    'viewingDistanceCm' 'durationSec'  ...
    'contrast' 'pixPerCm'  'nearPointXYPix'  'beginningTime' 'beginSecs' 'block' 'blocksDesired' };
oo=ReadExperimentData(experiment,vars); % Adds date and missingFields.
t=struct2table(oo);
time=datevec(t.beginningTime);
t.Year=time(:,1);
t = sortrows(t,'beginningTime');
t=t(t.Year==2019,:);
% t=t(ismember(t.experimenter,{'darshan' 'Darshan'}),:);
% t=sortrows(t,'block');
t(:,{'dataFilename' 'Year' 'trials' 'experimenter' 'observer' 'localHostName' 'block' 'blocksDesired'  'eccentricityXYDeg' 'conditionName'})
% return

% Compute delta time 's' for each file to the next file.
[~,ii]=unique(t(:,'dataFilename'));
t=sortrows(t(ii,:),'beginningTime');
time=table2array(t(:,'beginningTime'));
delta=[];
for i=1:height(t)-1
    delta(i)=etime(datevec(time(i+1)),datevec(time(i)));
end
delta(height(t))=nan;
t(:,'s')=array2table(delta');
t(:,{'dataFilename' 'experimenter' 'observer' 'localHostName' 's' 'block'})
%     return
    
% Replace o.observer oldName by newName.
localHostName='';
oldName='janet  gu';
newName='janet gu';
oldName='';
newName='ana';
oldName=' ';
newName='UNKNOWN';
oldName='Jessie';
newName='Jessie Zhanay';
oldName='Douglas';
newName='Elizabeth Kurtz';
localHostName='Pelli-Mac-1';
localHostName='';
oldName='';
newName='UNKNOWN2';

tt=t(ismember(t.observer,{oldName}),:);
cd(dataFolder);
list=table2array(tt(:,'dataFilename'));
observer='';
for f=1:height(tt)
    filename=list{f};
    load([filename '.mat'],'oo');
    assert(streq(oo(1).dataFilename,filename));
    if ismember(oo(1).observer,{oldName})
        % If localHostName is not empty, then it must match.
        if isempty(localHostName) || ismember({oo(1).cal.localHostName},localHostName)
            % Substitute newName for oldName.
            oldFilename=filename;
            filename=strrep(filename,[oldName '.2019'],[newName '.2019']);
            for oi=1:length(oo)
                oo(oi).observer=newName;
                oo(oi).dataFilename=filename;
            end
            fprintf('OLD: %s\n',oldFilename);
            fprintf('NEW: %s\n',filename);
            fprintf('Changing ''%s'' to ''%s''\n',oldName,newName);
            save([filename '.mat'],'oo');
            delete([oldFilename '.mat'])
        end
    end
end
return
   
if 0
% THE FIX: For 2019 files before April 3, when observer is Darshan or Sam
% Coleman, then set observer to Sam Colman and experimenter to Darshan.
        if ~ismember(oo(1).observer,{'Darshan' 'darshan'})
        % This block's observer valid, save for next block.
        if s(f)<1000
            observer=oo(1).observer;
        else
            observer='';
        end
    else
        % This block's observer is invalid.
        if ~isempty(observer)
            % Copy observer from previous block
            oldName=name;
            name=strrep(name,'Darshan.',[observer '.']);
            name=strrep(name,'darshan.',[observer '.']);
            for oi=1:length(oo)
                oo(oi).observer=observer;
                oo(oi).dataFilename=name;
            end
            save([name '.mat'],'oo');
            delete([oldName '.mat'])
            fprintf('Change Darshan to %s\n',observer);
            if s(f)<1000
                observer=oo(1).observer;
            else
                observer='';
            end
        end
    end
end
if 0
for nameCell=list
    name=nameCell{1};
    load([name '.mat'],'oo');
    assert(streq(oo(1).dataFilename,name));
%     delete([name '.mat'])
    name=strrep(name,'-Darshan-Darshan','-Darshan-Sam Colman');
    name=strrep(name,'--Sam Colman','-Darshan-Sam Colman');
    for oi=1:length(oo)
        oo(oi).observer='Sam Colman';
        oo(oi).experimenter='Darshan';
        oo(oi).dataFilename=name;
    end
    save([name '.mat'],'oo');
end
end