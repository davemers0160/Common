format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% Select PSO results files

save_path = 'D:\Projects\mnist_pso\pso_results';

file_filter = {'*.txt','Text Files';'*.*','All Files' };
startpath = 'D:\Projects\mnist_pso\pso_results';

[results_file, results_file_path] = uigetfile(file_filter, 'Select the PSO Results File(s)', startpath, 'multiselect','on');
if(results_file_path == 0)
    return;
end

commandwindow;

%%  Process through the files and read in the data

N = 20;                         % population size

if(iscell(results_file))
    
    max_itr = numel(results_file);

    % arrange the data in column form where the PSO member is the column
    results = zeros(N, max_itr);
    f = zeros(N,max_itr);
    
    for idx=1:max_itr
        tmp = parse_input_parameters(fullfile(results_file_path, results_file{idx}));
        
        for jdx=1:numel(tmp)
        
            % read in the iteration number
            itr_num = str2double(tmp{jdx}{1});
            
            % read in the population member
            pop_num = str2double(tmp{jdx}{2});
        
            results(pop_num,itr_num) = str2double(tmp{jdx}{8});
%             results(pop_num,2,itr_num) = str2double(tmp{jdx}{4})*cf;
%             results(pop_num,3,itr_num) = str2double(tmp{jdx}{5});
%             results(pop_num,4,itr_num) = str2double(tmp{jdx}{8})*cf;
%             results(pop_num,5,itr_num) = str2double(tmp{jdx}{9})*cf;
%             results(pop_num,6,itr_num) = str2double(tmp{jdx}{10});
            
            f(pop_num,itr_num) = (1-results(pop_num,itr_num));
            
        end
    end
    
else
    max_itr = 1;
    results = zeros(N, 6, max_itr);

end

itr_num = max_itr;

%% get some of the basic metrics

particle_min = zeros(N,1);
particle_mean = zeros(N,1);
particle_max= zeros(N,1);

p_min_idx = zeros(N,1);
p_max_idx = zeros(N,1);

for idx=1:N
    [particle_min(idx,1), p_min_idx(idx,1)] = min(results(idx,:));
    particle_mean(idx,1) = mean(results(idx,:));
    [particle_max(idx,1), p_max_idx(idx,1)] = max(results(idx,:));
end

[tmp, index_x] = min(particle_min);
min_metrics = [index_x, p_min_idx(index_x,1), tmp];

[tmp, index_x] = max(particle_max);
max_metrics = [index_x, p_max_idx(index_x,1), tmp];


% min_metrics = zeros(6,3);
% mean_metrics = zeros(6,3);
% max_metrics = zeros(6,3);
% 
% for idx=1:6
%     
%     [tmp, index_x] = min(results(:,idx,:));
%     [tmp, index_y] = min(tmp);
%     min_metrics(idx,:) = [index_x(:,:,index_y),index_y, tmp];
%     
% %     [tmp, index_x] = mean(results(:,idx,:));
% %     [tmp, index_y] = mean(tmp);
% %     mean_metrics(idx,:) = [index_x(:,:,index_y),index_y, tmp];
%     
%     [tmp, index_x] = max(results(:,idx,:));
%     [tmp, index_y] = max(tmp);
%     max_metrics(idx,:) = [index_x(:,:,index_y),index_y, tmp];
% end

best_result = [max_metrics(1,:)];


f_min = min(f,[],1);
f_max = max(f,[],1);
f_mean = mean(f,1);


%% plot the objective function stats

figure(plot_num)
set(gcf,'position',([100,50,1200,700]),'color','w')
hold on
box on
grid on

p1 = plot([1:max_itr], f_min, 'g', 'LineWidth', 1);
p2 = plot([1:max_itr], f_mean, '--k', 'LineWidth', 1);
p3 = plot([1:max_itr], f_max, 'b', 'LineWidth', 1);

