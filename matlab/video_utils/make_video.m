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

data_path = uigetdir(startpath, 'Select directory where the data is stored');

if(data_path == 0)
    return;
end


%% get the save name of the file
file_filter = {'*.mp4','MP4 Files'; '*.avi','AVI Files'; '*.*','All Files' };

[save_file, save_path] = uiputfile(file_filter, 'Enter the Save File Name', data_path);
if(save_path == 0)
    return;
end

[~,  ~, video_ext] = fileparts(save_file);
commandwindow;

%% read in the images and then create the movie

% set the frame rate
fps = 30;

% get the file type for the video
if(strcmp(video_ext, '.mp4'))
    video_type = 'MPEG-4';

elseif (strcmp(video_ext, '.avi'))
    video_type = 'Motion JPEG AVI';

else
    fprintf('Incorrect video file type!\n');
    return;
end

% only use this file type to build the video
file_type = '*.png';
listing = dir(strcat(data_path, filesep, file_type));

data = cell(length(listing),1);
for idx=1:length(listing)
    fprintf('Opening: %s\n', fullfile(listing(idx).folder, listing(idx).name));
    data{idx} = imread(fullfile(listing(idx).folder, listing(idx).name)); 

end

fprintf('\nBuilding movie...');
create_movie(fullfile(save_path, save_file), data, fps, video_type);

fprintf('\nComplete!');



