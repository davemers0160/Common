function [audio_out, audio_fs_actual] = fm_demod(iq_data, rf_fs, rf_ch_bw, rf_fc, rf_taps, f_offset, audio_fs, audio_fc, audio_taps)
% INPUTS:
%   iq_data - complex IQ data in a single column
%
%   rf_fs - The sample rate of the data in Hz
%
%   rf_ch_bw - The bandwidth of the RF channel to demodulate in Hz
% 
%   rf_fc - The RF low pass filter cutoff frequency in Hz
% 
%   rf_taps - The number of taps in the FIR filter (hint: more taps = 
%   sharper filter but will take longer to process)
% 
%   f_offset - The offset frequeny of the signal of interest in Hz
%
%   audio_fs - The desired audio sample rate in Hz
%
%   audio_fc - The audio low pass filter cutoff frequency in Hz
% 
%   audio_taps - The number of taps in the FIR filter (hint: more taps = 
%   sharper filter but will take longer to process)
% 
% OUPTUTS:
%   audio_out - The demodulated audio data
%
% Recommendations: start with the desired audio sample rate and the RF sample 
% rate to calculate the rf_ch_bw so that the decimation occurs in even
% decimation numbers.
% 

    % make the data into a column
    iq_data = iq_data(:);
    
    % number of IQ samples
	num_samples = numel(iq_data);
    
    % decimation rate
    rf_decimation_rate = floor(rf_fs / rf_ch_bw);

    % generate the low pass filter for RF processing using the Hamming window
    % need to generate a conversion from the sampling rate to +/- pi
    % as an added bonus matlab goes from 0 - 1, where 1 is sampling rate / 2
%     rf_freq_cutoff = rf_fc/rf_fs;
    rf_lpf = fir1(rf_taps, rf_fc/rf_fs, 'low');
    
    % calculate the new sampling rate based on the original and the decimated sample rate
    rf_fs_decimated = rf_fs/rf_decimation_rate;
    %rf_fs_actual = rf_fs/rf_fs_decimated;
    
    % scaling for tangent
    phasor_scale = 1/((2 * pi()) / (rf_fs_decimated / rf_ch_bw));

    % calculate the audio decimate rate and the new sample rate
    audio_decimation_rate = floor(rf_fs_decimated/audio_fs);  
    audio_fs_actual = rf_fs_decimated / audio_decimation_rate;
    
    % generate the low pass filter for audio processing using the Hamming window
%     audio_freq_cutoff = audio_fc/rf_fs_decimated;
    audio_lpf = fir1(audio_taps, audio_fc/audio_fs_actual, 'low');
    
    % calculate the frequency rotation based on the supplied offset value
    freq_rotation = exp(-1.0j*2.0*pi()* f_offset/rf_fs*(0:(num_samples-1)));
    
    % perform the frequency rotation to put the desired frequency at 0Hz
    x2 = iq_data .* freq_rotation(:);

    % filter the frequency shifted signal for downsampling
    x3 = filter(rf_lpf, 1, x2);

    % decimate the shifted and downsampled signal
    x4 = x3(1:rf_decimation_rate:end);
    
    % https://www.veron.nl/wp-content/uploads/2014/01/FmDemodulator.pdf
    % here's the FM demod part
    x4a = x4(2:end) .* conj(x4(1:end-1));
    x5 = angle(x4a) * phasor_scale;
    
    % filter the audio
    x6 = filter(audio_lpf, 1, x5);
    
    % decimate the audio
    audio_out = x6(1:audio_decimation_rate:end);
     
end
