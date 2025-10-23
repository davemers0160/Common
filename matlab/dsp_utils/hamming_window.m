function [w] = hamming_window(N)

    w = zeros(1, N);
    a0 = 25/49;
    a1 = 1 - a0;
    
    for idx=0:N-1
       w(idx+1) = a0 - a1*cos(2*pi*idx/(N-1));
    end

end
