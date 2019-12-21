function machine=IdentifyComputer(windowsOrScreens,modifier1,modifier2)
% machine=IdentifyComputer([windowsOrScreens,modifier1,modifier2]);
% IdentifyComputer is handy in testing, benchmarking, and bug reporting, to
% easily record the computer environment in a compact human-readable way.
% Runs on MATLAB and Octave 5.1 under macOS, Windows, and Linux, with any
% number of screens. It returns a struct with 19 fields (12 text, 5
% numerical, and 2 logical) that specify the basic configuration of your
% hardware and software with regard to compatibility. Some fields (e.g.
% bitsPlusPlus) appear only if the relevant feature is present.
% machine.modelDescription will be empty unless your computer is made by
% Apple and we have internet access. It can run without the Psychtoolbox,
% but then returns much less information.
%% OUTPUT ARGUMENT:
% "machine" is a struct with many informative fields. The screen, size,
% nativeSize, mm, and openGL fields are cell arrays, with one element per
% screen. By default, all screens are reported, but you can specify any
% subset by using the screens argument to IdentifyComputer2.
%% INPUT ARGUMENTS:
% Use the "windowsOrScreens" argument scalar or array to specify screen
% numbers or window pointers for the screens you want to test. (You can mix
% screen numbers and window pointers.) The main screen is 0, the next is 1,
% and so on. Default is all screens. [Under macOS if mirroring is enabled,
% then IdentifyComputer will think the mirrored displays are one. Mirroring
% results in very slow timing.] IdentifyComputer is quick if
% "windowsOrScreens" is empty [] or specifies screens on which windows are
% already open, and it's slow otherwise. That's because for each requested
% screen that lacks a window, IdentifyComputer has to open and close a
% window on that screen, which may take 30 s. Passing an empty
% "windowsOrScreens" argument skips opening a window, at the cost of
% leaving the screen size and openGL fields empty.
% The "modifier1" and "modifier2" arguments, if present, can be (in any
% order) the strings 'verbose', to not suppress warning messages, and/or
% 'noInternet' to prevent using the internet to access an Apple web page to
% get the modelDescription.
%
%% EXAMPLES of output struct for macOS, Windows, and Linux:
%
%                    model: 'MacBook10,1'
%         modelDescription: 'MacBook (Retina, 12-inch, 2017)'
%             manufacturer: 'Apple Inc.'
%             psychtoolbox: 'Psychtoolbox 3.0.16'
%                   matlab: 'MATLAB 9.6 (R2019a)'
%                   system: 'macOS 10.14.6'
%                screenMex: 'Screen.mexmaci64 08-Dec-2019'
%                  screens: 0
%                   screen: {[0]}
%                     size: {[2560 1600]}
%               nativeSize: {[2560 1600]}
%                       mm: {[259 161]}
%           openGLRenderer: {'Intel(R) HD Graphics 615'}
%             openGLVendor: {'Intel Inc.'}
%            openGLVersion: {'2.1 INTEL-12.10.14'}
% psychtoolboxKernelDriver: 'PsychtoolboxKernelDriver 1.1'
%           drawTextPlugin: 1
%           psychPortAudio: 1
%                  summary: 'MacBook10,1-macOS-10.14.6-PTB-3.0.16'
%
% Unavailable answers are empty. Inapplicable fields are left undefined.
% E.g. the psychtoolboxKernelDriver field appears only for macOS. The
% bitsPlusPlus field appears only if the Bits++ video hardware is detected.
%
% The machine.summary field helps you make a filename that identifies your
% configuration. For example:
% machine=IdentifyComputer([]);
% filename=['ScreenFlipTest-' machine.summary '.png'];
% produces a string like this:
% 'ScreenFlipTest-MacBook10,1-macOS-10.14.6-PTB-3.0.16.png'
%
% LIMITATIONS: 
% Needs more testing on computers with multiple screens. Currently it does
% not detect mirroring. I wish it did because mirroring will typically
% greatly slows performance, which is typically not good for experiments.
%
% denis.pelli@nyu.edu

