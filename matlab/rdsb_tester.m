format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;
line_width = 1;

commandwindow;

%%
samples_per_symbol = 24;
groups_per_frame = 19;
program_identification_code = [0 1 1 1 0 0 1 0 1 1 0 0 0 0 0 0];

%%
rbdsgen = comm.RBDSWaveformGenerator(SamplesPerSymbol=samples_per_symbol, GroupsPerFrame=groups_per_frame, RadioText='Test Radio!', ...
    ProgramServiceName='ABABABAB', ProgramIdentificationCode=program_identification_code, ProgramType="Rock")

Y = step(rbdsgen).';


figure(plot_num);
plot(Y, '.-b')
plot_num = plot_num + 1;

%% upsample

factor = 8;

sample_rate = samples_per_symbol * factor * 1187.5;

rbds_up = upsample(Y, factor);

N = 10*factor + 1;

w = blackman_nuttall_window(N);

% create the full filter using the window
lpf = N*create_fir_filter(2375/sample_rate, w);

% rolloff = 1;
% no_of_symbols = 10;
% lpf = rcosdesign(rolloff, no_of_symbols, (samples_per_symbol * factor) );

% apply the filter to the bpsk signal
rbds_conv = 20*conv(rbds_up, lpf(end:-1:1), 'same');

figure(plot_num);
plot(160*rbds_up, '-b')
hold on
box on
grid on
plot(rbds_conv, '-g')
plot_num = plot_num + 1;


%%

pilot_freq = 19000;

rbds_freq = 57000;

% pilot_tone = (800*exp(1i*2*pi()*(pilot_freq/sample_rate)*(0:1:numel(rbds_conv)-1)));
% rbds_rot = exp(1i*2*pi()*(rbds_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

% rbds_conv_c = complex(rbds_conv);
% iq_rbds = (rbds_conv_c .* rbds_rot);

% iq_data = int16(pilot_tone + iq_rbds);

pilot_tone = 1200*sin(2*pi()*(pilot_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

rbds_rot = 2*sin(2*pi()*(rbds_freq/sample_rate)*(0:1:numel(rbds_conv)-1));

iq_rbds = (rbds_conv .* rbds_rot);
iq_data = complex(int16(pilot_tone + iq_rbds));


figure(plot_num);
plot(real(iq_rbds), '-b')
plot_num = plot_num + 1;

max(real(iq_data))
max(imag(iq_data))
min(real(iq_data))
min(imag(iq_data))

%%
fft_rbds = fft(double(iq_data)/2048)/numel(iq_data);

x_rbds = linspace(-sample_rate/2, sample_rate/2, numel(fft_rbds));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on;
plot(x_rbds/1e3, 20*log10(abs(fftshift(fft_rbds))),'k')
% plot(x_rbds/1e6, 20*log10(abs(fftshift(fft_x1))),'g')
grid on
box on
set(gca,'fontweight','bold','FontSize', 13);
xlim([x_rbds(1), x_rbds(end)]/1e3);
xlabel('Frequency (KHz)', 'fontweight', 'bold', 'FontSize', 13);
ylabel('Amplitude', 'fontweight', 'bold', 'FontSize', 13);
title('Filtered vs. Un-Filtered Signal', 'fontweight', 'bold', 'FontSize', 14);

plot_num = plot_num + 1;

%%
data_type = 'int16';
byte_order = 'ieee-le';

filename = 'D:\Projects\data\RF\test_rds.sc16';

write_binary_iq_data(filename, iq_data, data_type, byte_order);

fprintf('complete\n');

%%

fname = 'D:\Projects\data\RF\test_rds2.bb';

bbw = comm.BasebandFileWriter(fname, sample_rate, 101.7e6);

tmp = single(pilot_tone + iq_rbds).';

tmp = tmp/(max(abs(tmp)));

bbw(tmp)

release(bbw);


