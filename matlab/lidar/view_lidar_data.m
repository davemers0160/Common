format long g
format compact
clc
%close all
%clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ~] = fileparts(full_path);
plot_num = 1;

%% get the user input to the lidar scan
file_filter = {'*.bin','Binary Files';'*.*','All Files' };

startpath = 'D:\IUPUI\Test_Data\real_world_raw\';
[data_file, data_path] = uigetfile(file_filter, 'Select DFD-Net Log File', startpath);
if(data_path == 0)
    return;
end

%% plot the data

[data] = read_binary_lidar_data(fullfile(data_path, data_file));

max_data = max(data(:));

figure(plot_num)
set(gcf,'position',([100,100,1200,400]),'color','w')
image(data);
%colormap(jet(max_data));
colormap(jet(40000));
axis off
ax = gca;
ax.Position = [0.05 0.05 0.90 0.90];

plot_num = plot_num + 1;