%% HISTORY
% August 24, 2019.  DGP wrote it.
% October 15, 2019. omkar.kumbhar@nyu.edu added support for linux.
% October 28, 2019. DGP added machine.screenMex with creation date.
% October 31, 2019. DGP replaced strip by strtrim, to extend compatibility
%                   back to MATLAB 2006a. Requested by Mario Kleiner.
% November 8, 2019. DGP. Now compatible with Octave 5.1. Use "strfind"
%                   instead of "contains", which is missing in Octave. Use
%                   "switch 4*ismacos+2*iswin+islinux" instead of "switch
%                   computer" because "computer" differs between MATLAB and
%                   Octave. Use "system" instead of "evalc('!...')", which
%                   was failing in Octave. Provide format to datenum, which
%                   otherwise fails in Octave.
% November 18, 2019. DGP. New argument 'noInternet' to prevent use of
%                   the internet to look up the modelDescription.
if nargin<2
    modifier1='';
end
if nargin<3
    modifier2='';
end
verbose=false;
useInternet=true;
switch lower(modifier1)
    case 'verbose'
        verbose=true;
    case lower('noInternet')
        useInternet=false;
    case ''
    otherwise
        error('Illegal argument ''%s''. Must be ''verbose'' or ''noInternet''.',modifier1);
end
switch lower(modifier2)
    case 'verbose'
        verbose=true;
    case lower('noInternet')
        useInternet=false;
    case ''
    otherwise
        error('Illegal argument ''%s''. Must be ''verbose'' or ''noInternet''.',modifier2);
end
ismacos=ismac;
iswin=ispc;
if exist('PsychtoolboxVersion','file')
    islinux=IsLinux;
    isoctave=IsOctave;
else
    % For clarity, MATLAB recommends "contains" instead of
    % "~isempty(strfind(...))", but it's not available in Octave.
    islinux=ismember(computer,{'GLNX86' 'GLNXA64'}) ...
        || ~isempty(strfind(computer,'linux-gnu'));
    isoctave=ismember(exist('OCTAVE_VERSION','builtin'),[102 5]);
end
machine.model='';
machine.modelDescription=''; % Currently non-empty only for Apple hardware.
machine.manufacturer='';
machine.psychtoolbox='';
machine.matlab='';
machine.system='';
if exist('Screen','file')
    s=which('Screen');
    d=dir(s);
    v=Screen('version');
    dt=strrep(v.date,'  ',' ');
    machine.screenMex=[d.name ' ' dt];
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
    physicalScreens=Screen('Screens',1);
    if length(machine.screens)~=physicalScreens
        fprintf('Unequal numbers of logical and physical screens. Guessing that you''re mirroring.\n');
        machine.mirroring=true;
    end
    % Restore former settings.
    if ~verbose
        PsychTweak('ScreenVerbosity',3);
        Screen('Preference','Verbosity',verbosity);
    end
end
if nargin<1
    windowsOrScreens=machine.screens;
end
% ALLOCATE VARIABLES; SET VALUES LATER.
machine.screen=num2cell(windowsOrScreens);
machine.size=cell(size(windowsOrScreens));
machine.nativeSize=cell(size(windowsOrScreens));
machine.mm=cell(size(windowsOrScreens));
if exist('PsychtoolboxVersion','file') && ~isempty(windowsOrScreens)
    for iScreen=1:length(windowsOrScreens)
		if ~ismember(windowsOrScreens(iScreen),machine.screens) ...
		&& Screen('WindowKind',windowsOrScreens(iScreen))~=1
			error(['Invalid windowsOrScreens(' num2str(iScreen) ') ' num2str(windowsOrScreens((iScreen))) '.']);
		end
        resolution=Screen('Resolution',windowsOrScreens(iScreen));
        machine.size{iScreen}=[resolution.width resolution.height];
        [screenWidthMm,screenHeightMm]=Screen('DisplaySize',windowsOrScreens(iScreen));
        machine.mm{iScreen}=[screenWidthMm screenHeightMm];
        res=Screen('Resolutions',windowsOrScreens(iScreen));
        machine.nativeSize{iScreen}=[0 0];
        for i=1:length(res)
            if res(i).width>machine.nativeSize{iScreen}(1)
                machine.nativeSize{iScreen}=[res(i).width res(i).height];
            end
        end
    end
