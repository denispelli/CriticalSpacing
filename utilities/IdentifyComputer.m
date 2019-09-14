function machine=IdentifyComputer(option)
% machine=IdentifyComputer([option]);
% Returns a struct with eight text fields that specify the basic
% configuration of your hardware and software. Getting the video driver
% information requires opening and closing a window, which can take around
% 30 s, so you may wish to set option='dontOpenWindow' to skip that test,
% and return a struct with the video driver fields empty ''.
%
% Here are display of the output struct for macOS and Windows:
%
%                    model: 'MacBook10,1'
%                modelLong: 'MacBook (Retina, 12-inch, 2017)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
% psychtoolboxKernelDriver: ''
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%             driverVendor: 'Intel Inc.'
%            driverVersion: '2.1 INTEL-12.10.12'
%           driverRenderer: 'Intel(R) HD Graphics 615'
%
%                    model: 'Inspiron 5379'
%                modelLong: ''
%             manufacturer: 'Dell Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
% psychtoolboxKernelDriver: ''
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'Windows NT-10.0.9200'
%
% Unavailable answers are empty ''.
%
% This is useful in testing and benchmarking to record the test environment
% in a human-readable way. If you are trying to produce a compact string,
% e.g. to use in a file name, you might do something like this:
% machine=ComputerModelName;
% filename=['TestFlip-' machine.model ...
%     '-' machine.system ...
%     '-' machine.psychtoolbox '.png'];
% filename=strrep(filename,'Windows','Win');
% filename=strrep(filename,'Psychtoolbox','Psy');
% filename=strrep(filename,' ','-');
% Which produces a string like this:
% TestFlip-MacBook10,1-macOS-10.14.6-Psy-3.0.16.png
%
% September 1, 2019, denis.pelli@nyu.edu
%
% LIMITATIONS:
% LINUX: Doesn't yet get model name or manufacturer.
% MACOS: It gets the long model name only if Terminal's default shell is
% bash or zsh, which it typically is. I am thus far unable to switch to the
% bash shell and back, using "bash" and "exit", because MATLAB hangs up
% forever, e.g. !s=evalc('bash;pwd;exit');
% http://osxdaily.com/2007/02/27/how-to-change-from-bash-to-tcsh-shell/
% https://support.apple.com/en-us/HT208050

%% HISTORY
% August 24, 2019. DGP wrote it as a subroutine for TestFlip.m
% August 25, 2019. DGP fixed bug that bypassed most of the cleanup of
%                  machine.system.
% August 27, 2019. DGP use macOS Terminal only if it is running the bash
%                  or zsh shell. Reduce dependence on Psychtoolbox.
% September 13, 2019. DGP debugged code to detect PsychtoolboxKernelDriver.
if nargin<1
    option='';
end
machine.model='';
machine.modelLong=''; % Currently non-empty only for macOS.
machine.manufacturer='';
machine.psychtoolbox='';
machine.psychtoolboxKernelDriver='';
machine.matlab='';
machine.system='';
machine.driverVendor='';
machine.driverVersion='';
machine.driverRenderer='';
if exist('PsychtoolboxVersion','file')
    [~,p]=PsychtoolboxVersion;
    machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',p.major,p.minor,p.point);
end
if exist('ver','file')
    m=ver('octave');
    if isempty(m)
        m=ver('matlab');
        if isempty(m)
            error('The language must be MATLAB or Octave.');
        end
    end
    machine.matlab=sprintf('%s %s %s',m.Name,m.Version,m.Release);
else
    warn('MATLAB/OCTAVE too old (pre 2006) to have "ver" command.');
end
if exist('Screen','file')
    c=Screen('Computer');
    machine.system=c.system;
    if isfield(c,'hw') && isfield(c.hw,'model')
        machine.model=c.hw.model;
    end
else
    warn('Currently need Psychtoolbox to get operating system name.');
end
switch computer
    case 'MACI64'
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        shell=evalc('!echo $0');
        if contains(shell,'bash')% || contains(shell,'zsh')
            % This script requires the bash shell.
            % Alas, macOS Catalina switches from bash to zsh as the default
            % shell. 
            s = evalc(['!'...
                'curl -s https://support-sp.apple.com/sp/product?cc=$('...
                'system_profiler SPHardwareDataType '...
                '| awk ''/Serial/ {print $4}'' '...
                '| cut -c 9- '...
                ') | sed ''s|.*<configCode>\(.*\)</configCode>.*|\1|''']);
            while ismember(s(end),{' ' char(10) char(13)})
                s=s(1:end-1); % Remove trailing whitespace.
            end
        else
            warning(['Sorry. '...
                'Getting the long model name requires that Terminal''s '...
                'default shell be "bash". Alas, macOS Catalina changes '...
                'the default to be "zsh".']);
            s='';
        end
        machine.modelLong=s;
        if length(s)<3 || ~all(ismember(lower(s(1:3)),'abcdefghijklmnopqrstuvwxyz'))
            machine
            warning('Oops. curl failed. Please send the lines above to denis.pelli@nyu.edu: "%s"',s);
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

%% PSYCHTOOLBOX KERNEL DRIVER
% http://psychtoolbox.org/docs/psychtoolboxKernelDriver';
machine.psychtoolboxKernelDriver='';
if ismac
    [~,result]=system('kextstat -l -b PsychtoolboxKernelDriver');
    hasKernel=contains(result,'PsychtoolboxKernelDriver');
    if hasKernel
        %'Psychtoolbox kernel driver version';
        v=regexp(result,'(?<=\().*(?=\))','match'); % find (version)
        if ~isempty(v)
            v=v{1};
        else
            v='';
        end
        machine.psychtoolboxKernelDriver=['PsychtoolboxKernelDriver ' v];
    end
end

%% Video driver
% Mario Kleiner suggests (1.9.2019) identifying the gpu hardware and driver
% by the concatenation of GLVendor, GLRenderer, and GLVersion, which are
% accessible via winfo=Screen('GetWindowInfo',window);
if ~contains(option,'dontOpenWindow')
    % This block is optional because opening and closing a window takes a
    % long time, on the order of 30 s, so you may want to skip it if you
    % don't need the video driver details.
    screen=0;
    useFractionOfScreenToDebug=0.2;
    screenBufferRect=Screen('Rect',screen);
    r=round(useFractionOfScreenToDebug*screenBufferRect);
    r=AlignRect(r,screenBufferRect,'right','bottom');
    try
        window=[];
        window=Screen('OpenWindow',screen,255,r);
        info=Screen('GetWindowInfo',window);
        machine.driverVendor=info.GLVendor;
        machine.driverRenderer=info.GLRenderer;
        machine.driverVersion=info.GLVersion;
    catch e
        warn('Unable to get video driver openGL details.');
        warning(e.message);
    end
    if Screen(window,'WindowKind')~=0
        Screen('Close',window);
    end
end
end % function