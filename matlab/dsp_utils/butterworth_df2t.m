function [sos, g] = butterworth_df2t(fc, order, gain_scale)
% BUTTERWORTH_DF2T_NORMALIZED designs a normalized Butterworth IIR filter
% using Direct Form II Transposed structure (no built-in filter design functions).
%
% [sos, g] = butterworth_df2t_normalized(Wc, N)
%
% Inputs:
%   Wc - Normalized cutoff frequency (0 < Wc < 1), where 1 = Nyquist
%   N  - Filter order (integer)
%
% Outputs:
%   sos - Second-order section coefficients [b0 b1 b2 a0 a1 a2]
%   g   - Gain for each section
%
% Example:
%   [sos, g] = butterworth_df2t_normalized(0.2, 4);

    % --- Input validation ---
    if fc <= 0 || fc >= 1
        error('Normalized cutoff frequency Wc must be between 0 and 1.');
    end
    if order < 1 || mod(order,1) ~= 0
        error('Filter order N must be a positive integer.');
    end

    % --- Prewarp frequency for bilinear transform ---
    omega_c = tan(2*pi*fc);
 
    num_sections = floor((order) / 2);

    % filter gain correction factor
    if order < 4
        gain_scale = 0.9204;
    elseif order > 40
        gain_scale = 0.978797;
    else
        gain_scale = -0.0000000715*order*order*order*order + 0.00000933*order*order*order - 0.0004626*order*order + 0.010875*order + 0.8693;
    end
        
    % --- Group poles into second-order sections ---
    sos = [];
    g = 1;
    
    for idx=0:num_sections-1
        
        % Analog Butterworth poles
        theta = pi * (2*idx + 1 + order) / (2*order);     
        pole_s = complex(omega_c*cos(theta), omega_c*sin(theta));
        
        % Compute digital poles - Bilinear transform: s -> (1 - z^-1)/(1 + z^-1)
        pole_z = (2.0 + pole_s) / (2.0 - pole_s);
        
%         a = [1 -2*real(pole_z) real(pole_z)*real(pole_z)+imag(pole_z)*imag(pole_z)];
        a = [1 -2*real(pole_z) (pole_z)*conj(pole_z)];
%         a = [1 -2*real(pole_z) abs(-pole_z*-pole_z)];
        b = [1 2 1];
        
        gain_stage = abs((sum(a)/sum(b)))*gain_scale;  % normalize DC gain

        sos = [sos; [b*gain_stage a]];
        
%         g = [g; gain_stage];      
        g = g * gain_stage;
    end
    
    if(mod(order,2) == 1)
        theta = pi * (2*num_sections + 1 + order) / (2*order);      
        pole_s = complex(omega_c*cos(theta), omega_c*sin(theta));
        
        pole_z = (2.0 + pole_s) / (2.0 - pole_s);
        
        a = [1, -real(pole_z), 0];
        b = [1 1 0];
        gain_stage = abs((sum(a)/sum(b)))*gain_scale;

        sos = [sos; [b*gain_stage a]];
        
%         g = [g; gain_stage];
        g = g * gain_stage;

    end
    
%     sos(1,1:3) = sos(1,1:3)*(g);
%     sos(:,1:3) = sos(:,1:3).*g;

end
