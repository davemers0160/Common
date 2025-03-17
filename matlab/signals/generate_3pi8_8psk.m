function [iq] = generate_3pi8_8psk(data, amplitude, sample_rate, symbol_length)

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);
    
    % check for odd number and append a 0 at the end if it is odd
    data = data(:);

    mod_result = mod(numel(data),3);
    if(mod_result == 1)
        data(end+1) = 0;
        data(end+1) = 0;        
    elseif(mod_result == 2)
        data(end+1) = 0;
    end

    v0 = amplitude/sqrt(2);
    v1 = amplitude;
    v2 = cos(3*pi/8);
    v3 = sin(3*pi/8);

    % vr = exp(1j * 3*pi/8);

    bit_mapper = [complex(-v0, -v0), complex(-v1, 0), complex(0, v1), complex(-v0, v0), complex(0, -v1), complex(v0, -v0), complex(v0, v0), complex(v1, 0),...
                  complex(v2, -v3), complex(-v2, -v3), complex(-v3, v2), complex(-v3, -v2), complex(v3, -v2), complex(v3, v2), complex(-v2, v3), complex(v2, v3)];

    iq = [];
    index = 0;

    for idx=1:3:numel(data)
    
        num = data(idx+2)*4 + data(idx+1)*2 + data(idx);
        offset = 8 * bitand(index, 1, 'uint8');

        iq = cat(1, iq, bit_mapper(num + offset + 1)*ones(samples_per_symbol,1));
        index = index + 1;
        if(index > 255)
            index = 0;
        end

    end

end


