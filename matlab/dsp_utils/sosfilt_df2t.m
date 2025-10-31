function y = sosfilt_df2t(sos, x)
%SOSFILT_DF2T Filters a complex sequence using a Direct Form II Transposed
%   Second-Order Sections (SOS) IIR filter.
%
%   y = sosfilt_df2t(sos, x) filters the complex input sequence x
%   using the filter defined by the SOS matrix sos.
%
%   Inputs:
%     sos: A Nx6 matrix where N is the number of second-order sections.
%          Each row of sos contains the coefficients [b0 b1 b2 a0 a1 a2]
%          for a single second-order section. a0 is typically 1.
%     x:   A complex vector representing the input data sequence.
%
%   Outputs:
%     y:   A complex vector representing the filtered output sequence.
%
%
% x[n]-->(+)-----------+--->[b0]--->(+)--> y[n]
%         ^            |             ^		
%         |            |             |
%         |          [z^-1]          |
%         |            |             |
%         |            |             |
%        (+)<--[-a1]<--+--->[b1]--->(+)
%         ^          w[n-1]          ^
%         |            |             |
%         |          [z^-1]          |
%         |            |             |
%         |            |             |
%        (+)<--[-a2]<--+--->[b2]--->(+)
%                    w[n-2]
%

    % Get the number of second-order sections
    num_sections = size(sos, 1);
    
    % Initialize the output sequence
    y = zeros(size(x), 'like', x);
    
    % Initialize the state variables for each section
    % Each section needs two state variables for the direct form II transposed structure.
    w = zeros(num_sections, 2); 
    
    % Iterate through each sample of the input sequence
    for idx = 1:length(x)
        current_input = x(idx);
    
        % Process through each second-order section
        for k = 1:num_sections
            % Direct Form II Transposed equations for a single section
            % w(k,1) and w(k,2) are the state variables for the k-th section.
            output_section = sos(k, 1) * current_input + w(k,1);
    
            % update state variables: Note: a0 (sos(k, 4)) is assumed to be 1 and not used in calculations
            w(k,1) = sos(k, 2) * current_input - sos(k, 5) * output_section + w(k,2);
            w(k,2) = sos(k, 3) * current_input - sos(k, 6) * output_section;
    
            % Output of current section becomes input for next
            current_input = output_section; 
        end

        % Final output after all sections
        y(idx) = current_input; 
    end

end
