function [iq] = generate_8fsk(data, amplitude, sample_rate, symbol_length, offset_frequency, freq_deviation)

    num_freqs = 8;
    num_bits = 3;

    num_data = numel(data);

    % data must be an even multiple of num_bits
    rem = mod(num_data, num_bits);
    if(rem ~= 0)
        data = cat(1,data(:),zeros(num_bits-rem,1));
    end

    samples_per_symbol = floor(sample_rate*symbol_length+0.5);

    % frequency separation ratios
    m = [ -1.0, -5.0 / 7.0, -3.0 / 7.0, -1.0 / 7.0, 1.0 / 7.0, 3.0 / 7.0, 5.0 / 7.0, 1.0 ];
    n = 0:samples_per_symbol-1;

    for idx=1:num_freqs
        c(idx) = 2*pi*1j*(offset_frequency+m(idx)*freq_deviation/sample_rate);
        f{idx} = amplitude*exp(c(idx)*n);
    end
    
    iq = [];

    for idx=1:num_bits:num_data
    
        num = data(idx)*4 + data(idx+1)*2 + data(idx+2) + 1;
     
        iq = cat(1, iq, f{num}(:));
    end

end