function [iq] = generate_bpsk(data, amplitude, sample_rate, bit_length)

    num_bits = numel(data);
    samples_per_bit = floor(sample_rate*bit_length);
    
    
end