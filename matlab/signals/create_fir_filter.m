function [g] = create_fir_filter(fc, w)

    n_taps = numel(w);

    g = zeros(1, n_taps);

    for idx = 0:n_taps-1

        % t = pi * fc * (idx - ((n_taps-1) / 2.0))
        t = (idx - ((n_taps-1) / 2.0))

        if (abs(t) < 1e-6)
            % g(idx+1) = w(idx+1);
            g(idx+1) = w(idx+1) * fc;
        else
            % g(idx+1) = w(idx+1) * (sin(t) / (t));
            g(idx+1) = w(idx+1) * (sin(pi * fc * t) / (pi * t));
        end
    end

    % g_sum = sum(g);
    % 
    % g = g / g_sum;

end
