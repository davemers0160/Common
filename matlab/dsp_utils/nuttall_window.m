function w = nuttall_window(N)

    w = zeros(1, N);
    a0 = 0.355768;
    a1 = 0.487396;
    a2 = 0.144232;
    a3 = 0.012604;

    for idx = 0:N-1
    
        w(idx+1) = a0 - a1 * cos(2.0 * pi() * idx/N) + a2 * cos(4.0 * pi() * idx/N) - a3 * cos(6.0 * pi() * idx/N);
    end
    

end