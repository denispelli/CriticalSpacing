function InstallationCheck(screen)
% InstallationCheck(screen);
% Are this computer and screen ready to run CriticalSpacing and
% NoiseDiscrimination?
global window
window=[];
clear Snd % Clear persistent variables in Snd.
% clear PsychPortAudio % A mex file.
clear o test
if nargin<1
    o.screen=0;
else
    o.screen=screen;
end
o.useFractionOfScreenToDebug=0.3;
o.clutMapLength=2048; % enough for 11-bit precision.
o.enableClutMapping=true; % Required. Using software CLUT.
o.useNative10Bit=false;
o.useNative11Bit=true;
o.screenVerbosity=0; % 0 for no messages, 1 for critical, 2 for warnings, 3 default
% See https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-Control-Verbosity-and-Debugging
o.textSize=40;

%% FILES
mainFolder=fileparts(fileparts(mfilename('fullpath')));
if ~exist('TextSizeToFit','file') && ...
        ~exist([mainFolder filesep 'lib' filesep 'TextSizeToFit.m'],'file')
    error(['Please run me from the "utility" folder in '...
    'NoiseDiscrimination or CriticalSpacing.  That allows me to find other '...
    'routines in the corresponding "lib" folder.']);
end
addpath(fullfile(mainFolder,'lib')); % "lib" folder in same directory as this file
addpath(fullfile(mainFolder,'utilities')); % "lib" folder in same directory as this file

rng('shuffle'); % Use time to seed the random number generator. TAKES 0.01 s.
plusMinusChar=char(177); % Use this instead of literal plus minus sign to
% prevent corruption of this non-ASCII character. MATLAB can print
% non-ASCII chars, but currently the text files are just 8 bits, by
% default.
escapeChar=char(27);
graveAccentChar='`';
returnChar=char(13);
spaceChar=' ';
% Keycodes are used when we call GetKeypress or any other function based on
% KbCheck. We use these keycode lists in preparing a list of keys to
% enable. For some characters, e.g. "1", there may be several ways to type
% it (main keyboard or numeric keypad), and several corresponding keyCodes.
KbName('UnifyKeyNames');
escapeKeyCode=KbName('escape');
graveAccentKeyCode=KbName('`~');
spaceKeyCode=KbName('space');
returnKeyCode=KbName('return');
numberKeyCodes=KbName({'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ...
    '0)' '1!' '2@' '3#' '4$' '5%' '6^' '7&' '8*' '9(' ...
    });
letterKeyCodes=KbName({'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm'...
    'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'});
letterNumberKeyCodes=[letterKeyCodes numberKeyCodes];
letterNumberChars=KbName(letterNumberKeyCodes);
letterNumberCharString='';
for i=1:length(letterNumberChars)
    % Take only the first character of each key name.
    letterNumberCharString(i)=letterNumberChars{i}(1);
end

%% OnCleanup
% Once we call onCleanup, when this program terminates,
% CloseWindowsAndCleanup will run  and close any open windows. It runs when
% this function terminates for any reason, whether by returning normally,
% the posting of an error here or in any function called from here, or the
% user hitting control-C.
cleanup=onCleanup(@() CloseWindowsAndCleanup);

%% SCREEN PARAMETERS
Screen('Preference','Verbosity',o.screenVerbosity);
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',o.screen);
screenBufferRect=Screen('Rect',o.screen);
o.screenRect=Screen('Rect',o.screen,1);
resolution=Screen('Resolution',o.screen);
if o.useFractionOfScreenToDebug
    o.screenRect=round(o.useFractionOfScreenToDebug*o.screenRect);
end
o.stimulusRect=o.screenRect; % Initialize to full screen. Restrict later.
if o.enableClutMapping % How we use LoadNormalizedGammaTable
    loadOnNextFlip=2; % Load software CLUT at flip.
else
    loadOnNextFlip=true; % Load hardware CLUT: 0. now; 1. on flip.
