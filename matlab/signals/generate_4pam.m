function [iq_data] = generate_4pam(data, amplitude, symbol_length, sample_rate)

    index = 1;

    span = 9;
    beta = 0.25;

    rrc_filt = create_rrc_filter(span, beta, mp.symbol_length, mp.sample_rate);

    % check for odd number and append a 0 at the end if it is odd
    data = data(:);
    if(mod(numel(data),2) == 1)
        data(end+1) = 0;
    end

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);

    % // pre-calculate the 4 amplitudes for the modulation
    a0 = complex(amplitude * -1.0, 0.0);
    a1 = complex(amplitude * -0.4, 0.0);
    a2 = complex(amplitude * 0.4, 0.0);
    a3 = complex(amplitude * 1.0, 0.0);

    iq_data = zeros(samples_per_symbol* numel(data)*0.5, 1);

    for idx=1:2:numel(data)
    
        num = data(idx)*2 + data(idx+1);

        switch(num)

        case 0
            iq_data(index,1) = a0;

        case 1
            iq_data(index,1) = a1;

        case 2
            iq_data(index,1) = a2;

        case 3
            iq_data(index,1) = a3;
        end
        index = index + samples_per_symbol;
    end

    iq_data = conv(iq_data, rrc_filt, 'same');


end
