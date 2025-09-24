function [iq] = generate_fsk(data, amplitude, sample_rate, symbol_length, offset_frequency, freq_deviation)

    num_bits = numel(data);
    samples_per_symbol = floor(sample_rate*symbol_length+0.5);
    
    c1 = 2*pi*1j*((offset_frequency - freq_deviation)/sample_rate);
    c2 = 2*pi*1j*((offset_frequency + freq_deviation)/sample_rate);
    
    n = (0:(samples_per_symbol-1));
    
    iq = [];

    for idx=1:num_bits
    
        if(data(idx) == 0)
            tmp_iq = amplitude * (exp(c1 * n)).';
        else
            tmp_iq = amplitude * (exp(c2 * n)).';
        end
                
        iq = cat(1, iq, tmp_iq);        
        
    end

end