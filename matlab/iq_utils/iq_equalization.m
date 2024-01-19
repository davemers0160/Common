function [iq_eq] = iq_equalization(iq)

    w_len       = 13;      % equalizer length
    mu          = 0.05;    % equalizer learning rate
    alpha       = 0.60;    % channel filter bandwidth

    % create and initialize arrays
    % float complex w[w_len];             // equalizer coefficients
    w = complex(zeros(1,w_len),zeros(1,w_len));
    % float complex b[w_len];             // equalizer buffer
    b = complex(zeros(1,w_len),zeros(1,w_len));

    for idx=1:w_len 
        
        if(idx == floor(w_len/2))
            w(idx) = 1;
        end
    end

    x_prime = complex(0,0);
    buf_index=0;

    for idx=1:numel(iq)

        % 2. compute received signal and store in buffer
        y = sqrt(1-alpha)*iq(idx) + alpha*x_prime;
        x_prime = y;
        b(buf_index+1) = y;
        buf_index = mod((buf_index+1), w_len);

        % 3. compute equalizer output
        r = complex(0,0);
        for jdx=1:w_len
            %r += b[(buf_index+i)%w_len] * conjf(w[i]);
            r = r + b(mod((buf_index+jdx),w_len)+1) * conj(w(jdx));
        end

        % 4. compute 'expected' signal (blind), skip first w_len symbols
        % float complex e = n < w_len ? 0.0f : r - r/cabsf(r);
        if idx<w_len
            e = complex(0,0);
        else
            e = r - r/abs(r);
        end

        % 5. adjust equalization weights
        for jdx=1:w_len
            w(jdx) = w(jdx) - mu*conj(e)*b(mod((buf_index+jdx),w_len)+1);
        end

        iq_eq(idx,1) = y; 
    end

end