end
if contains(mainFolder,'NoiseDiscrimination')
    %% GET SCREEN CALIBRATION cal
    cal=OurScreenCalibrations(o.screen);
    cal.clutMapLength=o.clutMapLength;
    if isfield(cal,'gamma')
        cal=rmfield(cal,'gamma');
    end
    if cal.screen>0
        fprintf('Using external monitor.\n');
    end
    if streq(cal.datestr,'none') || isempty(cal.datestr) || ~isfield(cal,'old') || ~isfield(cal.old,'L')
        warning('Your screen is uncalibrated. Use NoiseDiscrimination/utilities/CalibrateScreenLuminance to calibrate it.');
    end
else
    cal=struct('screen',0);
end
if ~isfield(cal,'datestr') || streq(cal.datestr,'none') || isempty(cal.datestr)
    computer=Screen('Computer');
    if isfield(computer,'processUserLongName')
        cal.processUserLongName=computer.processUserLongName;
    else
        cal.processUserLongName='';
    end
    if ~isfield(computer,'localHostName')
        cal.localHostName='';
    else
        cal.localHostName=computer.localHostName;
    end
    if ismac
        cal.macModelName=MacModelName;
    else
        cal.macModelName='Not-a-mac';
    end
    cal.calibratedBy='';
    cal.datestr='';
    cal.notes='';
end
% Check the global "window" pointer and clear it unless it's valid.
if ~isempty(window)
    if Screen(window,'WindowKind')~=1
        % error('Illegal window pointer.');
        window=[];
    end
end

%% REPORT CONFIGURATION
c=Screen('Computer'); % Get name and version of OS.
os=strrep(c.system,'Mac OS','macOS'); % Modernize the spelling.
[~,v]=PsychtoolboxVersion;
fprintf('%s, MATLAB %s, Psychtoolbox %d.%d.%d\n',...
    os,version('-release'),v.major,v.minor,v.point);
[screenWidthMm,screenHeightMm]=Screen('DisplaySize',cal.screen);
cal.screenWidthCm=screenWidthMm/10;
fprintf('Computer %s, %s, screen %d, %dx%d, %.1fx%.1f cm\n',...
    cal.localHostName,cal.macModelName,cal.screen,...
    RectWidth(o.screenRect),RectHeight(o.screenRect),...
    screenWidthMm/10,screenHeightMm/10);
assert(cal.screenWidthCm == screenWidthMm/10);
fprintf('Computer account %s.\n',cal.processUserLongName);
if contains(mainFolder,'NoiseDiscrimination')
    fprintf('%s %s calibrated by %s on %s.\n',...
        cal.localHostName,cal.macModelName,cal.calibratedBy,cal.datestr);
    fprintf('%s\n',cal.notes);
end

%% MAKE TABLE OF TEST RESULTS
test=struct([]);

test(end+1).name='Computer name';
test(end).value=cal.localHostName;
test(end).min='';
test(end).ok=true;

test(end+1).name='Computer account';
test(end).value=cal.processUserLongName;
test(end).min='';
test(end).ok=true;

test(end+1).name='Computer model';
test(end).value=cal.macModelName;
test(end).min='';
test(end).ok=true;

test(end+1).name='Screen pixels';
test(end).value=sprintf('%.0fx%.0f pixel',...
    RectWidth(o.screenRect),RectHeight(o.screenRect));
test(end).min='';
test(end).ok=true;

test(end+1).name='Screen cm';
test(end).value=sprintf('%.1fx%.1f cm^2',screenWidthMm/10,screenHeightMm/10);
test(end).min='';
test(end).ok=true;

test(end+1).name='OS version';
test(end).value=os;
test(end).min='';
test(end).ok=true;

test(end+1).name='MATLAB version';
test(end).value=version;
test(end).min='9.1 (R2016b)';
test(end).ok=~verLessThan('matlab','9.1');
if verLessThan('matlab','9.1')
    % https://en.wikipedia.org/wiki/MATLAB#Release_history
    warn('%s requires MATLAB 9.1 (R2016b) or later, for "split" function.',mfilename);
