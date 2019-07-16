function words=WordsInString(string)
% Parse text into a list of words.
% denis.pelli@nyu.edu
% July 16, 2019
% In MATLAB 2018a, inexplicably, even though "newline" is present as a
% built-in function, I am unable to call it from this routine. So I define
% it myself. This must be a bug in MATLAB.
newline=char(10); % Introduced in MATLAB 2016b.
rem=string;
words={};
rem=strrep(rem,'"','');    % Remove double quote.
rem=strrep(rem,' ''',' '); % Remove leading single quote.
rem=strrep(rem,''' ',' '); % Remove trailing single quote.
rem=strrep(rem,' -',' ');  % Remove leading dash.
rem=strrep(rem,'- ',' ');  % Remove trailing dash.
% Spare embedded apostrophes and dashes.
while ~isempty(rem)
    [words{end+1},rem]=strtok(rem,[newline char(255) ' ,:;.?!"0123456789?']);
end
if ~isempty(words) && isempty(words{end})
    words={words{1:end-1}};
end
end