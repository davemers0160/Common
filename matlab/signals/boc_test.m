format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% Parameters
fs      = 61.44e6;          % Sampling frequency (Hz)
T       = 1e-4;           % Signal duration (s)
t       = (0:1/fs:T-1/fs);

f_sc    = 10.23e6;        % Subcarrier frequency (Hz)
f_code  = 5.115e6;        % Code rate (Hz)

symbol_length = 1/f_code;

%% Generate PRN code (simple random ±1)
numChips = 1000;
prnChips = randi([0 1], 1, numChips) * 2 - 1;

prnChips = repmat([0, 1], 1, ceil(numChips/2)) * 2 - 1;

% Upsample PRN to sampling frequency
samples_per_symbol = floor(fs * symbol_length + 0.5);

prn = repelem(prnChips, samples_per_symbol);
prn = prn(1:length(t));

%% Generate square-wave subcarriers
subcarrier_I = sign(cos(2*pi*f_sc*t));   % Cosine-phased
sc_I = cos(2*pi*f_sc*t);
subcarrier_Q = sign(sin(2*pi*f_sc*t));   % Sine-phased

%% QBOC baseband I/Q
I = prn .* subcarrier_I;
% Q = prn .* subcarrier_Q;
Q = prn .* zeros(1, numel(subcarrier_I));

%% Normalize (optional)
I = I / sqrt(2);
Q = Q / sqrt(2);

%% Constellation plot

iq_start = 1;
iq_stop = 100;
step = 1;

figure(1);
grid on;
box on;
scatter3(t(iq_start:step:iq_stop), I(iq_start:step:iq_stop), Q(iq_start:step:iq_stop), 20, 'o', 'b', 'filled');
hold on;
plot3(t(iq_start:step:iq_stop), I(iq_start:step:iq_stop), Q(iq_start:step:iq_stop), 'b');

set(gca,'fontweight','bold','FontSize',11,'Ydir','reverse');

%axis equal;

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

title('QBOC(10.23, 5.115) Constellation');
hold off;


figure(2);
plot(I(iq_start:step:iq_stop), '-b')
hold on;
box on; 
grid on;
plot(prn(iq_start:step:iq_stop), '-k', 'LineWidth', 2)
plot(subcarrier_I(iq_start:step:iq_stop),'--r')
plot(sc_I(iq_start:step:iq_stop),'-c')
hold off;

%% Complex baseband QBOC signal
x = I;

% FFT parameters
Nfft = 2^nextpow2(length(x));   % FFT size
Xf   = fftshift(fft(x, Nfft));

f = (-Nfft/2:Nfft/2-1)*(fs/Nfft);   % Frequency axis

% Power spectrum (dB)
PSD = 20*log10(abs(Xf) / max(abs(Xf)));

% Plot FFT
figure(3);
hold on;
grid on;
plot(f/1e6, PSD, 'LineWidth', 1.2);

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('QBOC(10.23, 5.115) Baseband Spectrum');
xlim([-30 30]);      % Focus around main lobes
ylim([-80 5]);



