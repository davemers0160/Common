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

kernel_size = 69;
sigma = 20.0;

k = create_1D_gauss_kernel(kernel_size, sigma);

pixels_per_um = 2.5;     % number of nanometers per pixel
s = 70;     %um

pixels_per_um * s/2

% sample rate
scale = 1/pixels_per_um;

% create example data set
data = [0.9*ones(1,87), zeros(1,87)];
data = repmat(data, 1,6);

data = data - mean(data(:));

data = conv(data, k(end:-1:1), 'same');

num_data = size(data, 2);

%%
figure;
plot(scale*(0:num_data-1), data,'b')

xlabel('um', 'fontweight','bold');

%%

fft_half = floor(num_data/2);

S = scale*(0:num_data-1);

Y = fft(data)/num_data;

Y_abs = 20*log10(abs((Y))) + 1e-6;

Y_abs(isinf(Y_abs)) = -200;

figure;
plot(S(1:fft_half), Y_abs(1:fft_half), 'b')




