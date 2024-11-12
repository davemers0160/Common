function [iq_data, y2] = generate_fm(data, sample_rate, symbol_length, freq_deviation, amplitude)
    
    % % interpolation scale multiplier
    % N = floor(rf_fs/audio_fs);
    % sample_rate = N * audio_fs;
    % num_data_samples = numel(data);
    % num_rf_samples = floor(num_data_samples * N);
    % 
    % scale = 2*pi*1j*k;
    % 
    % iq = zeros(1, num_rf_samples);
    % 
    % % upsample data
    % y2 = upsample_data(data, N);
    % 
    % % shift data to approximately zero mean
    % y2_mean = mean(y2(:));
    % y2 = y2 - y2_mean;
    % 
    % accum = 0;
    % 
    % % apply FM modulation
    % for idx=1:num_rf_samples
    %     accum = accum + y2(idx); 
    %     iq(1,idx) = exp(scale * accum);
    % end

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

    c1 = pi * 1j * freq_deviation/sample_rate;

    iq_data = zeros(numel(data) * samples_per_symbol, 1);
    y2 = zeros(numel(data) * samples_per_symbol, 1);

    int_val = 0;
    index = 1;

    for idx = 1:numel(data)-1
 
        % // short cuts based on evenely spaced upsampling
        slope = (data(idx+1) - data(idx))/(samples_per_symbol);

        for jdx = 0:samples_per_symbol-1
            y2(index) = (data(idx) + jdx*slope);
            int_val = int_val + (data(idx) + jdx*slope);
            iq_data(index) = amplitude*exp(int_val*c1);
            index = index + 1;
        end
    end

end
