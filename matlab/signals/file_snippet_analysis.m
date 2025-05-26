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
% iq_filename = 'blade_F1G669_SR50M000_20240720_133942.sc16';
iq_filepath = 'D:\Projects\data\RF\20240720\RB\5M\';
data_filename = "D:\Projects\data\RF\20240720\rb_times_v1.csv";

% sample_rate = 50e6;

% frame_data = importfile1(data_filename, [5, Inf]);

[iq_filename, sample_rate, frame_number, frame_id, start_times, frame_lengths] = import_analysis_file(data_filename, [5, Inf]);


%%

[~,  fn, ext] = fileparts(iq_filename);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
else
    scale = 1/2048;
    data_type = 'int16';
end

byte_order = 'ieee-le';

%% read in iq filename

[~, iqc_in] = read_binary_iq_data(fullfile(iq_filepath, iq_filename), data_type, byte_order);
iqc = (scale) * iqc_in;

t = 0:1/sample_rate:(numel(iqc)-1)/sample_rate;

start_samples = floor(sample_rate * (start_times - 0.002));
frame_length = ceil(sample_rate * frame_lengths);


%% go through a frame ID and get the on/off times

frame_index = unique(frame_id);
frame_index = 7;

burst_lengths = {};
off_times = {};
sample_indices = {};

% 16, 17, 18, 21, 35, 40, 
% 22, 23, 24, 29, 48, 54
% idx = 54

for idx=1:numel(frame_id)
    if(frame_id(idx) == frame_index)
        iq_snippet = iqc(start_samples(idx):start_samples(idx)+frame_length(idx));
        t_snippet = t(start_samples(idx):start_samples(idx)+frame_length(idx));
        
        [bl, ot, indices] = get_burst_indices(iq_snippet, t_snippet, sample_rate);

        burst_lengths{end+1, 1} = bl;
        off_times{end+1, 1} = ot;
        sample_indices{end+1, 1} = indices;
    end
end

%% find the most common on/off times for a burst

burst = zeros(numel(burst_lengths), 2);
off_t = zeros(numel(burst_lengths), 2);

for idx=1:numel(burst_lengths)
    for jdx=1:numel(burst_lengths{idx})
        burst(idx,jdx) = burst_lengths{idx}(jdx);
    end

    for jdx=1:numel(off_times{idx})
        off_t(idx, jdx) = off_times{idx}(jdx);
    end
end

% get the burst means
burst_mean = zeros(1, size(burst, 2));

for idx=1:size(burst, 2)
    
    [N, edges] = histcounts(burst(:,idx));
    [~, index] = max(N);

    burst_mean(idx) = mean(edges(index:index+1));
end

% get the off time means
off_mean = zeros(1, size(off_t, 2));

for idx=1:size(off_t, 2)
    
    [N, edges] = histcounts(off_t(:,idx));
    [~, index] = max(N);

    off_mean(idx) = mean(edges(index:index+1));
end

%% look at the modulation type to determine what it might be

for idx=1:size(sample_indices,1)
    for jdx=1:size(sample_indices{idx},1)
        iq_snippet = iqc(start_samples(idx)+sample_indices{idx}(jdx, 1):start_samples(idx)+sample_indices{idx}(jdx, 2)+floor(sample_rate*110e-6));
        t_snippet = t(start_samples(idx)+sample_indices{idx}(jdx, 1):start_samples(idx)+sample_indices{idx}(jdx, 2)+floor(sample_rate*110e-6));

        figure(101)
        plot(t_snippet, real(iq_snippet),'b')
        hold on;
        plot(t_snippet, imag(iq_snippet),'r')
        plot_num = plot_num + 1;
        drawnow;
        % hold off;


        % figure(plot_num)
        % set(gcf,'position',([50,50,800,500]),'color','w')
        % scatter(real(iq_snippet),imag(iq_snippet),'o','filled', 'b')
        % grid on
        % box on
        % 
        % set(gca,'fontweight','bold','FontSize',12);
        % xlim([-1, 1]);
        % ylim([-1, 1]);
        % 
        % xlabel('I', 'fontweight','bold','FontSize',12);
        % ylabel('Q', 'fontweight','bold','FontSize',12);
        % 
        % ax = gca;
        % ax.XAxisLocation = 'origin';
        % ax.YAxisLocation = 'origin';
        % plot_num = plot_num + 1;

        figure(102)
        set(gcf,'position',([50,50,1400,500]),'color','w')
        
        scatter3(t_snippet, real(iq_snippet), imag(iq_snippet), 20, 'o', 'b', 'filled');
        hold on
        plot3(t_snippet, real(iq_snippet), imag(iq_snippet), 'b');
        
        set(gca,'fontweight','bold','FontSize',11,'Ydir','reverse');
        
        xlabel('time (s)', 'fontweight','bold');
        ylabel('I', 'fontweight','bold');
        zlabel('Q', 'fontweight','bold');
        
        plot_num = plot_num + 1;
        drawnow;
        % hold off;


    end
end








