function combined_signal = add_interference(desired_signal, noise_signal, target_snr_db)
    % ADD_INTERFERENCE Adds scaled noise to a desired signal based on target SNR.
    %
    % Inputs:
    %   desired_signal - Column vector of the clean IQ signal
    %   noise_signal   - Column vector of the AWGN noise (from previous function)
    %   target_snr_db  - Target Signal-to-Noise Ratio in decibels (e.g., 10 for low noise, -5 for heavy noise)
    %
    % Output:
    %   combined_signal - The combined IQ signal, maintained relative to the original signal's power.

    % Ensure both signals are column vectors and the same length
    desired_signal = desired_signal(:);
    noise_signal = noise_signal(:);
    if length(desired_signal) ~= length(noise_signal)
        error('Signal and Noise must be the same length.');
    end

    % 1. Calculate power (variance) of the desired signal
    % For complex IQ, power is the mean of the squared magnitudes
    p_sig = mean(abs(desired_signal).^2);

    % 2. Calculate the required power of the noise to match target SNR
    p_noise_target = p_sig / (10^(target_snr_db / 10));

    % 3. Normalize the input noise signal to have unity power (Power = 1.0)
    % This strips away whatever arbitrary scaling the noise had previously
    current_noise_power = mean(abs(noise_signal).^2);
    unity_noise = noise_signal / sqrt(current_noise_power);

    % 4. Scale the unity noise to the target interference power
    scaled_noise = unity_noise * sqrt(p_noise_target);

    % 5. Add the interference to the desired signal
    combined_signal = desired_signal + scaled_noise;

    % 6. Optional: Handle Peak Clipping
    % Adding signals means peaks might now exceed +/- 1.0. 
    % To fix this without ruining the SNR, we scale the ENTIRE combined vector down.
    max_peak = max(max(abs(real(combined_signal))), max(abs(imag(combined_signal))));
    if max_peak > 1.0
        % Warning: This reduces the absolute voltage amplitude of your desired signal, 
        % but it is mathematically required if you cannot exceed +/- 1.0 digital limits.
        combined_signal = combined_signal / max_peak;
        warning('Combined signal exceeded +/- 1.0. Scaled down uniformly to prevent clipping.');
    end
end
