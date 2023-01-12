function [iq] = generate_fsk(data, amplitude, sample_rate, bit_length, freq_separation)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    freq_offset = (freq_separation/2.0)/sample_rate;
    iq = [];

    for idx=1:num_bits
    
        if(data(idx) == 1)
            tmp_iq = amplitude * (exp(1j * 2 * pi() * freq_offset * (0:(samples_per_bit-1)) ))';
        else
            tmp_iq = amplitude * (exp(1j * 2 * pi() * -freq_offset * (0:(samples_per_bit-1)) ))';
        end
        
        iq = cat(1, iq, tmp_iq);        
        
    end


end