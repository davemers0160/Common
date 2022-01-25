function [y, phase_offset, frequency_offset, phi_hat] = test_fm_pll_2(x, phase_offset, frequency_offset, phi_hat)
% https:%liquidsdr.org/blog/pll-howto/
    % phase_offset;   % input signal's initial phase
    
    % parameters
    %phase_offset      = 0.00;    % carrier phase offset
    %frequency_offset  = 0.30;    % carrier frequency offset
    wn                = 0.01;    % pll bandwidth
    zeta              = 0.707;   % pll damping factor
    K                 = 1000;    % pll loop gain
    
    n          = numel(x);      % number of samples

    % generate loop filter parameters (active PI design)
    t1 = K/(wn*wn);   % tau_1
    t2 = 2*zeta/wn;   % tau_2

    % feed-forward coefficients (numerator)
    b0 = (4*K/t1)*(1.+t2/2.0);
    b1 = (8*K/t1);
    b2 = (4*K/t1)*(1.-t2/2.0);

    % feed-back coefficients (denominator)
    %    a0 =  1.0  is implied
%     a1 = -2.0;
%     a2 =  1.0;
    a = [1, -2, 1];

    % filter buffer
    %v0=0.0f, v1=0.0f, v2=0.0f;
    v = [0.0, 0.0, 0.0];

    % initialize states
    %phi_hat = 0.0;           % PLL's initial phase

    % run basic simulation
    %float complex y;   -   output
    
    for i=1:n
        % compute input sinusoid and update phase
        %x = cos(phase_offset) + 1j*sin(phase_offset);
        phase_offset = phase_offset + frequency_offset;

        % compute PLL output from phase estimate
        y(i) = cos(phi_hat) + 1j*sin(phi_hat);

        % compute error estimate
        delta_phi = angle( x(i) * conj(y(i)) );

        % push result through loop filter, updating phase estimate

        % advance buffer
        v(3) = v(2);  % shift center register to upper register
        v(2) = v(1);  % shift lower register to center register

        % compute new lower register
        v(1) = delta_phi*a(1) - v(2)*a(2) - v(3)*a(3);

        % compute new output
        phi_hat = v(1)*b0 + v(2)*b1 + v(3)*b2;
    end


end