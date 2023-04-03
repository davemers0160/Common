format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get the video file

file_filter = {'*.avi; *.mp4; *.mov','Video Files';'*.*','All Files' };
startpath = 'C:\Projects\data';

[input_file, input_path] = uigetfile(file_filter, 'Select Video File', startpath);
if(input_path == 0)
    return;
end


commandwindow;

%% read in video

v = VideoReader(fullfile(input_path, input_file));

frame = {};

% read in all of the frames
while hasFrame(v)
    frame{end+1} = readFrame(v);
end

%% save the data as a mat file for later use

file_filter = {'*.mat','Mat Files';'*.*','All Files' };
[~,save_file,~] = fileparts(input_file);

[save_file, save_path] = uiputfile(file_filter, 'Select Save Mat File', fullfile(input_path,strcat(save_file,'.mat')));

if(save_path == 0)
    return;
end

save(fullfile(save_path, save_file), 'frame2');
