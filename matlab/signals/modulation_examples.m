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

data_path = 'D:\data\modulation\';

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

% data plots
figure(plot_num)
set(gcf,'position',([50,50,1600,500]),'color','w')

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
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t, amplitude, 'k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Analog Data')
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, amplitude, 'k', 'LineWidth', line_width)
plot(t, am_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('am_time_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(complex(am_sig, zeros(1, numel(am_sig))), 64, 32, 64, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('am_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('am_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('am_spectrogram_90_90.png')));

plot_num = plot_num + 1;

%% ASK

amplitude = 1.0;
sample_rate = 1e6;
symbol_length = 0.001;

% time
t = 0:9999;

% base frequency to modulate
fo = 10000;
freq = sin(2*pi()*fo/sample_rate*t);

% amplitude
% A0 = 0.1*ones(1, 1000);
% A1 = 0.95 * ones(1, 1000);
% amplitude = [A1, A1, A0, A1, A0, A0, A1, A0, A1, A0];
% data
data = [1, 0, 1, 0, 0, 1, 1, 1, 0, 1];
[iq] = generate_ask(data, amplitude, sample_rate, symbol_length);
ask_sig = freq.' .* real(iq);

% create the signal
% ask_sig = freq.*amplitude;

% data plots
figure(plot_num)
set(gcf,'position',([50,50,1600,500]),'color','w')

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
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t, amplitude, 'k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Binary Data')
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, real(iq), 'k', 'LineWidth', line_width)
plot(t, ask_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('ask_time_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(ask_sig, 64, 32, 64, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('ask_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('ask_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('ask_spectrogram_90_90.png')));

plot_num = plot_num + 1;

%% PAM modulation

amplitude = 1.0;
sample_rate = 1e6;

% time
t = 0:9999;

symbol_length = 0.0001;
samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

data = randi([0,1], 200,1);

[iq, pulse_data] = generate_4pam(data, amplitude, symbol_length, sample_rate);
t_iq = (0:numel(iq)-1)/sample_rate;

x_data = 0:numel(data)-1;

% data plot
figure(plot_num)
set(gcf,'position',([50,50,1600,500]),'color','w')

subplot(3,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('4-PAM Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.025 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t_iq, pulse_data, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'Data'});
ax = gca;
ax.Position = [0.025 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t_iq, pulse_data, 'k', 'LineWidth', line_width)
plot(t_iq, real(iq), 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t_iq(end)]);
legend({'Data', 'Modulated Data'});
ax = gca;
ax.Position = [0.025 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('pam_time_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
box on
grid on
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.865 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('pam_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 64, 32, 64, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('pam_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('pam_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('pam_spectrogram_90_90.png')));

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

% data plots
figure(plot_num)
set(gcf,'position',([50,50,1600,500]),'color','w')

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
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t_plot, data, 'k', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,t_plot(end)]);
legend('Binary Data')
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('fm_time_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 64, 32, 64, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('fm_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('fm_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('fm_spectrogram_90_90.png')));

plot_num = plot_num + 1;

%% FSK

sample_rate = 1e6;

% freq
fo = 20000;
symbol_length = 0.001;

% data
% data = randi([0,1], 10,1);
data = [1, 0, 1, 0, 0, 1, 1, 1, 0, 1];

d2 = [];
for idx=1:numel(data)
    d2 = cat(1, d2, data(idx)*ones(sample_rate*symbol_length, 1));
end

iq = generate_fsk(data, 1, sample_rate, symbol_length, 0, fo);
fsk_sig = imag(iq);
t_iq = (0:numel(iq)-1)/sample_rate;

x_data = 0:numel(data)-1;
fm_plot = (0:numel(fsk_sig)-1)/sample_rate;

% data plot
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('FSK Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(fm_plot, d2, 'k', 'LineWidth', line_width)
plot(fm_plot, fsk_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, fm_plot(end)]);
legend({'Data', 'Modulated Data'});
ax = gca;
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('fsk_time_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
box on
grid on
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.865 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('fsk_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 512, 480, 512, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('fsk_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('fsk_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('fsk_spectrogram_90_90.png')));

plot_num = plot_num + 1;


%% bpsk

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 200,1);
x_data = 0:numel(data)-1;

num_bits = 1;
iq_map = [-1+-0i; 1+0i];
gc = [0,1];

[iq] = generate_bpsk(data, amplitude, sample_rate, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

% data plots
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('BPSK Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_time_plot.png')));
plot_num = plot_num + 1;

% iq map plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
grid on
box on
scatter(real(iq_map), imag(iq_map), 20, 'o', 'b', 'filled');
for idx=1:numel(iq_map)
    x = real(iq_map(gc(idx)+1,1));
    y = imag(iq_map(gc(idx)+1,1));
    text( x-0.01,y-0.1, strcat(dec2base(gc(idx),2, num_bits)),'Color',[0 0 0], 'fontweight','bold');
end
set(gca,'fontweight','bold','FontSize',11);
xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');
xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);
pt = title('Constellation Map', 'fontweight','bold','FontSize',12);
set(pt,'position',get(pt,'position')+[0 0.01 0])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0.04 0.04 0.92 0.92];
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_iqmap_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
box on
grid on
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 128, 64, 128, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('bpsk_spectrogram_90_90.png')));
plot_num = plot_num + 1;

%% QPSK

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 2*200,1);
x_data = 0:numel(data)-1;

num_bits = 2;
[iq_map, gc] = create_qam_constellation(num_bits);

[iq] = generate_qpsk(data, sample_rate, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

% data plots
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('QPSK Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_time_plot.png')));
plot_num = plot_num + 1;

% iq map plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
grid on
box on
scatter(real(iq_map), imag(iq_map), 20, 'o', 'b', 'filled');
for idx=1:numel(iq_map)
    x = real(iq_map(gc(idx)+1,1));
    y = imag(iq_map(gc(idx)+1,1));
    text( x-0.02,y-0.05, strcat(dec2base(gc(idx),2, num_bits)),'Color',[0 0 0], 'fontweight','bold');
end
set(gca,'fontweight','bold','FontSize',11);
xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');
xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);
pt = title('Constellation Map', 'fontweight','bold','FontSize',12);
set(pt,'position',get(pt,'position')+[0 0.01 0])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0.04 0.04 0.92 0.92];
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_iqmap_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
box on
grid on
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 128, 64, 128, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('qpsk_spectrogram_90_90.png')));
plot_num = plot_num + 1;

