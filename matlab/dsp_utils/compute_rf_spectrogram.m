function S_mag = compute_rf_spectrogram(iq_data, nfft)
    % Compute window parameters for 75% overlap
    win = hamming(nfft);
    noverlap = round(0.75 * nfft);
    
    % Calculate STFT centered at 0 Hz (fftshift equivalent)
    [S, ~, ~] = spectrogram(iq_data, win, noverlap, nfft, 'centered');
    
    % Convert to linear magnitude (or use 20*log10(abs(S)+eps) for dB scale)
    S_mag = (20*log10(abs(S)+eps)).'; 
end
