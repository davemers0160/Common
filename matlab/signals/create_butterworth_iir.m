function [b, a] = create_butterworth_iir(fc, order)
%  create_butterworth_iir Calculate IIR Butterworth filter coefficients
%
% Inputs:
%   fc - Normalized cutoff frequency (0 to 0.5)
%                      where 0.5 = Nyquist frequency
%   order           - Filter order (number of poles)
%
% Outputs:
%   b - Numerator coefficients (feedforward)
%   a - Denominator coefficients (feedback), a(1) = 1
    
    % Prewarp the cutoff frequency for bilinear transform
    omega = 2 * pi * fc;
    omegaPrewarped = 2 * tan(omega / 2);
    
    % Calculate analog Butterworth poles in s-plane
    % Poles are equally spaced on unit circle in left half-plane
    poles = zeros(order, 1);
    for k = 0:order-1
        theta = pi * (2*k + order + 1) / (2*order);
        poles(k+1) = omegaPrewarped * (cos(theta) + 1i*sin(theta));
    end
    
    % Apply bilinear transform: s -> 2(z-1)/(z+1)
    % Digital pole: p_d = (2 + p_a) / (2 - p_a)
    digitalPoles = (2 + poles) ./ (2 - poles);
    
    % Calculate denominator coefficients from poles
    % Expand polynomial: (z - p1)(z - p2)...(z - pN)
    a = zeros(1, order + 1);
    a(1) = 1;
    
    for k = 1:order
        pole = digitalPoles(k);
        % Multiply existing polynomial by (z - pole)
        for i = k+1:-1:2
            a(i) = a(i) - pole * a(i-1);
        end
    end
    
    % Take real part (imaginary parts should cancel for conjugate pairs)
    a = real(a);
    
    % For Butterworth lowpass: all zeros at z = -1
    % This gives numerator: (z+1)^order = (1+z^-1)^order
    % Calculate binomial coefficients
    b = zeros(1, order + 1);
    b(1) = 1;
    for k = 1:order
        b(k+1) = b(k) * (order - k + 1) / k;
    end
    
    % Normalize for unity gain at DC (z = 1)
    % DC gain = sum(b) / sum(a)
    aSum = sum(a);
    bSum = sum(b);
    gain = aSum / bSum;
    
    b = b * gain;
end
