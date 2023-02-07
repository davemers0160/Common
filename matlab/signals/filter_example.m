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
bit_length = 1e-3;
amplitude = 1800;
freq_separation = 200000;

% plot the chip sequence
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(data, 'b', 'LineWidth', line_width);
box on
grid on
set(gca,'fontweight','bold','FontSize', 13);
xlabel('Bit', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Value', 'fontweight', 'bold', 'FontSize', 13);
title('Data', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1; 

%% create the signal
bit_length = 1.0e-6;
samples_per_bit = floor(sample_rate*bit_length);

[iq_bpsk] = generate_bpsk(data, 1, sample_rate, bit_length);

% [iq_qpsk] = generate_qpsk(data, amplitude, sample_rate, bit_length);

% do the FFT on the signal
fft_bpsk = fft(iq_bpsk/2048)/numel(iq_bpsk);
fft_bpsk_q = fft(int32(iq_bpsk/2048))/numel(iq_bpsk);

% calculate the x axis
x_bpsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_bpsk));

%% create a low pass filter

% window size
n_taps = 301;

% nutall window
w = zeros(1, n_taps);
a0 = 0.355768;
a1 = 0.487396;
a2 = 0.144232;
a3 = 0.012604;

for idx = 0:n_taps-1
    w(1,idx+1) = a0 - a1 * cos(2.0 * pi * idx / n_taps) + a2 * cos(4.0 * pi * idx / n_taps) - a3 * cos(6.0 * pi * idx / n_taps);
end

% filter cutoff frequency
fc = 2.0e6/sample_rate;

% create the full filter using the window
lpf = create_fir_filter(fc, w);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(0:n_taps-1, lpf,'k')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([0, n_taps-1]);
title('Plot of Filter', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%% plot the results of the filter

% apply the filter to the bpsk signal
x1 = conv(iq_bpsk, lpf(end:-1:1), 'same');

fft_lpf = fft(lpf)/numel(lpf);

% calculate the x axis
x_lpf = linspace(-sample_rate/2, sample_rate/2, numel(fft_lpf));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_lpf/1e6, 20*log10(abs(fftshift(fft_lpf))),'k')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_lpf(1), x_lpf(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Frequency Response of LPF Filter', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(real(iq_bpsk),'k')
plot(real(x1),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
% xlim([x_bpsk(1), x_bpsk(end)]/1e6);
title('Plot of Filtered vs. Un-Filtered Samples', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%% plot the fft of the signals

fft_x0 = fft(iq_bpsk)/numel(iq_bpsk);
fft_x1 = fft(x1)/numel(x1);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x0))),'k')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x1))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Filtered vs. Un-Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%% shift the signal

f_offset = 2e6;

% create a frequency shift vector 
fc_rot = exp(1.0j*2.0*pi()* f_offset/sample_rate*(0:(numel(iq_bpsk)-1))).';

x1_r = x1 .* fc_rot;

fft_x0 = fft(iq_bpsk)/numel(iq_bpsk);
fft_x1_r = fft(x1_r)/numel(x1_r);

fft_fc_rot = fft(fc_rot)/numel(fc_rot);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x0))),'k')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x1_r))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Frequency Shift of Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%% shift the filter

f_offset = 2e6;

% create a frequency shift vector 
fc_rot = exp(1.0j*2.0*pi()* f_offset/sample_rate*(0:(numel(lpf)-1))).';

lpf_r = lpf.' .* fc_rot;

fft_lpf_r = fft(lpf_r)/numel(lpf_r);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_lpf/1e6, 20*log10(abs(fftshift(fft_lpf_r))),'k')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_lpf(1), x_lpf(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Frequency Response of Shifted Filter --> Band Pass Filter', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%% create a band reject filter

apf = create_fir_filter(1.0, w);   %ones(n_taps,1)

fft_apf = fft(apf-lpf)/numel(apf);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_lpf/1e6, 20*log10(abs(fftshift(fft_apf))),'k')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_lpf(1), x_lpf(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Frequency Response of Band Reject Filter', 'fontweight', 'bold', 'FontSize', 14);
plot_num = plot_num + 1;


%% apply the filter to the bpsk signal
brf = (apf-lpf);
x1_nf = conv(iq_bpsk, brf(end:-1:1), 'same');

fft_x1_nf = fft(x1_nf)/numel(x1_nf);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x0))),'k')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_x1_nf))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Band Reject Filter Result', 'fontweight', 'bold', 'FontSize', 14);
plot_num = plot_num + 1;
