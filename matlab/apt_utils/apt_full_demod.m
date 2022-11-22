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

filename = 'D:\Projects\bladerf\rx_record\recordings\137M000_1M000__600s_20221120_0955.bin';
% filename = 'D:\Projects\bladerf\rx_record\recordings\137M800_1M000__600s_20221120_1110.bin';

[~, iqc, ~, ~] = read_binary_iq_data(filename, data_type, byte_order);

num_samples = numel(iqc);


%% demod parameters
% this is the sample rate of the capture (Hz)
fs = 1000000;

% offset from the center where we want to demodulate (Hz)
% f_offset = 116000; 
f_offset = 103000;

% number of taps to create a low pass RF filter
rf_taps = 200;

% rf frequency filter cutoff
fc_rf = 45000;

% the FM broadcast signal has a bandwidth (Hz)
fs_rf2 = 100000;

% FM cutoff frequency
fc_fm = 20000;

% number of taps for the FM filtering
fm_taps = 200;

% plot the spectrogram
figure;
spectrogram(iqc(1:(5*fs)), 4096, 1024, 4096, fs, 'centered');

%% setup the specific decimation rates

% RF decimation rate
rf_dec_rate = (fs / fs_rf2);

% create a low pass filter using the blackman window
% need to generate a conversion from the sampling rate to +/- pi
% as an added bonus matlab goes from 0 - 1, where 1 is sampling rate / 2
% fs/fs = 1; channel_bw/fs = 
%freq_cutoff = pi()/(fs/2) * (channel_bw / 4.0);
lpf_rf = fir1(rf_taps, fc_rf/fs, 'low');

lpf_fm = fir1(fm_taps, fc_fm/fs_rf2, 'low');

% calculate the new sampling rate based on the original and the decimated sample rate
fs_d = fs/rf_dec_rate;

% scaling for tangent
phasor_scale = 1.0 /((2 * pi()) / (fs_d / fs_rf2));

% dec_audio = (fs_d/fs_audio);  
% fs_audio = fs_d / dec_audio;

% number of total blocks
% num_blocks = floor((num_samples)/block_size);
am_offset = 2400;
fc_am = 2400;

fs_am = 4160;
    
am_dec_rate = fs_rf2/fs_am;

lpf_am = fir1(fm_taps, fc_am/fs_rf2, 'low');


%% start block processing

% number of samples to process at one time
block_size = floor(fs);    %65536*8;

fft_size = 8192;
fft_bin = floor((f_offset/fs) * fft_size);
fft_width = 28;

% number of total blocks
num_blocks = floor((num_samples)/block_size);

rf_rot = exp(1.0j*2.0*pi() * (f_offset/fs) * (0:(block_size-1)))';

x10 = [];
x4 = [];

fprintf('Number of blocks to process: %04d\n', num_blocks);
for idx=1:num_blocks
    
    fprintf('Processing block %04d\n', idx-1);
    
    index = (1:block_size)+(idx-1)*block_size;
    
    x1 = iqc(index)/2048;

    % perform the frequency rotation to put the desired frequency at 0Hz
    x2 = x1 .* rf_rot;

    % filter the frequency shifted signal since there is a close signal
    x3 = filter(lpf_rf, 1, x2);

    % downsample
%     x4 = x3(floor(1:rf_dec_rate:numel(x3)));
    x4 = cat(1, x4, x3(floor(1:rf_dec_rate:numel(x3))));
end

% filter the downsampled RF
x5 = filter(lpf_fm, 1, x4);

x5a = x5(2:end) .* conj(x5(1:end-1));
x6 = angle(x5a) * phasor_scale;

% rotate the signal
am_rot = exp(-1.0j*2.0*pi()* am_offset/fs_rf2*(0:(numel(x6)-1)))';
x7 = x6 .* am_rot;

% filter the am
x8 = filter(lpf_am, 1, x7);

% magnitude
x9 = abs(x8);

% downsample the AM
x10 = x9(floor(1:am_dec_rate:numel(x9)));   

 
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