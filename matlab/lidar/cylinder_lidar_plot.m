
format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;


%% read in LIDAR data

%file_name = 'D:\IUPUI\Test_Data\real_world_raw\Library2\lidar\lidar_rng_00000_20180919_080140.bin';
%% get the user input to the lidar scan
file_filter = {'*.bin','Binary Files';'*.*','All Files' };

startpath = 'D:\IUPUI\Test_Data\';
[data_file, data_path] = uigetfile(file_filter, 'Select Binary Lidar File', startpath);
if(data_path == 0)
    return;
end

[lidar_data] = read_binary_lidar_data(fullfile(data_path, data_file));

%% plot the flat LIDAR data

figure(plot_num)
set(gcf,'position',([100,100,1000,300]),'color','k')
imagesc(lidar_data);
colormap(jet(500));
axis off
ax = gca;
ax.Position = [0.05 0.05 0.90 0.90];

plot_num = plot_num + 1;

%% create the curved cylinder shape
n = size(lidar_data,2)-1;

t_step = pi/128;

t = 0.25*pi:t_step:(0.75*pi-t_step);
[X,Y,Z] = cylinder(20+5*sin(t),n);

%% plot the cylinder and then overlay the LIDAR data

figure(plot_num)
set(gcf,'position',([100,100,1000,600]),'color','k')

cy = surf(-X,Y,-Z, 'FaceColor', 'none', 'EdgeColor', 'none');

ax = gca;
ax.Visible = 'off';

axis(ax, 'tight');

% Set initial view
view(-90,60);

set(cy, 'FaceColor', 'texturemap', 'CData', lidar_data, 'FaceAlpha', 1, 'EdgeColor', 'none');
colormap(jet(500));

ax.Position = [0.02 0.01 0.96 0.98];

plot_num = plot_num + 1;

%% same as above just with the data unwrapped

% figure(plot_num)
% set(gcf,'position',([100,100,1000,800]),'color','w')
% hold on
% 
% subplot(2,1,1)
% cy = surf(X,Y,-Z, 'FaceColor', 'none', 'EdgeColor', 0.5*[1 1 1]);
% 
% ax = gca;
% ax.Visible = 'off';
% 
% axis(ax, 'tight');
% 
% % Set initial view
% view(90,60);
% 
% set(cy, 'FaceColor', 'texturemap', 'CData', lidar_data, 'FaceAlpha', 1, 'EdgeColor', 'none');
% colormap(jet(500));
% 
% ax.Position = [0.02 0.4 0.96 0.58];
% 
% subplot(2,1,2)
% 
% imagesc(lidar_data);
% colormap(jet(500));
% 
% axis off
% ax = gca;
% ax.Position = [0.05 0.05 0.9 0.35];
% 
% 
% plot_num = plot_num + 1;











