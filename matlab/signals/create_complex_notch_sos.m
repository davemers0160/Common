function sos_filter = create_complex_notch_sos(sample_rate, notch_freqs, notch_bws)
    % Each notch creates one SOS row: [b0, b1, b2, a0, a1, a2]
    % Note: Coefficients will be complex numbers.
    
    num_notches = length(notch_freqs);
    sos_filter = zeros(num_notches, 6);
    
    for i = 1:num_notches
        % 1. Convert frequencies to normalized radians
        w0 = 2 * pi * notch_freqs(i) / sample_rate;
        bw_rad = 2 * pi * notch_bws(i) / sample_rate;
        
        % 2. Determine pole radius based on bandwidth
        % R is approximately 1 - (BW/2)
        R = 1 - (bw_rad / 2);
        
        % 3. Define the zero and pole locations
        z0 = exp(1j * w0);
        p0 = R * exp(1j * w0);
        
        % 4. Create Second Order Section by squaring the first order notch
        % This ensures a sharper null and meets the "second order" requirement.
        % H(z) = ((z - z0)(z - z0)) / ((z - p0)(z - p0))
        % H(z) = (z^2 - 2*z0*z + z0^2) / (z^2 - 2*p0*z + p0^2)
        
        b0 = 1.0;
        b1 = -2 * z0;
        b2 = z0^2;
        
        a0 = 1.0;
        a1 = -2 * p0;
        a2 = p0^2;
        
        % 5. DC Gain Normalization (0dB at DC)
        % For complex filters, "DC" is z=1. 
        % We want |H(1)| = 1.
%         denominator = (a0 + a1 + a2);
        gain_at_dc = (b0 + b1 + b2) / (a0 + a1 + a2);
        
        if(abs(gain_at_dc) > 1)        
            % Apply normalization to b coefficients
            b0 = b0 / gain_at_dc;
            b1 = b1 / gain_at_dc;
            b2 = b2 / gain_at_dc;
        end
        
        sos_filter(i, :) = [b0, b1, b2, a0, a1, a2];
    end
end