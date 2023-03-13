format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% 

file_filter = {'*.png','PNG Files'; '*.*','All Files'};

[data_file, data_path] = uigetfile(file_filter, 'Select LIDAR data file');
if(data_path == 0)
    return;
end

%%

img = imread(fullfile(data_path, data_file));

%% setup the expansion

block_w = 5;
block_h = 5;

spacing_x = 10;
spacing_y = 10;

img_w = block_w * floor(size(img, 2)/block_w);
img_h = block_h * floor(size(img, 1)/block_h);

img = img(1:img_h, 1:img_w, :);

exp_x = spacing_x * floor(size(img, 2)/block_w);
exp_y = spacing_y * floor(size(img, 1)/block_h);

%%

rows = 1;
cols = 1;
r2 = 1;
c2 = 1;

offset = false;

img_exp = zeros(exp_y, exp_x, 3);

while (rows < (exp_y-spacing_y+1))
    if(offset)
        cols = block_w+1;
    else
        cols = 1;
    end
    c2 = 1;
    
    while (cols < (exp_x-spacing_x+1))
        
        img_exp(floor(rows:(rows+block_h-1)), floor(cols:(cols+block_w-1)), :) = img(r2:(r2+block_h-1), c2:(c2+block_w-1), :);
        c2 = c2 + block_w;
        cols = cols + spacing_x;
    end
    
    offset = ~offset;
    r2 = r2 + block_h;
    rows = rows + spacing_y;
end


%%
imwrite(uint8(img_exp), fullfile(data_path, 'expanded_image.png'));

