function get_summarystats(x)
% function [mean_x min_x max_x] = get_summarystats(x)


mean_x = mean(x);
min_x = min(x);
max_x = max(x);
std_x = std(x);
mean_plusminus_2std = [(mean_x - 2*std_x) (mean_x + 2*std_x)];

summaryPCT_x = prctile(x,[2.5 5 25 50 75 95 97.5]);
IQR = summaryPCT_x(5) - summaryPCT_x(3);
fprintf('N observations:\t %d \nMean:\t%3.3f \nSD:\t%3.3f \nMin:\t%3.3f \nMax:\t%3.3f\n', length(x), mean_x, std_x, min_x, max_x);
fprintf('2.5th pct:\t%3.3f \n5th pct:\t%3.3f \n25th pct:\t%3.3f \n50th pct:\t%3.3f \n75th pct:\t%3.3f \n95th pct:\t%3.3f \n97.5th pct:\t%3.3f\n', summaryPCT_x); 
fprintf('Mean plus/minus 2 SDs:\t%3.3f\t%3.3f\n', mean_plusminus_2std);
fprintf('1.5 * IQR:\t%3.3f\n', IQR*1.5);