format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% set up some variables

pix_size = 1.6e-6;
object_size = 2.390775/pi;      % c = pi*d

%% get the folder

start_path = 'D:\Projects\';
training_data = uigetdir(start_path, 'Select Data Folder');

if(isempty(training_data))
    return;
end

commandwindow;

%% go through the image and load them
img = {};

listing = dir(training_data);
listing = listing(3:end);

img_count = numel(listing);


for idx=1:img_count

    if(listing(idx).isdir)
        continue;
    end
    img_file = fullfile(listing(idx).folder, listing(idx).name);

    img{end+1} = imread(img_file);
    
end






