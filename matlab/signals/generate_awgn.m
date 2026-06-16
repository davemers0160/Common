function iq_signal = generate_awgn(sample_rate, duration, bandwidth)
    % GENERATE_AWGN_IQ Generates a bandwidth-limited AWGN IQ signal.
    %
    % Inputs:
    %   sample_rate - Sampling frequency in Hz
    %   duration    - Signal duration in seconds
    %   bandwidth   - Desired double-sided bandwidth of the noise in Hz
    %
    % Output:
    %   iq_signal   - Complex column vector normalized within +/- 1.0
    
    % 1. Validation
    if bandwidth > sample_rate
        error('Bandwidth cannot exceed the sample rate.');
    end
    
    % Calculate total number of samples
    num_samples = round(sample_rate * duration);
    
    % 2. Generate Raw Complex White Gaussian Noise
    % (In-phase and Quadrature components are independent)
    raw_noise = (randn(num_samples, 1) + 1i * randn(num_samples, 1)) / sqrt(2);
    
    % 3. Filter the noise to the target bandwidth
    if bandwidth < sample_rate
        % Design a lowpass FIR filter (cutoff is half of the double-sided bandwidth)
        cutoff_freq = (bandwidth / 2) / (sample_rate / 2); 
        
        % Using a 100th-order FIR filter for a sharp, clean cutoff
        filter_order = 100;
        b = fir1(filter_order, cutoff_freq);
        
        % Filter the complex signal
        filtered_noise = filter(b, 1, raw_noise);
    else
        % If bandwidth equals sample rate, no filtering is needed
        filtered_noise = raw_noise;
    end
    
    % 4. Normalize to the strict peak range of +/- 1.0
    % We normalize by the absolute maximum peak of both real and imag components
    max_peak = max(max(abs(real(filtered_noise))), max(abs(imag(filtered_noise))));
    
    if max_peak > 0
        iq_signal = filtered_noise / max_peak;
    else
        iq_signal = filtered_noise;
    end
end
