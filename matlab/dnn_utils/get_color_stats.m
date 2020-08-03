format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;


%% select the data file with the images

file_filter = {'*.txt','Text Files';'*.*','All Files' };
startpath = 'D:\Projects\';

[input_file, input_path] = uigetfile(file_filter, 'Select Data Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% check to see if the inputs are normal or grouped

% Construct a questdlg with three options
%file_choice = questdlg('Select Input File Type:', 'File Type', 'Normal', 'Grouped', 'Cancel', 'Normal');

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

%% parse through the data

red = 0;
green = 0;
blue = 0;
gray = 0;

for idx=1:length(params)    

    % this is expected to be a 3-channel color image
    img = imread(fullfile(data_directory, params{idx}{file_index}));
%     img = img(:,:,1:3);

    if(size(img,3) == 1)
        r = mean(mean(img));
        g = mean(mean(img));
        b = mean(mean(img));
        gr = mean(mean(img));     
    else
        r = mean(mean(img(:,:,1)));
        g = mean(mean(img(:,:,2)));
        b = mean(mean(img(:,:,3)));
        gr = mean(mean(rgb2gray(img)));
    end
    
    red = red + r;
    green = green + g; 
    blue = blue + b;
    gray = gray + gr;
    
    fprintf('%05d: %s - %3.4f, %3.4f, %3.4f\n', idx, params{idx}{file_index}, r, g, b);

end

red = red/length(params);
green = green/length(params);
blue = blue/length(params);
gray = gray/length(params);

fprintf('red:   %3.4f\n', red);
fprintf('green: %3.4f\n', green);
fprintf('blue:  %3.4f\n', blue);
fprintf('gray:  %3.4f\n', gray);

fprintf('%8.4f, %8.4f, %8.4f, %8.4f\n', red, green, blue, gray);


