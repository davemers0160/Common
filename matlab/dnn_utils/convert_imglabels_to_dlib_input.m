format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;


%% select the file
startpath = 'D:/Projects/';

mat_file_filter = {'*.mat','Mat Files';'*.*','All Files' };

% the input mat file should be a single table with all of the image file
% names and rectangular bounding boxes
[mat_save_file, mat_path] = uigetfile(mat_file_filter, 'Select the *.mat file with the image label data', startpath);
if(mat_path == 0)
    return;
end

% load in the ground truth mat file into a struct and then list it out to
% select the right ground truth table
gt_tmp = load(fullfile(mat_path, mat_save_file));
gt_names = fieldnames(gt_tmp);

[gt_idx, tf] = listdlg('PromptString','Select a GroundTruth Table:',...
                           'SelectionMode','single',...
                           'ListString',gt_names);

if(tf == 0)
    fprintf('No ground truth table was selected!\n');
    return;
end

data = eval(strcat('gt_tmp(gt_idx).',gt_names{gt_idx}));

startpath = mat_path;
clear gt_tmp

%% get the location of the data
data_directory = uigetdir(startpath, 'Select directory where the data is stored');

if(data_directory == 0)
    return;
end

%% get the input file base name
file_filter = {'*.txt','Text Files';'*.*','All Files' };

[base_save_file, input_save_path] = uiputfile(file_filter, 'Enter Base File Name', startpath);
if(input_save_path == 0)
    return;
end

commandwindow;

%% convert the ground truth table to cell array and get the label names

%label_data = data.Variables;
label_data = table2cell(data);

label_names = data.Properties.VariableNames;
label_names = label_names(2:end);

num_images = size(label_data,1);
num_labels = numel(label_names);

%% parse through the ground truth object detection table labels

% get the filename to write the data to
[~, tmp_file, file_ext] = fileparts(base_save_file);    

data_directory = strrep(data_directory, '\', '/');
data_directory = strcat(data_directory,'/');
file_name = fullfile(input_save_path, strcat(tmp_file, '_input.txt'));
file_id = fopen(file_name, 'w');

fprintf(file_id, '# Data Directory:\n');
fprintf(file_id, '%s\n\n', data_directory);
fprintf(file_id, '# file location, {x,y,w,h,label}, {x,y,w,h,label}, ...\n');

% write the data in the following format:
% file location, {x,y,w,h,label}, {x,y,w,h,label},...
for jdx=1:num_images

    % get the image file name
    %[~,image_name,ext] = fileparts(data{jdx,1}{1});
    %image_file_name = strcat(image_name, ext);
    image_file_name = data{jdx,1}{1};
    image_file_name = strrep(image_file_name, '\', '/');
    
    % create an empty char string to store the bounding box data
    s_line = strcat(image_file_name, ',');

    % print out the boxes
    for kdx=2:num_labels+1

        if(~isempty(data{jdx,kdx}))

            tmp_boxes = data{jdx,kdx}{:};
            num_boxes = size(tmp_boxes,1);

            for mdx = 1:num_boxes         
                s_line = strcat(s_line, num2str(floor(tmp_boxes(mdx,1:2)), '{%d,%d,'), num2str(ceil(tmp_boxes(mdx,3:4)), '%d,%d,'), label_names{kdx-1}, '},');
            end           
        end        
    end

    s_line = s_line(1:end-1);   
    fprintf('%s\n', s_line);
    fprintf(file_id, '%s\n', s_line);   
end

fclose(file_id);
