function machine=IdentifyComputer(windowOrScreen,verbose)
% machine=IdentifyComputer([windowOrScreen,verbose]);
% IdentifyComputer is handy in testing, benchmarking, and bug reporting, to
% easily record the computer environment in a compact human-readable way.
% Runs on MATLAB and Octave under macOS, Windows, and Linux, with any
% number of screens. It returns a struct with 19 fields (12 text, 5
% numerical, and 2 logical) that specify the basic configuration of your
% hardware and software with regard to compatibility. Some fields (e.g.
% bitsPlusPlus) appear only if the relevant feature is present.
% machine.modelDescription will be empty unless your computer is made by
% Apple and we have internet access.
%% OUTPUT ARGUMENT:
% "machine" is a struct with many informative fields. The size, nativeSize,
% mm, and openGL fields refer to the screen with the number specified by
% the "screen" field.
%% INPUT ARGUMENTS:
% Use the "windowOrScreen" argument to specify a window pointer or the
% screen number. Default is screen 0, the main screen. This routine is
% quick if windowOrScreen is empty [], or points to an open window, or
% specifies a screen on which a window is already open, and it's slow
% otherwise. That's because if you provide a screen number (or use the
% default screen 0) without a window then it has to open and close a
% window, which may take 30 s. Passing an empty windowOrScreen skips
% opening a window, at the cost of leaving the screen size and openGL
% fields empty. The second argument, if present, should be the string
% 'verbose', to not suppress warning messages.
%
%% EXAMPLES of output struct for macOS, Windows, and Linux:
%
%                   model: 'iMac15,1'
%         modelDescription: 'iMac (Retina 5K, 27-inch, Late 2014)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                screenMex: 'Screen.mexmaci64 07-Aug-2019'
%                  screens: 0
%                   screen: 0
%                     size: [1800 3200]
%               nativeSize: [2880 5120]
%                       mm: [341 602]
%           openGLRenderer: 'AMD Radeon R9 M290X OpenGL Engine'
%             openGLVendor: 'ATI Technologies Inc.'
%            openGLVersion: '2.1 ATI-2.11.21'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%                  summary: 'iMac15,1-macOS-10.14.6-PTB-3.0.16'
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
%               nativeSize: [1600 2560]
%                       mm: [161 258]
%           openGLRenderer: 'Intel(R) HD Graphics 615'
%             openGLVendor: 'Intel Inc.'
%            openGLVersion: '2.1 INTEL-12.10.12'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%                  summary: 'MacBook10,1-macOS-10.14.6-PTB-3.0.16'
%
%                    model: 'MacBookPro14,3'
%         modelDescription: 'MacBook Pro (15-inch, 2017)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                screenMex: 'Screen.mexmaci64 21-Oct-2019'
%                  screens: 0
%                   screen: 0
%                     size: [2100 3360]
%               nativeSize: [2100 3360]
%                       mm: [206 330]
%           openGLRenderer: 'AMD Radeon Pro 560 OpenGL Engine'
%             openGLVendor: 'ATI Technologies Inc.'
%            openGLVersion: '2.1 ATI-2.11.20'
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%                  summary: 'MacBookPro14,3-macOS-10.14.6-PTB-3.0.16'
%
%                    model: 'MacBookPro13,2'
%         modelDescription: 'MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.15'
%                   matlab: 'MATLAB 9.5 (R2018b)'
%                   system: 'macOS 10.14.5'
%                  screens: 0
%                   screen: 0
%                     size: []
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
%                    model: '80WK Lenovo Y520-15IKBN'
%         modelDescription: ''
%             manufacturer: 'LENOVO'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'Linux 4.15.0-65-generic'
%                  screens: 0
%                   screen: 0
%                     size: [1080 1920]
%               nativeSize: []
%                       mm: [286 508]
%           openGLRenderer: 'GeForce GTX 1050 Ti/PCIe/SSE2'
%             openGLVendor: 'NVIDIA Corporation'
%            openGLVersion: '4.6.0 NVIDIA 396.54'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%
%                    model: 'MacBookPro9,2 1.0'
%         modelDescription: ''
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.15'
%                   matlab: 'MATLAB 9.5 (R2018b)'
%                   system: 'Linux 5.2.0-3-amd64'
%                screenMex: 'Screen.mexa64 21-Sep-2019'
%                  screens: 0
%                   screen: 0
%                     size: [1920.00 2480.00]
%               nativeSize: [800.00 1280.00]
%                       mm: [504.00 651.00]
%           openGLRenderer: 'Mesa DRI Intel(R) Ivybridge Mobile '
%             openGLVendor: 'Intel Open Source Technology Center'
%            openGLVersion: '3.0 Mesa 19.2.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%                  summary: 'MacBookPro9,2-1.0-Linux-5.2.0-3-amd64-PTB-3.0.15'
%
% Unavailable answers are '' or []. The psychtoolboxKernelDriver field
% appears only for macOS. The bitsPlusPlus field appears only if the Bits++
% video hardware is detected.
%
% The machine.summary field helps you make a filename that identifies your
% configuration. For example:
% machine=IdentifyComputer([]);
% filename=['ScreenFlipTest-' machine.summary '.png'];
% produces a string like this:
% ScreenFlipTest-MacBook10,1-macOS-10.14.6-PTB-3.0.16.png
%
% JUST ONE SCREEN. In principle, one might want to separately report the
% openGL driver info for each screen, but, in practice, there's typically
% no gain in doing that. In the old days one could plug in arbitrary video
% cards and have different drivers for each screen. Today, most of us use
% computers with no slots. At most we plug in a cable connected to an
% external display (or two) and thus use the same video driver on all
% screens. Thus some properties, e.g. resolution and frame rate, can differ
% from screen to screen, but not the openGL fields we report here. If it
% becomes useful to report screen-dependent information we could drop the
% screen field, and change each of the screen-dependent fields to be a cell
% array.
%
% LIMITATIONS: needs more testing on computers with multiple screens.
%
% denis.pelli@nyu.edu

