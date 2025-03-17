function [iq] = generate_pi4qpsk(data, amplitude, sample_rate, symbol_length)

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);
    
    % check for odd number and append a 0 at the end if it is odd
    data = data(:);
    if(mod(numel(data),2) == 1)
        data(end+1) = 0;
    end

    v0 = amplitude/sqrt(2);
    v1 = amplitude;

    bit_mapper = [complex(-v0, -v0), complex(-v0, v0), complex(v0, -v0), complex(v0, v0), complex(-v1, 0), complex(0, v1), complex(0, -v1), complex(v1, 0) ];

    iq = [];

    index = 0;
    for idx=1:2:numel(data)
    
        num = data(idx+1)*2 + data(idx);

        offset = 4 * bitand(index, 1, 'uint8');

        iq = cat(1, iq, bit_mapper(num + offset + 1)*ones(samples_per_symbol,1));

        index = index + 1;

    end

end