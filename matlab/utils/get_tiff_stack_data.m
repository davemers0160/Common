format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get the tiff file

file_filter = {'*.tiff','tiff Files'; '*.tif','tif Files'; '*.*','All Files' };
%startpath = 'D:\Projects\';

[input_file, input_path] = uigetfile(file_filter, 'Select tiff Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% read in the 

[img] = read_tiff_stack(fullfile(input_path, input_file));


%% display the images

for idx=1:numel(img)
    min_img = double(min(img{idx}(:)));
    max_img = double(max(img{idx}(:)));
    img{idx} = uint8(255*((double(img{idx})-min_img)/(max_img-min_img)));
    imshow(img{idx});
end

%% export individual images...

img_path = uigetdir(startpath, 'Select Folder to Save Images');

if(img_path == 0)
    return;
end

for idx=1:numel(img)
    
    img_filename = fullfile(img_path, strcat('image_', num2str(idx, '%04d'), '.png'));
    fprintf('saving: %s\n', img_filename);
    imwrite(img{idx}, img_filename);
    
end

