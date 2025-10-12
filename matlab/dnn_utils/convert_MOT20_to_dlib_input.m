format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%%

file_filter = {'*.txt','Text Files';'*.*','All Files' };

startpath = 'D:\data\';
[data_file, data_path] = uigetfile(file_filter, 'Select the Data File', startpath);
if(data_path == 0)
    return;
end

%% read in the data

data = read_MOT20(fullfile(data_path, data_file));

% get the unique number of images
image_id = unique(data(:,1));

%% save the data

label = 'person';
data_directory = '';

file_filter = {'*.txt','Text Files';'*.*','All Files' };

[data_save_file, input_save_path] = uiputfile(file_filter, 'Enter Base File Name', data_path);
if(input_save_path == 0)
    return;
end

file_name = fullfile(input_save_path, data_save_file);
file_id = fopen(file_name, 'w');

fprintf(file_id, '# Data Directory:\n');
fprintf(file_id, '%s\n\n', data_directory);
fprintf(file_id, '# file location, {x,y,w,h,label}, {x,y,w,h,label}, ...\n');

for idx=1:numel(image_id)
    
    % get the number of entries equal to the first entry
    M = data(data(:,1) == image_id(idx),:);
    
    % print the image name
    s_line = strcat(num2str(image_id(idx), '%06d'), '.jpg,');
    
    % print the remaining gt detections
    for jdx=1:size(M,1)
        s_line = strcat(s_line, '{', num2str(M(jdx,3:6),'%d,%d,%d,%d,'), label, '},');
    end
    
    s_line = s_line(1:end-1);   
    fprintf('%s\n', s_line);
    fprintf(file_id, '%s\n', s_line);   
    
end

fclose(file_id);

