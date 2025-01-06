function [iq] = generate_ask(data, amplitude, sample_rate, bit_length)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    iq = [];

    for idx=1:num_bits
    
        if(data(idx) == 1)
            iq = cat(1, iq, amplitude*0.90*ones(samples_per_bit,1));
        else
            iq = cat(1, iq, 0.1*ones(samples_per_bit,1));
        end
    end
    
    % realmin("double") is used becuase MATLAB doesn't correctly handle complex values
    iq = complex(iq, realmin("double")*ones(numel(iq),1));
end
