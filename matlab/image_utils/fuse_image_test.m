format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get image 1

file_filter = {'*.png;*.jpg;*.tif;*.bmp','Image Files'; '*.*','All Files' };

[image_file1, image_path1] = uigetfile(file_filter, 'Select Image 1', startpath, 'multiselect','off');
if(image_path1 == 0)
    return;
end

%% get image 2

[image_file2, image_path2] = uigetfile(file_filter, 'Select Image 1', image_path1, 'multiselect','off');
if(image_path2 == 0)
    return;
end

%% get alpha
prompt = {'Enter alpha value for Image 1:'};
dlgtitle = ' ';
dims = [1 35];
definput = {'0.5'};
alpha = str2double(inputdlg(prompt, dlgtitle, dims, definput));

if(isempty(alpha) || isnan(alpha))
    alpha = 0.5;
end

%% read in images and fuse them
img1 = imread(fullfile(image_path1, image_file1));
img2 = imread(fullfile(image_path2, image_file2));

[img] = fuse_image(img1, img2, alpha);

%% save image

[save_file, save_path] = uiputfile(file_filter,'Save File Name', image_path2);

imwrite(uint8(img), fullfile(save_path, save_file));

