% clear data other than 3-16
if strcmp('clearPrevDates')
    
    dinfo = dir(fileparts(mfilename('fullpath')));
    files = {dinfo.name};
    for i = 1:length(files)
        file = files{i};
        
        if ~(strcmp(file(1:11), '2020-03-16'))
            [res, msg, msgID] = movefile(file, [fileparts(mfilename('fullpath')), filesep, 'RecycleBin']);
            if ~res
                fprintf('Operation failed with errCode %d when removing file %s: %s\n', msgID, file, msg);
            else
                fprintf('File removed: %s\n', file);
            end
        end
    end
    return;  
end
