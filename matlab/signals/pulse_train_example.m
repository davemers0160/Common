format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%% generate the base pulse train

% barker codes
b5 = [1, 1, 1, -1, 1];
b7 = [1, 1, 1, -1, -1, 1, 1];
b11 = [1, 1, 1, -1, -1, -1, 1, -1, -1, 1, -1];
b13 = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];

% nested barker B5XB13 
% x = (b13' * b5)';
% x = x(:)';
% sig_noise = 0.7;

% maximal length sequence
taps = [1,3,6];
x = maxmimal_length_seq(6, taps);
sig_noise = 0.20;

x_length = length(x);

x2 = cat(2, zeros(1,20), x, zeros(1,20));
x2c = conv(x, x(end:-1:1), 'same');

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
stairs(x, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(x)]);
legend('binary sequence')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(x2c, 'g', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(x)]);
legend('auto correlation')

ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num  = plot_num + 1;

%% start offset
start = 50;

% number of samples to place between pulses
pulse_spacing = 200 - x_length;

% number of pulses
pulse_num = 16;

% build the pulse train
space = zeros(1, pulse_spacing);
signal_int = repmat([x space], 1, pulse_num);
signal = [zeros(1, numel(signal_int)) signal_int, zeros(1, numel(signal_int))];

%% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
stairs(signal, 'b', 'LineWidth', line_width)
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(signal)]);
title('Binary Sequence Pulse Train','fontweight','bold','FontSize',12);

ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];
ylabel('Base Signal', 'fontweight','bold','FontSize',12);

plot_num  = plot_num + 1;

%% create noised signal

noise = sig_noise * randn(1,length(signal));

% build the signal
sn = signal + noise;

figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

plot(sn, 'b', 'LineWidth', line_width)
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
title('Captured Pulse Train','fontweight','bold','FontSize',13);

xlim([0, numel(sn)]);
ax = gca;
ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
ylabel(strcat('Signal + Noise'), 'fontweight','bold','FontSize',12);

plot_num  = plot_num + 1;

%% run the correlation

rxy_ind = conv(sn, x(end:-1:1), 'same');
rxy_all = conv(sn, signal_int(end:-1:1), 'same');

% plot the auto correlation signals
figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

plot(rxy_all, 'g', 'LineWidth', line_width)
grid on
box on
hold on
plot(rxy_ind, 'b', 'LineWidth', line_width)


set(gca,'fontweight','bold','FontSize',12);
title('Auto Correlation with Captured Pulse Train','fontweight','bold','FontSize',13);

xlim([0, numel(rxy_ind)]);
ax = gca;
ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
% ylabel(strcat('Rxx',32, num2str(idx)), 'fontweight','bold','FontSize',12);

