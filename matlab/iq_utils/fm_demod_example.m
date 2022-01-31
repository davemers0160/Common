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
        fs_audio = 20000; 
        
        % audio filter cutoff frequency (Hz)
        fc_audio = 12000;
        
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
        fs_audio = 48000;

        % audio filter cutoff frequency (Hz)
        fc_audio = 24000;
        
        
    % Weather
    case 2
%         filename = 'D:\Projects\bladerf\rx_record\recordings\137M000_0M624__640s_test2.bin';
%         filename = 'D:\Projects\bladerf\rx_record\recordings\137M500_1M4__64s_test3.bin';
        filename = 'D:\Projects\bladerf\rx_record\recordings\137M800_0M624__640s_test3.bin';
        
        % this is the sample rate of the capture (Hz)
%         fs = 1.4e6;
        fs = 624000;
        
        % number of taps to create a low pass RF filter
        n_taps = 100;
        
        % offset from the center where we want to demodulate (Hz)
%         f_offset = 100000; 
        f_offset = 116000; 
        
        % rf frequency filter cutoff
        fc_rf = 62400;
        
        % the FM broadcast signal has a bandwidth (Hz)
        channel_bw = 62400*2;

        % find a decimation rate to achieve audio sampling rate between 44-48 kHz
        fs_audio = 20800;
        
        % audio filter cutoff frequency (Hz)
        fc_audio = 2400*3;
             
end

[~, iqc, ~, ~] = read_binary_iq_data(filename, data_type, byte_order);

num_samples = numel(iqc);

%% setup the fequency specifics

% decimation rate
dec_rate = floor(fs / channel_bw);

% size of each block to process
block_size = fs;    %65536*8;

% create a low pass filter using the blackman window
% need to generate a conversion from the sampling rate to +/- pi
% as an added bonus matlab goes from 0 - 1, where 1 is sampling rate / 2
% fs/fs = 1; channel_bw/fs = 
%freq_cutoff = pi()/(fs/2) * (channel_bw / 4.0);
freq_cutoff = fc_rf/fs;
lpf = fir1(n_taps, freq_cutoff, 'low');

% create a frequency shift vector to mix the data down, generate a digital complex exponential 
fc1 = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(block_size-1)));

% calculate the new sampling rate based on the original and the decimated sample rate
fs_d = fs/dec_rate;

% scaling for tangent
phasor_scale = 1/((2 * pi()) / (fs_d / channel_bw));

dec_audio = floor(fs_d/fs_audio);  
fs_audio = fs_d / dec_audio;

% number of total blocks
num_blocks = floor((num_samples)/block_size);

% lpf_fft = fft(lpf, block_size);

% print out all of the specs
fprintf('------------------------------------------------------------------\n');
fprintf('fs:         %d\n', fs);
fprintf('f_offset:   %d\n', f_offset);
fprintf('channel_bw: %d\n', channel_bw);
fprintf('dec_rate:   %d\n', dec_rate);
fprintf('fs_d:       %d\n', fs_d);
fprintf('audio_freq: %d\n', fs_audio);
fprintf('dec_audio:  %d\n', dec_audio);
fprintf('fs_audio:   %d\n', fs_audio);
fprintf('------------------------------------------------------------------\n');


%% do a rough frequency shift and the filter and downsample

fc_rot = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(100*fs-1)));

% perform the frequency rotation to put the desired frequency at 0Hz
x2 = iqc(1:100*fs) .* fc_rot(:);

% filter the frequency shifted signal since there is a close signal
x3 = filter(lpf, 1, x2);

% decimate the shifted signal
iqc_d = x3(1:dec_rate:end);

% plot the spectrogram
figure;
% fc_rot = exp(-1.0j*2.0*pi()* (f_offset+0)/fs*(0:(300*fs-1)));
% spectrogram(iqc(1:300*fs).*fc_rot(:), 4096, 1024, 4096, fs, 'centered');
spectrogram(iqc_d, 4096, 1024, 4096, fs_d, 'centered');

bp = 1;
% spectrogram(iqc, 4096, 1024, 4096, fs, 'centered');

%% test of pll
% phase_in    =  0.1;     % input phase (error)
% phase_out   = 0.181;        % output phase
% freq_out    = 0;        % output frequency
% alpha       =  0.010;   % loop filter bandwidth
% beta        = alpha^2;  % frequency adjustment factor
% freq_in     = 0.16;    % input frequency (error)
% 
% % run loop
% y = zeros(floor(240*fs),1);   % output signal
% 
% for i=1:floor(240*fs)
%     % mix input signal down
%     y(i) = iqc(i) * exp(-1i*phase_out);
% 
%     % compute true phase and frequency errors
% %     p = arg( exp(1i*phase_in)*exp(-1i*phase_out) );
% %     f = freq_in - freq_out;
% 
%     % compute phase error estimate
%     v = y(i).^2; % QPSK: use 4th-order moment
%     e = imag(v) / abs(v);
% 
%     % apply loop filter
%     phase_out = phase_out + alpha*e;
%     freq_out = freq_out + beta*e;
% 
%     % update input and output phase values
%     phase_in = phase_in + freq_in;
%     phase_out = phase_out + freq_out;
% end

