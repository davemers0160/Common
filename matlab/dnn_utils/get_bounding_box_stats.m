format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get the data file
startpath = 'D:\Projects\';
file_filter = {'*.txt','Text Files';'*.*','All Files' };

[input_file, input_path] = uigetfile(file_filter, 'Select Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% check to see if the inputs are normal or grouped

[param_type, file_index] = file_params_dialog;

switch param_type
    case 'Normal'
        params = parse_input_parameters(fullfile(input_path, input_file));

    case 'Grouped'
        params = parse_grouped_input_paramters(fullfile(input_path, input_file), {'{', '}'});
        
    case 'Cancel'
        return;
end

% get the directory for the data
data_directory = params{1}{1};
params(1) = [];
file_index = file_index + 1;

%% run through the entries and get the bounding box info
image_files = cell(numel(params),1);
box = {}; %cell(numel(params),1);
label = {}; %cell(numel(params),1);
ul = {};

for idx=1:numel(params)
    image_files{idx,1} = strcat(data_directory,params{idx}{1});
    
    index = 1;
    b = [];
    l = {};
    for jdx=file_index:numel(params{idx})
        gp = parse_csv_line(params{idx}{jdx});
        
        box{end+1, 1} = [str2double(gp{1}), str2double(gp{2}), str2double(gp{3}), str2double(gp{4})];
        
        label{end+1, 1} = gp{5};
        
        index = index + 1;
    end

end

% get the unique labels
label_names = unique(label);
num_classes = numel(label_names);

%% start the analysis

min_width = zeros(1, num_classes);
max_width = zeros(1, num_classes);

min_w = [];
max_w = [];

for idx=1:numel(box)
    % need to get the min/max/mean and number of each class
    
    
    
    
    
    
end








