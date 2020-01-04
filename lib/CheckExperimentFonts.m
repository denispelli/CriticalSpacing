function CheckExperimentFonts(ooo)
% CheckExperimentFonts(ooo)
%% MAKE SURE NEEDED FONTS ARE AVAILABLE
fonts={};
diskFonts={};
if isfield(ooo{1}(1),'targetFont')
    fonts={};
    diskFonts={};
    for block=1:length(ooo)
        for oi=1:length(ooo{block})
            if ooo{block}(oi).getAlphabetFromDisk
                diskFonts{end+1}=ooo{block}(oi).targetFont;
            else
                fonts{end+1}=ooo{block}(oi).targetFont;
            end
        end
    end
    fonts=unique(fonts);
    diskFonts=unique(diskFonts);
    missing=any(~IsFontAvailable(fonts,'warn'));
    missingFromDisk=any(~IsFontAvailableOnDisk(diskFonts,'warn'));
    msg='';
    if missing
        msg='Please install the missing system fonts. Try double clicking the corresponding font file in the /fonts/ folder.';
    end
    if missingFromDisk
        msg=[msg 'Please use SaveAlphabetToDisk to add the missing disk fonts to the /alphabets/ folder.'];
    end
    msg=strrep(msg,'. Please',', and');
    if ~isempty(msg)
        error(msg);
    end
end
fprintf('Will use %d system fonts: ',length(fonts));
for i=1:length(fonts)
    fprintf('%s, ',fonts{i});
end
fprintf('\nWill use %d disk fonts: ',length(diskFonts));
for i=1:length(diskFonts)
    fprintf('%s, ',diskFonts{i});
end
fprintf('\n\n');