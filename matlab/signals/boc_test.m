%% Parameters
fs      = 200e6;          % Sampling frequency (Hz)
T       = 1e-4;           % Signal duration (s)
t       = (0:1/fs:T-1/fs);

f_sc    = 10.23e6;        % Subcarrier frequency (Hz)
f_code  = 5.115e6;        % Code rate (Hz)

%% Generate PRN code (simple random ±1)
numChips = ceil(T * f_code);
prnChips = randi([0 1], 1, numChips)*2 - 1;

% Upsample PRN to sampling frequency
samplesPerChip = round(fs / f_code + 0.5);
prn = repelem(prnChips, samplesPerChip);
prn = prn(1:length(t));

%% Generate square-wave subcarriers
subcarrier_I = sign(cos(2*pi*f_sc*t));   % Cosine-phased
subcarrier_Q = sign(sin(2*pi*f_sc*t));   % Sine-phased

%% QBOC baseband I/Q
I = prn .* subcarrier_I;
Q = prn .* subcarrier_Q;

%% Normalize (optional)
I = I / sqrt(2);
Q = Q / sqrt(2);

%% Constellation plot
figure;
scatter(I(1:500), Q(1:500), 25, 'o', 'filled');
grid on;
axis equal;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title('QBOC(10.23, 5.115) Constellation');



figure;
hold on
box on 
grid on
plot(I(1:100), '-b')
plot(prn(1:100), '-g')
plot(subcarrier_I(1:100),'--r')


%% Complex baseband QBOC signal
x = I;

% FFT parameters
Nfft = 2^nextpow2(length(x));   % FFT size
Xf   = fftshift(fft(x, Nfft));

f = (-Nfft/2:Nfft/2-1)*(fs/Nfft);   % Frequency axis

% Power spectrum (dB)
PSD = 20*log10(abs(Xf) / max(abs(Xf)));

% Plot FFT
figure;
plot(f/1e6, PSD, 'LineWidth', 1.2);
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('QBOC(10.23, 5.115) Baseband Spectrum');
xlim([-30 30]);      % Focus around main lobes
ylim([-80 5]);



