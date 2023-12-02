function [iq] = generate_fsk(data, amplitude, sample_rate, bit_length, center_freq, freq_separation)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length+0.5);
    
%     f1 = (-freq_separation)/sample_rate;
%     f2 = (+freq_separation)/sample_rate;  

    f1 = (center_freq - freq_separation)/sample_rate;
    f2 = (center_freq + freq_separation)/sample_rate;
    
    samples_per_cycle_f1 = floor(floor(samples_per_bit*f1 + 0.5)*(1/f1) + 0.5)
    samples_per_cycle_f2 = floor(floor(samples_per_bit*f2 + 0.5)*(1/f2) + 0.5)    
    

    
    iq = [];

    for idx=1:num_bits
    
        if(data(idx) == 1)
%             tmp_iq = amplitude * (exp(1j * 2 * pi() * -f1 * (0:(samples_per_bit-1)) )).';
            tmp_iq = amplitude * (exp(1j*2 * pi() * f1 * (0:(samples_per_bit-1)) )).';
        else
%             tmp_iq = amplitude * (exp(1j * 2 * pi() * f2 * (0:(samples_per_bit-1)) )).';
            tmp_iq = amplitude * (exp(1j*2 * pi() * f2 * (0:(samples_per_bit-1)) )).';
        end
        
%         tmp_iq = tmp_iq .* exp(1j * 2 * pi() * center_freq/sample_rate * (0:(samples_per_bit-1))).';
        
        iq = cat(1, iq, tmp_iq);        
        
    end
    
%     iq = iq .* exp(1j * 2 * pi() * center_freq/sample_rate * (0:(numel(iq)-1))).';
    

end