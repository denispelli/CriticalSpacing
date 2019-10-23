function machine=IdentifyComputer(windowOrScreen)
% machine=IdentifyComputer([windowOrScreen]);
% Returns a struct with ten text fields (plus list of screens, and a screen
% number and size) that specify the basic configuration of your hardware
% and software. The openGL fields refer to the screen with the number
% specified by the screen field. Use windowOrScreen to provide a window
% pointer or the screen number. Default is screen 0, the main screen. This
% routine is quick if windowOrScreen is empty [] or points to a window, and
% it's slow if you provide a screen number (or use the default screen 0)
% because then it has to open and close a window, which may take 30 s.
% Passing an empty windowOrScreen skips opening a window, at the cost of
% leaving the screen size and openGL fields empty.
%
% Here are several examples of the output struct for macOS and Windows:
%
%                    model: 'iMac15,1'
%         modelDescription: 'iMac (Retina 5K, 27-inch, Late 2014)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                  screens: 0
%                   screen: 0
%                     size: [1800 3200]
%                       mm: [341 602]
%           openGLRenderer: 'AMD Radeon R9 M290X OpenGL Engine'
%             openGLVendor: 'ATI Technologies Inc.'
%            openGLVersion: '2.1 ATI-2.11.20'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%
%                    model: 'MacBook10,1'
%         modelDescription: 'MacBook (Retina, 12-inch, 2017)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                  screens: 0
%                   screen: 0
%                     size: [1440 2304]
%           openGLRenderer: 'Intel(R) HD Graphics 615'
%             openGLVendor: 'Intel Inc.'
%            openGLVersion: '2.1 INTEL-12.10.12'
% psychtoolboxKernelDriver: ''
%           drawTextPlugin: 1
%           psychPortAudio: 1
%
%                    model: 'MacBookPro11,5'
%         modelDescription: 'MacBook Pro (Retina, 15-inch, Mid 2015)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.4 (R2018a)'
%                   system: 'macOS 10.14.6'
%                  screens: 0
%                   screen: 0
%                     size: [1800 2880]
%           openGLRenderer: 'AMD Radeon R9 M370X OpenGL Engine'
%             openGLVendor: 'ATI Technologies Inc.'
%            openGLVersion: '2.1 ATI-2.11.20'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%
%                    model: 'MacBookPro13,2'
%         modelDescription: 'MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.15'
%                   matlab: 'MATLAB 9.5 (R2018b)'
%                   system: 'macOS 10.14.5'
%                  screens: 0
%                   screen: 0
%                     size: [? ?]
%           openGLRenderer: 'Intel(R) Iris(TM) Graphics 550'
%             openGLVendor: 'Intel Inc.'
%            openGLVersion: '2.1 INTEL-12.9.22?
% psychtoolboxKernelDriver: ''
%           drawTextPlugin: 1
%           psychPortAudio: 1
%
%                    model: 'Inspiron 5379'
%             manufacturer: 'Dell Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'Windows NT-10.0.9200'
%                  screens: 0
%
% Unavailable answers are empty ''.
%
% This is handy in testing, benchmarking, and bug reporting, to easily
% record the test environment in a compact human-readable way.
%
% If you are trying to produce a compact string, e.g. to use in a file
% name, you might do something like this:
% machine=IdentifyComputer([]);
% filename=['TestFlip-' machine.model ...
%     '-' machine.system ...
%     '-' machine.psychtoolbox '.png'];
% filename=strrep(filename,'Windows','Win');
% filename=strrep(filename,'Psychtoolbox','Psy');
% filename=strrep(filename,' ','-');
% Which produces a string like this:
% TestFlip-MacBook10,1-macOS-10.14.6-Psy-3.0.16.png
%
% In principle one might want to separately report each screen, but in
% practice there's typically no gain in doing that. In the old days one
% could plug in arbitrary video cards and have different drivers for each
% screen. Today, most of us use computers with no slots. At most we plug in
% a cable connected to an external display (or two) and thus use the same
% video driver as the built-in display (screen 0). Thus some properties,
% e.g. resolution and frame rate, can differ from screen to screen, but not
% the openGL fields we report here. If it becomes useful to report
% screen-dependent information we could drop the screen field, and change
% each of the screen-dependent fields to be a cell array.
%
% October 7, 2019, denis.pelli@nyu.edu
%
% LIMITATIONS: Works on all OSes, but, under Linux, requires root privilege
% to get model name and manufacturer.