% phd_output = [];
% %Initilize PLL Loop 
% phi_hat = 30; 
% x2 = iqc(1); 
% phd_output(1) = 0; 
% vco = 0;
% 
% %Define Loop Filter parameters(Sets damping)
% kp = 0.15; %Proportional constant 
% ki = 0.1; %Integrator constant 
% 
% %PLL implementation 
% for n=2:floor(2*fs) 
% %     vco(n)=conj(exp(1j*(2*pi*n*f/fs+phi_hat(n-1))));%Compute VCO 
% %     phd_output(n)=imag(Signal(n)*vco(n));%Complex multiply VCO x Signal input 
% %     e(n)=e(n-1)+(kp+ki)*phd_output(n)-ki*phd_output(n-1);%Filter integrator 
% %     phi_hat(n)=phi_hat(n-1)+e(n);%Update VCO 
% 
%     vco = conj(exp(1j*(2*pi*n*f_offset/fs+phi_hat)));%Compute VCO 
%     phd_output(n) = imag(iqc(n)*vco);%Complex multiply VCO x Signal input 
% %     if(phd_output(n) > 2*pi)
% %         phd_output(n) = phd_output(n) - 2*pi;
% %     end
%     x2(n) = x2(n-1) + (kp+ki)*phd_output(n)-ki*phd_output(n-1);%Filter integrator 
%     phi_hat = phi_hat + x2(n);%Update VCO 
% 
% end

% phase_offset = 0;
% phi_hat = 0;
% % [y, phase_offset, frequency_offset, phi_hat] = test_fm_pll_2(iqc(1:60*fs), phase_offset, f_offset/fs, phi_hat);
% [y] = test_fm_pll_1(iqc(1:60*fs), 3.0, f_offset/fs, 0.05);
% 
% 
% bp = 1;

%%
% figure
% spectrogram(x2, 4096, 1024, 4096, fs, 'centered');


%% block processing loop
x7a = [];

fft_size = 65536*2;
fft_bin = floor((f_offset/fs) * fft_size);
fft_width = 128;


% %Initilize PLL Loop 
% phi_hat = 30; 
% x2 = 0; 
% % phd_output(1) = 0;
% phd_output_0 = 0;
% phd_output_1 = 0;
% vco(1) = 0; 
% %Define Loop Filter parameters(Sets damping)
% kp = 0.15; %Proportional constant 
% ki = 0.1; %Integrator constant 

for idx=1:num_blocks

    x1 = iqc((1:block_size)+(idx-1)*block_size);
    
    % find the doppler shift
    fft_bin = floor((f_offset/fs) * fft_size);
    fft_x1 = fft(x1, fft_size);
    
    [max_fft(idx), max_fft_idx] = max(abs(fft_x1((fft_bin-fft_width):(fft_bin+fft_width))));
    
    f_offset = ((fft_bin-fft_width) + max_fft_idx) * fs/fft_size;
    fc1 = exp(-1.0j*2.0*pi()* f_offset/fs*(0:(block_size-1)));
    
    f_off(idx) = f_offset;
    
    % perform the frequency rotation to put the desired frequency at 0Hz
    x2 = x1 .* fc1(:);

    % double filter the frequency shifted signal since there is a close signal
     x3 = filter(lpf, 1, x2);
%     x3 = filter(lpf, 1, x3);
%     x3 = x2 .* lpf_fft(:);
   
    % decimate the shifted signal
     x4 = x3(1:dec_rate:end);
    
%     figure(2);
%     subplot(1,2,1);
%     spectrogram(x4, 2048, 1024, 2048, fs_d, 'centered');
%     plot(linspace(-fs/2, fs/2, numel(x3)), 20*log10(abs(fftshift(fft(x3)/numel(x3)))),'b');
%     plot(linspace(-fs_d/2, fs_d/2, numel(x4)), 20*log10(abs(fftshift(fft(x4)/numel(x4)))),'b');
%     ylim([0, 90]);

%     figure(3);
%     scatter(real(x4), imag(x4), '.', 'b');

    % https://www.veron.nl/wp-content/uploads/2014/01/FmDemodulator.pdf
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

    freq_cutoff2 = fc_audio/fs_d;
    lpf2 = fir1(256, freq_cutoff2, 'low');

    y7 = filter(lpf2, 1, x6);
    x7 = y7(1:dec_audio:end);
%     x7 = decimate(x6, dec_audio);

%     x7 = x6(1:dec_audio:end);
    % x7 = int16(x7 * 10000 / max(abs(x7(:))));
%     x7 = x7/ max(abs(x7(:)));
    %x7 = x7/0.4;

    figure(4)
%     subplot(1,2,2);

%     plot(linspace(-fs_audio/2, fs_audio/2, numel(x7)), 20*log10(abs(fftshift(fft(x7)/numel(x7)))),'b');
    spectrogram(x7, 2048, 1024, 2048, fs_audio, 'centered');
    drawnow;
    
    % play the audio
    sound(x7, fs_audio);
    
    x7a = cat(1, x7a, x7);
    pause(0.2);
end

return;

%% section to save the audio to a wave file


filename = 'd:/Projects/apt-decoder-master/examples/noaa18_20220130_1130.wav';
audiowrite(filename, x7a*2, 20800);

