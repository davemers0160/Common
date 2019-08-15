format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% select the data file

file_filter = {'*.txt','Text Files';'*.*','All Files' };

startpath = 'D:\Projects\MNIST\results';
[data_file, data_path] = uigetfile(file_filter, 'Select Multi Trial Results File', startpath);
if(data_path == 0)
    return;
end

% [test_data_file, test_data_path] = uigetfile(file_filter, 'Select Test Reduction Results File', data_path);
% if(test_data_path == 0)
%     return;
% end

run_test_data = true;

test_data_path = uigetdir(data_path, 'Select Multi Trial Results Folder');
if(test_data_path == 0)
    run_test_data = false;
end

save_path = 'D:\IUPUI\PhD\IEEE\NNLS_MNIST_REDUX\images';

commandwindow;

%% Get the data from the file

data_params = parse_input_parameters(fullfile(data_path, data_file));

num_trials = size(data_params,1);

for idx=1:num_trials
    train_accuracy(idx,1) = str2double(data_params{idx}{4});
    test_accuracy(idx,1) = str2double(data_params{idx}{7});
end

stats = zeros(4,2);

stats(1,1) = min(train_accuracy(:,1));
stats(2,1) = mean(train_accuracy(:,1));
stats(3,1) = max(train_accuracy(:,1));
stats(4,1) = std(train_accuracy(:,1));

stats(1,2) = min(test_accuracy(:,1));
stats(2,2) = mean(test_accuracy(:,1));
stats(3,2) = max(test_accuracy(:,1));
stats(4,2) = std(test_accuracy(:,1));

sig_m = 2;

% get the lower limits
limits_test(1,1) = stats(2,2) - sig_m*stats(4,2);

% get the upper limits
limits_test(1,2) = stats(2,2) + sig_m*stats(4,2);

fprintf('Min Error: %2.4f%%\n', (1-stats(3,2))*100);
fprintf('Avg Error: %2.4f%%\n', (1-stats(2,2))*100);
fprintf('Std Deviation: %2.4f\n', stats(4,2));


%% Plot the initial test results

figure(plot_num)
set(gcf,'position',([50,50,1200,500]),'color','w')
% set(gcf,'position',([50,50,800,400]),'color','w')
hold on
box on
grid on 

%plot the area
p1 = area([-1,num_trials+2],[limits_test(1,2), limits_test(1,2)]*100, 'BaseValue', limits_test(1,1)*100, 'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',1, 'EdgeColor','b', 'LineWidth',1);

%plot the mean line - maybe
p2 = plot([-1,num_trials+2],[stats(2,2), stats(2,2)]*100, '--b', 'LineWidth', 1);

% plot the test points
p3 = scatter([1:num_trials], test_accuracy(:,1)*100, 15, 'filled', 'k');
set(gca, 'fontweight', 'bold', 'FontSize', 13);