%% HISTORY
% August 24, 2019. DGP wrote it.
% October 15, 2019 omkar.kumbhar@nyu.edu added support for linux.
if nargin<1
    windowOrScreen=0;
end
machine.model='';
machine.modelDescription=''; % Currently non-empty only for macOS.
machine.manufacturer='';
machine.psychtoolbox='';
machine.matlab='';
machine.system='';
if exist('Screen','file')
    % PsychTweak 0 suppresses some early print outs made by Screen
    % Preference Verbosity.
    PsychTweak('ScreenVerbosity',0);
    verbosity=Screen('Preference','Verbosity',0);
    machine.screens=Screen('Screens');
else
    machine.screens=[];
end
% Restore former settings.
PsychTweak('ScreenVerbosity',3);
Screen('Preference','Verbosity',verbosity);
machine.screen=0;
machine.size=[];
machine.mm=[];
if exist('Screen','file')
    resolution=Screen('Resolution',windowOrScreen);
    machine.size=[resolution.height resolution.width];
    [screenWidthMm,screenHeightMm]=Screen('DisplaySize',windowOrScreen);
    machine.mm=[screenHeightMm,screenWidthMm];
end
machine.openGLRenderer='';
machine.openGLVendor='';
machine.openGLVersion='';
if exist('PsychtoolboxVersion','file')
    [~,p]=PsychtoolboxVersion;
    machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',...
        p.major,p.minor,p.point);
end
machine.psychtoolboxKernelDriver='';
machine.drawTextPlugin=[];
machine.psychPortAudio=[];
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
    warning('MATLAB/OCTAVE too old (pre 2006) to have "ver" command.');
end
if exist('Screen','file')
    c=Screen('Computer');
    machine.system=c.system;
    if isfield(c,'hw') && isfield(c.hw,'model')
        machine.model=c.hw.model;
    end
else
    warning('Currently need Psychtoolbox to get operating system name.');