end

test(end+1).name='Psychtoolbox version';
[~,ver]=PsychtoolboxVersion;
test(end).value=sprintf('%d.%d.%d',ver.major,ver.minor,ver.point);
v=ver.major*1000+ver.minor*100+ver.point;
test(end).ok=v>=3013;
if ~test(end).value
    warn(['Your Psychtoolbox %d.%d.%d is to old. '...
        'We need at least version 3.0.13. '...
        'Please run: UpdatePsychtoolbox'],...
        ver.major,ver.minor,ver.point);
end
test(end).min='3.0.13';
test(end).help='web http://psychtoolbox.org';

if ~verLessThan('matlab','8.1')
    test(end+1).name='PsychJava';
    test(end).min='true';
    ok=false;
    classpathFile=which('javaclasspath.txt');
    if isempty(classpathFile)
        % Nope. So we try the preference folder.
        % Retrieve path to preference folder.
        prefFolder=prefdir(1);
        classpathFile=[prefFolder filesep 'javaclasspath.txt'];
    end
    if exist(classpathFile,'file')
        fid=fopen(classpathFile);
        fileContentsWrapped=textscan(fid,'%s','delimiter','\n');
        fclose(fid);
        fileContents=fileContentsWrapped{1};
        for i=1:length(fileContents)
            % Look for any instance of PsychJava in the classpath.
            if ~isempty(strfind(fileContents{i},'PsychJava'))
                ok=true;
                break
            end
        end
    end
    if ok
        test(end).value='true';
        test(end).ok=true;
        %         fprintf('Good! PsychJava appears in javaclasspath.txt.\n');
    else
        test(end).value='false';
        test(end).ok=false;
        %         warning('Boo! PsychJava does not appear in javaclasspath.txt. Please read "help PsychJavaTrouble".');
    end
    test(end).help='help PsychJavaTrouble';
end

try
    test(end+1).name='Speak';
    test(end).min='true';
    Speak('Hello. Two beeps');
    test(end).value='true';
    test(end).ok=true;
catch e
    test(end).value='false';
    test(end).ok=false;
    warning(e.message)
end

%% TEST SOUND
Snd('Open');
e=Snd('Play',MakeBeep(1000,0.4));
test(end+1).name='Snd';
if e==0
    test(end).value='true';
else
    test(end).value=e;
end
test(end).min='true';
test(end).ok= e==0;
WaitSecs(0.5);
Snd('Play',MakeBeep(1000,0.5));

if IsOSX
    % Copied from InitializePsychSound, abbreviating the error messages.
    try
        test(end+1).name='PsychPortAudio';
        d=PsychPortAudio('GetDevices');
        %         fprintf('PsychPortAudio driver loaded. \n');
        test(end).value='true';
        test(end).ok=true;
    catch em
        fprintf('Failed to load PsychPortAudio driver with error:\n%s\n\n',em.message);
        test(end).value=em.message;
        test(end).ok=false;
    end
    test(end).min='true';
end
test(end).min='';
test(end).ok=true;
test(end).help='help PsychPortAudio';

% test(end+1).name='Brightness applescript';
% test(end).min='true';
% try
%     Brightness(0);
%     test(end).value='true';
%     test(end).ok=true;
% catch me
%     test(end).value='false';
%     test(end).ok=false;
%     warning(me.message);
%     test(end).help='help Brightness';
% end

if 0
    test(end+1).name='AutoBrightness applescript';
    test(end).min='true';
    try
        fprintf('Testing AutoBrightness(0) ...\n');
        s=GetSecs;
        AutoBrightness(0);
        test(end).value='true';
        test(end).ok=true;
    catch me
        test(end).value='false';
        test(end).ok=false;
        warning(me.message);
    end
    fprintf('(%.0f s)\n',GetSecs-s);
    test(end).help='help AutoBrightness';
end