end
machine.openGLRenderer=cell(size(windowsOrScreens));
machine.openGLVendor=cell(size(windowsOrScreens));
machine.openGLVersion=cell(size(windowsOrScreens));
for iScreen=1:length(windowsOrScreens)
    machine.openGLRenderer{iScreen}='';
    machine.openGLVendor{iScreen}='';
    machine.openGLVersion{iScreen}='';
end
if exist('PsychtoolboxVersion','file')
    [~,p]=PsychtoolboxVersion;
    machine.psychtoolbox=sprintf('Psychtoolbox %d.%d.%d',...
        p.major,p.minor,p.point);
end
if ismacos
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
switch 4*ismacos+2*iswin+islinux
    case 4
        %% macOS
        machine.manufacturer='Apple Inc.';
        % Whatever shell is running, we maintain compatibility by sending
        % each script to the bash shell.
        [~,serialNumber]=system(...
            'bash -c ''system_profiler SPHardwareDataType'' | awk ''/Serial/ {print $4}''');
        if useInternet
            machine.modelDescription=GetAppleModelDescription(serialNumber);
        end
        
    case 2
        %% Windows
        [~,wmicString]=system(...
            'wmic computersystem get manufacturer, model');
        % Here's a typical result:
        % wmicString=sprintf(['    ''Manufacturer  Model            \n'...
        % '     Dell Inc.     Inspiron 5379    ']);
        % MATLAB recommends "newline" instead of char(10), but I've had
        % problems with "newline" being undefined. That doesn't make sense,
        % but it's not worth fighting since char(10) works fine.
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
        
    case 1
        %% Linux
        % Most methods for getting the computer model require root
        % privileges, which we cannot assume here. We use method 4 from:
        % https://www.2daygeek.com/how-to-check-system-hardware-manufacturer-model-and-serial-number-in-linux/
        % Tested in MATLAB under Ubuntu 18.04.
        % Written by omkar.kumbhar@nyu.edu, October 22, 2019.
        [~,productVersion]=system('cat /sys/class/dmi/id/product_version');
        [~,productName]=system('cat /sys/class/dmi/id/product_name');
        [~,boardVendor]=system('cat /sys/class/dmi/id/board_vendor');
        machine.manufacturer=strtrim(boardVendor);
        machine.model=[strtrim(productName) ' ' strtrim(productVersion)];
        try
        	% This fails if we lack root priviledges.
        	[~,serialNumber]=system('cat /sys/class/dmi/id/product_serial');
        catch me
        	serialNumber='';
        end
        if useInternet && ismember(machine.manufacturer,{'Apple Inc.'}) ...
                && ~isempty(serialNumber)
            machine.modelDescription=GetAppleModelDescription(serialNumber);
        end
    otherwise
        error('Unknown OS %d.',4*ismacos+2*iswin+islinux);
end
% Clean up the Operating System name.
machine.system=strtrim(machine.system);
if ~isempty(machine.system) && machine.system(end)=='-'
    machine.system=machine.system(1:end-1);
end
% Modernize spelling.
machine.system=strrep(machine.system,'Mac OS','macOS');
if iswin
    % Prepend "Windows".
    if ~all('win'==lower(machine.system(1:3)))
        machine.system=['Windows ' machine.system];
    end
end

