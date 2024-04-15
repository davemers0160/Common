format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%%

% setup the example
scale = 1;     % number of nanometers per pixel

% setup an example
data = [0.5*ones(1,10), -0.5*ones(1,10)];
data = repmat(data, 1,10);

w = size(data, 2);

% sample rate
N = w/2;

%%

Y = fft(data)/w;

Y_abs = 20*log10(abs(fftshift(Y))) + 1e-6;

figure;
plot(Y_abs, '--b')




