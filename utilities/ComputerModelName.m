function machine=ComputerModelName
% machine=ComputerModelName;
% Returns a struct with six text fields that specify the basic
% configuration of your hardware and software. Here are examples for macOS
% and Windows:
%
%            model: 'MacBook10,1'
%        modelLong: 'MacBook (Retina, 12-inch, 2017)'
%     manufacturer: 'Apple Inc.'
%           system: 'macOS 10.14.6'
%     psychtoolbox: 'Psychtoolbox 3.0.16'
%           matlab: 'MATLAB 9.6 (R2019a)'
%     
%            model: 'Inspiron 5379'
%        modelLong: ''
%     manufacturer: 'Dell Inc.'
%           system: 'Windows NT-10.0.9200'
%     psychtoolbox: 'Psychtoolbox 3.0.16'
%           matlab: 'MATLAB 9.6 (R2019a)'
%
% Unavailable answers are empty ''.
%
% This is useful in testing and benchmarking to record the test environment
% in a human-readable way. If you are trying to produce a compact string,
% e.g. to use in a file name, you might do something like this:
% machine=ComputerModelName;
% filename=['TestFlip-' machine.model '-' machine.system ...
%     '-' machine.psychtoolbox '.png'];
% filename=strrep(filename,'Windows','Win');
% filename=strrep(filename,'Psychtoolbox','Psy');
% filename=strrep(filename,' ','-');
% Which produces a string like this: 
% TestFlip-MacBook10,1-macOS-10.14.6-Psy-3.0.16.png
%
% August 24, 2019, denis.pelli@nyu.edu
%
% LIMITATIONS:
% The "curl" trick to get macOS modelLong failed on a MacBookPro:
%     Model: 'MacBookPro13,2'
% ModelLong: 'fish: Expected a variable name after this $. curl -s https://support-sp.apple.com/sp/product?cc=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 9- ) | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|'                                                    ^'

%% HISTORY
% August 24, 2019. DGP wrote it as a subroutine for TestFlip.m
% August 25, 2019. DGP fixed bug that bypassed most of the cleanup of
%                  machine.system.

machine.model='';
machine.modelLong=''; % Currently non-empty only for macOS.
machine.manufacturer='';
machine.system='';
machine.psychtoolbox='';
machine.matlab='';
[~,p]=PsychtoolboxVersion;
machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',p.major,p.minor,p.point);
if ~exist('ver','file')
    error('Need MATLAB release R2006 or later.');
end
m=ver('matlab');
machine.matlab=sprintf('%s %s %s',m.Name,m.Version,m.Release);
c=Screen('Computer');
machine.system=c.system;
if isfield(c,'hw') && isfield(c.hw,'model')
    machine.model=c.hw.model;
end
switch computer
    case 'MACI64'
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        s = evalc(['!'...
            'curl -s https://support-sp.apple.com/sp/product?cc=$('...
            'system_profiler SPHardwareDataType '...
            '| awk ''/Serial/ {print $4}'' '...
            '| cut -c 9- '...
            ') | sed ''s|.*<configCode>\(.*\)</configCode>.*|\1|''']);
        while ismember(s(end),{' ' char(10) char(13)})
            s=s(1:end-1); % Remove trailing whitespace.
        end
        machine.modelLong=s;
        if all(machine.modelLong(1:5)=='fish:') || ...
                ~all(ismember(lower(machine.modelLong(1:3)),'abcdefghijklmnopqrstuvwxyz'))
            warning('Oops. curl failed. Send this to denis.pelli@nyu.edu: "%s"',s);
            machine.modelLong='';
        end
        machine.manufacturer='Apple Inc.';
        % A python solution: https://gist.github.com/zigg/6174270

    case 'PCWIN64'
        wmicString = evalc('!wmic computersystem get manufacturer, model');
        % Here's a typical result:
        % wmicString=sprintf(['    ''Manufacturer  Model            \n'...
        % '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(wmicString,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Change run of 2+ spaces to a tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9)); % Use tabs to split into tokens.
        clear ok
        for i=1:length(fields)
            ok(i)=~isempty(fields{i});
        end
        fields=fields(ok); % Discard empty fields.
        % The original had two columns: category and value. We've now got
        % one long column with n categories followed by n values.
        % We asked for manufacturer and model so n should be 2.
        if length(fields)==4
            n=length(fields)/2; % n names followed by n values.
            for i=1:n
                % Grab each field's name and value.
                % Lowercase name.
                fields{i}(1)=lower(fields{i}(1));
                machine.(fields{i})=fields{i+n};
            end
        end
        if ~isfield(machine,'manufacturer') || isempty(machine.manufacturer)...
                || ~isfield(machine,'model') || isempty(machine.model)
            wmicString
            warning('Failed to retrieve manufacturer and model from WMIC.');
        end
        
    case 'GLNXA64'
        % Can anyone provide Linux code here?
end
% Clean up the Operating System name.
while ismember(machine.system(end),{' ' '-'})
    % Strip trailing separators.
    machine.system=machine.system(1:end-1);
end
while ismember(machine.system(1),{' ' '-'})
    % Strip leading separators.
    machine.system=machine.system(2:end);
end
% Modernize spelling.
machine.system=strrep(machine.system,'Mac OS','macOS'); 
if IsWin
    % Prepend "Windows".
    if ~all('win'==lower(machine.system(1:3)))
        machine.system=['Windows ' machine.system];
    end
end
end