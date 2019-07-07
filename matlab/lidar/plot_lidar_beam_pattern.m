format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% load in the lidar struct data
save_path = 'D:\IUPUI\PhD\images\lidar';

load('D:\Common\matlab\lidar\OS1_991838000603.mat');

%% plot the data

figure(plot_num)
set(gcf,'position',([100,100,300,400]),'color','w')

hold on
grid on
box on

scatter(lidar_struct.beam_azimuth_angles,[0:1:63],15,'r','filled')

stem(0,65, 'BaseValue',-1, 'Color','k', 'LineWidth', 1.0, 'Marker', 'none')

set(gca,'fontweight', 'bold')

% X-AXIS
xlim([-4 4]);
xticks([-4:1:4]);
%set(gca,'XMinorTick','on', 'XMinorGrid','on');
xlabel(strcat('Angle (degrees)'), 'fontweight', 'bold', 'FontSize', 13);

% Y-AXIS
ylim([-1 64])
yticks([0:4:64])
ylabel(strcat('LIDAR Beam Number'), 'fontweight', 'bold', 'FontSize', 13);

ax = gca;
ax.Position = [0.17 0.13 0.77 0.84];

print(plot_num, '-dpng', fullfile(save_path,strcat('lidar_beam_pattern.png')));

plot_num = plot_num + 1;
