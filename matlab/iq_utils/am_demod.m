format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% load in data
file_filter = {'*.sc16;*.fc32','IQ Files';'*.*','All Files' };

[data_file, data_filepath] = uigetfile(file_filter, 'Select File', startpath, 'MultiSelect', 'on');
if(data_filepath == 0)
    return;
end

[~,  fn, ext] = fileparts(data_file);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
else
    scale = 1/2048;
    data_type = 'int16';
end

byte_order = 'ieee-le';

fprintf('filename: %s\n', fullfile(data_filepath, data_file));

%%

[~, iqc_in] = read_binary_iq_data(fullfile(data_filepath, data_file), data_type, byte_order);

%% get sample rate
dlgtitle = 'Input';
prompt = {'Sample Rate:', 'Down Samples Rate:', 'num taps:'};
fieldsize = [1 30; 1 30; 1 30];
definput = {'882000', '20', '17'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

fs_o = str2double(res{1});
ds_rate = str2double(res{2});
num_taps = str2double(res{3});
fs_audio = floor(fs_o/ds_rate);

%%

fprintf("\n");
fprintf("max real: %f\n", max(real(iqc_in)));
fprintf("min real: %f\n", min(real(iqc_in)));
fprintf("max imag: %f\n", max(imag(iqc_in)));
fprintf("min imag: %f\n", min(imag(iqc_in)));
fprintf("\n");

max_v = max([max(real(iqc_in)), max(imag(iqc_in)), abs(min(real(iqc_in))), abs(min(imag(iqc_in)))]);

iqc_o = (1/max_v) * iqc_in;

%% filter and downsample

w = hamming(num_taps);
fc = 0.1e6/fs_o;
lpf = create_fir_filter(fc, w);

iqc_f = conv(iqc_o, lpf(end:-1:1),'same');

iqc = iqc_f(1:ds_rate:end);
fs_audio = floor(fs_o/ds_rate);

t = 0:1/fs_audio:(numel(iqc)-1)/fs_audio;


%% FFT
Y = fft(iqc)/numel(iqc);
f = linspace(-fs_audio/2, fs_audio/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (Hz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%%

audio_out = abs(iqc);
sound(audio_out, fs_audio); 






