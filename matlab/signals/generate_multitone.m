function iq_data = generate_multitone(sample_rate, duration, amplitude, freq_start, freq_stop, tone_spacing)

    % calculate the number of samples needed
    num_samples = round(sample_rate * duration);

    % generate the tone frequencies
    tones = freq_start:tone_spacing:freq_stop;
    num_tones = length(tones);

    % time step
    t = (0:(num_samples-1))/sample_rate;

    iq_data = zeros(1,num_samples);

    for idx=1:num_tones
        iq_data = iq_data + (amplitude/num_tones) * exp(1i*2.0*pi()* tones(idx) * t);
    end 

end
