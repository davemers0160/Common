function [iq] = generate_oqpsk(data, sample_rate, half_symbol_length)

    samples_per_symbol = floor(sample_rate * half_symbol_length);
    samples_per_symbol_x2 = floor(2 * sample_rate * half_symbol_length);
    
    % check for odd number and append a 0 at the end if it is odd
    data = data(:);
    if(mod(numel(data),2) == 1)
        data(end+1) = 0;
    end
    
    % reshape to 2 bits
    d2 = reshape(data, [], 2);
    num_bit_pairs = size(d2, 1);
    
    % this will expand the bit to fill the right number of samples
    s = ones(floor(samples_per_symbol_x2), 1);
    
    % pre calculate the base 45 degree value
    v = sqrt(2)/2;
          
    % start with I and Q offset by half a bit length
    I = [];
    Q = zeros(samples_per_symbol,1);
    
    for idx=1:2:numel(data)
    
        num = data(idx)*2 + data(idx+1);
        
        % map the bit pair value to IQ values
        switch(num)
            case 0
                v_i = -v;
                v_q = -v;
            case 1
                v_i = -v;
                v_q = v;
            case 2
                v_i = v;
                v_q = -v;
            case 3
                v_i = v;
                v_q = v;
        end
        
        % append the new data
        I = cat(1, I, v_i*s);
        Q = cat(1, Q, v_q*s);
        
    end
    
    % add half a bit length of zeros to the I channel
    I = cat(1, I, zeros(samples_per_symbol,1));
    
    % merge the I and Q channels
    iq = I + 1j*Q;

end
