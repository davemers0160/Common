% % 1. Create Synthetic IQ signal (chirp + complex sinusoid)
% fs = 10e6; 
% t = 0:1/fs:0.01; % 10 ms
% iq_raw = exp(1i * 2 * pi * 100e3 * t) + exp(1i * 2 * pi * (50e3 + 20e6*t) .* t);
% iq_scaled = iq_raw / max([abs(real(iq_raw)), abs(imag(iq_raw))]); % Scale -1 to 1


format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% load in data
file_filter = {'*.sc16;*.fc32;*.iq;*.sigmf-data','IQ Files';'*.*','All Files' };

[data_file, data_filepath] = uigetfile(file_filter, 'Select File', startpath, 'MultiSelect', 'on');
if(data_filepath == 0)
    return;
end

[~,  fn, ext] = fileparts(data_file);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
elseif(strcmp(ext,'.sc16') == 1)
    scale = 1/2048;
    data_type = 'int16';
elseif(strcmp(ext,'.sigmf-data') == 1)
    scale = 1/2048;
    data_type = 'int16';
elseif(strcmp(ext,'.iq') == 1)
    scale = 1/2048;
    data_type = 'int16';
else
    return;
end

byte_order = 'ieee-le';

fprintf('file: %s\n\n', fullfile(data_filepath, data_file));

%%

[~, iqc_in] = read_binary_iq_data(fullfile(data_filepath, data_file), data_type, byte_order);
iq_data_tmp = scale * iqc_in;

%% truncate signal for faster processing times
capture_time = 0.09;
sample_rate = 60e6;
n = floor(min(capture_time*sample_rate, length(iq_data_tmp)));

% get the number of new samples based on t
% n = floor(signal_length * sample_rate);

iq_scaled = iq_data_tmp(1:n);

%% 2. Execution Parameters
min_fft = 512;
max_fft = 8192;
padding = 10;        % 8-pixel border
padding_val = -120;    % Dark background padding



%% 3. Generate Pyramid
[pyramid_image, layout] = create_spectrogram_pyramid(iq_scaled, min_fft, max_fft, padding, padding_val);

%% 4. Render Layout
figure('Color', 'w');
imagesc(max(pyramid_image, -120)); % Log scale for RF dynamic range
colormap(jet(100));
colorbar;
axis image; 
% title('2D Packed Spectrogram Pyramid (dB Magnitude)');
xlabel('Packed Frame Index');
ylabel('Frequency Bins (Packed)');
ax = gca;
set(ax, 'Position', [0, 0.05, 0.9, 0.9]);

%% Draw bounding boxes around packed levels
% hold on;
% for k = 1:length(layout)
%     rectangle('Position', layout(k).bbox, 'EdgeColor', 'r', 'LineWidth', 1.5, 'LineStyle', '--');
% end
% hold off;

