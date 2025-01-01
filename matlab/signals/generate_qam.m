function [iq] = generate_qam(data, amplitude, sample_rate, iq_map, bit_length)

    samples_per_bit = floor(sample_rate * bit_length + 0.5);
    
    % determine how many bits are being mapped
    num_bits = log2(numel(iq_map));
    
    % make sure that data has the right number of bits
    data = data(:);
    n = mod(numel(data), num_bits);
    if(n ~= 0)
        data = cat(1, data, zeros(n,1));
    end   
    
    % reshape the bits
    d2 = reshape(data, [], num_bits);
    num_bit_groups = size(d2, 1);
    
    iq = [];
      
    for idx=1:num_bit_groups
    
        num = 0;
        for jdx=1:num_bits
            num = num + bitshift(d2(idx, jdx),(num_bits-jdx));
        end
        
        iq = cat(1, iq, amplitude*iq_map(num + 1)*ones(samples_per_bit,1));
        
        
    end   

end
