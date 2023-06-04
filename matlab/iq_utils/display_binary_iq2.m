format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% select the data file with the images

file_filter = {'*.bin','Binary Files';'*.*','All Files' };
startpath = 'D:\Projects\';

[input_file, input_path] = uigetfile(file_filter, 'Select Binary File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% load in the data - expecting it to be in the form of 16-bit signed integer, IQIQIQIQ...
byte_order = 'ieee-le';

data_type = 'int16';

% open the file and read as a little-endian
[~, data] = read_binary_iq_data(fullfile(input_path, input_file), data_type, byte_order);

data = data/2048;

%% display the FFT of the data in a spectrogram

%sample rate
fs =  20e6;
fft_size = 256;


% fft_time_step = fft_size/fs;
% freq_bin = fs/fft_size;
% 
% overlap = floor(fft_size/2);
% 
% num_ffts = floor(numel(data)/fft_size);
% 
% Z = zeros(num_ffts, fft_size);
% 
% fft_offset = 0;
% 
% y(num_ffts, :) = fftshift(fft(data(1+fft_offset:fft_size+fft_offset), fft_size))/fft_size;
% fft_offset = fft_offset + fft_size;
% 
% for idx=1:num_ffts
%     Z(idx, :) = fftshift(fft(data(1+fft_offset:fft_size+fft_offset), fft_size))/fft_size;
%     fft_offset = fft_offset + fft_size;
% end

% Z(1, :) = fftshift(fft(data(1+fft_offset:end), fft_size))/fft_size;

% %% plot the fft
% 
% X = -fs/2:freq_bin:fs/2-freq_bin;
% Y = 0:fft_time_step:num_ffts*fft_time_step-fft_time_step;
% 
% figure(plot_num)
% set(gcf,'position',([100,100,1000,800]),'color','w')
% 
% surf(X, Y, 20*log10(abs(Z)));
% %surf(X, Y, 2*abs(y));
% shading interp;
% colormap(jet(1024));
% 
% set(gca, 'fontweight', 'bold', 'FontSize', 13);
% 
% % X-Axis
% xlim([X(1) X(end)]);
% xticks(linspace(X(1), X(end), 11));
% xticklabels([(-fs/2):1e6:fs/2]/1e6);
% xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
% 
% % Y-Axis
% ylim([Y(1) Y(end)]);
% yticks(linspace(Y(1), Y(end), 11));
% %yticklabels([0:0.005:0.1]);
% ytickformat('%1.3f')
% ylabel('Time (s)', 'fontweight', 'bold', 'FontSize', 13);
% 
% view(0, 90);
% plot_num = plot_num + 1;
% 
% %% 
% figure(plot_num)
% set(gcf,'position',([100,100,1000,800]),'color','w')
% pwelch(data,[],[],[],fs,'centered');
% plot_num = plot_num + 1;

%%
% figure
% overlap = floor(fft_size/2);
overlap = fft_size - 128;


s1 = spectrogram(data(1:20e6), fft_size, overlap, fft_size, fs, 'centered');

% figure
s2 = spectrogram(data(20e6:40e6), fft_size, overlap, fft_size, fs, 'centered');

% figure
s3 = spectrogram(data(40e6:60e6), fft_size, overlap, fft_size, fs, 'centered');

% figure
s4 = spectrogram(data(60e6:80e6), fft_size, overlap, fft_size, fs, 'centered');

% figure
s5 = spectrogram(data(80e6:100e6), fft_size, overlap, fft_size, fs, 'centered');

% figure
s6 = spectrogram(data(100e6:120e6), fft_size, overlap, fft_size, fs, 'centered');

s7 = spectrogram(data(120e6:140e6), fft_size, overlap, fft_size, fs, 'centered');

s8 = spectrogram(data(140e6:160e6), fft_size, overlap, fft_size, fs, 'centered');

s9 = spectrogram(data(160e6:180e6), fft_size, overlap, fft_size, fs, 'centered');

s10 = spectrogram(data(180e6:200e6), fft_size, overlap, fft_size, fs, 'centered');


%%





