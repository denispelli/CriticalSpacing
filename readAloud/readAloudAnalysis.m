function [res] = readAloudAnalysis(data, operation)
% [] = readAloudAnalysis(data);
% TO BE IMPLEMENTED
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
    
    % plot
    figure
    hold on
    errorbar(3:6, [mean(l3TimeArr), mean(l4TimeArr), mean(l5TimeArr), mean(l6TimeArr)],...
                  [std(l3TimeArr), std(l4TimeArr), std(l5TimeArr), std(l6TimeArr)],...
                  '-o', 'MarkerSize', 4, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue');
    scatter(ones(length(l3TimeArr), 1).*3.05, l3TimeArr, '.');
    scatter(ones(length(l4TimeArr), 1).*4.05, l4TimeArr, '.');
    scatter(ones(length(l5TimeArr), 1).*5.05, l5TimeArr, '.');
    scatter(ones(length(l6TimeArr), 1).*6.05, l6TimeArr, '.');
    
    xlabel("Word Length");
    ylabel("Reaction Time (s)");
    xlim([2.4, 6.6]);
    xticks([3, 4, 5, 6]);
    grid on
    title('Relation between mean reaction time and word length');
end

end

% END OF READALOUDANALYSIS
