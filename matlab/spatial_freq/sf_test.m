format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% setup the example

pixels_per_um = 100;                                 % number of pixels per um

sample_rate = (pixels_per_um * 1e6);                % spatial resolution
spatial_step = 1/sample_rate;

fprintf('pixels_per_um = %10.5f\n', pixels_per_um);
fprintf('sample_rate (px/meter) = %d\n', sample_rate);
fprintf('spatial_step (meter/px) = %10.9f\n', spatial_step);
fprintf('spatial_step (um/px) = %10.9f\n', spatial_step*1e6);

% create example data set
% cos operates on the cycle of 0->2pi
% to create a sin wave the repeats every 70um we need to map 70um to 2pi
% 0->1 where 1 represents 70um
s = 70e-6;                              % m
w = (1/s);
num_cycles = 12;

data = 0.9*cos(2*pi*w*(0:spatial_step:(num_cycles*s-spatial_step)));
data2 = 0.9*cos(2*pi*(1/8e-7)*(0:spatial_step:(num_cycles*s-spatial_step)));

data = (data+data2)/2;

num_data = size(data, 2);

image_size = spatial_step * num_data;
fprintf('image_size (um) = %10.9f\n', image_size);             % current setup: 1 pixel == 400nm/0.4um/


%%
figure;
plot(spatial_step*(0:num_data-1)*1e6, data,'b')
% plot((0:num_data-1), data,'b')

xlabel('um', 'fontweight','bold');

%%
% https://www.physicsforums.com/threads/spatial-frequency-of-pixels-in-an-fft-transformed-image.679406/

fft_half = floor(num_data/2);

S = (0:num_data-1);

Y = fft(data)/num_data;

Y_abs = 20*log10(abs((Y))) + 1e-6;

Y_abs(isinf(Y_abs)) = -200;

figure;
% plot(S(1:fft_half)*(1/(spatial_step*1e6))*2*pi*pixels_per_um, Y_abs(1:fft_half), 'b')
plot(S(1:fft_half)*(sample_rate/num_data), Y_abs(1:fft_half), 'b')