%% HISTORY
% August 24, 2019. DGP wrote it.
% October 15, 2019. omkar.kumbhar@nyu.edu added support for linux.
% October 28, 2019. DGP added machine.screenMex with creation date.
% October 31, 2019. DGP replaced strip by strtrim, to extend compatibility
%                      back to MATLAB 2006a. Requested by Mario Kleiner.
if nargin<1
    windowOrScreen=0;
end
if nargin<2
    verbose=false;
else
    if ismember(verbose,{'verbose'})
        verbose=true;
    else
        error('Second argument, if present, must be the string ''verbose''');
    end
end
machine.model='';
machine.modelDescription=''; % Currently non-empty only for macOS.
machine.manufacturer='';
machine.psychtoolbox='';
machine.matlab='';
machine.system='';
if exist('PsychtoolboxVersion','file')
    s=which('Screen');
    d=dir(s);
    creationDatenum=GetFileCreationDatenum(s);
    if isempty(creationDatenum)
        % If creation date is not available (common under Linux) then fall
        % back on modification date, which is always available.
        creationDatenum=d.datenum; % File modification date.
    end
    machine.screenMex=[d.name ' ' datestr(creationDatenum,'dd-mmm-yyyy')];
end
machine.screens=[];
if exist('PsychtoolboxVersion','file')
    % PsychTweak 0 suppresses some early printouts made by Screen
    % Preference Verbosity.
    if ~verbose
        PsychTweak('ScreenVerbosity',0);
        verbosity=Screen('Preference','Verbosity',0);
    end
    machine.screens=Screen('Screens');
    % Restore former settings.
    if ~verbose
        PsychTweak('ScreenVerbosity',3);
        Screen('Preference','Verbosity',verbosity);
    end
end
machine.screen=0;
machine.size=[];
machine.nativeSize=[];
machine.mm=[];
if exist('PsychtoolboxVersion','file') && ~isempty(windowOrScreen)
    if ~ismember(windowOrScreen,machine.screens) && Screen('WindowKind',windowOrScreen)~=1
        error('Invalid windowOrScreeen.');
    end
    resolution=Screen('Resolution',windowOrScreen);
    machine.size=[resolution.height resolution.width];
    [screenWidthMm,screenHeightMm]=Screen('DisplaySize',windowOrScreen);
    machine.mm=[screenHeightMm,screenWidthMm];
    res=Screen('Resolutions',machine.screen);
    machine.nativeSize=[0 0];
    for i=1:length(res)
        if res(i).width>machine.nativeSize(2)
            machine.nativeSize=[res(i).height res(i).width];
        end
    end
end
machine.openGLRenderer='';
machine.openGLVendor='';
machine.openGLVersion='';
if exist('PsychtoolboxVersion','file')
    [~,p]=PsychtoolboxVersion;
    machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',...
        p.major,p.minor,p.point);
end
if ismac
    machine.psychtoolboxKernelDriver='';
end
machine.drawTextPlugin=logical([]);
machine.psychPortAudio=logical([]);
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
if exist('PsychtoolboxVersion','file')
    c=Screen('Computer');
    machine.system=c.system;
    if isfield(c,'hw') && isfield(c.hw,'model')
        machine.model=c.hw.model;
    end
