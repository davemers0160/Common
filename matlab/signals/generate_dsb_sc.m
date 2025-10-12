function [iq_data] = generate_dsb_sc(data, sample_rate, symbol_length, k, amplitude, data_scale)

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

    c1 = (k*amplitude) / (data_scale);

    iq_data = zeros((numel(data)-1) * samples_per_symbol, 1);
    y2 = zeros(numel(data) * samples_per_symbol, 1);

    index = 1;

    for idx = 1:numel(data)-1
 
        % // short cuts based on evenely spaced upsampling
        slope = (data(idx+1) - data(idx))/(samples_per_symbol);
        % int_val = 0;

        for jdx = 0:samples_per_symbol-1
            y2(index) = (data(idx) + jdx*slope);
            int_val = (data(idx) + jdx*slope);
            iq_data(index) = complex(int_val*c1, 0.00000001);
            index = index + 1;
        end
    end

end