format long g
format compact
clc
close all
clearvars

%% select the folder containing the data

start_path = 'D:\Projects\';
training_data = uigetdir(start_path, 'Select Data Folder');

if(isempty(training_data))
    return;
end

commandwindow;

%% run through the images and merge them
img = [];

listing = dir(training_data);
listing = listing(3:end);

img_count = numel(listing);

for idx=1:img_count

    if(listing(idx).isdir)
        continue;
    end

    img_file = fullfile(listing(idx).folder, listing(idx).name);

    
    tmp_img = double(imread(img_file))/img_count;
    
    if(isempty(img))
        img = tmp_img;
    else
        img = img + tmp_img;
    end


end
    
bp = 1;

imwrite(uint8(img(:,:,1:3)), fullfile(training_data, 'test_img.png'));

