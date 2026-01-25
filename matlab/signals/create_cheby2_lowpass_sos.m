function sos_filter = create_cheby2_lowpass_sos(sample_rate, cutoff_freq)
    % Hardcoded order N = 4
    N = 4;
    stopband_atten_db = 40; % Standard ripple attenuation in dB
    
    % 1. Pre-warp the cutoff frequency for Bilinear Transform
    T = 1 / sample_rate;
    wa = (2/T) * tan(pi * cutoff_freq / sample_rate);
    
    % 2. Find Analog Prototype Poles and Zeros (Cheby II)
    % Calculate epsilon and auxiliary parameter mu
    eps = 1 / sqrt(10^(stopband_atten_db/10) - 1);
    mu = asinh(1/eps) / N;
    
    % Calculate poles and zeros for the sections
    % For N=4, we have two sections (k=1,2)
    sos_filter = zeros(2, 6);
    
    for k = 1:2
        % Angles for poles/zeros
        phi_k = (2*k - 1) * pi / (2 * N);
        
        % Analog Poles (of the inverse prototype, then inverted)
        sp_real = -sinh(mu) * sin(phi_k);
        sp_imag = cosh(mu) * cos(phi_k);
        p_proto = 1 / (sp_real + 1j*sp_imag);
        
        % Analog Zeros (on the jw axis)
        sz_imag = 1 / cos(phi_k);
        z_proto = 1j * sz_imag;
        
        % Scale by pre-warped frequency
        pa = p_proto * wa;
        za = z_proto * wa;
        
        % 3. Bilinear Transformation: s = (2/T)*(z-1)/(z+1)
        % This yields: H(z) = [ (2+zaT)z + (zaT-2) ] / [ (2-paT)z - (paT+2) ]
        % For a conjugate pair, we multiply (s-za)(s-conj(za))
        
        % Transform zeros to Z-domain
        num_poly = [ (2/T - za), (2/T + za) ];
        num_poly = conv(num_poly, conj(num_poly)); % Second order
        
        % Transform poles to Z-domain
        den_poly = [ (2/T - pa), -(2/T + pa) ];
        den_poly = conv(den_poly, conj(den_poly)); % Second order
        
        % 4. Normalize and Store
        b = real(num_poly);
        a = real(den_poly);
        
        % Normalize so a0 = 1
        b = b / a(1);
        a = a / a(1);
        
        % 5. DC Gain Normalization (0dB at DC)
        % Ensure sum(b)/sum(a) = 1
        gain_correction = sum(a) / sum(b);
        b = b * gain_correction;
        
        sos_filter(k, :) = [b(1), b(2), b(3), a(1), a(2), a(3)];
    end
end