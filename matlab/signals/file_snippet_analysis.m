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
frame_index = 1;
fprintf("frame index: %d\n", frame_index);

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
        burst(idx,jdx) = (floor((burst_lengths{idx}(jdx)/sample_rate)*1e8))/1e8;
    end

    for jdx=1:numel(off_times{idx})
        off_t(idx, jdx) = (floor((off_times{idx}(jdx)/sample_rate)*1e8))/1e8;
    end
end

% get the burst means
burst_mean = zeros(1, size(burst, 2));

for idx=1:size(burst, 2)
    
    min_edge = floor(min(burst(:,idx))*1e6)/1e6;
    max_edge = floor(max(burst(:,idx))*1e6)/1e6;
    bin_num = floor(round(max_edge-min_edge, 6)/1e-6);
    edges = min_edge:1e-6:max_edge;

    [N, ~] = histcounts(burst(:,idx), edges);
    [~, index] = max(N);

    burst_mean(idx) = mean(edges(index:index+1));
end

% get the off time means
off_mean = zeros(1, size(off_t, 2));

for idx=1:size(off_t, 2)
    
    min_edge = floor(min(off_t(:,idx))*1e6)/1e6;
    max_edge = floor(max(off_t(:,idx))*1e6)/1e6;
    bin_num = floor(round(max_edge-min_edge, 6)/1e-6);
    edges = min_edge:1e-6:max_edge;

    [N, ~] = histcounts(off_t(:,idx), edges);
    [~, index] = max(N);

    off_mean(idx) = mean(edges(index:index+1));
end

off_mean(end+1) = frame_length(1)/sample_rate - sum(off_mean(:)) - sum(burst_mean(:));

for idx=1:numel(burst_mean)
    fprintf("burst[%d]: %f, %f\n", idx, burst_mean(idx), off_mean(idx));
end

bp = 1;
%% look at the modulation type to determine what it might be

for kdx=1:numel(frame_id)
    if(frame_id(kdx) == frame_index)

        start_time = start_samples(kdx);
        stop_time = start_samples(kdx) + frame_length(kdx) + floor(sample_rate*110e-6);
        iq_snippet = iqc(start_time:1:stop_time);
        t_snippet = t(start_time:1:stop_time);

        figure(100)
        hold off;
        plot(t_snippet, abs(iq_snippet),'g')
        hold on;
        % plot(t_snippet, imag(iq_snippet),'r')
        plot_num = plot_num + 1;
        drawnow;
        bp = 1;

        for idx=1:size(sample_indices,1)-1
            for jdx=1:size(sample_indices{idx},1)

                start_time = start_samples(kdx) + sample_indices{idx}(jdx, 1);
                stop_time = start_samples(kdx) + sample_indices{idx}(jdx, 2) + floor(sample_rate*110e-6);
                % start_time = start_samples(kdx);
                % stop_time = start_samples(kdx) + frame_length(kdx) + floor(sample_rate*110e-6);
                figure(100)
                stem(t(start_time), 1, 'r', 'filled');
                stem(t(stop_time), 1, 'k', 'filled');

                % iq_snippet = iqc(start_samples(idx)+sample_indices{idx}(jdx, 1):start_samples(idx)+sample_indices{idx}(jdx, 2)+floor(sample_rate*110e-6));
                % t_snippet = t(start_samples(idx)+sample_indices{idx}(jdx, 1):start_samples(idx)+sample_indices{idx}(jdx, 2)+floor(sample_rate*110e-6));
                iq_snippet = iqc(start_time:1:stop_time);
                t_snippet = t(start_time:1:stop_time);
        
                figure(101)
                plot(t_snippet, real(iq_snippet),'b')
                hold on;
                plot(t_snippet, imag(iq_snippet),'r')
                plot_num = plot_num + 1;
                drawnow;
                hold off;
                bp = 1;
        
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
                hold off;
        
                bp = 1;
            end
        end
    end
end







