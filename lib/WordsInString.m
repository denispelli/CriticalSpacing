function words=WordsInString(string)
% Parse text into a list of words.
% denis.pelli@nyu.edu
% April 18, 2019
rem=string;
words={};
rem=strrep(rem,'"','');    % Remove double quote.
rem=strrep(rem,' ''',' '); % Remove leading single quote.
rem=strrep(rem,''' ',' '); % Remove trailing single quote.
rem=strrep(rem,' -',' ');  % Remove leading dash.
rem=strrep(rem,'- ',' ');  % Remove trailing dash.
% Spare embedded apostrophes and dashes.
while ~isempty(rem)
    [words{end+1},rem]=strtok(rem,[char(10) char(255) ' ,:;.?!"0123456789?']);
end
if isempty(words{end})
    words={words{1:end-1}};
end
end