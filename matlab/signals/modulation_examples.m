format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

line_width = 1.0;
plot_num = 1;

%% AM modulation

sample_rate = 1e6;

% time
t = 0:9999;

% base frequency to modulate
fo = 10000;
freq = sin(2*pi()*fo/sample_rate*t);

% amplitude
amplitude = 0.5*cos(2*pi()*(200/sample_rate)*t) + 0.5;

% create the signal
am_sig = freq.*amplitude;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(3,1,1)
hold on
grid on
box on
plot(t, freq, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Frequency')
title('Amplitude Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t, amplitude, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Analog Data')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, amplitude, '--k', 'LineWidth', line_width)
plot(t, am_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;


[s, f, ts] = spectrogram(complex(am_sig, zeros(1, numel(am_sig))), 64, 32, 64, sample_rate, 'centered'); 


figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;



%% ASK

sample_rate = 1e6;

% time
t = 0:9999;

% base frequency to modulate
fo = 10000;
freq = sin(2*pi()*fo/sample_rate*t);

% amplitude
A0 = 0.1*ones(1, 1000);
A1 = 0.95 * ones(1, 1000);
amplitude = [A1, A1, A0, A1, A0, A0, A1, A0, A1, A0];

% create the signal
ask_sig = freq.*amplitude;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(3,1,1)
hold on
grid on
box on
plot(t, freq, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Frequency')
title('ASK Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t, amplitude, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Binary Data')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, amplitude, '--k', 'LineWidth', line_width)
plot(t, ask_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(complex(ask_sig, zeros(1, numel(ask_sig))), 64, 32, 64, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;

%% FM
amplitude = 1.0;

sample_rate = 1e6;
analog_sr = 20000;

% time
t = (0:199);

% base frequency to modulate
fo = sample_rate;
freq = sin(2*pi()*fo/(200*sample_rate)*(0:19999));

% analog data
d1 = cos(2*pi()*(400/analog_sr)*t);
d2 = cos(2*pi()*(100/analog_sr)*t);
d3 = cos(2*pi()*(600/analog_sr)*t);
d4 = cos(2*pi()*(200/analog_sr)*t);
d5 = cos(2*pi()*(800/analog_sr)*t);
data = [d1, d2, d3, d4, d5];


[iq] = generate_fm(data, sample_rate, 1/analog_sr, 4000, amplitude);
fm_sig = imag(iq);

% calculate the real FM signal
% samples_per_symbol = floor(sample_rate * 1/analog_sr + 0.5);
% fm_sig = zeros(numel(data) * samples_per_symbol, 1);

% int_val = 0;
% index = 1;
% 
% for idx = 1:numel(data)-1
% 
%     % // short cuts based on evenely spaced upsampling
%     slope = (data(idx+1) - data(idx))/(samples_per_symbol);
% 
%     for jdx = 0:samples_per_symbol-1
%         int_val = int_val + (data(idx) + jdx*slope);
%         fm_sig(index) = cos(int_val*2*pi*(4000/sample_rate));
%         index = index + 1;
%     end
% end

t_plot = (0:numel(data)-1)/analog_sr;
fm_plot = (0:numel(fm_sig)-1)/sample_rate;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(3,1,1)
hold on
grid on
box on
plot(0:numel(freq)-1, freq, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(freq)-1]);
legend('Frequency')
title('Frequency Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t_plot, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,t_plot(end)]);
legend('Binary Data')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
% plot(t, data, '--g', 'LineWidth', line_width)
% plot(real(iq_data), 'b', 'LineWidth', line_width)
plot(fm_plot, fm_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
% xlim([0, numel(t)]);
legend({'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 64, 32, 64, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;

%% FSK

sample_rate = 1e6;

% freq
fo = 20000;
symbol_length = 0.001;

% data
data = randi([0,1], 10,1);

d2 = [];
for idx=1:numel(data)
    d2 = cat(1, d2, data(idx)*ones(sample_rate*symbol_length, 1));
end

iq = generate_fsk(data, 1, sample_rate, symbol_length, 0, fo);
fsk_sig = imag(iq);

x_data = 0:numel(data)-1;
fm_plot = (0:numel(fsk_sig)-1)/sample_rate;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('FSK Modulation', 'fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(fm_plot, d2, '--k', 'LineWidth', line_width)
% plot(real(iq_data), 'b', 'LineWidth', line_width)
plot(fm_plot, fsk_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, fm_plot(end)]);
legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 512, 256, 512, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;


%% bpsk

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 200,1);
x_data = 0:numel(data)-1;

[iq] = generate_bpsk(data, amplitude, sample_rate, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('BPSK Modulation', 'fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(t_iq, real(iq), 'b', 'LineWidth', line_width)
plot(t_iq, imag(iq), 'r', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'I', 'Q'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')

scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(t_iq, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 256, 128, 256, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;

%% QPSK

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 200,1);
x_data = 0:numel(data)-1;

[iq] = generate_qpsk(data, sample_rate, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('QPSK Modulation', 'fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(t_iq, real(iq), 'b', 'LineWidth', line_width)
plot(t_iq, imag(iq), 'r', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'I', 'Q'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')

scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(t_iq, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 256, 128, 256, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;

%% O-QPSK

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 200, 1);
x_data = 0:numel(data)-1;

[iq] = generate_oqpsk(data, sample_rate, bit_length/2);
t_iq = (0:numel(iq)-1)/sample_rate;


figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('OQPSK Modulation', 'fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(t_iq, real(iq), 'b', 'LineWidth', line_width)
plot(t_iq, imag(iq), 'r', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'I', 'Q'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')

scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(t_iq, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 256, 128, 256, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;

%% 16 QAM

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;
num_bits = 4;

% data
data = randi([0,1], num_bits*100, 1);
x_data = 0:numel(data)-1;

% create the mapping constellation
iq_map = create_qam_constellation(num_bits);

[iq] = generate_qam(data, amplitude, sample_rate, iq_map, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, '--k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('16QAM Modulation', 'fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(t_iq, real(iq), 'b', 'LineWidth', line_width)
plot(t_iq, imag(iq), 'r', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'I', 'Q'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
plot3(t_iq, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 256, 128, 256, sample_rate, 'centered'); 

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
zlabel('Amplitude (dBfs)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;
