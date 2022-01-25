function [signal_out] = test_fm_pll_1(signal_in, phase_in, frequency_in, alpha)
% https://liquidsdr.org/blog/pll-simple-howto/
%     % parameters and simulation options
%     float        phase_in      =  3.0;    % carrier phase offset
%     float        frequency_in  = -0.20;    % carrier frequency offset
%     float        alpha         =  0.05;   % phase adjustment factor

    n             =  numel(signal_in);     % number of samples

    % initialize states
    beta          = 0.5*alpha*alpha; % frequency adjustment factor
    phase_out     = 0.0;            % output signal phase
    frequency_out = 0.0;            % output signal frequency

    % print line legend to standard output
%     fprintf("# %6s %12s %12s %12s %12s %12s\n", index, real(in), "imag(in)", "real(out)", "imag(out)", "error");

    % run basic simulation
    for i=1:n 
        
        % compute input and output signals
%         float complex signal_in  = cexpf(_Complex_I * phase_in);
%         float complex signal_out = cexpf(_Complex_I * phase_out);
        signal_out(i) = exp(1j * phase_out);

        % compute phase error estimate
        phase_error = angle( signal_in(i) * conj(signal_out(i)) );
        
        % apply loop filter and correct output phase and frequency
        phase_out     = phase_out + (alpha * phase_error);    % adjust phase
        frequency_out =  frequency_out + (beta * phase_error);    % adjust frequency

        % increment input and output phase values
        phase_in  = phase_in + frequency_in;
        phase_out = phase_out + frequency_out;
    end

end
