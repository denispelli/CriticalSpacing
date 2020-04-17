function [res] = readAloudAnalysis(data, operation)
% readAloudAnalysis(data, 'plotmean');
% MORE TO BE IMPLEMENTED
% Written by Ziyi Zhang, Feb, 2020.

% 

operation = lower(operation); % case insensitive
res = [];

% plotMean
if strcmp(operation, 'plotmean')
    
    stringArr = string(data{:, 1});  % string of the words tested
    timeArr = data{:, 4};  % reaction time array
    lengthArr = zeros(size(timeArr));
    for i = 1:length(stringArr)
        lengthArr(i) = strlength(stringArr(i));
    end
    % extract four time arrays
    l3TimeArr = timeArr(lengthArr == 3);
    l4TimeArr = timeArr(lengthArr == 4);
    l5TimeArr = timeArr(lengthArr == 5);
    l6TimeArr = timeArr(lengthArr == 6);
    meanArr = [mean(l3TimeArr),mean(l4TimeArr),mean(l5TimeArr),mean(l6TimeArr)];
    
    % plot
    figure
    hold on
    errorbar(3:6, [mean(l3TimeArr), mean(l4TimeArr), mean(l5TimeArr), mean(l6TimeArr)],...
                  [std(l3TimeArr)/sqrt(length(l3TimeArr)), std(l4TimeArr)/sqrt(length(l4TimeArr)), std(l5TimeArr)/sqrt(length(l5TimeArr)), std(l6TimeArr)/sqrt(length(l6TimeArr))],...
                  '-o', 'MarkerSize', 4, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
    scatter(ones(length(l3TimeArr), 1).*3.05, l3TimeArr, '.');
    scatter(ones(length(l4TimeArr), 1).*4.05, l4TimeArr, '.');
    scatter(ones(length(l5TimeArr), 1).*5.05, l5TimeArr, '.');
    scatter(ones(length(l6TimeArr), 1).*6.05, l6TimeArr, '.');
   
    xlabel("Word Length");
    ylabel("Reaction Time (s)");
    xlim([2.4, 6.6]);
    ylim([0, 1.5]);
    xticks([3, 4, 5, 6]);
    grid on
    title('Relation between mean reaction time and word length');
%     dx = 0.1; dy = 0.1;
%     c = cellstr(meanArr);
%     text(x+dx, y+dy, c);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ask for confirmation
function [res] = confirmation(option)

    answer = questdlg(['Please confirm this operation:  ', option], 'Confirm', 'Cancel', 'Confirm', 'Cancel');
    switch answer
        case 'Cancel'
            res = 0;
        case 'Confirm'
            res = 1;
    end
end

% END OF READALOUDANALYSIS
