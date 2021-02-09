format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);

%% get the location of the data
data_path = uigetdir(startpath, 'Select directory where the images are stored');

if(data_path == 0)
    return;
end
%% get the save file name

file_filter = {'*.tiff','Tiff Images Files';'*.*','All Files' };

[save_file, save_path] = uiputfile(file_filter, 'Enter the Tiff File Name', data_path);
if(save_path == 0)
    return;
end

commandwindow;
%% write the images
file_type = '*.png';

listing = get_listing(data_path, file_type);

fprintf('writing...\n');
for idx=1:numel(listing)
    
    fprintf('%s\n', fullfile(listing(idx).folder, listing(idx).name));
    
    img = imread(fullfile(listing(idx).folder, listing(idx).name));
    
    imwrite(img, fullfile(save_path, save_file), 'WriteMode', 'append',  'Compression','none');
end
