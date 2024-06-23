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

v

% read in all of the frames
while hasFrame(v)
    frame{end+1} = readFrame(v);
end

%%

file_filter = {'*.mp4','mp4 Files';'*.*','All Files' };
[~,save_file,~] = fileparts(input_file);

[save_file, save_path] = uiputfile(file_filter, 'Select Save Mat File', fullfile(input_path,strcat(save_file,'_convert.mp4')));

if(save_path == 0)
    return;
end

v_w = VideoWriter(fullfile(save_path,save_file), 'MPEG-4');

bp = 1;

%% open write and close
v_w.FrameRate = 15;
v_w.Quality = 75;

open(v_w)

% for idx = [250:3145,3440:(numel(frame)-180)]
for idx = 30:(numel(frame)-20)
   writeVideo(v_w, frame{idx});
end

close(v_w);

fprintf('Complete\n');

