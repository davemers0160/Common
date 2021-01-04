function [iq, iq_c] = generate_iq(fs, t, type, params)

    % get the number of samples to generate
    N = fs*t;
    
    iq = 0;
    iq_c = complex(0,0);

    switch type

        case 'rand'
            iq = int16(randi([params(1), params(2)], 2*(N), 1));
            iq_c = complex(iq(1:2:end), iq(2:2:end));
            
        case 'linear'
            % params(1): min_iq value
            % params(2): max_iq value
            % params(3): starting frequency
            % params(4): stopping frequency
            span = 0:1/fs:t-1/fs;
            
            iq_c = exp(1i*2*pi*(params(3)*span + params(4)*span.*span/t));            
            iq_c = int16(iq_c*params(2));
            
            iq = [real(iq_c); imag(iq_c)];
            iq = iq(:);

%         case 'quadratic'
%             span = 0:1/fs:t-1/fs;
%             iq = chirp(span, params(3), params(4), params(5),'quadratic');
%             iq_c = complex(iq(1:1:end), zeros(size(iq)));
%             
%         case 'logarithmic'
%             span = 0:1/fs:t-1/fs;
%             iq = chirp(span, params(3), params(4), params(5),'logarithmic');
%             iq_c = complex(iq(1:1:end), zeros(size(iq)));
 
    end
    

end
