format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;
line_width = 1;

commandwindow;

%% setup some of the variables

data_rate = 1187.5;
sample_rate = data_rate * 100;
amplitude = 1800;

d = randi([0, 1], 1, 4*104);

% encode data
data = zeros(1, numel(d));
data(1) = d(1);

for idx=2:numel(d)
    data(idx) = xor(data(idx-1), d(idx));
end

data = 2*data - 1;


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
bit_length = 1.0/data_rate;
samples_per_bit = floor(sample_rate*bit_length);

[iq_rbds] = generate_bpsk(data, 1, sample_rate, bit_length);

%% filter data

N = 101;

% filter cutoff frequency
fc = 1250/sample_rate;

w = blackman_nuttall_window(N);

% create the full filter using the window
lpf = create_fir_filter(fc, w);

% apply the filter to the bpsk signal
x1 = conv(iq_rbds, lpf(end:-1:1), 'same');


%% AM modulate

x1_am = amplitude * x1;




%%

% [iq_qpsk] = generate_qpsk(data, amplitude, sample_rate, bit_length);

% do the FFT on the signal
fft_rbds = fft(x1_am/2048)/numel(x1_am);

% calculate the x axis
x_rbds = linspace(-sample_rate/2, sample_rate/2, numel(fft_rbds));


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_rbds/1e3, 20*log10(abs(fftshift(fft_rbds))),'k')
% plot(x_rbds/1e6, 20*log10(abs(fftshift(fft_x1))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_rbds(1), x_rbds(end)]/1e3);
xlabel('Frequency (KHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Filtered vs. Un-Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;


