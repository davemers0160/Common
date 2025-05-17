function [burst_lengths, off_times, indexes] = get_burst_indices(iq_snippet, t_snippet, sample_rate)

    iq_mag = abs(iq_snippet);
    sample_index = 0:numel(iq_mag)-1;

    % smooth the data to reduce highs and lows
    filter_size = 31;
    iq_mag_filt = conv(iq_mag, 1/filter_size*ones(filter_size,1), 'same');
    
    % calculate the threshold
    iq_mag_filt_mean = 1.18*mean(iq_mag_filt);
    
    % create a binary amplitude map
    iq_mag_bin = iq_mag_filt > iq_mag_filt_mean;

    iq_mag_bin_sum = sum(iq_mag_bin);
    iq_mag_sum_delta = 1e6;

    num_contiguous_samples = (ceil(sample_rate * 20e-6) + 1);
    count = 0;

    min_pulse_width = (ceil(sample_rate * 1e-6) + 1);

    % figure(1000)
    % hold on
    % plot(iq_mag_bin, 'b');

    % run an open operation to remove small blips smaller than min_pulse_width
    iq_mag_bin = imopen(iq_mag_bin, ones(7,1));
    % plot(iq_mag_bin, '.-');

    while(iq_mag_sum_delta > 1 || count > 100)
        iq_mag_bin = imclose(iq_mag_bin, ones(num_contiguous_samples,1));
        % plot(iq_mag_bin, '.-');
        % drawnow;

        current_sum = sum(iq_mag_bin);
        iq_mag_sum_delta = abs(iq_mag_bin_sum - current_sum);
        iq_mag_bin_sum = current_sum;
        count = count + 1;
    end
    
    iq_mag_bin = imopen(iq_mag_bin, ones(min_pulse_width,1));
    % plot(iq_mag_bin, '.-');

    iq_mag_bin = 2*iq_mag_bin - 1;
    
    % look at neighboring values +(sample_rate * 1e-6) and determine if there
    % is a drop to fill in the values
    
    
    % find the transitions
    start_filter = [-1 1 1];
    stop_filter = [1 1 -1];
    
    start_corr = conv(iq_mag_bin, start_filter(end:-1:1), 'same');
    stop_corr = conv(iq_mag_bin, stop_filter(end:-1:1), 'same');
    
    start_corr = (start_corr == 3);
    stop_corr = (stop_corr == 3);
    
    % use the count and end values to determine if we are in the middle of a
    % hump or at the end
    start_index = sample_index(start_corr)';
    stop_index = sample_index(stop_corr)';
    
    % add a point for the start if the first element is a 1
    if(iq_mag_bin(1) == 1)
        start_index = cat(1, 1, start_index);
    end

    % add a point for stop if the last element is a 1
    if(iq_mag_bin(end) == 1)
        stop_index = cat(1, stop_index, numel(iq_mag_bin));
    end

    min_index = min(numel(stop_index), numel(start_index));

    burst_lengths = (stop_index(1:min_index)-start_index(1:min_index))';
    off_times = (start_index(2:min_index) - stop_index(1:min_index-1))';

    indexes = cat(2, start_index(1:min_index), stop_index(1:min_index));

    figure;
    hold on;
    plot(t_snippet, iq_mag_filt, 'g');
    plot([t_snippet(1), t_snippet(end)], [iq_mag_filt_mean, iq_mag_filt_mean], '--k');
    plot(t_snippet, iq_mag_bin, 'b');

    scatter(t_snippet(indexes(:,1)), ones(numel(indexes(:,1)),1), 30, 'o','r', 'filled');
    scatter(t_snippet(indexes(:,2)), ones(numel(indexes(:,2)),1), 30, 'o','k', 'filled');
    drawnow;
end