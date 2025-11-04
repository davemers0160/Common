format long g
format compact
% clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% 

sample_rate = 10e6;
symbol_length = 0.010;
amplitude = 2046;
freq_offset = 1e6;

samples_per_symbol = floor(sample_rate*symbol_length);

%%

iqc = complex(single(zeros(1,samples_per_symbol)), single(amplitude*ones(1,samples_per_symbol)));


%%

num_samples = numel(iqc);
n = 0:1:num_samples-1;

f_rot_s = exp(1j*2*pi*single(freq_offset)/single(sample_rate)*n);

iqc_rs = f_rot_s.*iqc;
iqc_rs = complex(int16(real(iqc_rs)), int16(imag(iqc_rs)));


iqc_d = complex(zeros(1,samples_per_symbol), amplitude*ones(1,samples_per_symbol));
f_rot_d = exp(1j*2*pi*(freq_offset/sample_rate)*n);

iqc_rd = f_rot_d.*iqc_d;
iqc_rd = complex(double(int16(real(iqc_rd))), double(int16(imag(iqc_rd))));


 %% FFT
iqc_rs_fft = fft(iqc_rs)/numel(iqc_rs);
f = linspace(-sample_rate/2, sample_rate/2, numel(iqc_rs_fft));

iqc_rd_fft = fft(iqc_rd)/numel(iqc_rd);
fd = linspace(-sample_rate/2, sample_rate/2, numel(iqc_rd_fft));

%%
iq_start = max(floor(sample_rate*0.00999), 1);
iq_stop = min(iq_start + ceil(sample_rate*0.01), numel(iqc));
step = 1;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(real(iqc_rs(iq_start:step:iq_stop)),'b')

box on
grid on
hold on
plot(real(iqc_rd(iq_start:step:iq_stop)),'--r')
% plot(real(iqc_filt_t),'g')
% plot(imag(iqc),'m')
% plot(real(filtered),'c')

xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1; 

%%

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(iqc_rs_fft))), 'b');
box on
grid on
hold on
plot(fd*1e-6, 20*log10(abs(fftshift(iqc_rd_fft+complex(1e-9,1e-9)))), '--r');
% plot(f*1e-6, 20*log10(abs(fftshift(Y_filt_t))), 'g');

xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1; 