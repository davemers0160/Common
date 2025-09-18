format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% create the data
analog_sample_rate = 44100;
t_step = 1/analog_sample_rate;
duration = 0.1;

t = 0:t_step:duration-t_step;

analog_data = 0.5 * cos(2*pi*800*t) + 0.8 * cos(2*pi*1200*t) + 0.4*cos(2*pi*2000*t);

disp("max data: " + num2str(max(analog_data)));
disp("min data: " + num2str(min(analog_data)));

%% plot data

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(t, analog_data, 'b');
box on
grid on
xlabel('Time (s)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');

plot_num = plot_num + 1;

%% plot the FFT of the data

Y = fft(analog_data)/numel(analog_data);
f = linspace(0, analog_sample_rate/2, floor(numel(Y)/2));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-3, 20*log10(abs(Y(1:floor(numel(Y)/2 +0.5)))), 'b');
box on
grid on
xlabel('Frequency (kHz)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%% modulate the data

symbol_length = 1/analog_sample_rate;
sample_rate = analog_sample_rate * 20;
amplitude = 2046;
data_scale = max(abs(analog_data));
k = 0.95;

[iqc] = generate_dsb_sc(analog_data, sample_rate, symbol_length, k, amplitude, data_scale);

%% plot modulated data

t_rf = (0:numel(iqc)-1) * (1/sample_rate);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(t_rf, real(iqc),'b')
hold on;
plot(t_rf, imag(iqc),'r')
xlabel('Time (s)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');

plot_num = plot_num + 1;

%% plot the FFT of the modulated data

Y = fft(iqc)/numel(iqc);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
plot_num = plot_num + 1;


%% test of USB cheat

iq_usb = hilbert(real(iqc)/2047);
max_usb = max(abs(imag(iq_usb)));
iq_usb = (iq_usb/max_usb);

Y = fft(iq_usb)/numel(iq_usb);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%% test of USB cheat

iq_usb = hilbert(real(iqc)/2047);
iq_lsb = conj(iq_usb);

Y = fft(iq_lsb)/numel(iq_lsb);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%% test demod

an_demod = amdemod(real(iqc), 1000, sample_rate);




%% save iq data

data_type = 'int16';
byte_order = 'ieee-le';
iq_data = complex(int16(real(iqc)), int16(imag(iqc)));

filename = 'C:\Projects\data\RF\test_tones2_882k000.sc16';

write_binary_iq_data(filename, iq_data, data_type, byte_order);

fprintf('complete\n');