%% TRY-CATCH BLOCK CONTAINS ALL CODE IN WHICH THE WINDOW IS OPEN
try
    %% OPEN WINDOW
    Screen('Preference','SkipSyncTests',1);
    Screen('Preference','TextAntiAliasing',1);
    if o.useFractionOfScreenToDebug
        %         fprintf('Using tiny window for debugging.\n');
    end
    if isempty(window)
        fprintf('Opening the window. ...\n'); % Newline for Screen warnings.
        s=GetSecs;
        if ~o.useFractionOfScreenToDebug
            [window,o.screenRect]=Screen('OpenWindow',cal.screen,255);
        else
            r=round(o.useFractionOfScreenToDebug*screenBufferRect);
            r=AlignRect(r,screenBufferRect,'right','bottom');
            [window,o.screenRect]=Screen('OpenWindow',cal.screen,255,r);
        end
        Screen('FillRect',window,255);
        Screen('Flip',window);
        fprintf('Done opening window (%.1f s).\n',GetSecs-s);
        if ~o.useFractionOfScreenToDebug
            HideCursor;
        end
    end % if isempty(window)
    o.screenRect=Screen('Rect',cal.screen,1); % screen rect in UseRetinaResolution mode
    if o.useFractionOfScreenToDebug
        o.screenRect=round(o.useFractionOfScreenToDebug*o.screenRect);
    end
    [o.textSize,o.textLineLength]=TextSizeToFit(window);
    
    %% OPEN OUTPUT FILES
    o.dataFolder=fullfile(mainFolder,'data');
    if ~exist(o.dataFolder,'dir')
        success=mkdir(o.dataFolder);
        if ~success
            error('Failed attempt to create data folder: %s',o.dataFolder);
        end
    end
    
    Screen('Preference','SkipSyncTests',1);
    oldVisualDebugLevel=Screen('Preference','VisualDebugLevel',0);
    oldSupressAllWarnings=Screen('Preference','SuppressAllWarnings',1);
    
    %% GET DETAILS OF THE OPEN WINDOW
    if ~isempty(window)
        % ListenChar(2) sets no-echo mode that allows us to collect
        % keyboard responses without any danger of inadvertenly writing to
        % the MATLAB command window or the program's text.
        %         ListenChar(2); % no echo
        
        test(end+1).name='DrawText plugin';
        % Recommended by Mario Kleiner, July 2017.
        % The first 'DrawText' call triggers loading of the plugin, but may fail.
        value=Screen('Preference','TextRenderer')>0;
        test(end).value=value;
        test(end).min=true;
        test(end).ok=test(end).value;
        Screen('DrawText',window,' ',0,0,0,1,1);
        %         fprintf('Loaded DrawText Plugin %s. Needed for accurate text rendering.\n',mat2str(value));
        if ~value
            %             warning('The DrawText plugin failed to load. We need it. See warning above. Read "Install NoiseDiscrimination.docx" B.7 to learn how to install it.');
        end
        test(end).help='help DrawTextPlugin';
        
        %% CHECK FOR NEEDED FONTS
        for f={'Pelli' 'Sloan'}
            font=f{1};
            test(end+1).name=sprintf('%s font',font);
            test(end).value=IsFontAvailable(font,'warn');
            test(end).min=true;
            test(end).ok=test(end).value;
            test(end).help=['dir ' fullfile(mainFolder,'fonts')];
        end
        
        %% BEAM POSITION QUERY
        % Recommended by Mario Kleiner, July 2017.
        windowInfo=Screen('GetWindowInfo',window);
        test(end+1).name='Beam position queries available';
        test(end).value=windowInfo.Beamposition ~= -1 && windowInfo.VBLEndline ~= -1;
        %         fprintf('Beam position queries %s, and should be true for best timing.\n',mat2str(test(end).value));
        test(end).min='';
        test(end).ok=true;
        test(end).help='Screen GetWindowInfo?';
   
        %% VIDEO CARD VENDOR
        windowInfo=Screen('GetWindowInfo',window);
        test(end+1).name='Built-in display DisplayCoreId';
        test(end).value=windowInfo.DisplayCoreId;
        test(end).min='';
        test(end).ok=true;
        test(end).help='Screen GetWindowInfo?';
        test(end+1).name='Built-in display GLRenderer';
        test(end).value=windowInfo.GLRenderer;
        test(end).min='';
        test(end).ok=true;
        test(end).help='Screen GetWindowInfo?';
        
        %% PSYCHTOOLBOX KERNEL DRIVER
        if ismac
            test(end+1).name='Psychtoolbox kernel driver';
            test(end).value=~system('kextstat -l -k | grep PsychtoolboxKernelDriver > /dev/null');
            test(end).min=true; % Helpful only if AMD driver.
            test(end).ok=test(end).value;
            test(end).help='web http://psychtoolbox.org/docs/PsychtoolboxKernelDriver';
            
            test(end+1).name='Psychtoolbox kernel driver version';
            [~,result]=system('kextstat -l -b PsychtoolboxKernelDriver');
            v=regexp(result,'(?<=\().*(?=\))','match'); % find (version)
            test(end).value=v{1};
            test(end).min='1.1';
            if ~isempty(test(end).value)
                test(end).ok= str2num(test(end).value)>=str2num(test(end).min);
            else
                test(end).ok=true;
            end
            test(end).help='web http://psychtoolbox.org/docs/PsychtoolboxKernelDriver';
        end
        
        if 0
            %% STIMULUS TIMING
            o.targetDurationSecsMean=mean(o.likelyTargetDurationSecs,'omitnan');
            o.targetDurationSecsSD=std(o.likelyTargetDurationSecs,'omitnan');
            if ~ismember(o.observer,o.algorithmicObservers)
                fprintf(['Across %d trials, target duration %.3f',plusMinusChar,'%.3f s (m',plusMinusChar,'sd).\n'],...
                    length(o.likelyTargetDurationSecs),...
                    o.targetDurationSecsMean,o.targetDurationSecsSD);
            end
        end
    end % if ~isempty(window)
    
    if false
        %% SAVE TO DISK
        o=SortFields(o);
        o.newCal=cal;
        o.dataFilename='InstallationCheck';
        save(fullfile(o.dataFolder,[o.dataFilename '.mat']),'o','cal');
        fprintf('Saved mat file.\n');
    end
    
    %% USE CAMERA
    o.recordGaze=true;
    test(end+1).name='Camera';
    if o.recordGaze
        fprintf('Trying to use the camera to take a photo. ...\n');
        videoExtension='.avi'; % '.avi', '.mp4' or '.mj2'
        clear cam webcam
        try
            cam=webcam(1);
            preview(cam);
            WaitSecs(1);
            o.dataFilename='InstallationCheckPhoto';
            photoFile=fullfile(o.dataFolder,[o.dataFilename videoExtension]);
            vidWriter=VideoWriter(photoFile);
            vidWriter.FrameRate=1; % frame/s.
            open(vidWriter);
            fprintf('Recording snapshot in file: %s\n',photoFile);
            test(end).value=true;
        catch e
            fprintf(2,'Failed to connect to your camera.\n');
            warning(e.message);
            test(end).value=false;
            o.recordGaze=false;
        end
    end
    if o.recordGaze
        try
            img=snapshot(cam);
        catch e
            warning(e.message)
        end
        % FUTURE: Write trial number and condition number in
        % corner of recorded movie image.
        writeVideo(vidWriter,img); % Write frame to video.
    end
    if exist('vidWriter','var')
        close(vidWriter);
        clear cam
    end
    test(end).min=true;
    test(end).ok=test(end).value;
    test(end).help='web https://www.mathworks.com/help/supportpkg/usbwebcams/';
    % Weirdly this web page says the support package is NOT needed:
    % https://www.mathworks.com/help/supportpkg/usbwebcams/ug/installing-the-webcams-support-package.html
    % test(end).help='web https://www.mathworks.com/hardware-support/matlab-webcam.html';
    % test(end).help=sprintf(['MATLAB Support Package for USB Webcams has not been installed. \n'...
    %     'Open Add-Ons Explorer to install the Webcam Support Package.\n'...
    %     'web https://www.mathworks.com/matlabcentral/fileexchange/45182-matlab-support-package-for-usb-webcams\n'...
    %     'In the MATLAB Command Window type "webcam(1)" to get the best installation link.']);
    
    %% Is screen calibrated?
    if contains(mainFolder,'NoiseDiscrimination')
        test(end+1).name='Screen is calibrated';
        if streq(cal.datestr,'none') || isempty(cal.datestr);
            test(end).value='false';
            test(end).ok=false;
        else
            test(end).value='true';
            test(end).ok=true;
        end
        test(end).min='true';
        test(end).help='help CalibrateScreenLuminance; % In NoiseDiscrimination/utilities/';
        if exist('OurScreenCalibrations','file')
            cal=OurScreenCalibrations(0);
            if isfield(cal,'old') && isfield(cal.old,'L') && isfield(cal,'datestr')
                if ~streq(cal.datestr,'none') && ~isempty(cal.datestr)
                    test(end).value='true';
                    test(end).ok=true;
                end
            end
        end
    end
    
    %% Goodbye
    o.speakInstructions=false;
    if o.speakInstructions && o.congratulateWhenDone
        Speak('Congratulations. Done.');
    end
    %     ListenChar(0); % flush
    %     ListenChar;
    if ~isempty(window)
        if Screen(window,'WindowKind') == 1
            % Tell observer what's happening.
            Screen('TextFont',window,'Verdana');
            if isfield(cal,'old') && isfield(cal.old,'gamma')
                Screen('LoadNormalizedGammaTable',window,cal.old.gamma,loadOnNextFlip);
            end
            Screen('FillRect',window);
            black=0;
            white=255;
            Screen('DrawText',window,' ',0,0,black,white,1); % Set background color.
            string=sprintf('Installation check is done. See the complete report and a list of errors in the Command Window.');
            black=0;
            DrawFormattedText(window,string,...
                2*o.textSize,2.5*o.textSize,black,...
                o.textLineLength,[],[],1.3);
            Screen('Flip',window); % Display message.
            pause(3);
        end
        CloseWindowsAndCleanup;
    end
    for i=1:length(test)
        if islogical(test(i).value)
            if test(i).value
                test(i).value='true';
            else
                test(i).value='false';
            end
        end
        if islogical(test(i).min)
            if test(i).min
                test(i).min='true';
            else
                test(i).min='false';
            end
        end
    end
    t=struct2table(test);
    tErr=t(~t.ok,:);
    disp(t);
    if ~isempty(tErr)
        fprintf('\n<strong>This computer failed %d tests:</strong>\n\n',height(tErr));
        disp(tErr);
        fprintf(['\n<strong>Please consult the Word document \n'...
            '"*Install CriticalSpacing & NoiseDiscrimination.docx"\n'...
            'to fix these problems before testing observers.</strong>\n']);
    end
    
catch e
    %% MATLAB catch
    CloseWindowsAndCleanup
    if exist('cal','var') && isfield(cal,'old') && isfield(cal.old,'gamma')
        Screen('LoadNormalizedGammaTable',0,cal.old.gamma);
    end
    rethrow(e);
end % try
end % function InstallationCheck(screen)

%% CloseWindowsAndCleanup
function CloseWindowsAndCleanup
% Close any window opened by the Psychtoolbox Screen command, re-enable
% keyboard, show cursor, and restore AutoBrightness.
global window

if ~isempty(Screen('Windows'))
    fprintf('Closing all windows. ... ');
    s=GetSecs;
    Screen('CloseAll');
    window=[];
    fprintf('Done (%.1f s).\n',GetSecs-s); % Closing all windows.
end

Screen('Preference','Verbosity',2); % Restore default level.
ListenChar; % May already be done by Screen('CloseAll').
ShowCursor; % May already be done by Screen('CloseAll').
end % function CloseWindowsAndCleanup
