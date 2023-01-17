function [iq] = generate_bpsk(data, amplitude, sample_rate, bit_length)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    iq = [];
    
    for idx=1:num_bits
    
        iq = cat(1, iq, amplitude*data(idx)*ones(samples_per_bit,1));

    end
    
    % realmin("double") is used becuase MATLAB doesn't correctly handle complex values
    iq = complex(iq, realmin("double")*ones(numel(iq),1));

end