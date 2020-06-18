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

%%

for idx=1:numel(params)
       
    img = imread(fullfile(data_directory, params{idx}{1}));
    
    img = mat2gray(img);
    
    img = gray2ind(img, 256);
        
    imwrite(uint8(img), fullfile(data_directory, params{idx}{1}));
    
end
