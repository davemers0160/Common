function [g] = create_rrc_filter(span, beta, symbol_length, sample_rate, scale)

    samples_per_symbol = floor(sample_rate * symbol_length + 0.5);
    N = span*samples_per_symbol + 1;

    a0 = 1.0 / sqrt(samples_per_symbol);
    a1 = (4.0 * beta) / samples_per_symbol;
    a2 = pi * (1.0 + beta) / samples_per_symbol;
    a3 = pi * (1.0 - beta) / samples_per_symbol;

    g = zeros(1,N);

    for idx = 0:N-1
    
        t = (idx - ((N - 1)/2));

        if (abs(t) < 1e-6)
            g(1, idx+1) = scale * a0 * ((1-beta) + (4*beta/pi));

        elseif (abs(t*4*beta) == samples_per_symbol)
            g(1, idx+1) = scale * (beta/sqrt(2*samples_per_symbol)) * ( (1+(2/pi)) * sin(pi/(4*beta)) + (1-(2/pi))*cos(pi/(4*beta)) );

        else
            g(1, idx+1) = scale * a0 * ( (sin(a3*t)) + (a1*t)*(cos(a2*t)) ) / ( (pi/samples_per_symbol) * t * (1 - a1 * a1 * t * t) );
        end
    end

end