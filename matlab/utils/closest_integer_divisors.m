function [a,b] = closest_integer_divisors(n)

    sqrt_n = floor(sqrt(n));
    a = 1;
    b = n;

    for idx = 2:sqrt_n
        if (mod(n, idx) == 0) 
            if (abs(idx - n / idx) < abs(a - b)) 
                a = idx;
                b = n / idx;
            end
        end
    end

end