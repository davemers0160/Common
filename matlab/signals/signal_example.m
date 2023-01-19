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

%% setup some of the variables
line_width = 1;
num_bits = 7;
data = maxmimal_length_seq(num_bits, [1,3,4,num_bits]);
sample_rate = 20e6;
bit_length = 1e-2;
amplitude = 1800;
freq_separation = 5000000;

% plot the chip sequence
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(data, 'b', 'LineWidth', line_width);

plot_num = plot_num + 1;

%% generate the various signals

[iq_ask] = generate_ask(data, amplitude, sample_rate, bit_length);

[iq_fsk] = generate_fsk(data, amplitude, sample_rate, bit_length, freq_separation);

[iq_bpsk] = generate_bpsk(data, amplitude, sample_rate, bit_length);

[iq_qpsk] = generate_qpsk(data, amplitude, sample_rate, bit_length);


%% plot ASK

% do the FFT on the signal
fft_ask = fft(iq_ask/2048)/numel(iq_ask);
fft_ask_q = fft(int32(iq_ask/2048))/numel(iq_ask);

% calculate the x axis
x_ask = linspace(-sample_rate/2, sample_rate/2, numel(fft_ask));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

plot(x_ask, 20*log10(abs(fftshift(fft_ask))),'b')
hold on;
% plot(x_ask, 20*log10(abs(fftshift(fft_ask_q))),'g')

plot_num = plot_num + 1;


figure(plot_num)
spectrogram(iq_ask/2048, 1024, 512, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%% plot FSK
% do the FFT on the signal
fft_fsk = fft(iq_fsk/2048)/numel(iq_fsk);
fft_fsk_q = fft(int32(iq_fsk/2048))/numel(iq_fsk);

% calculate the x axis
x_fsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_fsk));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

plot(x_fsk, 20*log10(abs(fftshift(fft_fsk))),'b')
hold on;
% plot(x_fsk, 20*log10(abs(fftshift(fft_fsk_q))),'g')

plot_num = plot_num + 1;

figure(plot_num)
spectrogram(iq_fsk/2048, 1024, 512, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%% plot BPSK
% do the FFT on the signal
fft_bpsk = fft(iq_bpsk/2048)/numel(iq_bpsk);
fft_bpsk_q = fft(int32(iq_bpsk/2048))/numel(iq_bpsk);

% calculate the x axis
x_bpsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_bpsk));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

plot(x_bpsk, 20*log10(abs(fftshift(fft_bpsk))),'b')
hold on;
% plot(x_bpsk, 20*log10(abs(fftshift(fft_bpsk_q))),'g')

plot_num = plot_num + 1;

figure(plot_num)
spectrogram(iq_bpsk/2048, 1024, 512, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%% plot QPSK
% do the FFT on the signal
fft_qpsk = fft(iq_qpsk/2048)/numel(iq_qpsk);
fft_qpsk_q = fft(int32(iq_qpsk/2048))/numel(iq_qpsk);

% calculate the x axis
x_qpsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_qpsk));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

plot(x_qpsk, 20*log10(abs(fftshift(fft_qpsk))),'b')
hold on;
% plot(x_qpsk, 20*log10(abs(fftshift(fft_qpsk_q))),'g')

plot_num = plot_num + 1;


figure(plot_num)
spectrogram(iq_qpsk/2048, 2048, 2000, 8192, sample_rate, 'centered');
plot_num = plot_num + 1;

%%
return;

spectrogram(iq, 1024, 512, 1024, sample_rate, 'centered');
figure
plot(20*log10(abs(fftshift(fft_bpsk))),'b')
hold on
plot(20*log10(abs(fftshift(fft_qpsk))),'g')
figure
plot(linspace(-sample_rate/2,sample_rate/2,numel(fft_bpsk)), 20*log10(abs(fftshift(fft_bpsk))),'b')
hold on
plot(linspace(-sample_rate/2,sample_rate/2,numel(fft_qpsk)), 20*log10(abs(fftshift(fft_qpsk))),'g')
[iq_f] = generate_fsk(seq, amplitude, sample_rate, bit_length, 4e6);
fft_fsk = fft(iq_f)/numel(iq_f);
plot(linspace(-sample_rate/2,sample_rate/2,numel(fft_fsk)),20*log10(abs(fftshift(fft_fsk))),'r')

[iq_a] = generate_ask(data, amplitude, sample_rate, bit_length);
[iq_a] = generate_ask(seq, amplitude, sample_rate, bit_length);
fft_ask = fft(iq_a)/numel(iq_a);
plot(linspace(-sample_rate/2,sample_rate/2,numel(fft_ask)),20*log10(abs(fftshift(fft_ask))),'k')









figure;
spectrogram(pulse, 128, 64, 128, sample_rate, 'centered');
generated_radar_pulse
figure;
spectrogram(pulse, 512, 2000, 2048, sample_rate, 'centered');
spectrogram(pulse, 2048, 2000, 2048, sample_rate, 'centered');
spectrogram(pulse, 1024, 974, 1024, sample_rate, 'centered');