set(gca, 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
xlim([1 max_itr]);
xticks([1:max_itr]);
xlabel('PSO Iteration Number','fontweight', 'bold', 'FontSize', 13);

% Y-axis
ylim([0 1.0]);
yticks([0:0.1:1.0]);
ytickformat('%1.1f')
ylabel('Objective Function Value', 'fontweight', 'bold', 'FontSize', 13);

title('Objective Function', 'fontweight', 'bold', 'FontSize', 16);
lgd = legend([p1, p2, p3], 'Minimum', 'Mean', 'Maximum', 'location', 'northeast', 'orientation', 'vertical');

ax = gca;
ax.Position = [0.06 0.09 0.91 0.85];

%lgd.Position = [.36, .02, .32, 0.034];

%print(plot_num, '-dpng', fullfile(save_path,strcat('dfd_pso_fx_results.png')));

plot_num = plot_num + 1;

%% setup the plot limits
% which one to plot: train: NMAE=1, NRMSE=2, SSIM=3, test: NMAE=4, NRMSE=5, SSIM=6
metric = 2;
metric_name = {'Training Accuracy', 'Test Accuracy'};
metric_save_name = {'tr_acc', 'te_acc'};

% z is the actual value [nmae_min,nmae_max;nrmse_min,nrmse_max;ssim_min,ssim_max]
z_lim = [0.15, 1.0];
     
z_step = [0.05];

z_ticks = [z_lim(1,1):z_step(1):z_lim(1,2)];


%% 3-D view of the scatter plot

figure(plot_num)
set(gcf,'position',([100,50,1200,700]),'color','w')
hold on
box on
grid on

% Y = 1:1:N;
% Y = repmat(Y,1,itr_num);
% 
% X = 1:1:itr_num;
% X = repmat(X,1,N);
% 
% Z = permute(results(:,metric,:),[3 2 1]);
% Z = Z(:)';

S = 15*ones(1,itr_num);
cm = colormap(jet(100)); 

for idx=1:N
    
    X = idx*ones(1,itr_num);    % this will be the population member
    Y = 0:(itr_num-1);    % this will be the iteration number
    Z = results(idx,:);    % this will be the data
                                        % Define Colormap
    c2 = ceil(Z(:)*100);
    
    s1 = scatter3(X, Y, Z, 15, 'filled', 'b');
    %s1 = scatter3(X, Y, Z(:), S, cm(c2,:), 'filled');
end

sb = scatter3(best_result(1,1), best_result(1,2), best_result(1,3), 20, 'filled', 'r');

%s1 = scatter3(X, Y, Z, 15, 'filled', 'b');
%sb = scatter3(best_result(metric,2), best_result(metric,1), best_result(metric,3), 18, 'filled', 'r');

set(gca,'fontweight','bold');

% Y-Axis
ylim([-1 itr_num]);
yticks([0:1:(itr_num-1)]);
%ytickformat('%1.2f')
ylabel(strcat('Iteration Number',13), 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
%set(gca,'TickLabelInterpreter','none')
xlim([0 N+1]);
xticks([1:1:N]);
%set(gca,'XMinorTick','on', 'XMinorGrid','on');
xlabel(strcat('Particle Number',13), 'fontweight', 'bold', 'FontSize', 13);
%xticklabels(test_label);

% Z-axis
zlim(z_lim)
zticks(z_ticks);
zlabel(metric_name{metric}, 'fontweight', 'bold', 'FontSize', 13);
ztickformat('%1.2f')
view(60,45);

%title('MNIST Multi-Training Event - Test Results Distribution','fontweight','bold','FontSize', 15)

lgd = legend([s1, sb], 'Particle Results', 'Global Best Particle', 'location', 'southoutside', 'orientation', 'horizontal');

ax = gca;
ax.Position = [0.08 0.15 0.88 0.82];

lgd.Position = [.36, .02, .32, 0.034];

%print(plot_num, '-dpng', fullfile(save_path,strcat('dfd_pso_',metric_save_name{metric},'_results.png')));

plot_num = plot_num + 1;


%% surface version of the plot over iteration and population member

if(false)
% build the surface
X = 1:N;
Y = 1:itr_num;

Z = zeros(itr_num,N);

for idx=1:N
   Z(:,idx) = results(idx,metric,:);
end

figure(plot_num)
set(gcf,'position',([100,100,1000,600]),'color','w')
hold on
box on
grid on

s1 = surf(X,Y,Z);
colormap(jet(1000));
sb = scatter3(best_result(metric,1), best_result(metric,2), best_result(metric,3), 18, 'filled', 'k');

set(gca,'fontweight','bold');

% Y-Axis
ylim([-1 itr_num]);
yticks([0:1:itr_num-1]);
%ytickformat('%1.2f')
ylabel('Iteration Number', 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
%set(gca,'TickLabelInterpreter','none')
xlim([0 N+1]);
xticks([1:1:N]);
%set(gca,'XMinorTick','on', 'XMinorGrid','on');
xlabel('Particle Number', 'fontweight', 'bold', 'FontSize', 13);
%xticklabels(test_label);

% Z-axis
zlim(z_lim(metric,:))
zticks(z_ticks);
zlabel(metric_name{metric}, 'fontweight', 'bold', 'FontSize', 13);

view(60,45);

plot_num = plot_num + 1;

end
%% 3-D scatter plot with both train and test

if(false)

m2 = mod(metric,3)+1;
    
z_label_name = {'NMAE','NRMSE','SSIM'};

figure(plot_num)
set(gcf,'position',([100,100,1000,600]),'color','w')
hold on
box on
grid on

for idx=1:N

    % this will be the population member
    X = idx*ones(itr_num,1);

    % this will be the iteration number
    Y = 1:itr_num;

    % this will be the data
    Z1 = results(idx,m2,:);
    Z2 = results(idx,m2+3,:);

    s1 = scatter3(X, Y, Z1, 15, 'filled', 'b');   
    s2 = scatter3(X, Y, Z2, 15, 'filled', 'g');

end

set(gca,'fontweight','bold');

% Y-Axis
ylim([-1 itr_num]);
yticks([0:1:itr_num-1]);
%ylim([0.85 1]);
%yticks([0:0.05:1]);
%ytickformat('%1.2f')
ylabel('Iteration Number', 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
%set(gca,'TickLabelInterpreter','none')
xlim([0 N+1]);
xticks([1:1:N]);
%set(gca,'XMinorTick','on', 'XMinorGrid','on');
xlabel('Particle Number', 'fontweight', 'bold', 'FontSize', 13);
%xticklabels(test_label);

% Z-axis
zlim(z_lim(metric,:))
zticks(z_ticks);
zlabel(z_label_name{m2}, 'fontweight', 'bold', 'FontSize', 13);

view(60,45);

%title('MNIST Multi-Training Event - Test Results Distribution','fontweight','bold','FontSize', 15)

plot_num = plot_num + 1;

end

%% plot the particle results on the training distribution graph
limits_test = [];
sig_m = 2;

test_acc_stats = [.95,.95; 0.999,0.99; 1.0,0.9951; 0.001,0.005];

% get the lower limits
limits_test(1,1) = test_acc_stats(2,2) - sig_m*test_acc_stats(4,2);

% get the upper limits
limits_test(1,2) = test_acc_stats(2,2) + sig_m*test_acc_stats(4,2);

[g_best, g_best_index] = max(particle_max);

figure(plot_num)
set(gcf,'position',([50,50,1200,700]),'color','w')
hold on
box on
grid on

%plot the area
a1 = [-1,limits_test(1,2); N+2,limits_test(1,2); N+2,limits_test(1,1); -1,limits_test(1,1)];
%a2 = [-1,limits_test(5,2); num_scene+2,limits_test(5,2); num_scene+2,limits_test(5,1); -1,limits_test(5,1)];

p1 = patch('Faces',[1 2 3 4], 'Vertices',a1,'FaceColor','blue','FaceAlpha',0.3, 'LineStyle','-','EdgeColor','b', 'LineWidth', 1);
%patch('Faces',[1 2 3 4], 'Vertices',a2,'FaceColor','blue','FaceAlpha',0.3, 'LineStyle','-','EdgeColor','b', 'LineWidth', 1);

%plot the mean line - maybe
p2 = plot([-1,N+2],[test_acc_stats(2,2), test_acc_stats(2,2)], '--b', 'LineWidth', 1);

% plot the test points
p3 = scatter([1:N], particle_max, 17, 'filled', 'k');
p4 = scatter(g_best_index, g_best, 20, 'filled', 'g');

set(gca, 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
xlim([0 N+1]);
xticks([1:N]);
xlabel(strcat('Particle Number'), 'fontweight', 'bold', 'FontSize', 13);

% Y-Axis
%plt_max = ceil(limits_test(2,2)*80)/80;
%plt_min = floor(limits_test(2,1)*80)/80;
plt_max = 1.02;
plt_min = 0.96;

ylim([plt_min plt_max]);
yticks([plt_min:0.01:plt_max]);
ytickformat('%1.3f')
ylabel('Test Accuracy', 'fontweight', 'bold', 'FontSize', 13);

title('MNIST PSO Particle Best Results','fontweight','bold','FontSize', 16)
legend([p1, p2, p3, p4], strcat(32,'{\pm}',num2str(sig_m),'{\sigma} Trial Bounds'), 'Trial Mean', 'P-Best Results', 'G-Best Results', 'location', 'southoutside', 'orientation', 'horizontal')

ax = gca;
ax.Position = [0.07 0.14 0.91 0.8];

%print(plot_num, '-dpng', fullfile(save_path,strcat('dfd_pso_best_results.png')));

plot_num = plot_num + 1;  


%% The end
fprintf('Complete!\n');