%% O-QPSK

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;

% data
data = randi([0,1], 2*200, 1);
x_data = 0:numel(data)-1;

num_bits = 2;
[iq_map, gc] = create_qam_constellation(num_bits);

[iq] = generate_oqpsk(data, sample_rate, bit_length/2);
t_iq = (0:numel(iq)-1)/sample_rate;

% data plot
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('OQPSK Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_time_plot.png')));
plot_num = plot_num + 1;

% iq map plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
grid on
box on
scatter(real(iq_map), imag(iq_map), 20, 'o', 'b', 'filled');
for idx=1:numel(iq_map)
    x = real(iq_map(gc(idx)+1,1));
    y = imag(iq_map(gc(idx)+1,1));
    text( x-0.02,y-0.05, strcat(dec2base(gc(idx),2, num_bits)),'Color',[0 0 0], 'fontweight','bold');
end
set(gca,'fontweight','bold','FontSize',11);
xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');
xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);
pt = title('Constellation Map', 'fontweight','bold','FontSize',12);
set(pt,'position',get(pt,'position')+[0 0.01 0])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0.04 0.04 0.92 0.92];
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_iqmap_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
box on
grid on
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 128, 64, 128, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('oqpsk_spectrogram_90_90.png')));

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
[iq_map, gc] = create_qam_constellation(num_bits);

