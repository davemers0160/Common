function iq_vector = generate_cpfsk(symbol_rate, sample_rate, data, amplitude)
    % generate_cpfsk: Generates a complex baseband CPFSK (MSK) signal
    % Inputs:
    %   symbol_rate - Symbol rate in Hz (e.g., 16000)
    %   sample_rate - Sample rate in Hz (must be >= 2 * symbol_rate for Nyquist, preferably higher)
    %   data        - Vector of binary data (1s and 0s)
    %   amplitude   - Peak amplitude of the output signal
    % Output:
    %   iq_vector   - Complex baseband IQ sequence (I + jQ)

    % 1. Set Modulation Index
    % h = 0.5 is the specific modulation index for Minimum Shift Keying (MSK)
    h = 0.5; 

    % 2. Convert binary (0, 1) to bipolar NRZ (-1, +1)
    % Ensure data is a row vector
    data = data(:)'; 
    nrz_data = 2 * data - 1;

    % 3. Calculate Samples Per Symbol
    sps = round(sample_rate / symbol_rate);

    % 4. Upsample the data (Sample and Hold)
    % Repeat each NRZ bit 'sps' times to match the sample rate
    num_symbols = length(nrz_data);
    upsampled_data = zeros(1, num_symbols * sps);
    
    for k = 1:num_symbols
        start_idx = (k - 1) * sps + 1;
        end_idx = k * sps;
        upsampled_data(start_idx:end_idx) = nrz_data(k);
    end

    % 5. Calculate Phase Increments
    % Peak frequency deviation from the center (delta_f) = (h * symbol_rate) / 2
    delta_f = (h * symbol_rate) / 2;
    
    % Time per sample
    dt = 1 / sample_rate;
    
    % Instantaneous phase step per sample: d(theta) = 2 * pi * delta_f * data * dt
    phase_step = 2 * pi * delta_f * upsampled_data * dt;

    % 6. Integrate Phase over Time
    % This cumsum (cumulative sum) is the secret to Continuous Phase!
    % It adds the new phase step to the previous total, ensuring no abrupt jumps.
    continuous_phase = cumsum(phase_step);

    % 7. Generate Complex Baseband Signal (I and Q)
    i_component = amplitude * cos(continuous_phase);
    q_component = amplitude * sin(continuous_phase);

    % Combine into a complex vector
    iq_vector = i_component + 1j * q_component;
end
