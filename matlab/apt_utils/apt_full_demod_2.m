% helpful sites:
% http://www.site2241.net/december2020.htm
% https://noaa-apt.mbernardi.com.ar/how-it-works.html#resampling-algorithm

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

%% get the IQ file

data_type = 'int16';
byte_order = 'ieee-le';

filename = 'D:\Projects\SDR\bladerf\rx_record\recordings\137M000_1M000__600s_20221120_0955.bin';
% filename = 'D:\Projects\bladerf\rx_record\recordings\137M800_1M000__600s_20221120_1110.bin';
filename = 'D:\data\RF\20240224\blade_F137.912M_SR0.624M_20240224_222353.sc16';

[~, iqc] = read_binary_iq_data(filename, data_type, byte_order);

num_samples = numel(iqc);


%% demod parameters
% this is the sample rate of the capture (Hz)
sample_rate = 624000;

% offset from the center where we want to demodulate (Hz)
% f_offset = 116000; 
rf_freq_offset = 0;

% RF decimation factor
rf_decimation_factor = 6;

% rf frequency filter cutoff
fc_rf = 45000;

% the FM broadcast signal has a bandwidth (Hz)
% fm_channel_bw = 45000;

% FM cutoff frequency
fc_fm = 20000;

% AM signal offset
am_offset = 2400*1;

% AM filter cutoff frequency
fc_am = 2*2400;

am_decimation_factor = 5;

am_sample_rate = 4160;

% number of taps to create a low pass RF filter
rf_taps = 200;

% number of taps for the FM filtering
fm_taps = 200;


%% calculate the additional parameters

% calculate the new sampling rate based on the original and the decimated sample rate
decimated_sample_rate = sample_rate/rf_decimation_factor;

% scaling for tangent
% phasor_scale = 1.0 /((2 * pi()) / (decimated_sample_rate / fm_channel_bw));
phasor_scale = 1.0 /((2 * pi()));

am_sample_rate = decimated_sample_rate/am_decimation_factor;

% plot the spectrogram
% figure;
% spectrogram(iqc(1:(5*fs)), 4096, 1024, 4096, fs, 'centered');

%% setup the specific decimation rates


% create a low pass filter using the blackman window
% need to generate a conversion from the sampling rate to +/- pi
% as an added bonus matlab goes from 0 - 1, where 1 is sampling rate / 2
% fs/fs = 1; channel_bw/fs = 
%freq_cutoff = pi()/(fs/2) * (channel_bw / 4.0);
lpf_rf = fir1(rf_taps, fc_rf/sample_rate, 'low');

lpf_fm = fir1(fm_taps, fc_fm/decimated_sample_rate, 'low');


% dec_audio = (fs_d/fs_audio);  
% fs_audio = fs_d / dec_audio;

% number of total blocks
% num_blocks = floor((num_samples)/block_size);


lpf_am = fir1(fm_taps, fc_am/am_sample_rate, 'low');

%% print out the parameters

fprintf('sample_rate: %d\n', sample_rate);
fprintf('frequency_offset: %d\n', rf_freq_offset);
fprintf('rf_decimation_factor: %d\n', rf_decimation_factor);
fprintf('decimated_sample_rate %d\n', decimated_sample_rate);
fprintf('fc_fm: %d\n', fc_fm);
fprintf('fc_rf: %d\n', fc_rf);
fprintf('phasor_scale: %d\n', phasor_scale);
fprintf('am_offset: %d\n', am_offset);
fprintf('am_decimation_factor: %d\n', am_decimation_factor);
fprintf('am_sample_rate: %d\n', am_sample_rate);
fprintf('fc_am: %d\n', fc_am);

fprintf('\n');

%% start block processing

% number of samples to process at one time
block_size = floor(sample_rate);    %65536*8;

fft_size = 8192;
fft_bin = floor((rf_freq_offset/sample_rate) * fft_size);
fft_width = 28;

% number of total blocks
num_blocks = floor((num_samples)/block_size);

rf_rot = exp(1.0j*2.0*pi() * (rf_freq_offset/sample_rate) * (0:(block_size-1)))';

x10 = [];
x4 = [];

fprintf('Number of blocks to process: %04d\n', num_blocks);
for idx=1:num_blocks
    
    fprintf('Processing block: %05d\n', idx-1);
    
    index = (1:block_size)+(idx-1)*block_size;
    
    x1 = iqc(index)/2048;

    % perform the frequency rotation to put the desired frequency at 0Hz
    x2 = x1 .* rf_rot;

    % filter the frequency shifted signal since there is a close signal
    x3 = filter(lpf_rf, 1, x2);

    % downsample
%     x4 = x3(floor(1:rf_dec_rate:numel(x3)));
    x4 = cat(1, x4, x3(floor(1:rf_decimation_factor:numel(x3))));
end

fprintf('Processing Complete!\n');

%%
% filter the downsampled RF
x5 = filter(lpf_fm, 1, x4);

% spectrogram(x5, 4096, 1024, 4096, decimated_sample_rate, 'centered');

x5a = x5(2:end) .* conj(x5(1:end-1));
x6 = angle(x5a) * phasor_scale;


% rotate the signal
am_rot = exp(1i*-2.0*pi()* am_offset/decimated_sample_rate*(0:(numel(x6)-1)))';
x7 = x6 .* am_rot;

% filter the am
x8 = filter(lpf_am, 1, x7);

% magnitude
x9 = abs(x8);

% downsample the AM
x10 = x9(floor(1:am_decimation_factor:numel(x9)));   

 
%% digitize

% x = prctile(x10, [0.1, 99.8]);

% min_val = min(x);
% max_val = max(x);

min_val = min(x10);
max_val = max(x10);

delta = max_val - min_val;

% Normalize the signal to px luminance values, discretize
x11 = floor((255 * (x10 - min_val) / delta) + 0.5);

d5 = x11;
d5(d5 < 0) = 0;
d5(d5 > 255) = 255;

%% correlations

d5s = d5 - 128;
% sync = [0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 0 0] - 128;
sync = 255*[0 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0] - 128;
% sync = 255*[0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0 0 0 0] - 128;

mindistance = 2000;

peaks = [1,0];

idx = 1;

while(idx <= numel(d5s)-numel(sync))
% for idx=1:numel(d5s)-numel(sync)

    c5d(idx) = dot(sync, d5s(idx:idx+numel(sync)-1))/numel(sync);

    corr = c5d(idx);

    % If previous peak is too far, we keep it but add this value as new
    if ((idx - peaks(end,1)) > mindistance)
        peaks(end+1,:) = [idx, corr];
%         idx = idx + ceil(mindistance/4);
    elseif (corr > peaks(end,2))
        peaks(end,:) = [idx, corr];
    end
    idx = idx + 1;
end

%%

img = [];

for idx=1:(size(peaks,1) - 2)
    img = cat(1,img, d5(peaks(idx,1):peaks(idx,1)+2079)');
end

figure
image(uint8(img));
colormap(gray(256));