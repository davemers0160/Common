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
sample_rate = 61.44e6;          % Sampling frequency (Hz)
% T       = 1e-4;           % Signal duration (s)
% t       = (0:1/fs:T-1/fs);

f_sc    = 10.23e6;        % Subcarrier frequency (Hz)
f_code  = 5.115e6;        % Code rate (Hz)

symbol_length = 1/f_code;
amplitude = 1 / sqrt(2);
% amplitude = 1;

%% Generate PRN code (simple random ±1)
numChips = 100;

% data = randi([0 1], 1, numChips) * 2 - 1;
data = repmat([0, 1], 1, ceil(numChips/2)) * 2 - 1;

% Upsample PRN to sampling frequency
samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

prn = repelem(data, samples_per_symbol);

n = 0:numel(prn)-1;

%% Generate square-wave subcarriers
subcarrier_I = sign(cos(2*pi*(f_sc/sample_rate)*n));   % Cosine-phased
sc_I = cos(2*pi*(f_sc/sample_rate)*n);
subcarrier_Q = sign(sin(2*pi*(f_sc/sample_rate)*n));   % Sine-phased

%% QBOC baseband I/Q
I = prn .* subcarrier_I;
% Q = prn .* subcarrier_Q;
Q = prn .* zeros(1, numel(subcarrier_I));

%%
index = 0;
I2 = zeros(1, samples_per_symbol * numel(data));
Q2 = zeros(1, samples_per_symbol * numel(data));

c1 = 2*pi*(f_sc/sample_rate);

for idx=1:numel(data)

    for jdx=1:samples_per_symbol
        cosine_phase = sign(cos(c1 * index));
        % cosine_phase *= (data[idx] == 0) ? -a1 : a1;
        if(data(idx) == -1)
            cosine_phase = -amplitude * cosine_phase;
        else
            cosine_phase = amplitude * cosine_phase;
        end

        I2(index+1) = cosine_phase;
        index = index + 1;
    end
end


%% Normalize (optional)
I = amplitude * I;
Q = amplitude * Q;

%% Constellation plot

iq_start = 1;
iq_stop = 100;
step = 1;

t = n/sample_rate;

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
plot(I2(iq_start:step:iq_stop), '--m')

plot(prn(iq_start:step:iq_stop), '-k', 'LineWidth', 1.5)
% plot(subcarrier_I(iq_start:step:iq_stop),'--r')
% plot(sc_I(iq_start:step:iq_stop),'-c')
hold off;

%% Complex baseband QBOC signal
x = I;

% FFT parameters
Nfft = 2^(nextpow2(length(x))+2);   % FFT size
Xf   = fftshift(fft(x, Nfft));

f = (-Nfft/2:Nfft/2-1)*(sample_rate/Nfft);   % Frequency axis

% Power spectrum (dB)
PSD = 20*log10(abs(Xf) / max(abs(Xf)));


%% Plot FFT
figure(3);
hold on;
grid on;
plot(f/1e6, PSD, '-m', 'LineWidth', 1);

xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('QBOC(10.23, 5.115) Baseband Spectrum');
xlim([-30 30]);      % Focus around main lobes
ylim([-80 5]);



