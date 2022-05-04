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

filename = 'D:\Projects\bladerf\rx_record\recordings\162M400_1M__10s_test.bin';

% this is the sample rate of the capture
rf_fs = 1e6;        

% the FM broadcast signal has a bandwidth of approximately 10 kHz
rf_ch_bw = 50000;

% number of taps to create a low pass RF filter
rf_taps = 100;

% rf cutoff frequency
rf_fc = 50000;

% offset from the center where we want to demodulate
f_offset = 50000; 

% find a decimation rate to achieve audio sampling rate between 44-48 kHz
audio_fs = 25000; 

audio_fc = 12000;

% audio filter cutoff frequency (Hz)
fc_audio = 12000;
        
audio_taps = 200;

% load the data
[~, iq_data, ~, ~] = read_binary_iq_data(filename, data_type, byte_order);

num_samples = numel(iq_data);

%% setup the fequency specifics

% size of each block to process
block_size = rf_fs;    %65536*8;

% number of total blocks
num_blocks = floor((num_samples)/block_size);

% print out all of the specs
fprintf('------------------------------------------------------------------\n');
fprintf('fs:         %d\n', rf_fs);
fprintf('f_offset:   %d\n', f_offset);
fprintf('channel_bw: %d\n', rf_ch_bw);
fprintf('audio_freq: %d\n', audio_fs);
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
    
    pause(0.9*(block_size/rf_fs));
end


%% section to save the audio to a wave file
% filename = 'd:/Projects/apt-decoder-master/examples/noaa18_202202013_1201.wav';
% audiowrite(filename, x7a*3.5, 20800);

