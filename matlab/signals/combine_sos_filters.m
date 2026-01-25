function combined_sos = combine_sos_filters(sos_cell_array)
    % Initialize the combined matrix
    combined_sos = [];
    
    % 1. Concatenate all SOS matrices into one long chain
    num_filters = length(sos_cell_array);
    for i = 1:num_filters
        current_sos = sos_cell_array{i};
        combined_sos = [combined_sos; current_sos];
    end
    
    % 2. Calculate the total DC gain of the entire cascade
    % The gain of a cascade is the product of the gains of each section.
    % DC gain is found by setting z = 1 (sum of b / sum of a)
    total_gain = 1.0;
    num_sections = size(combined_sos, 1);
    
    for j = 1:num_sections
        b = combined_sos(j, 1:3);
        a = combined_sos(j, 4:6);
        
        section_gain = sum(b) / sum(a);
        
        % Avoid division by zero for high-pass filters where sum(b) might be 0
        % In notch/low-pass, this is the standard normalization point.
        if abs(section_gain) > 1e-12
            total_gain = total_gain * section_gain;
        end
    end
    
    % 3. Normalize the filter to 0dB (Gain = 1)
    % We apply the correction to the first section's b-coefficients 
    % to maintain the 0dB identity across the whole chain.
    if abs(total_gain) > 1e-12
        combined_sos(1, 1:3) = combined_sos(1, 1:3) / total_gain;
    end
end