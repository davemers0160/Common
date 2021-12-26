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
filename = 'D:\Projects\bladerf\rx_record\recordings\162M400_1M__10s_test.bin';
data_type = 'uint16';
byte_order = 'ieee-le';

[iq, iqc, i_data, q_data] = read_binary_iq_data(filename, data_type, byte_order);


%% setup the fequency specifics
% this is the sample rate of the capture
fs = 1e6;

% offset from the center where we want to demodulate
f_offset = 50000; 

% the FM broadcast signal has a bandwidth of approximately 10 kHz
fm_bw = 12500;

% decimation rate
dec_rate = floor(fs / fm_bw);

% number of taps to create a filter
n_taps = 64;

% size of each block to process
block_size = 65536*4;

% create a low pass filter using the blackman window
% lpf = blackman(n_taps, 'symmetric');
filter_half_bw = pi()/fs * (fm_bw / 4.0);
lpf = fir1(n_taps, filter_half_bw);

% create a frequency shift vector to mix the data down, generate a digital complex exponential 
fc1 = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(block_size-1)));

% calculate the new sampling rate based on the original and the decimated sample rate
fs_d = fs/dec_rate;

% scaling for tangent
phasor_scale = 1/((2 * pi()) / (fs_d / fm_bw));

% number of total blocks
num_blocks = floor(numel(iqc)/block_size);

lpf_fft = fft(lpf, block_size);

%% plot the spectrogram
figure;
spectrogram(iqc(1:1e6), 4096, 1024, 4096, fs, 'centered');
    
%% block processing loop
for idx=1:num_blocks

    x1 = iqc((1:block_size)+(idx-1)*block_size);
    
    % perform the frequency rotation to put the desired frequency at 0Hz
    x2 = x1 .* fc1(:);

    % plot the spectrum
%     figure(1);
%     spectrogram(x2, 4096, 1024, 4096, fs, 'centered');
    
    %x2 = fft(x2);

    % double filter the frequency shifted signal since there is a close signal
    x3 = filter(lpf, 1, x2);
%     x3 = filter(lpf, 1, x3);
%     x3 = x2 .* lpf_fft(:);
    
    % plot the spectrum
%     figure(2);
%     spectrogram(x3, 4096, 1024, 4096, fs, 'centered');

    % decimate the shifted signal
%     x3 = ifft(x3);
    x4 = x3(1:dec_rate:end);
    


    % plot the spectrum
%     figure(1);
%     spectrogram(x4, 2048, 1024, 2048, fs_d, 'centered');

%     figure(2);
%     scatter(real(x4), imag(x4), '.', 'b');

    y5 = x4(2:end) .* conj(x4(1:end-1));
    x5 = angle(y5) * phasor_scale;


    d = fs_d * 75e-6;   % Calculate the # of samples to hit the -3dB point  
    x = exp(-1/d);      % Calculate the decay between each sample  
    b = [1-x];          % Create the filter coefficients  
    a = [1,-x];  
    x6 = filter(b,a,x5);  

    % find a decimation rate to achieve audio sampling rate between 44-48 kHz
    audio_freq = 10000.0; 
    dec_audio = floor(fs_d/audio_freq);  
    fs_audio = fs_d / dec_audio;
    
    x7 = decimate(x6, dec_audio);

%     x7 = x6(1:dec_audio:end);
    % x7 = int16(x7 * 10000 / max(abs(x7(:))));

    x7 = x7/ max(abs(x7(:)));

    % play the audio
    sound(x7, fs_audio);
    pause(0.2);
end
