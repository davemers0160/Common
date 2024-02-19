function w = blackman_nuttall_window(N)

    w = zeros(1, N);
    a0 = 0.3635819;
    a1 = 0.4891775;
    a2 = 0.1365995;
    a3 = 0.0106411;

    for idx = 0:N-1
        w(idx+1) = a0 - a1 * cos(2.0 * pi() * idx/(N-1)) + a2 * cos(4.0 * pi() * idx/(N-1)) - a3 * cos(6.0 * pi() * idx/(N-1));
    end
    

end