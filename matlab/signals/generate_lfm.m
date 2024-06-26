function [iq] = generate_lfm(sample_rate, f_start, f_stop, signal_length)

    % calculate the number of samples in the RF signal
    num_samples = floor(sample_rate * signal_length);
    
    % time step
    t = (1.0 / sample_rate) * (0:num_samples-1);
      
    %v = 1i * 2.0 * M_PI * (f_start * idx * t + (f_stop - f_start) * 0.5 * idx * idx * t * t / signal_length)
    
    iq = exp(1j * 2.0 * pi() * (f_start * t + (f_stop - f_start) * 0.5 * (t .* t) / signal_length));
    
end
    