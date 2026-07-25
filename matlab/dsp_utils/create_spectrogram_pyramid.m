function [packed_pyramid, layout_info] = create_spectrogram_pyramid(iq_data, min_fft_size, max_fft_size, padding_size, pad_value)
% CREATE_SPECTROGRAM_PYRAMID Generates a 2D packed image pyramid of RF magnitude spectrograms.
%
% Inputs:
%   iq_data      - 1D complex IQ data vector (scaled -1 to 1)
%   min_fft_size - Minimum FFT size (e.g., 64)
%   max_fft_size - Maximum FFT size (e.g., 1024)
%   padding_size - Pixels/cells of padding around each spectrogram
%   pad_value    - Value to fill padding area with (Default: 0 / min magnitude)
%
% Outputs:
%   packed_pyramid - 2D matrix containing packed spectrogram magnitudes
%   layout_info    - Structure array containing spatial bounding boxes for each level

    if nargin < 5 || isempty(pad_value)
        pad_value = -200; 
    end

    % Ensure input vector is a column
    iq_data = iq_data(:);
    
    % Generate power-of-2 FFT sizes for the pyramid levels
    fft_sizes = 2.^(log2(min_fft_size):log2(max_fft_size));
    num_levels = length(fft_sizes);
    
    % Cell array to store individual unpadded spectrogram magnitude matrices
    spectrograms = cell(num_levels, 1);
    
    % Step 1: Compute magnitude spectrograms for each FFT size
    for k = 1:num_levels
        nfft = fft_sizes(k);
        spectrograms{k} = compute_rf_spectrogram(iq_data, nfft);
    end
    
    % Step 2: Pack spectrograms into a single 2D matrix
    [packed_pyramid, layout_info] = pack_spectrogram_levels(spectrograms, padding_size, pad_value);
end
