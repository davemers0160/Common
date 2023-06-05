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

%% load in a sample audio file

% creates y & Fs
load 'D:\data\test_audio.mat';
% y = y(1:(2^15-1));
% y = resample(y, 61, 10);

Fs = 50e3;
t_audio = 1/Fs;

% y = cos(2*pi()*2000*t_audio*(0:1:((2^16)-1)));
% y = cat(2,y, cos(2*pi()*4000*t_audio*(0:1:((2^16)-1))));


num_samples = numel(y);

%% RF specifics

fc = 5e3;
fs = 1e6;

beta = 0.5;

m = exp(1i * beta * y);

f = exp(1i*2*pi()*fc*t_audio*(0:1:num_samples-1));

s = m(:).*f(:);

%%

figure;
plot(y, 'b');

figure;
plot(real(s), 'b');


figure
Y = fft((s), 1024)/1024;
plot(linspace(-Fs/2,Fs/2,1024),fftshift(20*log10(abs(Y))), 'b')

%%

M = 20;
n_taps = 201;

x1 = upsample(y, M);

fc = 1.0/(2*M);

% create the full filter using the window
w = nuttall_window(n_taps);
lpf_fm = create_fir_filter(fc, w);

x2 = conv(x1, M*lpf_fm(end:-1:1), 'same');

fs_ts = 1/fs;

f = exp(1i*2*pi()*fc*(0:1:numel(x2)-1));
s2 = real(exp(1i * beta * x2));%.*f(:);

%% 

rf_fs = fs;
rf_ch_bw = 200e3;
rf_fc = 50e3;
rf_taps = 201;
f_offset = 0;
audio_fs = 50e3;
audio_fc = 25e3;
audio_taps = 201;
[audio_out, audio_fs_actual] = fm_demod(s2, rf_fs, rf_ch_bw, rf_fc, rf_taps, f_offset, audio_fs, audio_fc, audio_taps);
audio_out = 5.5*audio_out;

sound(audio_out, audio_fs_actual);

%% save
s2_int = int16(1850 * s2);

data_type = 'int16';
filename = 'D:/data/fm_test_1M.sc16';
write_binary_iq_data(filename, s2_int, data_type)

%%
fft_size = 2048;

figure;
plot(real(x2), 'b');

figure;
plot(real(s2), 'b');


figure
Y2 = fft((s2), fft_size)/fft_size;
plot(linspace(-fs/2,fs/2,fft_size), fftshift(20*log10(abs(Y2))), 'b')