end
%% For each OS, get computer model and manufacturer.
switch computer
    case 'MACI64'
        %% macOS
        machine.manufacturer='Apple Inc.';
        % https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
        % Whatever shell is running, we maintain compatibility by sending
        % each script to the bash shell.
        serialNumber=evalc('!bash -c ''system_profiler SPHardwareDataType'' | awk ''/Serial/ {print $4}''');
        machine.modelDescription=GetAppleModelDescription(serialNumber);
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
        % privileges, which we cannot assume here. We use method 4 from:
        % https://www.2daygeek.com/how-to-check-system-hardware-manufacturer-model-and-serial-number-in-linux/
        % Tested in MATLAB under Ubuntu 18.04.
        % Written by omkar.kumbhar@nyu.edu, October 22, 2019.
        % Now get serialNumber (thanks Hormet Yiltiz) to look up Apple
        % modelDescription.
        
        [statusVersion,productVersion]=system('cat /sys/class/dmi/id/product_version');
        [statusName,productName]=system('cat /sys/class/dmi/id/product_name');
        [statusBoard,boardVendor]=system('cat /sys/class/dmi/id/board_vendor');
        machine.manufacturer=strtrim(boardVendor);
        machine.model=[strtrim(productName) ' ' strtrim(productVersion)];
        [statusSerial,serialNumber]=system('cat /sys/class/dmi/id/product_serial');
        if ismember(machine.manufacturer,{'Apple Inc.'})
            machine.modelDescription=GetAppleModelDescription(serialNumber);
        end
end
% Clean up the Operating System name.
machine.system=strtrim(machine.system);
if ~isempty(machine.system) && machine.system(end)=='-'
    machine.system=machine.system(1:end-1);
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
if ismac
    machine.psychtoolboxKernelDriver='';
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
if exist('PsychtoolboxVersion','file') && ~isempty(windowOrScreen)
    % From the provided windowOrScreen we find both the screen and a
    % window on that screen. If there's no window open, we open one.
    window=[];
    isNewWindow=false;
    if ismember(windowOrScreen,machine.screens)
        % It's a screen. We need a window on it.
        machine.screen=windowOrScreen;
        % Try to find a window already open on the specified screen.
        windows=Screen('Windows');
        for i=1:length(windows)
            if machine.screen==Screen('WindowScreenNumber',windows(i))
                % This window is on specified screen.
                if Screen('WindowKind',windows(i))==1
                    % This window belongs to Psychtoolbox, so use it.
                    window=windows(i);
                    break
                end
            end
        end
        if isempty(window)
            % Opening and closing a window takes a long time, on the order
            % of 30 s, so you may want to skip that, by passing an empty
            % argument [], if you don't need the openGL fields.
            if IsLinux
                % This is safer, because one user reported a fatal error when
                % attempting to open a less-than-full-screen window under
                % Linux.
                fractionOfScreenUsed=1;
            else
                % This is much less disturbing to watch.
                fractionOfScreenUsed=0.2;
            end
            screenBufferRect=Screen('Rect',machine.screen);
            r=round(fractionOfScreenUsed*screenBufferRect);
            r=AlignRect(r,screenBufferRect,'right','bottom');
            if ~verbose
                PsychTweak('ScreenVerbosity',0);
                verbosity=Screen('Preference','Verbosity',0);
            end
            try
                Screen('Preference','SkipSyncTests',1);
                window=Screen('OpenWindow',machine.screen,255,r);
                isNewWindow=true;
            catch em
                warning(em.message);
                warning('Unable to open window on screen %d.',...
                    machine.screen);
            end
            if ~verbose
                Screen('Preference','Verbosity',verbosity);
            end
        end
    elseif Screen('WindowKind',windowOrScreen)==1
        % It's a window pointer. Get the screen number.
        window=windowOrScreen;
        machine.screen=Screen('WindowScreenNumber',window);
        if ~ismember(machine.screen,Screen('Screens'))
            % This failed only with an experimental version of Screen.
            error('Could not get screen number of window pointer.');
        end
    else
        if ~isempty(windowOrScreen)
            error(['Illegal windowOrScreen=%.0f, '...
                'should be a window pointer, '...
                'a screen number, or empty.'],windowOrScreen);
        end
    end
    if ~isempty(window)
        %% OpenGL DRIVER
        % Mario Kleiner suggests (1.9.2019) identifying the gpu hardware
        % and driver by the combination of GLRenderer, GLVendor, and
        % GLVersion, which are provided by Screen('GetWindowInfo',window).
        info=Screen('GetWindowInfo',window);
        machine.openGLRenderer=info.GLRenderer;
        machine.openGLVendor=info.GLVendor;
        machine.openGLVersion=info.GLVersion;
        
        %% DRAWTEXT PLUGIN
        % Check for presence of DrawText Plugin, for best rendering. The
        % first 'DrawText' call should trigger loading of the plugin, but
        % may fail. Recommended by Mario Kleiner, July 2017.
        Screen('DrawText',window,' ',0,0,0,1,1);
        machine.drawTextPlugin=Screen('Preference','TextRenderer')>0;
        
        %% CLOSE WINDOW
        if isNewWindow
            % If we opened the window, then close it.
            Screen('Close',window);
        end
    end
