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

test_case = 2;

switch test_case

    % NOAA
    case 0
        filename = 'D:\Projects\bladerf\rx_record\recordings\162M400_1M__10s_test.bin';
        
        % this is the sample rate of the capture
        fs = 1e6;        
        
        % number of taps to create a low pass RF filter
        n_taps = 80;
        
        % offset from the center where we want to demodulate
        f_offset = 50000; 
        
        % the FM broadcast signal has a bandwidth of approximately 10 kHz
        channel_bw = 25000;

        % find a decimation rate to achieve audio sampling rate between 44-48 kHz
        audio_freq = 20000; 
        
    % FM radio
    case 1
        filename = 'D:\Projects\bladerf\rx_record\recordings\096M600_1M__10s_test.bin';
        
        % this is the sample rate of the capture (Hz)
        fs = 1e6;        
        
        % number of taps to create a low pass RF filter
        n_taps = 100;
        
        % offset from the center where we want to demodulate (Hz)
        f_offset = 100000; 
        
        % the FM broadcast signal has a bandwidth (Hz)
        channel_bw = 200000;

        % find a decimation rate to achieve audio sampling rate between 44-48 kHz
        audio_freq = 48000;
       
    % Weather
    case 2
%         filename = 'D:\Projects\bladerf\rx_record\recordings\137M000_1M__64s_test.bin';
%         filename = 'D:\Projects\bladerf\rx_record\recordings\137M500_1M4__64s_test3.bin';
        filename = 'D:\Projects\bladerf\rx_record\recordings\137M800_0M624__640s_test.bin';
        
        % this is the sample rate of the capture (Hz)
%         fs = 1.4e6;
        fs = 624000;
        
        % number of taps to create a low pass RF filter
        n_taps = 100;
        
        % offset from the center where we want to demodulate (Hz)
        f_offset = 112500; 
%         f_offset = -400000; 
%         f_offset = 412000; 
        
        % the FM broadcast signal has a bandwidth (Hz)
        channel_bw = 62400;

        % find a decimation rate to achieve audio sampling rate between 44-48 kHz
        audio_freq = 20800;
             
end

[~, iqc, ~, ~] = read_binary_iq_data(filename, data_type, byte_order);


%% setup the fequency specifics

% decimation rate
dec_rate = floor(fs / channel_bw);

% size of each block to process
block_size = 2*fs;    %65536*8;

% create a low pass filter using the blackman window
% need to generate a conversion from the sampling rate to +/- pi
% as an added bonus matlab goes from 0 - 1, where 1 is sampling rate / 2
% fs/fs = 1; channel_bw/fs = 
%freq_cutoff = pi()/(fs/2) * (channel_bw / 4.0);
freq_cutoff = (channel_bw/2)/fs;
lpf = fir1(n_taps, freq_cutoff, 'low');

% create a frequency shift vector to mix the data down, generate a digital complex exponential 
fc1 = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(block_size-1)));

% calculate the new sampling rate based on the original and the decimated sample rate
fs_d = fs/dec_rate;

% scaling for tangent
phasor_scale = 1/((2 * pi()) / (fs_d / channel_bw));


dec_audio = floor(fs_d/audio_freq);  
fs_audio = fs_d / dec_audio;

% number of total blocks
num_blocks = floor(numel(iqc)/block_size);

lpf_fft = fft(lpf, block_size);

% print out all of the specs
fprintf('------------------------------------------------------------------\n');
fprintf('fs:         %d\n', fs);
fprintf('f_offset:   %d\n', f_offset);
fprintf('channel_bw: %d\n', channel_bw);
fprintf('dec_rate:   %d\n', dec_rate);
fprintf('fs_d:       %d\n', fs_d);
fprintf('audio_freq: %d\n', audio_freq);
fprintf('dec_audio:  %d\n', dec_audio);
fprintf('fs_audio:   %d\n', fs_audio);
fprintf('------------------------------------------------------------------\n');

%% plot the spectrogram
figure;
fc_rot = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(4*fs-1)));
spectrogram(iqc(1:4*fs).*fc_rot(:), 4096, 1024, 4096, fs, 'centered');

x7a = [];
    
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
    x4 = x3(1:dec_rate:end);
    

%     figure(2);
%    plot(linspace(-fs/2, fs/2, numel(x3)), 20*log10(abs(fftshift(fft(x3)/numel(x3)))),'b');
%     plot(linspace(-fs_d/2, fs_d/2, numel(x4)), 20*log10(abs(fftshift(fft(x4)/numel(x4)))),'b');

%     ylim([0, 90]);


%     figure(3);
%     scatter(real(x4), imag(x4), '.', 'b');

    y5 = x4(2:end) .* conj(x4(1:end-1));
    x5 = angle(y5) * phasor_scale;


    d = fs_d * 75e-6;   % Calculate the # of samples to hit the -3dB point  
    x = exp(-1/d);      % Calculate the decay between each sample  
    b = [1-x];          % Create the filter coefficients  
    a = [1,-x];  
%     x6 = filter(b,a,x5);  
    
%     lpf_de = fir1(128, 1/(d), 'low');
%     x6 = filter(lpf_de, 1, x5);
    x6=x5;

    freq_cutoff2 = (2400*3)/fs_d;
    lpf2 = fir1(n_taps, freq_cutoff2, 'low');

    y7 = filter(lpf2, 1, x6);
    x7 = y7(1:dec_audio:end);
%     x7 = decimate(x6, dec_audio);

%     x7 = x6(1:dec_audio:end);
    % x7 = int16(x7 * 10000 / max(abs(x7(:))));
%    x7 = x7/ max(abs(x7(:)));
    x7 = x7/0.4;

    figure(4)
%     plot(linspace(-fs_audio/2, fs_audio/2, numel(x7)), 20*log10(abs(fftshift(fft(x7)/numel(x7)))),'b');
    spectrogram(x7, 2048, 1024, 2048, fs_audio, 'centered');

    % play the audio
    sound(x7, fs_audio);
    
    x7a = cat(1, x7a, x7);
    pause(0.2);
end

return;

%% section to save the audio to a wave file


filename = 'd:/Projects/apt-decoder-master/examples/noaa_18_2.wav';
audiowrite(filename,x7a,20800);

