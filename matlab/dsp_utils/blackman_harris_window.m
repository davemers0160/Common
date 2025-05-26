function w = blackman_harris_window(N)

    w = zeros(1, N);
    a0 = 0.35875;
    a1 = 0.48829;
    a2 = 0.14128;
    a3 = 0.01168;

    for idx = 0:N-1
        w(idx+1) = a0 - a1 * cos(2.0 * pi() * idx/(N-1)) + a2 * cos(4.0 * pi() * idx/(N-1)) - a3 * cos(6.0 * pi() * idx/(N-1));
    end
    
end
