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
%   Output:
%     y:   A complex vector representing the filtered output sequence.

% Get the number of second-order sections
num_sections = size(sos, 1);

% Initialize the output sequence
y = zeros(size(x), 'like', x);

% Initialize the state variables for each section
% Each section needs two state variables for the direct form II transposed structure.
% These states are complex.
w = zeros(num_sections, 2); 

% Iterate through each sample of the input sequence
for idx = 1:length(x)
    current_input = x(idx);

    % Process through each second-order section
    for k = 1:num_sections
        b0 = sos(k, 1);
        b1 = sos(k, 2);
        b2 = sos(k, 3);
        a1 = sos(k, 5); % Note: a0 is assumed to be 1 and not used in calculations
        a2 = sos(k, 6);

        % Direct Form II Transposed equations for a single section
        % w(k,1) and w(k,2) are the state variables for the k-th section.
        output_section = b0 * current_input + w(k,1);

        % update state variables
        w(k,1) = b1 * current_input - a1 * output_section + w(k,2);
        w(k,2) = b2 * current_input - a2 * output_section;

        current_input = output_section; % Output of current section becomes input for next
    end
    y(idx) = current_input; % Final output after all sections
end

end