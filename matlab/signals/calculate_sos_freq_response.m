function H = calculate_sos_freq_response(sos_matrix, num_freq_points)
    % Manually calculate the frequency response of a SOS filter cascade.
    % sos_matrix: Px6 matrix, where each row is [b0k b1k b2k a0k a1k a2k]

    num_sections = size(sos_matrix, 1);
    %num_freq_points = length(w);
    
    w = linspace(-pi, pi, num_freq_points);
    
    H = ones(1, num_freq_points);
    
    % Initialize the total frequency response to the overall system gain
    % If G is a vector, we multiply the gain of each section
    %if isscalar(G)
    %    H = G * ones(1, num_freq_points);
    %else
    %    % If G is provided as a vector of gains per section, 
    %    % the total gain is the product of all G values.
    %    H = prod(G) * ones(1, num_freq_points);
    %end

    % Loop through each section and multiply their frequency responses
    for k = 1:num_sections
        b = sos_matrix(k, 1:3);
        a = sos_matrix(k, 4:6);
        
        % Ensure a0k is 1, as per standard SOS representation (division by a0k)
        if a(1) ~= 1.0
            b = b / a(1);
            a = a / a(1);
        end

        % Calculate frequency response for this section
        % H_k(e^j_omega) = (b0 + b1*e^-j_omega + b2*e^-j2_omega) / ...
        %                  (a0 + a1*e^-j_omega + a2*e^-j2_omega)
        
        % Pre-compute the complex exponential z^-1 = e^-j_omega
        z_inv = exp(-1j * w);
        z_inv_sq = z_inv .* z_inv; % e^-j2_omega

        % Numerator and denominator polynomial evaluation without polyval
        numerator = b(1) + b(2) * z_inv + b(3) * z_inv_sq;
        denominator = a(1) + a(2) * z_inv + a(3) * z_inv_sq;
        
        H_k = numerator ./ denominator;
        
        % Multiply with the total response
        H = H .* H_k;
    end
    
    H = 20 * log10(abs(H));  % magnitude_dB
end