end % if exist('PsychtoolboxVersion','file') && ~isempty(windowOrScreen)
if exist('PsychtoolboxVersion','file')
    try
        if ~verbose
            verbosity=PsychPortAudio('Verbosity',0);
        end
        InitializePsychSound;
        machine.psychPortAudio=true;
    catch em
        warning('Failed to load PsychPortAudio driver, with error:\n%s\n\n',...
            em.message);
        machine.psychPortAudio=false;
    end
    if ~verbose
        PsychPortAudio('Verbosity',verbosity);
    end
end
if exist('PsychtoolboxVersion','file')
    % Look for Bits++ video interface.
    % Based on code provided by Rob Lee at Cambridge Research Systems Ltd.
    list=PsychHID('Devices');
    for k=1:length(list)
        if strcmp(list(k).product,'BITS++')
            machine.bitsPlusPlus=true;
            break
        end
    end
    h=BitsPlusPlus('OpenBits#');
    if h~=0
        % CAUTION: This will fail to notice your Bits# device if it's
        % already open. Does anyone know a polite way to detect that case?
        % Closing the user's device would be rude.
        machine.bitsSharp=true;
        BitsPlusPlus('Close',h);
    end
end
%% Produce summary string useful in a filename.
machine.summary=[machine.model '-' machine.system '-' machine.psychtoolbox];
machine.summary=strrep(machine.summary,'Windows','Win');
machine.summary=strrep(machine.summary,'Psychtoolbox','PTB');
machine.summary=strrep(machine.summary,' ','-');
end % function

function creationDatenum=GetFileCreationDatenum(filePath)
% Get the file's creation date.
switch computer
    case 'MACI64'
        %% macOS
        [~,b]=system(sprintf('GetFileInfo "%s"',filePath));
        filePath=strfind(b,'created: ')+9;
        crdat=b(filePath:filePath+18);
        creationDatenum=datenum(crdat);
    case 'PCWIN64'
        %% Windows
        % https://www.mathworks.com/matlabcentral/answers/288339-how-to-get-creation-date-of-files
        d=System.IO.File.GetCreationTime(filePath);
        % Convert the .NET DateTime d into a MATLAB datenum.
        creationDatenum=datenum(datetime(d.Year,d.Month,d.Day,d.Hour,d.Minute,d.Second));
    case 'GLNXA64'
        %% Linux
        % Alas, depending on the file system used, Linux typically does not
        % retain the creation date.
        creationDatenum='';
end % switch
end % function IdentifyComputer

function modelDescription=GetAppleModelDescription(serialNumber)
% This uses the internet to enter our serial number into an Apple web page
% to get a model description of our Apple computer. Returns '' if the
% serial number is not in Apple's database, or we lack internet access.
% Currently we get the error code if the lookup fails, but we don't report
% it.
if nargin<1
    error('Input argument string "serialNumber" is required.');
end
if length(serialNumber)<11
    error('serialNumber string must be more than 10 characters long.');
end
report=evalc(['!bash -c ''curl -s https://support-sp.apple.com/sp/product?cc=' serialNumber(9:end-1) '''']);
x=regexp(report,'<configCode>(?<description>.*)</configCode>','names');
if isempty(x)
    if isempty(err)
        % warning('Apple serial number lookup failed, possibly because of no internet access.');
    else
        % Probably tried to look up a non-Apple product.
        warning('Apple serial number lookup failed with error ''%s''.',err.error);
    end
    modelDescription='';
else
    modelDescription=x.description;
    s=modelDescription;
    if length(s)<3 || ~all(isstrprop(s(1:3),'alpha'))
        shell=evalc('!echo $0') % name of current shell.
        warning(['Oops. Failed in getting modelDescription. '...
            'Please send the lines above to denis.pelli@nyu.edu: "%s"'],s);
        modelDescription='';
        % http://osxdaily.com/2007/02/27/how-to-change-from-bash-to-tcsh-shell/
        % https://support.apple.com/en-us/HT208050
    end
end
end % function GetAppleModelDescription