%% PSYCHTOOLBOX KERNEL DRIVER
% http://psychtoolbox.org/docs/psychtoolboxKernelDriver';
if ismacos
    machine.psychtoolboxKernelDriver='';
    [~,result]=system('kextstat -l -b PsychtoolboxKernelDriver');
    % MATLAB recommends "contains", but Octave doesn't provide it.
    if ~isempty(strfind(result,'PsychtoolboxKernelDriver'))
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
if exist('PsychtoolboxVersion','file') && ~isempty(windowsOrScreens)
    for iScreen=1:length(windowsOrScreens)
		% For each windowsOrScreens we find both the screen and a
		% window on that screen. If there's no window open, we open one.
		window=[];
		isNewWindow=false;
		if ismember(windowsOrScreens(iScreen),machine.screens)
			% It's a screen. We need a window on it.
			machine.screen{iScreen}=windowsOrScreens(iScreen);
			% Try to find a window already open on the specified screen.
			windows=Screen('Windows');
			for i=1:length(windows)
				if machine.screen{iScreen}==Screen('WindowScreenNumber',windows(i))
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
				if islinux
					% This is safer, because one user reported a fatal error when
					% attempting to open a less-than-full-screen window under
					% Linux.
					fractionOfScreenUsed=1;
				else
					% This is much less disturbing to watch.
					fractionOfScreenUsed=0.2;
				end
				screenBufferRect=Screen('Rect',machine.screen{iScreen});
				r=round(fractionOfScreenUsed*screenBufferRect);
				r=AlignRect(r,screenBufferRect,'right','bottom');
                % screen=machine.screen{iScreen}
                % screenBufferRect
                % r
                % globalRect=Screen('GlobalRect',machine.screen{iScreen})
				if ~verbose
					PsychTweak('ScreenVerbosity',0);
					verbosity=Screen('Preference','Verbosity',0);
				end
				try
					Screen('Preference','SkipSyncTests',1);
					window=Screen('OpenWindow',machine.screen{iScreen},255,r);
					isNewWindow=true;
				catch em
					warning(em.message);
					warning('Unable to open window on screen %d.',...
						machine.screen{iScreen});
				end
				if ~verbose
					Screen('Preference','Verbosity',verbosity);
				end
			end
		elseif Screen('WindowKind',windowsOrScreens(iScreen))==1
			% It's a window pointer. Get the screen number.
			window=windowsOrScreens(iScreen);
			machine.screen{iScreen}=Screen('WindowScreenNumber',window);
			if ~ismember(machine.screen{iScreen},Screen('Screens'))
				% This failed only with an experimental version of Screen.
				error('Could not get screen number of window pointer.');
			end
		else
			if ~isempty(windowsOrScreens)
				error(['Illegal windowsOrScreens [' num2str(windowsOrScreens) '], '...
					'should be an array of window pointers '...
					'and/or screen numbers, or empty.']);
			end
		end
        if ~isempty(window)
            %% OpenGL DRIVER
            % Mario Kleiner suggests (1.9.2019) identifying the gpu
            % hardware and driver by the combination of GLRenderer,
            % GLVendor, and GLVersion, which are provided by
            % Screen('GetWindowInfo',window).
            info=Screen('GetWindowInfo',window);
            machine.openGLRenderer{iScreen}=info.GLRenderer;
            machine.openGLVendor{iScreen}=info.GLVendor;
            machine.openGLVersion{iScreen}=info.GLVersion;

        	%% DRAWTEXT PLUGIN
            if isempty(machine.drawTextPlugin)
                % Check for presence of DrawText Plugin, for best
                % rendering. The first 'DrawText' call should trigger
                % loading of the plugin, but may fail. Recommended by Mario
                % Kleiner, July 2017.
                Screen('DrawText',window,' ',0,0,0,1,1);
                machine.drawTextPlugin=...
                    Screen('Preference','TextRenderer')>0;
            end
            
            %% CLOSE WINDOW
            if isNewWindow
                % If we opened the window, then close it.
                Screen('Close',window);
            end
        end
    end % for iScreen=1:length(windowsOrScreens)
end % if exist('PsychtoolboxVersion','file') && ~isempty(windowsOrScreens)
if exist('PsychtoolboxVersion','file')
    if ~verbose
        verbosity=PsychPortAudio('Verbosity',0);
    end
    try
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
            configurationFile=fullfile('~','Library','Preferences',...
                'Psychtoolbox','BitsSharpConfig.txt');
            if exist(configurationFile,'file')==2
                machine.bitsPlusPlus='bits#';
            else
                machine.bitsPlusPlus='bits++';
            end
            break
        end
    end