end
switch computer
    case 'MACI64'
        %% macOS
        machine.manufacturer='Apple Inc.';
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        % Whatever shell is running, we maintain compatibility by sending
        % each script to the bash shell.
        serialNumber=evalc('!bash -c ''system_profiler SPHardwareDataType'' | awk ''/Serial/ {print $4}''');
        report=evalc(['!bash -c ''curl -s https://support-sp.apple.com/sp/product?cc=' serialNumber(9:end-1) '''']);
        x=regexp(report,'<configCode>(?<description>.*)</configCode>','names');
        machine.modelDescription=x.description;
        s=machine.modelDescription;
        if length(s)<3 || ~all(isstrprop(s(1:3),'alpha'))
            machine
            shell=evalc('!echo $0') % name of current shell.
            warning(['Oops. Failed in getting modelDescription. '...
                'Please send the lines above to denis.pelli@nyu.edu: "%s"'],s);
            machine.modelDescription='';
            % http://osxdaily.com/2007/02/27/how-to-change-from-bash-to-tcsh-shell/
            % https://support.apple.com/en-us/HT208050
        end
        % A python solution: https://gist.github.com/zigg/6174270
        
    case 'PCWIN64'
        %% Windows
        wmicString=evalc('!wmic computersystem get manufacturer, model');
        % Here's a typical result:
        % wmicString=sprintf(['    ''Manufacturer  Model            \n'...
        % '     Dell Inc.     Inspiron 5379    ']);
        s=strrep(wmicString,char(10),' '); % Change to space.
        s=strrep(s,char(13),' '); % Change to space.
        s=regexprep(s,'  +',char(9)); % Change run of 2+ spaces to a tab.
        s=strrep(s,'''',''); % Remove stray quote.
        fields=split(s,char(9)); % Use tabs to split into tokens.
        fields=fields(~ismissing(fields)); % Discard empty fields.
        % The original had two columns: category and value. We've now got
        % one long column with n categories followed by n values. We asked
        % for manufacturer and model so n should be 2.
        if length(fields)==4
            n=length(fields)/2; % n names followed by n values.
            for i=1:n
                % Grab each field's name and value.
                % Lowercase name.
                fields{i}(1)=lower(fields{i}(1));
                machine.(fields{i})=fields{i+n};
            end
        end
        if ~isfield(machine,'manufacturer') ...
                || isempty(machine.manufacturer)...
                || ~isfield(machine,'model') || isempty(machine.model)
            wmicString
            warning('Failed to retrieve manufacturer and model from WMIC.');
        end
        
    case 'GLNXA64'
        %% Linux
        % Most methods for getting the computer model require root
        % privileges, which we cannot assume here. We used method 4 from:
        % https://www.2daygeek.com/how-to-check-system-hardware-manufacturer-model-and-serial-number-in-linux/
        % Tested in MATLAB under Ubuntu 18.04.
        % Written by omkar.kumbhar@nyu.edu, October 22, 2019.
        [status_version,product_version]=system("cat /sys/class/dmi/id/product_version");
        [status_name,product_name]=system("cat /sys/class/dmi/id/product_name");
        [status_board,board_vendor]=system("cat /sys/class/dmi/id/board_vendor");
        machine.manufacturer=strtrim(board_vendor);
        machine.model=strtrim(strcat(product_name," ",product_version));
end
%% Clean up the Operating System name.
while ismember(machine.system(1),{' ' '-'})
    % Strip leading separators.
    if length(machine.system)>1
        machine.system=machine.system(2:end);
    else
        machine.system='';
    end
end
while ismember(machine.system(end),{' ' '-'})
    % Strip trailing separators.
    if length(machine.system)>1
        machine.system=machine.system(1:end-1);
    else
        machine.system='';
    end
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
    if contains(result,'PsychtoolboxKernelDriver')
        % Get version number of Psychtoolbox kernel driver.
        v=regexp(result,'(?<=\().*(?=\))','match'); % find (version)
        if ~isempty(v)
            v=v{1};
        else
            v='';
            warning('Failed to get version of PsychtoolboxKernelDriver.');
        end
        machine.psychtoolboxKernelDriver=['PsychtoolboxKernelDriver ' v];
    end
end
if exist('Screen','file')
    % From the provided windowOrScreen we get a window and screen.
    window=[];
    if ismember(windowOrScreen,machine.screens)
        % It's a screen. Open a window on it.
        machine.screen=windowOrScreen;
        % Opening and closing a window takes a long time, on the order of 30 s,
        % so you may want to skip it if you don't need the openGL fields.
        fractionOfScreenUsed=0.2;
        screenBufferRect=Screen('Rect',machine.screen);
        r=round(fractionOfScreenUsed*screenBufferRect);
        r=AlignRect(r,screenBufferRect,'right','bottom');
        PsychTweak('ScreenVerbosity',0);
        verbosity=Screen('Preference','Verbosity',0);
        try
            window=Screen('OpenWindow',machine.screen,255,r);
        catch e
            warning(e.message);
            warning('Unable to open window on screen %d.',machine.screen);
        end
        Screen('Preference','Verbosity',verbosity);
    elseif Screen('WindowKind',windowOrScreen)==1
        % It's a window pointer. Get the screen number.
        machine.screen=Screen('WindowScreenNumber',windowOrScreen);
        if ~ismember(machine.screen,Screen('Screens'))
            % This occurred only with an experimental version of Screen.
            error('Could not get screen number of window.');
        end
    else
        if ~isempty(windowOrScreen)
            error(['Illegal windowOrScreen=%.0f, '...
                'should be a window pointer, '...
                'a screen number, or empty.'],windowOrScreen);
        end
    end
    if ~isempty(window)
        % Check for presence of DrawText Plugin, for best rendering.
        % Recommended by Mario Kleiner, July 2017.
        % The first 'DrawText' call should triggers loading of the plugin, but may fail.
        Screen('DrawText',window,' ',0,0,0,1,1);
        machine.drawTextPlugin=Screen('Preference','TextRenderer')>0;
        if ~machine.drawTextPlugin
            % warning('The DrawText plugin failed to load. See ''help DrawTextPlugin''.');
        end
        
        %% OpenGL DRIVER
        % Mario Kleiner suggests (1.9.2019) identifying the gpu hardware
        % and driver by the combination of GLRenderer, GLVendor, and
        % GLVersion, which are provided by
        % info=Screen('GetWindowInfo',window);
        info=Screen('GetWindowInfo',window);
        machine.openGLRenderer=info.GLRenderer;
        machine.openGLVendor=info.GLVendor;
        machine.openGLVersion=info.GLVersion;
        if windowOrScreen==machine.screen
            % If we opened the window, then close it.
            Screen('Close',window);
        end
    end
end
try
    verbosity=PsychPortAudio('Verbosity',0);
    InitializePsychSound;
    machine.psychPortAudio=true;
catch em
    fprintf('Failed to load PsychPortAudio driver, with error:\n%s\n\n',...
        em.message);
    machine.psychPortAudio=false;
end
PsychPortAudio('Verbosity',verbosity);
end % function
