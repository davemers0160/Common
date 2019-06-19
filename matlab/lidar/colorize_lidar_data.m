format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);

%% get the user input to the lidar scan
file_filter = {'*.png','PNG Files'; '*.bin','Binary Files'; '*.*','All Files' };

startpath = 'D:\IUPUI\Test_Data\';
[data_file, data_path] = uigetfile(file_filter, 'Select Binary Lidar File', startpath);
if(data_path == 0)
    return;
end

folders = strsplit(data_path,filesep);

%% get the location to save the data to
save_path = 'D:\IUPUI\PhD\Images\lidar\';
file_filter = {'*.png','PNG Files';'*.*','All Files' };

[save_file, save_path] = uiputfile(file_filter, 'Select Save File', save_path);
if(save_path == 0)
    return;
end

%% read in the data

[~,~,ext] = fileparts(data_file);

if(strcmp(ext,'.bin')==1)

    [data] = read_binary_lidar_data(fullfile(data_path, data_file));
    max_data = (floor(max(data(:))/1000) + 1) * 1000;
    s_data = uint8(255*(data/max_data));
elseif(strcmp(ext,'.png')==1)

    s_data = imread(fullfile(data_path, data_file));    
    max_data = 255;    
end

%% display and save the data

figure
image(s_data)
colormap(jet(256))
axis off

imwrite(s_data,jet(256),fullfile(save_path,save_file));

