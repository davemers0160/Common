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
[mat_save_file, mat_path] = uigetfile(mat_file_filter, 'Select ground truth mat file', startpath);
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

%% get the save location
save_path = uigetdir(startpath, 'Select save directory');

if(save_path == 0)
    return;
end

%% get the location of the data
data_path = uigetdir(startpath, 'Select directory where the data is stored');

if(data_path == 0)
    return;
end

%% get the input file base name
file_filter = {'*.txt','Text Files';'*.*','All Files' };

[base_save_file, input_save_path] = uiputfile(file_filter, 'Enter Base File Name', save_path);
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

scale_folder_name = {'full','half','third','quarter'};
scales = [1.0, 1/2, 1/3, 1/4];
num_scales = numel(scale_folder_name);

%% parse through the ground truth object detection table labels

% get the filename to write the data to
[~, tmp_file, file_ext] = fileparts(base_save_file);

% cycle through
parfor idx=1:num_scales
    
    data_directory = strcat(save_path,'/',scale_folder_name{idx},'/');
    fprintf('Creating directory: %s\n', data_directory);
    
    mkdir(data_directory);
    
    file_name = fullfile(input_save_path, strcat(tmp_file, '_', scale_folder_name{idx}, '_input.txt'));
    file_id = fopen(file_name, 'w');
  
    fprintf(file_id, '# Full data listing\n');
    fprintf(file_id, '# Data Directory:\n');
    fprintf(file_id, '%s\n\n', data_directory);
    fprintf(file_id, '# file location, {x,y,w,h,label}, {x,y,w,h,label}, ...\n');

    % write the data in the following format:
    % file location, {x,y,w,h,label}, {x,y,w,h,label},...
    for jdx=1:num_images
        
        % get the image file name
        [~,image_name,ext] = fileparts(data{jdx,1}{1});
        
        % load the image and then resize based on the current scale setting
        img = imread(fullfile(data_path, strcat(image_name, ext)));
        img = imresize(img, scales(idx));
        
        image_file_name = strcat(image_name, ext);
        
        % save the image resized image
        imwrite(img, strcat(data_directory,image_file_name));
        
        s_line = strcat(image_file_name, ',');

        % print out the boxes
        for kdx=2:num_labels+1

            if(~isempty(data{jdx,kdx}))

                tmp_boxes = data{jdx,kdx}{:};
                num_boxes = size(tmp_boxes,1);

                for mdx = 1:num_boxes         
                    s_line = strcat(s_line, num2str(floor(tmp_boxes(mdx,1:2)*scales(idx)), '{%d,%d,'), num2str(ceil(tmp_boxes(mdx,3:4)*scales(idx)), '%d,%d,'), label_names{kdx-1}, '},');
                end           
            end        
        end

        s_line = s_line(1:end-1);   
        fprintf('%s\n', s_line);
        fprintf(file_id, '%s\n', s_line);   
    end

    fclose(file_id);

end

