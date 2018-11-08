format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);

%% get the user input to the lidar scan
file_filter = {'*.bin','Binary Files';'*.*','All Files' };

startpath = 'D:\IUPUI\Test_Data\rw\';
[data_file, data_path] = uigetfile(file_filter, 'Select Binary Lidar File', startpath);
if(data_path == 0)
    return;
end

folders = strsplit(data_path,filesep);

%%
[data] = read_binary_lidar_data(fullfile(data_path, data_file));

max_data = (floor(max(data(:))/1000) + 1) * 1000;

save_path = 'D:\IUPUI\PhD\Images\lidar\';
s_data = uint8(255*(data/max_data));

figure
image(s_data)
colormap(jet(256))
axis off

imwrite(s_data,jet(256),fullfile(save_path,strcat(folders{5},'_color_lidar.png')));

