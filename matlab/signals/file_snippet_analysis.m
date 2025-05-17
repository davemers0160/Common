format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% open text file

% TODO: make this part of the file import
iq_file = 'blade_F1G669_SR50M000_20240720_133942.sc16';
iq_filepath = 'D:\Projects\data\RF\20240720\RB\5M\';

sample_rate = 50e6;

frame_data = importfile1("D:\Projects\data\RF\20240720\rb_times_v1.csv", [2, Inf]);


%%

[~,  fn, ext] = fileparts(iq_file);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
else
    scale = 1/2048;
    data_type = 'int16';
end

byte_order = 'ieee-le';

%% read in iq filename

[~, iqc_in] = read_binary_iq_data(fullfile(iq_filepath, iq_file), data_type, byte_order);
iqc = (scale) * iqc_in;

t = 0:1/sample_rate:(numel(iqc)-1)/sample_rate;

start_samples = floor(sample_rate*(frame_data(:,3)-0.002));
frame_length = ceil(sample_rate*frame_data(:,4));


%%

frame_index = unique(frame_data(:,2));
frame_index = 7;

burst_lengths = {};
off_times = {};
% 16, 17, 18, 21, 35, 40, 
% 22, 23, 24, 29, 48, 54
idx = 54

for idx=1:size(frame_data, 1)
    if(frame_data(idx,2) == frame_index)
        iq_snippet = iqc(start_samples(idx):start_samples(idx)+frame_length(idx));
        t_snippet = t(start_samples(idx):start_samples(idx)+frame_length(idx));
        
        [bl, ot, indexes] = get_burst_indices(iq_snippet, t_snippet, sample_rate);

        burst_lengths{end+1, 1} = bl;
        off_times{end+1, 1} = ot;
    end
end

burst = zeros(numel(burst_lengths), 8);
off_t = zeros(numel(burst_lengths), 8);

for idx=1:numel(burst_lengths)
    for jdx=1:numel(burst_lengths{idx})
        burst(idx,jdx) = burst_lengths{idx}(jdx);
    end

    for jdx=1:numel(off_times{idx})
        off_t(idx, jdx) = off_times{idx}(jdx);
    end    

end


