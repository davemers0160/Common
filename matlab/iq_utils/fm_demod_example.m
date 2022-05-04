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

%% read in IQ data
data_type = 'int16';
byte_order = 'ieee-le';

%% select the file
startpath = 'D:/Projects/';

file_filter = {'*.bin','Binary Files';'*.*','All Files' };

% the input mat file should be a single table with all of the image file
% names and rectangular bounding boxes
[filename, data_path] = uigetfile(file_filter, 'Select the *.bin file with the IQ data', startpath);
if(data_path == 0)
    return;
end

% load the data
[~, iq_data, ~, ~] = read_binary_iq_data(fullfile(data_path, filename), data_type, byte_order);
num_samples = numel(iq_data);

%% set up some parameters
% this is the sample rate of the capture
rf_fs = 1e6;        

% offset from the center where we want to demodulate
f_offset = 50000; 

% the FM broadcast signal has a bandwidth of approximately 10 kHz
rf_ch_bw = 100000;

% number of taps to create a low pass RF filter
rf_taps = 200;

% rf cutoff frequency
rf_fc = 50000;

% find a decimation rate to achieve audio sampling rate between 44-48 kHz
audio_fs = 25000; 

% audio filter cutoff frequency (Hz)
audio_fc = 8000;

% number of taps to create a low pass audio filter  
audio_taps = 200;

%% setup the fequency specifics

% size of each block to process
block_size = rf_fs; % 1 second block size

% number of total blocks
num_blocks = floor((num_samples)/block_size);

% print out all of the specs
fprintf('------------------------------------------------------------------\n');
fprintf('rf_fs:      %d\n', rf_fs);
fprintf('f_offset:   %d\n', f_offset);
fprintf('channel_bw: %d\n', rf_ch_bw);
fprintf('audio_fs:   %d\n', audio_fs);
fprintf('------------------------------------------------------------------\n');

%% do it all at once

% [audio_out, audio_fs_actual] = fm_demod(iq_data, rf_fs, rf_ch_bw, rf_fc, rf_taps, f_offset, audio_fs, audio_fc, audio_taps);
% 
% sound(audio_out, audio_fs_actual);


%% block processing loop

for idx=1:num_blocks
    
    x1 = iq_data((1:block_size)+(idx-1)*block_size);
    
    [audio_out, audio_fs_actual] = fm_demod(x1, rf_fs, rf_ch_bw, rf_fc, rf_taps, f_offset, audio_fs, audio_fc, audio_taps);

    sound(audio_out, audio_fs_actual);    
    pause(0.94*(block_size/rf_fs));

end


%% section to save the audio to a wave file
% filename = 'd:/Projects/apt-decoder-master/examples/noaa18_202202013_1201.wav';
% audiowrite(filename, x7a*3.5, 20800);

