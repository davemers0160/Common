function [iq] = generate_qpsk(data, amplitude, sample_rate, bit_length)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    angles = pi()/4:pi()/2:2*pi();
    
    if(min(data) == -1)
        data = (data + 1) / 2;
    end
    
    iq = [];
    for idx=1:2:(num_bits-1)
        
        q_bit = 2*data(idx+1) + data(idx);
        
        switch(q_bit)
        
            case 0
                tmp_iq = amplitude*exp(1j*angles(1)) * ones(samples_per_bit,1);
                
            case 1
                tmp_iq = amplitude*exp(1j*angles(2)) * ones(samples_per_bit,1);
                
            case 2
                tmp_iq = amplitude*exp(1j*angles(3)) * ones(samples_per_bit,1);
                                
            case 3
                tmp_iq = amplitude*exp(1j*angles(4)) * ones(samples_per_bit,1);
                
        end
        
        iq = cat(1, iq, tmp_iq);        
        
    end
    
end