% Y-Axis
p = 1000;
plt_max = max(ceil(limits_test(1,2)*p)/p, ceil(stats(3,2)*p)/p);
plt_min = min(floor(limits_test(1,1)*p)/p, floor(stats(1,2)*p)/p);
% plt_max = 0.9912;
% plt_min = 0.989;
ylim([plt_min plt_max]*100);
yticks([plt_min:(1/(5*p)):plt_max]*100);
%ylim([0.85 1]);
%yticks([0:0.05:1]);
ytickformat('%1.2f')
ylabel('Test Accuracy (%)', 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
set(gca,'TickLabelInterpreter','none')
xlim([0 num_trials+1]);
xticks([1:1:num_trials]);
xtickangle(90);
set(gca,'XMinorTick','on', 'XMinorGrid','on');
xlabel(strcat('Training Event Number'), 'fontweight', 'bold', 'FontSize', 13);
%xticklabels(test_label);

title('MNIST Multi-Training Event - Test Results Distribution','fontweight','bold','FontSize', 15)

legend([p1 p2 p3], strcat(32,'{\pm}',num2str(sig_m),'{\sigma} Trial Mean Bounds'), 'Trial Mean', 'Test Results', 'location', 'southoutside', 'orientation', 'horizontal')

ax = gca;
ax.XAxis.MinorTickValues = 1:1:num_trials;
ax.Position = [0.07 0.2 0.915 0.7];
%ax.Position = [0.11 0.23 0.85 0.68];

%print(plot_num, '-dpng', fullfile(save_path,strcat('mnist_multi_trial_tests.png')));

plot_num = plot_num + 1;

%% add the trials
% test_label = {'05_16_120_84', '05_14_120_84', '05_15_120_84', '05_14_75_84', '05_15_80_84',...
%               'L03_1', 'L03_2','L03_3','L03_4'};
% 
% test_data = [60000, 0, 1, 9901, 99, 0.9901, 0, 0;...
%              60000, 0, 1, 9894, 106, 0.9894, 4.09658e-06, 5.010408e-06;...
%              60000, 0, 1, 9895, 105, 0.9895, 4.29972e-06, 4.71726e-06
%              60000, 0, 1, 9898, 102, 0.9898, 4.33566e-06, 4.50639e-06;...
%              59998, 2, 0.999967, 9898, 102, 0.9898, 4.35091e-06, 4.66531e-06;...
%              60000, 0, 1, 9887, 113, 0.9887, 4.19487e-06, 4.68241e-06;...
%              60000, 0, 1, 9885, 115, 0.9885, 4.82678e-06, 5.1088e-06;...
%              60000, 0, 1, 9892, 108, 0.9892, 4.46073e-06, 4.73569e-06;...
%              60000, 0, 1, 9882, 118, 0.9882, 4.47482e-06, 4.73975e-06;...
%              ];
         
if(false)
% read in the test results
test_data_params = parse_input_parameters(fullfile(test_data_path, test_data_file));

test_label = cell(numel(test_data_params),1);
test_data = zeros(numel(test_data_params),8);

for idx=1:numel(test_data_params)
    test_label{idx,1} = strcat(32,test_data_params{idx}{1});
    test_data(idx,:) = [str2double(test_data_params{idx}{2}), str2double(test_data_params{idx}{3}), str2double(test_data_params{idx}{4}),...
                      str2double(test_data_params{idx}{5}), str2double(test_data_params{idx}{6}), str2double(test_data_params{idx}{7}),...
                      str2double(test_data_params{idx}{8}), str2double(test_data_params{idx}{9})];
end

% test_label = {'05-15-76-62', '05_16_120_84', '05_15_120_84', '05_14_75_84', '05_15_80_84',...
%               'L03_1', 'L03_2','L03_3','L03_4'};     
%           
% test_data = [60000, 0, 1, 9883, 117, 0.9883; ...
%              60000, 0, 1, 9900, 100, 0.9900, 0, 0;...
%              60000, 0, 1, 9895, 105, 0.9895, 4.29972e-06, 4.71726e-06;...
%              60000, 0, 1, 9898, 102, 0.9898, 4.33566e-06, 4.50639e-06;...
%              59998, 2, 0.999967, 9898, 102, 0.9898, 4.35091e-06, 4.66531e-06;...
%              60000, 0, 1, 9887, 113, 0.9887, 4.19487e-06, 4.68241e-06;...
%              60000, 0, 1, 9885, 115, 0.9885, 4.82678e-06, 5.1088e-06;...
%              60000, 0, 1, 9892, 108, 0.9892, 4.46073e-06, 4.73569e-06;...
%              60000, 0, 1, 9882, 118, 0.9882, 4.47482e-06, 4.73975e-06;...
%              ];
         
td_size = size(test_data,1);
area_limits = max(num_trials, td_size);

figure(plot_num)
set(gcf,'position',([50,100,1400,500]),'color','w')
% Plot the NRMSE values
hold on
box on
grid on

%plot the area
p1 = area([-1,area_limits+2],[limits_test(1,2), limits_test(1,2)], 'BaseValue', limits_test(1,1), 'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',1, 'EdgeColor','b', 'LineWidth',1.0);

%plot the mean line - maybe
p2 = plot([-1,area_limits+2],[stats(2,2), stats(2,2)], '--b', 'LineWidth', 1);

% plot the test points
%scatter([1:num_trials], test_accuracy(:,1),15,'filled','k')
p3 = scatter([1:td_size],test_data(:,6),20,'filled','r');
set(gca, 'fontweight', 'bold', 'FontSize', 13);

% Y-Axis
plt_max = 0.992;
plt_min = 0.987;
ylim([plt_min plt_max]);
yticks([plt_min:0.001:plt_max]);
%ylim([0.85 1]);
%yticks([0:0.05:1]);
ytickformat('%1.2f')
ylabel('Test Accuracy', 'fontweight', 'bold', 'FontSize', 13);

title('Multiple Trial Performance Comparison','fontweight','bold','FontSize', 16)

legend([p1 p2 p3], strcat(32,'{\pm}',num2str(sig_m),'{\sigma} Trial Bounds'), 'Trial Mean', 'Redcution Results', 'location', 'northeast', 'orientation', 'horizontal')

set(gca,'TickLabelInterpreter','none')
xlim([0 td_size+1]);
xticks([1:td_size]);
xlabel(strcat('Test Configuration'), 'fontweight', 'bold', 'FontSize', 13);
xticklabels(test_label);
xtickangle(90);

ax = gca;
ax.Position = [0.07 0.3 0.92 0.6];

plot_num = plot_num + 1;

end

%% now check one of the final results against the initial results

if(run_test_data)
    
    test_listing = dir(strcat(test_data_path,filesep,'*.txt'));
    num_test_trials = numel(test_listing);

    test_label = {};
    test_stats = [];
    for idx=1:num_test_trials
        test_name = test_listing(idx).name;
        test_label{idx,1} = strcat(32,test_name(4:end-4));
        test_data_params = parse_input_parameters(fullfile(test_listing(idx).folder, test_listing(idx).name));

        train_accuracy2 = [];
        test_accuracy2 = [];    
        for jdx=1:size(test_data_params,1)
            train_accuracy2(jdx,1) = str2double(test_data_params{jdx}{4});
            test_accuracy2(jdx,1) = str2double(test_data_params{jdx}{7});
        end
        test_stats(idx,:) = [min(test_accuracy2(:,1)), mean(test_accuracy2(:,1)), max(test_accuracy2(:,1)), std(test_accuracy2(:,1))];
    end

    test_sig_m = 2;

%% Plot the overlay of the initial results and the final results

    %area_limits = max(num_trials, num_test_trials) + 2;
    area_limits = num_test_trials + 2;

    figure(plot_num)
    set(gcf,'position',([50,50,1400,500]),'color','w')
    % Plot the NRMSE values
    hold on
    box on
    grid on

    %plot the initial area
    p1 = area([-1,area_limits+2],[limits_test(1,2), limits_test(1,2)]*100, 'BaseValue', limits_test(1,1)*100, 'FaceColor','b','FaceAlpha',.3,'EdgeAlpha',1, 'EdgeColor','b', 'LineWidth',1);

    %plot the mean line - maybe
    p2 = plot([-1,area_limits+2],[stats(2,2), stats(2,2)]*100, '--b', 'LineWidth', 1);
    plot([-1,area_limits+2],[limits_test(1,1), limits_test(1,1)]*100, '-b', 'LineWidth', 1);

    % plot the updated area
    %p3 = area([-1,area_limits+2],[limits_test2(1,2), limits_test2(1,2)], 'BaseValue', limits_test2(1,1), 'FaceColor','g','FaceAlpha',.3,'EdgeAlpha',1, 'EdgeColor','g', 'LineWidth',1);
    %p4 = plot([-1,area_limits+2],[test_stats(2,2), test_stats(2,2)], '--g', 'LineWidth', 1);
    p3 = errorbar([1:num_test_trials], test_stats(:,2)*100, test_sig_m*test_stats(:,4)*100,'.',...
        'MarkerSize',13, 'MarkerEdgeColor','red','MarkerFaceColor','red','Color','k','LineWidth',1);
    scatter([1:num_test_trials], test_stats(:,3)*100, 13, 'MarkerEdgeColor','green', 'MarkerFaceColor','green','LineWidth',1);
    scatter([1:num_test_trials], test_stats(:,1)*100, 13, 'MarkerEdgeColor','green', 'MarkerFaceColor','green','LineWidth',1); 
    
    % plot the test points
    %p5 = scatter([1:num_test_trials], test_accuracy2(:,1),15,'filled','k');

    set(gca, 'fontweight', 'bold', 'FontSize', 13);

    % Y-Axis
    plt_max = 0.992;
    plt_min = 0.9855;
    ylim([plt_min plt_max]*100);
    yticks([plt_min:0.0005:plt_max]*100);
    ytickformat('%1.2f')
    ylabel('Test Accuracy (%)', 'fontweight', 'bold', 'FontSize', 13);

    % X-Axis
    %set(gca,'TickLabelInterpreter','none')
    xlim([0 area_limits-1]);
    xticks([1:area_limits-2]);
    xlabel(strcat('Network Configuration'), 'fontweight', 'bold', 'FontSize', 13);
    xticklabels(test_label);
    xtickangle(60);
    
    % color the individual XTickLabels
    ax = gca;
    ax.XTickLabel{1} = ['\color{red}' ax.XTickLabel{1}];
    ax.XTickLabel{2} = ['\color{green}' ax.XTickLabel{2}];    
    ax.XTickLabel{6} = ['\color{blue}' ax.XTickLabel{6}];
    ax.XTickLabel{15} = ['\color{blue}' ax.XTickLabel{15}];
    ax.XTickLabel{21} = ['\color{blue}' ax.XTickLabel{21}];
    ax.XTickLabel{32} = ['\color{blue}' ax.XTickLabel{32}];
    ax.XTickLabel{39} = ['\color{blue}' ax.XTickLabel{39}];
    ax.XTickLabel{40} = ['\color{blue}' ax.XTickLabel{40}];
    
    % just for reference
    %for i = 1:nColors
    %    ax.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', cm(i,:), ax.YTickLabel{i});
    %end
    
    title(strcat('MNIST Reduction Test Results'),'fontweight','bold','FontSize', 16)

    legend([p1 p2 p3], strcat(32,'{\pm}',num2str(sig_m),'{\sigma} Trial Bounds'), 'Trial Mean', 'Test Results', 'location', 'southoutside', 'orientation', 'horizontal')


    ax.Position = [0.065 0.37 0.92 0.56];

    print(plot_num, '-dpng', fullfile(save_path,strcat('mnist_reduction_results.png')));
    
    plot_num = plot_num + 1;

end