[iq] = generate_qam(data, amplitude, sample_rate, iq_map, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

% time plots
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('16QAM Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_time_plot.png')));
plot_num = plot_num + 1;

% iq map plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
grid on
box on
scatter(real(iq_map), imag(iq_map), 20, 'o', 'b', 'filled');
for idx=1:numel(iq_map)
    x = real(iq_map(gc(idx)+1,1));
    y = imag(iq_map(gc(idx)+1,1));
    text( x-0.04,y-0.05, strcat(dec2base(gc(idx),2, num_bits)),'Color',[0 0 0], 'fontweight','bold');
end
set(gca,'fontweight','bold','FontSize',11);
xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');
xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);
pt = title('Constellation Map', 'fontweight','bold','FontSize',12);
set(pt,'position',get(pt,'position')+[0 0.01 0])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0.04 0.04 0.92 0.92];
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_iqmap_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
box on
grid on
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 128, 64, 128, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_spectrogram_0_0.png')));
view(90,0)
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_spectrogram_90_0.png')));
view(90,-90)
print(plot_num, '-dpng', fullfile(data_path,strcat('16qam_spectrogram_90_90.png')));

plot_num = plot_num + 1;

%% 64 QAM

amplitude = 1.0;
sample_rate = 10e6;

bit_length = 0.000001;
num_bits = 6;

% data
data = randi([0,1], 2*num_bits*100, 1);
x_data = 0:numel(data)-1;

% create the mapping constellation
[iq_map, gc] = create_qam_constellation(num_bits);

[iq] = generate_qam(data, amplitude, sample_rate, iq_map, bit_length);
t_iq = (0:numel(iq)-1)/sample_rate;

% time plots
figure(plot_num)
set(gcf,'position',([50,50,1600,400]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x_data, data, 'k', 'LineWidth', 1)
set(gca,'fontweight','bold','FontSize',11);
xlim([0,x_data(end)]);
legend('Binary Data')
title('64QAM Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.02 ax.Position(2) 0.96 ax.Position(4)];

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
ax.Position = [0.02 0.125 0.96 ax.Position(4)];
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_time_plot.png')));
plot_num = plot_num + 1;

% iq map plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
grid on
box on
scatter(real(iq_map), imag(iq_map), 20, 'o', 'b', 'filled');
for idx=1:numel(iq_map)
    x = real(iq_map(gc(idx)+1,1));
    y = imag(iq_map(gc(idx)+1,1));
    text( x-0.06,y-0.05, strcat(dec2base(gc(idx),2, num_bits)),'Color',[0 0 0], 'fontweight','bold');
end
set(gca,'fontweight','bold','FontSize',11);
xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');
xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);
pt = title('Constellation Map', 'fontweight','bold','FontSize',12);
set(pt,'position',get(pt,'position')+[0 0.01 0])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0.04 0.04 0.92 0.92];
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_iqmap_plot.png')));
plot_num = plot_num + 1;

% iq data plot
figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
hold on
box on
grid on
scatter3(t_iq, real(iq), imag(iq), 20, 'o', 'b', 'filled');
plot3(t_iq, real(iq), imag(iq), 'b');
set(gca,'fontweight','bold','FontSize',11);
xlabel('Time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');
view(-70,10);
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_iq_plot.png')));
plot_num = plot_num + 1;

[s, f, ts] = spectrogram(iq, 128, 64, 128, sample_rate, 'centered'); 

% spectrogram
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
ax = gca;
ax.Position = [0.08 0.08 0.875 0.88];

view(0,0);
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_spectrogram_0_0.png')));
view(90,0)
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_spectrogram_90_0.png')));
view(90,-90)
% print(plot_num, '-dpng', fullfile(data_path,strcat('64qam_spectrogram_90_90.png')));

plot_num = plot_num + 1;
