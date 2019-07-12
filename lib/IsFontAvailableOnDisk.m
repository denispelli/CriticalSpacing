function ok=IsFontAvailableOnDisk(font,warn)
% ok=IsFontAvailableOnDisk(font,warn)
% "font" is a string or a cell array of strings. Each string is a font
% name. Returns a logical array, one element per font, indicating true if
% the font is available. If the optional argument "warn" is the string
% 'warn' then a warning is printed for each missing font.
% Denis Pelli, June 26, 2019
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

%% CHECK FOR SPECIFIED FONTS
ok=logical([]);
for i=1:length(fonts)
    font=fonts{i};
    alphabetsFolder=fullfile(fileparts(myPath),'alphabets'); % CriticalSpacing/alphabets/
    ok(i)=exist(alphabetsFolder,'dir')==7;
    if ~ok(i)
        if ismember(warn,{'warn'})
            s=warning('QUERY','BACKTRACE');
            warning OFF BACKTRACE
            warning('Folder missing: <strong>%s</strong>',alphabetsFolder);
            warning(s);
        end
        continue
    end
    folder=fullfile(alphabetsFolder,EncodeFilename(font));
    ok(i)=exist(folder,'dir')==7;
    if ~ok(i) && ismember(warn,{'warn'})
        s=warning('QUERY','BACKTRACE');
        warning OFF BACKTRACE
        warning('Font folder <strong>%s</strong> is missing. Please use SaveAlphabetToDisk to save font <strong>%s</strong> .',folder,font);
        warning(s);
    end
end
end