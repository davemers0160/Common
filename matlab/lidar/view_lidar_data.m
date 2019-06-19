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

startpath = 'D:\IUPUI\Test_Data\';
[data_file, data_path] = uigetfile(file_filter, 'Select Binary Lidar File', startpath);
if(data_path == 0)
    return;
end

%% read in the data

[data] = read_binary_lidar_data(fullfile(data_path, data_file));

max_data = (floor(max(data(:))/1000) + 1) * 1000;


%% plot the data
figure(plot_num)
set(gcf,'position',([100,100,1300,400]),'color','w')
%image(data);
imagesc(data);
%colormap(jet(max_data));
colormap(jet(500));
axis off
ax = gca;
ax.Position = [0.05 0.05 0.90 0.90];

plot_num = plot_num + 1;

%% convert the data to a point cloud
t = data(2:63,925:1125);
load('D:\Common\matlab\lidar\OS1_991838000603.mat');
[lx, ly, lz] = convert_lidar_to_xyz(lidar_struct, t);

% get the data into the form of M x N x 3
l_xyz = cat(3,lx,ly,lz);

R = sqrt(lx.*lx + ly.*ly + lz.*lz);

pc1 = pointCloud(l_xyz,'Intensity',R);

figure(plot_num);
pcshow(pc1);




