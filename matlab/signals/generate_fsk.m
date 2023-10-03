function [iq] = generate_fsk(data, amplitude, sample_rate, bit_length, center_freq, freq_separation)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    % freq_offset = (freq_separation/2.0)/sample_rate;

    f1 = (center_freq - freq_separation)/sample_rate;
    f2 = (center_freq + freq_separation)/sample_rate;

    iq = [];

    for idx=1:num_bits
    
        if(data(idx) == 1)
            tmp_iq = amplitude * (exp(1j * 2 * pi() * f1 * (0:(samples_per_bit-1)) )).';
        else
            tmp_iq = amplitude * (exp(1j * 2 * pi() * f2 * (0:(samples_per_bit-1)) )).';
        end
        
        iq = cat(1, iq, tmp_iq);        
        
    end

end