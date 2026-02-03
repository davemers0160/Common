function [h] = calculate_sos_impulse_response(sos_filter)

    % create the impulse response
    x = zeros(1,201);
    x(21) = 1;

    % filter and get response
    h = sosfilt(sos_filter, x);

end
