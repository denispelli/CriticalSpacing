function line=MFileLineNr()
% line=MFileLineNr;
% MFILELINENR returns the current line number
line=[];
stack=dbstack;
if length(stack)<2
    return
end
line=stack(2).line; % line number of the calling function
end

% Downloaded from MATLAB Central in November 2015
% http://www.mathworks.com/matlabcentral/fileexchange/26262-mfilelinenr