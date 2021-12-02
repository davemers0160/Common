function [err] = calc_tdoa_error(P, T, S, v)

    % P: estimated postion x, y, z, ...
    % T: the measured arrival time - row vector of arrival times for each station
    % S: the station position - each row represents x, y, z, ... locations for each stations
    % v: velocity of the signal
    % num stations == num measured_time
    
    % get the dimensions of the data
    N = size(S, 1);

    if(size(T,1) ~= N)
       fprintf("measured_time ~= stations: %d, %d", size(T,1), N);
    end

    % calculate the arrival times
    for idx=1:N
        T_est(idx, 1) = sqrt(sum((S(idx, :) - P).*(S(idx, :) - P)))/v;
    end
    
    err = sqrt(sum((T - T_est).*(T - T_est)));

end