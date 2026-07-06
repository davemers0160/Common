function [target_noise_mask, diagnostics] = generate_interference_mask2(iq_data, fs, num_stft_bins, target_freq_bins, alias_free_bw, user_cfg)
% GENERATE_INTERFERENCE_MASK Analyzes IQ data within a specified alias-free bandwidth.
%
% Inputs:
%   iq_data          - Complex baseband IQ data (column vector)
%   fs               - Sample rate of the iq_data in Hz
%   num_stft_bins    - Number of frequency bins for the STFT analysis
%   target_freq_bins - Vector of frequencies (Hz) corresponding to MUSIC bins
%   alias_free_bw    - The width of the alias-free region in Hz (e.g., fs/M for a PFB)
%   user_cfg         - (Optional) Struct containing threshold configurations
%
% Outputs:
%   target_noise_mask - 1 x length(target_freq_bins) logical array (1 = interference, 0 = clean)
%   diagnostics       - Struct containing intermediate metrics for visualization/tuning

    %% 1. Configuration & Setup
    cfg.impulse_kurtosis_th = 5.0;  
    cfg.comb_prominence_db  = 12.0; 
    cfg.lfm_variance_th     = 10.0; 
    cfg.noise_floor_db_th   = 2.0;  
    
    % --- MODIFIED: Handle optional user_cfg with the new argument order ---
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
    
    [~, F_stft, ~, P] = spectrogram(iq_data, blackman(window_len), overlap, num_stft_bins, fs, 'centered');
    
    % --- NEW: Restrict all analysis to the alias-free bandwidth ---
    alias_free_limit = alias_free_bw / 2;
    valid_stft_indices = find(abs(F_stft) <= alias_free_limit);
    
    % If no STFT bins fall within the specified region, exit cleanly.
    if isempty(valid_stft_indices)
        target_noise_mask = false(1, num_target_bins);
        diagnostics.error = 'No STFT bins found within the specified alias_free_bw.';
        if nargout < 2, clear diagnostics; end
        return;
    end
    
    % Create subsets of the STFT data that are within the valid region
    F_stft_valid = F_stft(valid_stft_indices);
    P_valid = P(valid_stft_indices, :);
    
    P_db_valid = 10*log10(P_valid + eps);

    %% 3. STFT-Level Detection Algorithms (Now operating on the VALID subset)
    
    % Background Noise & Wideband EMI
    median_psd_db = median(P_db_valid, 2); 

    %measure
    % baseline_noise_floor = movmedian(median_psd_db, max(3, floor(length(F_stft_valid)/5)));

    % set to a static level - maybe get a quite reading and then add XX dB
    % as a threshold.
    % for now just use a fixed value
    baseline_noise_floor = -90*ones(length(median_psd_db),1);
    psd_delta = (median_psd_db - baseline_noise_floor);

    mask_awgn = psd_delta > cfg.noise_floor_db_th;
    % figure;plot(F_stft_valid,median_psd_db);hold on;plot(F_stft_valid,baseline_noise_floor);yyaxis right;plot(F_stft_valid,psd_delta);

    % Tone Combs & CW
    mask_combs = (median_psd_db - baseline_noise_floor) > cfg.comb_prominence_db;

    % RF Bursts & Impulsive Noise
    linear_mag = sqrt(P_valid);
    bin_kurtosis = kurtosis(linear_mag, 0, 2); 
    mask_bursts = bin_kurtosis > cfg.impulse_kurtosis_th;

    % figure;plot(F_stft_valid, bin_kurtosis);hold on;yyaxis right;plot(F_stft_valid,max(P_db_valid,[],2));plot(F_stft_valid, mean(P_db_valid,2));plot(F_stft_valid,median_psd_db);

    % Wideband LFMs
    bin_std = std(linear_mag, 0, 2);
    bin_mean = mean(linear_mag, 2);
    coeff_of_variation = bin_std ./ (bin_mean + eps);
    mask_lfms = coeff_of_variation > cfg.lfm_variance_th;

    % Aggregate STFT-level mask for the VALID bins
    % stft_noise_mask_valid = mask_awgn | mask_combs | mask_bursts | mask_lfms;
    stft_noise_mask_valid = mask_awgn | mask_combs | mask_lfms;

    %% 4. Map STFT Bins to Target (MUSIC) Bins
    
    [sorted_targets, sort_idx] = sort(target_freq_bins);
    midpoints = (sorted_targets(1:end-1) + sorted_targets(2:end)) / 2;
    edges = [-Inf; midpoints; Inf];
    
    % --- MODIFIED: Map only the valid STFT frequencies ---
    bin_mapping = discretize(F_stft_valid, edges);
    
    sorted_target_mask = false(num_target_bins, 1);
    
    % Combine STFT masks into the target mask using logical OR
    for i = 1:length(F_stft_valid)
        target_idx = bin_mapping(i);
        if ~isnan(target_idx)
            sorted_target_mask(target_idx) = sorted_target_mask(target_idx) | stft_noise_mask_valid(i);
        end
    end
    
    target_noise_mask = false(1, num_target_bins);
    target_noise_mask(sort_idx) = sorted_target_mask;

    %% 5. Diagnostics Output
    if nargout > 1
        % --- MODIFIED: Provide full-spectrum context and valid-region masks ---
        diagnostics.F_stft_full = F_stft;
        diagnostics.P_db_full = 10*log10(P + eps);
        diagnostics.alias_free_indices = valid_stft_indices;
        
        diagnostics.F_stft_valid = F_stft_valid;
        diagnostics.stft_noise_mask_valid = stft_noise_mask_valid.';
        diagnostics.bin_mapping_edges = edges;
        diagnostics.stft_to_target_map_valid = bin_mapping;
        
        diagnostics.median_psd_db = median_psd_db;
        diagnostics.baseline_noise_floor = baseline_noise_floor;
        diagnostics.bin_kurtosis = bin_kurtosis;
        diagnostics.coeff_of_variation = coeff_of_variation;
    end
end
