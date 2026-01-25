function f = create_notch_fir(sample_rate, notch_freq, notch_bw, num_taps)
    % Ensure num_taps is odd for a symmetric Type I FIR filter
    if mod(num_taps, 2) == 0
        num_taps = num_taps + 1;
    end

    % 1. Normalize frequencies (0 to pi)
    wc = 2 * pi * notch_freq / sample_rate;
    bw = 2 * pi * notch_bw / sample_rate;
    
    % 2. Initialize coefficients and constants
    b_bp = zeros(1, num_taps);
    tau = (num_taps - 1) / 2; % Center of the filter
    
    for n = 0:(num_taps - 1)
        dist = n - tau;
        
        % 3. Calculate Band-Pass Impulse Response
        if dist == 0
            % Handle division by zero for the sinc function center
            h_bp = bw / pi;
        else
            h_bp = (sin(bw/2 * dist) / (pi * dist)) * 2 * cos(wc * dist);
        end
        
        % 4. Apply Hamming Window: 0.54 - 0.46 * cos(2*pi*n/(M-1))
        w_n = 0.54 - 0.46 * cos(2 * pi * n / (num_taps - 1));
        b_bp(n + 1) = h_bp * w_n;
    end
    
    % 5. Create Notch by subtracting Band-Pass from an Identity (Delta)
    % A delta function is 1 at the center (tau) and 0 elsewhere
    delta = zeros(1, num_taps);
    delta(tau + 1) = 1;
    
    f = delta - b_bp;
    
    % Optional: Normalize so the gain at DC is 1
    f = f / sum(f); 
end