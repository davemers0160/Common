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
[mat_save_file, mat_save_path] = uigetfile(mat_file_filter, 'Select Mat File', startpath);
if(mat_save_path == 0)
    return;
end
load(fullfile(mat_save_path,mat_save_file));
%fields = fieldnames(data);

%label_data = data.(fields{1});

commandwindow;

%% convert the ground truth table to cell array and get the label names

label_data = data.Variables;

label_names = data.Properties.VariableNames;
label_names = label_names(2:end);


%% parse through the ground truth object detection table labels

% get the filename to write the data to based on the input mat file
[~, tmp_file, ~] = fileparts(mat_save_file);
file_name = fullfile(mat_save_path, strcat(tmp_file, '_input.txt'));
file_id = fopen(file_name, 'w');

fprintf(file_id, '# Full data listing\n');
fprintf(file_id, '# Data Directory:\n\n');
fprintf(file_id, '# file location, {x,y,w,h,label}, {x,y,w,h,label}, ...\n');

num_images = size(label_data,1);
num_labels = numel(label_names);

% write the data in the following format:
% file location, {x,y,w,h,label}, {x,y,w,h,label},...
for idx=1:num_images
    
    % print out the image file name
    [~,image_name,ext] = fileparts(data{idx,1});
    s_line = strcat(image_name, ext, ',');
    
    % print out the boxes
    for jdx=2:num_labels
        
        if(~isempty(data{idx,jdx}))
            
            num_boxes = size(data{idx,jdx},1);
            
            for kdx = 1:num_boxes         
                s_line = strcat(s_line, num2str(floor(data{idx,jdx}(kdx,1:2)), '{%d,%d,'), num2str(ceil(data{idx,jdx}(kdx,3:4)), '%d,%d,'), label_names{jdx}, '},');
            end           
        end        
    end
    
    s_line = s_line(1:end-1);   
    fprintf('%s\n', s_line);
    fprintf(file_id, '%s\n', s_line);   
end

fclose(file_id);

