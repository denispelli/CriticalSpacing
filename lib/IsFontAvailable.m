function ok=IsFontAvailable(font,warn)
% ok=IsFontAvailable(font,warn)
% "font" is a string or a cell array of strings. Each string is a font
% name. Returns a logical array, one element per font, indicating true if
% the font is available. If the optional argument "warn" is the string
% 'warn' then a warning is printed for each missing font. If there is a 
% /fonts/ folder where we expect it, then we suggest the user look there 
% for the missing font to be installed. 
% There is some
% overhead in opening and closing a window, so it's best to call this once
% with a list of fonts, rather than multiple times, once for each font.
% Denis Pelli, July 6, 2019
% denis.pelli@nyu.edu
if nargin<1 || isempty(font)
    ok=logical([]);
    return
end
if nargin<2
    warn='';
end
switch class(font)
    case 'cell'
        fonts=font;
    case 'char'
        fonts={font};
end
myPath=fileparts(mfilename('fullpath')); % Takes 0.1 s.
o.useFractionOfScreenToDebug=0.1;
o.screen=0;
screenBufferRect=Screen('Rect',o.screen);
r=round(o.useFractionOfScreenToDebug*screenBufferRect);
r=AlignRect(r,screenBufferRect,'right','bottom');
oldVerbosity=Screen('Preference','Verbosity',0);
windows=Screen('Windows');
window=[];
for i=1:length(windows)
    if Screen(windows(i),'WindowKind')==1
        % A window is already open, so open an offscreen window.
        window=Screen('OpenOffscreenWindow',o.screen,1.0,r);
        if Screen(window,'WindowKind')~=-1
            error('Failed attempt to open an offscreen window.');
        end
        break;
    end
end
if isempty(window)
    % Nothing's open, so open a window.
    window=Screen('OpenWindow',o.screen,1.0,r);
    if Screen(window,'WindowKind')~=1
        error('Failed attempt to open a window.');
    end
end

%% CHECK FOR SPECIFIED FONTS
ok=logical([]);
for i=1:length(fonts)
    font=fonts{i};
    oldFont=Screen('TextFont',window,font);
    % Perform dummy DrawText call, in case the OS defers setting of the font.
    Screen('DrawText',window,' ',0,0);
    newFont=Screen('TextFont',window);
    Screen('TextFont',window,oldFont); % Restore old font.
    ok(i)=streq(newFont,font);
    if ~ok(i) && ismember(warn,{'warn'})
        if true
            mainFolderPath=fileparts(fileparts(mfilename('fullpath'))); % Assume we're in /lib folder.
            [~,mainFolder]=fileparts(mainFolderPath);
            fontsFolderPath=fullfile(mainFolderPath,'fonts');
            if exist(fontsFolderPath,'dir')
                msg=sprintf(' Look in folder <strong>%s%s%s%s</strong> .',mainFolder,filesep,'fonts',filesep);
            else
                msg='';
            end
        else
            msg='';
        end
        s=warning('QUERY','BACKTRACE');
        warning OFF BACKTRACE
        warning('The font <strong>%s</strong> is not installed in your OS. Please install it.%s',font,msg);
        warning(s);
    end
end
Screen('Close',window);
Screen('Preference','Verbosity',oldVerbosity);
