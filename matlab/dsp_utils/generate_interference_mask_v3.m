function [target_noise_mask, diagnostics, diagnostics_lfm] = generate_interference_mask_v3(iq_data, fs, num_stft_bins, target_freq_bins, alias_free_bw, user_cfg)
% GENERATE_INTERFERENCE_MASK v3 - With localized LFM detection.

    %% 1. Configuration & Setup
    % cfg.papr_time_domain_th = 10.0; 
    % cfg.comb_prominence_db  = 12.0;
    cfg.noise_floor_db_th   = 2.0;  

    % --- LFM THRESHOLDS ---
    cfg.peak_threshold_db  = 10.0;  % Minimum dB above local median to be a "peak"
    cfg.time_neighborhood  = 1;    % How many time slices forward to look
    cfg.freq_neighborhood  = 2;    % How many frequency bins up/down to look
    cfg.min_track_length   = 5;    % Minimum time slices a track must span
    cfg.min_freq_sweep     = 3;    % Minimum frequency bins a track must cross to be an LFM

    if nargin > 5
        fields = fieldnames(user_cfg);
        for i = 1:numel(fields)
            cfg.(fields{i}) = user_cfg.(fields{i}); 
        end
    end

    iq_data = iq_data(:);
    target_freq_bins = target_freq_bins(:);
    num_target_bins = length(target_freq_bins);
    
    %% 2. Time-Frequency Representation (STFT)
    window_len = num_stft_bins; 
    overlap = floor(window_len * 0.75); 
    
    [~, F_stft, T_stft, P] = spectrogram(iq_data, blackman(window_len), overlap, num_stft_bins, fs, 'centered');
    
    alias_free_limit = alias_free_bw / 2;
    valid_stft_indices = find(abs(F_stft) <= alias_free_limit);
    
    if isempty(valid_stft_indices)
        target_noise_mask = false(1, num_target_bins); diagnostics.error = 'No STFT bins found'; if nargout < 2, clear diagnostics; end, return;
    end
    
    F_stft_valid = F_stft(valid_stft_indices);
    P_valid = P(valid_stft_indices, :);
    P_db_valid = 10*log10(P_valid + eps);

    %% STFT-Level Detection Algorithms
    
    median_psd_db = median(P_db_valid, 2); 
    % baseline_noise_floor = movmedian(median_psd_db, max(3, floor(length(F_stft_valid)/10)));
    baseline_noise_floor = -90*ones(length(median_psd_db),1);

    psd_delta = (median_psd_db - baseline_noise_floor);

    mask_awgn = psd_delta > cfg.noise_floor_db_th;
    % mask_combs = (median_psd_db - baseline_noise_floor) > cfg.comb_prominence_db;

    % peak_power_time = max(P_valid, [], 2);
    % mean_power_time = mean(P_valid, 2);
    % papr_time = peak_power_time ./ (mean_power_time + eps);
    % mask_bursts = papr_time > cfg.papr_time_domain_th;

    %% Localized LFM Detector

    % [mask_lfms, diagnostics_lfm] = lfm_detector(P_db_valid,  median_psd_db, F_stft_valid, T_stft);
    [mask_lfms, diagnostics_lfm] = lfm_detector2(P_db_valid, median_psd_db, F_stft_valid);

    % stft_noise_mask_valid = mask_awgn | mask_combs | mask_bursts | mask_lfms;
    stft_noise_mask_valid = mask_awgn | mask_lfms;

    %% Mapping & Diagnostics

    [sorted_targets, sort_idx] = sort(target_freq_bins);
    midpoints = (sorted_targets(1:end-1) + sorted_targets(2:end)) / 2;
    edges = [-Inf; midpoints; Inf];
    bin_mapping = discretize(F_stft_valid, edges);

    sorted_target_mask = false(num_target_bins, 1);

    for i = 1:length(F_stft_valid)
        target_idx = bin_mapping(i); 
        if ~isnan(target_idx)
            sorted_target_mask(target_idx) = sorted_target_mask(target_idx) | stft_noise_mask_valid(i); 
        end
    end

    target_noise_mask = false(1, num_target_bins);
    target_noise_mask(sort_idx) = sorted_target_mask;
    
    if nargout > 1
        diagnostics.F_stft_full = F_stft; 
        diagnostics.P_db_full = 10*log10(P + eps); 
        diagnostics.alias_free_indices = valid_stft_indices;
        diagnostics.F_stft_valid = F_stft_valid; 
        diagnostics.stft_noise_mask_valid = stft_noise_mask_valid.';
        diagnostics.median_psd_db = median_psd_db; 
        diagnostics.baseline_noise_floor = baseline_noise_floor;
        % diagnostics.papr_time = papr_time;
        % diagnostics.active_pixel_mask_for_lfm = active_pixel_mask;
    end
end
