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

%% load in the data - expecting it to be in the form of 16-bit signed integer, IQIQIQIQ...

% open the file and read as a little-endian 
file_id = fopen(fullfile(input_path, input_file), 'r', 'l');

% read the size
fseek(file_id, 0,'eof');
filesize = ftell(file_id);
fseek(file_id, 0,'bof');

% read in the data
data = fread(file_id, filesize, 'int16');

data = complex(data(1:2:end-1)/2048, data(2:2:end)/2048);

fclose(file_id);

%% display the FFT of the data in a spectrogram

%sample rate
fs =  10e6;
fft_size = 4096;


fft_time_step = fft_size/fs;
freq_bin = fs/fft_size;

overlap = 0;

num_ffts = floor(numel(data)/fft_size);

Z = zeros(num_ffts, fft_size);

fft_offset = 0;

% y(num_ffts, :) = fftshift(fft(data(1+fft_offset:fft_size+fft_offset), fft_size))/fft_size;
% fft_offset = fft_offset + fft_size;

for idx=1:num_ffts
    Z(idx, :) = fftshift(fft(data(1+fft_offset:fft_size+fft_offset), fft_size))/fft_size;
    fft_offset = fft_offset + fft_size;
end

% Z(1, :) = fftshift(fft(data(1+fft_offset:end), fft_size))/fft_size;

%% plot the fft

X = -fs/2:freq_bin:fs/2-freq_bin;
Y = 0:fft_time_step:num_ffts*fft_time_step-fft_time_step;

figure(plot_num)
set(gcf,'position',([100,100,1000,800]),'color','w')

surf(X, Y, 20*log10(abs(Z)));
%surf(X, Y, 2*abs(y));
shading interp;
colormap(jet(1024));

set(gca, 'fontweight', 'bold', 'FontSize', 13);

% X-Axis
xlim([X(1) X(end)]);
xticks(linspace(X(1), X(end), 11));
xticklabels([(-fs/2):1e6:fs/2]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);

% Y-Axis
ylim([Y(1) Y(end)]);
yticks(linspace(Y(1), Y(end), 11));
%yticklabels([0:0.005:0.1]);
ytickformat('%1.3f')
ylabel('Time (s)', 'fontweight', 'bold', 'FontSize', 13);

view(0, 90);
plot_num = plot_num + 1;

%% 
figure(plot_num)
set(gcf,'position',([100,100,1000,800]),'color','w')
pwelch(data,[],[],[],fs,'centered');
plot_num = plot_num + 1;

