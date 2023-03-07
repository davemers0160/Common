format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% select the folder where the images are stored

data_path = uigetdir("d:\projects\vs_gen", 'Select directory where the data is stored');

if(data_path == 0)
    return;
end


%% get the save name of the file
file_filter = {'*.mp4','MP4 Files'; '*.avi','AVI Files'; '*.*','All Files' };

[save_file, save_path] = uiputfile(file_filter, 'Enter the Save File Name', data_path);
if(save_path == 0)
    return;
end

[~,  save_filename, video_ext] = fileparts(save_file);
commandwindow;

%% read in the images and then create the movie

% set the frame rate
fps = 10;

% get the file type for the video
if(strcmp(video_ext, '.mp4'))
    video_type = 'MPEG-4';

elseif (strcmp(video_ext, '.avi'))
%     video_type = 'Motion JPEG AVI';
    video_type = 'Uncompressed AVI';
else
    fprintf('Incorrect video file type!\n');
    return;
end

% only use this file type to build the video
file_type = '*.png';
listing = dir(strcat(data_path, filesep, file_type));

%% run through the data
data = cell(15,1);%cell(length(listing),1);
for idx=1:length(data)
    fprintf('Opening: %s\n', fullfile(listing(idx).folder, listing(idx).name));
    tmp_img = imread(fullfile(listing(idx).folder, listing(idx).name)); 
    %tmp_img = imresize(tmp_img, 0.5, 'lanczos3');
    %data{idx} = insertMarker(tmp_img, [floor(size(tmp_img, 2)/2), floor(size(tmp_img,1)/2)], '+', 'color', 'red', 'size', 4);
    %data{idx} = insertShape(data{idx}, 'Rectangle', [floor(size(tmp_img, 2)/2)-64, floor(size(tmp_img,1)/2)-64, 128, 128], 'Color', 'yellow', 'LineWidth', 1, 'Opacity',1, 'SmoothEdges', false);
    data{idx} = tmp_img;
end

fprintf('\nBuilding movie...');
create_movie(fullfile(save_path, save_file), data, fps, video_type);
create_animated_gif(fullfile(save_path, strcat(save_filename, '.gif')), 1.0/fps*ones(numel(data),1), data, Inf);

fprintf('\nComplete!');



