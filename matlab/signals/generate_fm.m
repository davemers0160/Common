function [iq, sample_rate, y2] = generate_fm(data, audio_fs, rf_fs, k)
    
    % interpolation scale multiplier
    N = floor(rf_fs/audio_fs);
    sample_rate = N * audio_fs;
    num_data_samples = numel(data);
    num_rf_samples = floor(num_data_samples * N);
    
    scale = 2*pi*1j*k;
    
    iq = zeros(1, num_rf_samples);
    
    % upsample data
    y2 = upsample_data(data, N);
    
    % shift data to approximately zero mean
    y2_mean = mean(y2(:));
    y2 = y2 - y2_mean;
    
    accum = 0;
    
    % apply FM modulation
    for idx=1:num_rf_samples
        accum = accum + y2(idx); 
        iq(1,idx) = exp(scale * accum);
    end

end
