function [target_noise_mask, diagnostics] = generate_interference_mask(iq_data, fs, num_stft_bins, target_freq_bins, user_cfg)
% GENERATE_INTERFERENCE_MASK Analyzes IQ data and maps interference to specific target bins.
%
% Inputs:
%   iq_data          - Complex baseband IQ data (column vector)
%   fs               - Sample rate in Hz
%   num_stft_bins    - Number of frequency bins for the STFT analysis
%   target_freq_bins - Vector of frequencies (Hz) corresponding to MUSIC bins
%   user_cfg         - (Optional) Struct containing threshold configurations
%
% Outputs:
%   target_noise_mask - 1 x length(target_freq_bins) logical array (1 = interference, 0 = clean)
%   diagnostics       - Struct containing intermediate metrics for visualization/tuning

    %% 1. Configuration & Setup
    cfg.impulse_kurtosis_th = 5.0;  
    cfg.comb_prominence_db  = 12.0; 
    cfg.lfm_variance_th     = 10.0; 
    cfg.noise_floor_db_th   = 5.0;  
    
    if nargin > 4
        fields = fieldnames(user_cfg);
        for i = 1:numel(fields)
            cfg.(fields{i}) = user_cfg.(fields{i});
        end
    end

    iq_data = iq_data(:);
    target_freq_bins = target_freq_bins(:); % Ensure column vector
    num_target_bins = length(target_freq_bins);

    %% 2. Time-Frequency Representation (STFT)
    window_len = num_stft_bins; 
    overlap = floor(window_len * 0.75); 
    
    % Notice we now capture F_stft (the frequency vector of the STFT)
    [~, F_stft, ~, P] = spectrogram(iq_data, blackman(window_len), overlap, num_stft_bins, fs, 'centered');
    
    P_db = 10*log10(P + eps);

    %% 3. STFT-Level Detection Algorithms
    
    % Background Noise & Wideband EMI
    median_psd_db = median(P_db, 2); 
    baseline_noise_floor = movmedian(median_psd_db, max(3, floor(num_stft_bins/10)));
    mask_awgn = (median_psd_db - baseline_noise_floor) > cfg.noise_floor_db_th;

    % Tone Combs & CW
    mask_combs = (median_psd_db - baseline_noise_floor) > cfg.comb_prominence_db;

    % RF Bursts & Impulsive Noise
    linear_mag = sqrt(P);
    bin_kurtosis = kurtosis(linear_mag, 0, 2); 
    mask_bursts = bin_kurtosis > cfg.impulse_kurtosis_th;

    % Wideband LFMs
    bin_std = std(linear_mag, 0, 2);
    bin_mean = mean(linear_mag, 2);
    coeff_of_variation = bin_std ./ (bin_mean + eps);
    mask_lfms = coeff_of_variation > cfg.lfm_variance_th;

    % Aggregate STFT-level mask
    stft_noise_mask = mask_awgn | mask_combs | mask_bursts | mask_lfms;

    %% 4. Map STFT Bins to Target (MUSIC) Bins
    
    % Sort target frequencies to safely establish boundaries (keep original index mapping)
    [sorted_targets, sort_idx] = sort(target_freq_bins);
    
    % Calculate the midpoints between target bins to serve as mapping edges
    midpoints = (sorted_targets(1:end-1) + sorted_targets(2:end)) / 2;
    edges = [-Inf; midpoints; Inf]; % Catch-all bounds for the edges
    
    % Discretize maps each STFT frequency to a bin defined by our edges
    % This tells us which sorted_target bin each STFT bin belongs to
    bin_mapping = discretize(F_stft, edges);
    
    % Preallocate the mapped target mask
    sorted_target_mask = false(num_target_bins, 1);
    
    % Combine STFT masks into the target mask using logical OR
    for i = 1:length(F_stft)
        target_idx = bin_mapping(i);
        if ~isnan(target_idx)
            % If multiple STFT bins map to the same target_idx, this ORs them together
            sorted_target_mask(target_idx) = sorted_target_mask(target_idx) | stft_noise_mask(i);
        end
    end
    
    % Revert the mask back to the original unsorted order of target_freq_bins
    target_noise_mask = false(1, num_target_bins);
    target_noise_mask(sort_idx) = sorted_target_mask;

    %% 5. Diagnostics Output
    if nargout > 1
        diagnostics.F_stft = F_stft;
        diagnostics.stft_noise_mask = stft_noise_mask.';
        diagnostics.bin_mapping_edges = edges;
        diagnostics.stft_to_target_map = bin_mapping;
        
        diagnostics.P_db = P_db;
        diagnostics.median_psd_db = median_psd_db;
        diagnostics.baseline_noise_floor = baseline_noise_floor;
        diagnostics.bin_kurtosis = bin_kurtosis;
        diagnostics.coeff_of_variation = coeff_of_variation;
    end
end