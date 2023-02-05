function [g] = create_fir_filter(fc, w)

    n_taps = numel(w);

    g = zeros(1, n_taps);

    for idx = 0:n_taps-1

        if (abs(idx - (n_taps / 2.0)) < 1e-6)
            g(idx+1) = w(idx+1) * fc;
        else
            g(idx+1) = w(idx+1) * (sin(pi * fc * (idx - (n_taps/2))) / (pi * (idx - (n_taps/2))));
        end
    end

end
