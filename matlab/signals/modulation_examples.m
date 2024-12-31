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
plot(t, amplitude, '--g', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Analog Data')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, amplitude, '--g', 'LineWidth', line_width)
plot(t, am_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

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
plot(t, amplitude, '--g', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend('Binary Data')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,3)
hold on
grid on
box on
plot(t, amplitude, '--g', 'LineWidth', line_width)
plot(t, ask_sig, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(t)]);
legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;

%% FM

sample_rate = 200000;
analog_sr = 20000;

% time
t = (0:199);

% base frequency to modulate
fo = 10000;
freq = sin(2*pi()*fo/sample_rate*t);

% analog data
d1 = cos(2*pi()*(400/analog_sr)*t);
d2 = cos(2*pi()*(100/analog_sr)*t);
d3 = cos(2*pi()*(600/analog_sr)*t);
d4 = cos(2*pi()*(200/analog_sr)*t);
d5 = cos(2*pi()*(800/analog_sr)*t);
data = [d1, d2, d3, d4, d5];

[iq_data] = generate_fm(data, sample_rate, 1/analog_sr, 5000, 1);

t_plot = (0:numel(data)-1)/analog_sr;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(3,1,1)
hold on
grid on
box on
plot(t, freq, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, t(end)]);
legend('Frequency')
title('Frequency Modulation', 'fontweight','bold','FontSize',12);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(3,1,2)
hold on
grid on
box on
plot(t_plot, data, '--g', 'LineWidth', line_width)
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
plot(real(iq_data), 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
% xlim([0, numel(t)]);
% legend({'Data', 'Modulated Data'});

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num = plot_num + 1;


%% FSK


