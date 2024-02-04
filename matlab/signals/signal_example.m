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
num_bits = 9;
data = maxmimal_length_seq(num_bits, [1,3,4,num_bits]);
sample_rate = 20e6;
bit_length = 0.5e-6;
amplitude = 1950;
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

%% generate the various signals
samples_per_bit = floor(sample_rate*bit_length);

[iq_ask] = generate_ask(data, amplitude, sample_rate, bit_length);

[iq_fsk] = generate_fsk(data, amplitude, sample_rate, bit_length, 0, freq_separation);


%% plot ASK

% do the FFT on the signal
fft_ask = fft(iq_ask(1:samples_per_bit*10)/2048)/numel(iq_ask(1:samples_per_bit*10));
fft_ask_q = fft(int32(iq_ask(1:samples_per_bit*10)/2048))/numel(iq_ask(1:samples_per_bit*10));

% calculate the x axis
x_ask = linspace(-sample_rate/2, sample_rate/2, numel(fft_ask));

figure(plot_num)
set(gcf,'position',([50,50,650,500]),'color','w')
scatter(real(iq_ask(1:samples_per_bit*10)), imag(iq_ask(1:samples_per_bit*10)), 'o', 'b', 'filled');
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
plot(x_ask/1e6, 20*log10(abs(fftshift(fft_ask))),'b')
hold on;
% plot(x_ask/1e6, 20*log10(abs(fftshift(fft_ask_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_ask(1), x_ask(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;

figure(plot_num)
spectrogram(iq_ask/2048, 1024, 512, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%% plot FSK
% do the FFT on the signal
fft_fsk = fft(iq_fsk(1:samples_per_bit*20)/2048)/numel(iq_fsk(1:samples_per_bit*20));
fft_fsk_q = fft(int32(iq_fsk(1:samples_per_bit*20)/2048))/numel(iq_fsk(1:samples_per_bit*10));

% calculate the x axis
x_fsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_fsk));

figure(plot_num)
set(gcf,'position',([50,50,650,500]),'color','w')
scatter(real(iq_fsk(1:samples_per_bit*10)), imag(iq_fsk(1:samples_per_bit*10)), 'o', 'b', 'filled');
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
plot(x_fsk/1e6, 20*log10(abs(fftshift(fft_fsk))),'b')
hold on;
% plot(x_fsk, 20*log10(abs(fftshift(fft_fsk_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_fsk(1), x_fsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;

figure(plot_num)
spectrogram(iq_fsk/2048, 1024, 512, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%%
bit_length = 1e-6;
samples_per_bit = floor(sample_rate*bit_length);

[iq_bpsk] = generate_bpsk(data, amplitude, sample_rate, bit_length);

[iq_qpsk] = generate_qpsk(data, amplitude, sample_rate, bit_length);

fo = 1e6;
% create a frequency shift vector to mix the data down, generate a digital complex exponential 
f_r = exp(-1.0j*2.0*pi()* fo/sample_rate*(0:(numel(iq_qpsk)-1))).';
iq_qpsk_r = iq_qpsk.*f_r;

iq_qpsk = amplitude*(iq_qpsk_r/amplitude + 0.01*complex(randn(numel(iq_qpsk),1), randn(numel(iq_qpsk),1)));

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

%% plot QPSK
% do the FFT on the signal
fft_qpsk = fft(iq_qpsk/2048)/numel(iq_qpsk);
fft_qpsk_q = fft(int32(iq_qpsk/2048))/numel(iq_qpsk);

% calculate the x axis
x_qpsk = linspace(-sample_rate/2, sample_rate/2, numel(fft_qpsk));


figure(plot_num)
set(gcf,'position',([50,50,650,500]),'color','w')
scatter(real(iq_qpsk(1:samples_per_bit*10)), imag(iq_qpsk(1:samples_per_bit*10)), 'o', 'b', 'filled');
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
plot(x_qpsk/1e6, 20*log10(abs(fftshift(fft_qpsk))),'b')
hold on;
% plot(x_qpsk, 20*log10(abs(fftshift(fft_qpsk_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_qpsk(1), x_qpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;


figure(plot_num)
spectrogram(iq_qpsk/2048, 1024, 1000, 1024, sample_rate, 'centered');
plot_num = plot_num + 1;

%%
return;


%%
figure(plot_num)
set(gcf,'position',([50,50,650,500]),'color','w')
scatter(0.99*real(iq_ask(1:samples_per_bit*100)), imag(iq_ask(1:samples_per_bit*100)), 'o', 'k', 'filled');
hold on
scatter(real(iq_fsk(1:samples_per_bit*10)), imag(iq_fsk(1:samples_per_bit*10)), 'o', 'b', 'filled');
scatter(real(iq_bpsk(1:samples_per_bit*10)), imag(iq_bpsk(1:samples_per_bit*10)), 'o', 'g', 'filled');
scatter(real(iq_qpsk(1:samples_per_bit*10)), imag(iq_qpsk(1:samples_per_bit*10)), 'o', 'r', 'filled');

grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([-amplitude, amplitude]);
ylim([-amplitude, amplitude]);
xlabel('I', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Q', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;

%%
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(x_ask/1e6, 20*log10(abs(fftshift(fft_ask))),'k')
hold on;
plot(x_fsk/1e6, 20*log10(abs(fftshift(fft_fsk))),'b')

% plot(x_ask/1e6, 20*log10(abs(fftshift(fft_ask_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_ask(1), x_ask(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;

%% combined BPSK and QPSK
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(x_bpsk/1e6, 20*log10(abs(fftshift(fft_bpsk))),'g')
hold on;
plot(x_qpsk/1e6, 20*log10(abs(fftshift(fft_qpsk))),'r')

% plot(x_bpsk, 20*log10(abs(fftshift(fft_bpsk_q))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_bpsk(1), x_bpsk(end)]/1e6);
xlabel('Frequency (MHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
plot_num = plot_num + 1;
