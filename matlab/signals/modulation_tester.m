format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;
%%
symbol_length=single(1e-5);
sample_rate = 1e6;
amplitude=2020;
k=0.8;
data_scale=1000;
offset_frequency = 0;
freq_deviation = 100000;
n = 1;

samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

%% IQ data
% data = [-1000,0,1000];
% [iq] = generate_dsb_sc(data, sample_rate, symbol_length, k, amplitude, data_scale);

% data = [1,0];
% [iq] = generate_fsk(data, amplitude, sample_rate, symbol_length, offset_frequency, freq_deviation);

n = [0,1,2,3];
data = int2bit(n(:), 2);
[iq] = generate_4fsk(data, amplitude, sample_rate, symbol_length, offset_frequency, freq_deviation);


% n = [0,1,2,3,4,5,6,7];
% data = int2bit(n(:), 3);
% [iq] = generate_8fsk(data, amplitude, sample_rate, symbol_length, offset_frequency, freq_deviation);


%%
iq_data = int16(iq);

index = 1;
for jdx=1:numel(n)
    for idx=1:samples_per_symbol
        fprintf('{%d, %d},', real(iq_data(index)), imag(iq_data(index)))
        index = index + 1;
    end
    fprintf('\n')
end
fprintf('\n')


% for idx=21:
%     fprintf('{%d, %d},', real(iq_data(idx)), imag(iq_data(idx)))
% end
% fprintf('\n')

%% FFT
Y = fft(iq)/numel(iq);
f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%%
figure(plot_num);
spectrogram(iq, 32, 30, 32, sample_rate, 'centered');
plot_num = plot_num + 1;
