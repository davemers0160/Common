function sos_matrix = create_cheby2_bp_sos(sample_rate, center_freq, bandwidth, filter_order)
% 1. Frequency Warping
    t_step = 1 / sample_rate;
    f1 = center_freq - (bandwidth / 2);
    f2 = center_freq + (bandwidth / 2);
    
    % Map digital frequencies to analog s-plane via pre-warping
    alpha_1 = (2 / t_step) * tan(pi * f1 / sample_rate);
    alpha_2 = (2 / t_step) * tan(pi * f2 / sample_rate);
    
    bw_analog = alpha_2 - alpha_1;
    omega_0_sq = alpha_1 * alpha_2;

    % 2. Analog Low-Pass Prototype (Chebyshev II)
    stop_attn_db = 60; % Standard stopband rejection
    delta = 10^(stop_attn_db / 20);
    epsilon = 1 / sqrt(delta^2 - 1);
    
    v_0 = asinh(1 / epsilon) / filter_order;
    
    p_proto = [];
    z_proto = [];
    
    for k = 1:filter_order
        phi = (pi * (2 * k - 1)) / (2 * filter_order);
        
        % Prototype Poles
        sp_real = -sinh(v_0) * sin(phi);
        sp_imag = cosh(v_0) * cos(phi);
        p_lp = 1 / (sp_real + 1i * sp_imag);
        p_proto = [p_proto; p_lp];
        
        % Prototype Zeros (Only for pairs)
        if mod(filter_order, 2) == 0 || k ~= (filter_order + 1) / 2
            z_lp = 1i / cos(phi);
            z_proto = [z_proto; z_lp];
        end
    end

    % 3. Transform LP to BP
    % Transformation: s_lp = (s_bp^2 + omega_0^2) / (s_bp * bw_analog)
    % Leads to quadratic: s_bp^2 - (s_lp * bw_analog) * s_bp + omega_0^2 = 0
    
    p_bp = [];
    for i = 1:length(p_proto)
        b = p_proto(i) * bw_analog;
        roots_p = [ (b + sqrt(b^2 - 4 * omega_0_sq)) / 2;
                    (b - sqrt(b^2 - 4 * omega_0_sq)) / 2 ];
        p_bp = [p_bp; roots_p];
    end
    
    z_bp = [];
    for i = 1:length(z_proto)
        b = z_proto(i) * bw_analog;
        roots_z = [ (b + sqrt(b^2 - 4 * omega_0_sq)) / 2;
                    (b - sqrt(b^2 - 4 * omega_0_sq)) / 2 ];
        z_bp = [z_bp; roots_z];
    end
    
    % Add zeros at origin and infinity to fill the remaining slots
    % (A BP filter needs filter_order zeros at 0 and filter_order at infinity)
    while length(z_bp) < length(p_bp)
        z_bp = [z_bp; 0]; 
    end

    % 4. Bilinear Transform to Z-Domain
    z_digital = (2/t_step + z_bp) ./ (2/t_step - z_bp);
    p_digital = (2/t_step + p_bp) ./ (2/t_step - p_bp);
    
    % 5. Form SOS Matrix
    % Pair poles with nearest zeros to optimize dynamic range
    sos_matrix = [];
    used_zeros = false(size(z_digital));
    
    for i = 1:2:length(p_digital)
        p_pair = [p_digital(i); p_digital(i+1)];
        
        % Find closest available zeros for this pole pair
        z_pair = [];
        for j = 1:2
            dist = abs(z_digital - p_pair(j));
            dist(used_zeros) = Inf;
            [~, idx] = min(dist);
            z_pair = [z_pair; z_digital(idx)];
            used_zeros(idx) = true;
        end
        
        % Coeffs: (1 - z1*z^-1)(1 - z2*z^-1) -> [1, -(z1+z2), z1*z2]
        poly_b = real([1, -(z_pair(1) + z_pair(2)), z_pair(1) * z_pair(2)]);
        poly_a = real([1, -(p_pair(1) + p_pair(2)), p_pair(1) * p_pair(2)]);
        
        % Normalize each section to unit gain at center frequency
        z_center = exp(1i * 2 * pi * center_freq / sample_rate);
        h_center = (poly_b(1)*z_center^2 + poly_b(2)*z_center + poly_b(3)) / ...
                   (poly_a(1)*z_center^2 + poly_a(2)*z_center + poly_a(3));
        
        poly_b = poly_b / abs(h_center);
        sos_matrix = [sos_matrix; poly_b, poly_a];
    end

end