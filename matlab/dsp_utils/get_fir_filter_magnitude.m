function [m, m2] = get_fir_filter_magnitude(b, num_points)

    m = zeros(num_points, 1);
    m2 = zeros(num_points, 1);
    
    step = (2.0 * pi()) / (num_points - 1);
    
    for idx = 0:num_points-1 
    
        omega = -pi() + (idx * step);
        
        h = complex(0,0);
        h2 = complex(0,0);

        for jdx = 0:numel(b)-1 
        
            % // Evaluate H(e^jω) = Σ b[n] * e^(-j * omega * n)
            % // Using Euler's formula: e^(-jθ) = cos(θ) - j*sin(θ)
            angle = omega * jdx;
            % h = h + complex(b(jdx+1) * cos(angle), -b(jdx+1) * sin(angle));
            h = h + (b(jdx+1) * exp(-1j * angle));
        end
        
        % //magnitudes.push_back(get_fir_filter_magnitude(b, omega));
        m(idx+1) = (abs(h));
        m2(idx+1) = 20.0 * log10(abs(h) + 1e-12);
    end

end