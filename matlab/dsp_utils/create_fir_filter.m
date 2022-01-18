function g = create_fir_filter(N, fc, w)

    g = zeros(1, N);

    for idx = 0:N-1
        
        x = pi() * fc * (idx - N / 2.0);
    
        if (abs(idx - (N / 2.0)) < 1e-6)
            g(idx+1) = w(idx+1) * fc;
        else
            g(idx+1) = w(idx+1) * (sin(x) /x);
        end
    end
    
end