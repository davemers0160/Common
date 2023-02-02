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
plot_num = plot_num + 1; 

%% create the signal
bit_length = 1e-6;
samples_per_bit = floor(sample_rate*bit_length);

[iq_bpsk] = generate_bpsk(data, 1, sample_rate, bit_length);

% [iq_qpsk] = generate_qpsk(data, amplitude, sample_rate, bit_length);

%% plot BPSK
% do the FFT on the signal
fft_bpsk = fft(iq_bpsk/2048)/numel(iq_bpsk);
fft_bpsk_q = fft(int32(iq_bpsk/2048))/numel(iq_bpsk);

% calculate the x axis
x_bpsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_bpsk));

figure(plot_num)
set(gcf,'position',([50,50,650,500]),'color','w')
scatter(real(iq_bpsk(1:samples_per_bit*10)), imag(iq_bpsk(1:samples_per_bit*10)), 'o', 'b', 'filled');
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([-amplitude, amplitude]);
ylim([-amplitude, amplitude]);
xlabel('I', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Q', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_bpsk))),'b')
hold on;
% plot(x_bpsk, 20*log10(abs(fftshift(fft_bpsk_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;

figure(plot_num)
spectrogram(iq_bpsk/2048, 2048, 2000, 2048, sample_rate, 'centered');
plot_num = plot_num + 1; 

%% create a low pass filter

% window size
n_taps = 300;

% nutall window
w = zeros(1, N+1);
a0 = 0.355768;
a1 = 0.487396;
a2 = 0.144232;
a3 = 0.012604;

for idx = 0:n_taps
    w(1,idx+1) = a0 - a1 * cos(2.0 * pi * idx / n_taps) + a2 * cos(4.0 * pi * idx / n_taps) - a3 * cos(6.0 * pi * idx / n_taps);
end

% create the filter
%std::sin(M_PI * fc * (idx - (N >> 1))) / (M_PI * (idx - (N >> 1)))

% filter cutoff frequency
fc = 0.6e6/sample_rate;
filt = sinc(pi * fc * (-N/2:1:N/2));

g = zeros(1, n_taps + 1);

for idx = 0:n_taps

    if (abs(idx - (n_taps / 2.0)) < 1e-6)
        g(idx+1) = w(idx+1) * fc;
    else
        g(idx+1) = w(idx+1) * (sin(pi * fc * (idx - (n_taps/2))) / (pi * (idx - (n_taps/2))));
    end
end



lpf = fir1(n_taps, fc, nuttallwin(n_taps+1));
lpf2 = fir1(n_taps, fc, ones(n_taps+1,1));

% apply window to the filter
nutall_filter = w .* filt;

%% plot the results of the filter


%% apply the filter to the bpsk signal

iq_bpsk_filt = filter(nutall_filter, 1, iq_bpsk);

iq_bpsk_conv = conv(iq_bpsk, nutall_filter(end:-1:1), 'same');


fft_bpsk_filt = fft(iq_bpsk_filt)/numel(iq_bpsk_filt);

fft_bpsk_conv = fft(iq_bpsk_conv)/numel(iq_bpsk_conv);


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_bpsk_filt))),'b')
hold on;
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_bpsk_conv))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;



