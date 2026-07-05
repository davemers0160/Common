function w = flat_top_window(N)

    w = zeros(1, N);
    a0 = 0.21557895;
    a1 = 0.41663158;
    a2 = 0.277263158;
    a3 = 0.083578947;
    a4 = 0.006947368;

    for idx = 0:N-1
        w(idx+1) = a0 - a1 * cos(2.0 * pi() * idx/(N-1)) + a2 * cos(4.0 * pi() * idx/(N-1)) - a3 * cos(6.0 * pi() * idx/(N-1)) + a4 * cos(8.0 * pi() * idx/(N-1));
    end
    
end