end
%% Produce summary string useful in a filename.
machine.summary=[machine.model '-' machine.system '-' machine.psychtoolbox];
machine.summary=strrep(machine.summary,'--','-');
if machine.summary(1)=='-'
    machine.summary=machine.summary(2:end);
end
if ~isempty(machine.summary) && machine.summary(end)=='-'
    machine.summary=machine.summary(1:end-1);
end
machine.summary=strrep(machine.summary,'Windows','Win');
machine.summary=strrep(machine.summary,'Psychtoolbox','PTB');
machine.summary=strrep(machine.summary,' ','-');
if isempty(machine.summary)
    machine.summary='';
end
end % function IdentifyComputer

function creationDatenum=GetFileCreationDatenum(filePath)
% Try to get the file's creation date.
ismacos=ismac;
iswin=ispc;
if exist('PsychtoolboxVersion','file')
    islinux=IsLinux;
else
    % MATLAB recommends calling "contains" instead of "~isempty(strfind(",
    % but it's not available in Octave.
    islinux=ismember(computer,{'GLNX86' 'GLNXA64'}) ...
        || ~isempty(strfind(computer,'linux-gnu'));
end
switch 4*ismacos+2*iswin+islinux
    case 4
        %% macOS
        [~,b]=system(sprintf('GetFileInfo "%s"',filePath));
        filePath=strfind(b,'created: ')+9;
        crdat=b(filePath:filePath+18);
        % In Octave, datenum fails without the explicit format.
        creationDatenum=datenum(crdat,'mm/dd/yyyy HH:MM:SS');
    case 2
        %% Windows
        % https://www.mathworks.com/matlabcentral/answers/288339-how-to-get-creation-date-of-files
        d=System.IO.File.GetCreationTime(filePath);
        % Convert the .NET DateTime d into a MATLAB datenum.
        creationDatenum=datenum(datetime(...
            d.Year,d.Month,d.Day,d.Hour,d.Minute,d.Second));
    case 1
        %% Linux
        % Alas, depending on the file system used, Linux typically does not
        % retain the creation date.
        creationDatenum='';
    otherwise
        error('Unknown OS.');
end % switch
end % function GetFileCreationDatenum

function modelDescription=GetAppleModelDescription(serialNumber)
% This uses the internet to enter the last four characters of our
% 12-character serial number into an Apple web page to get a model
% description of our Apple computer. Returns '' if the serial number is not
% in Apple's database, or we lack internet access. Currently we get the
% error code if the lookup fails, but we don't report it.
% https://apple.stackexchange.com/questions/98080/can-a-macs-model-year-be-determined-with-a-terminal-command/98089
% A version of this in python: https://gist.github.com/zigg/6174270
if nargin<1
    error('Input argument string "serialNumber" is required.');
end
if length(serialNumber)<11
    error('serialNumber string must be more than 10 characters long.');
end
[~,report]=system(...
    ['bash -c ''curl -s https://support-sp.apple.com/sp/product?cc=' ...
    serialNumber(9:end-1) '''']);
x=regexp(report,'<configCode>(?<description>.*)</configCode>','names');
if isempty(x)
    if isempty(err)
        % warning(['Apple serial number lookup failed, '...
        % 'possibly because of no internet access.']);
    else
        % Probably tried to look up a non-Apple product.
        warning('Apple serial number lookup failed with error ''%s''.',...
            err.error);
    end
    modelDescription='';
else
    modelDescription=x.description;
    s=modelDescription;
    if length(s)<3 || ~all(isstrprop(s(1:3),'alpha'))
        [~,shell]=system('echo $0') % Display shell name.
        warning(['Oops. Failed in getting modelDescription. '...
            'Please send this line and those above to denis.pelli@nyu.edu: "%s"'],s);
        modelDescription='';
        % http://osxdaily.com/2007/02/27/how-to-change-from-bash-to-tcsh-shell/
        % https://support.apple.com/en-us/HT208050
    end
end
end % function GetAppleModelDescription