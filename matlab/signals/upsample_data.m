function [data] = upsample_data(data, N)
% upsample data by an integer factor N.  For fractional upsampling upsample
% by N and downsample by M to reach the correct fractional value

    filter_tap_mult = 20;
    
    num_data_samples = numel(data);
    y = zeros(num_data_samples * N,1);
    
    % insert samples with N-1 zeros
    for idx=0:num_data_samples-1
        y(idx*N + 1) = data(idx+1);
    end
    
    % create fir filter
    n_taps = filter_tap_mult*N;
    if(mod(n_taps, 2) == 0)
        n_taps = n_taps + 1;
    end
    
    fc = 1/N;
    
    w = nuttall_window(n_taps);
    lpf = create_fir_filter(fc, w);
    
    % normalize lpf
    lpf_sum  = sum(lpf);
    lpf = lpf/lpf_sum;
    
    % convolve with scaled version of the lpf based on the upsampling factor
    data = conv(y, N*lpf(end:-1:1).', 'same');


end