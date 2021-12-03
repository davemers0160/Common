function [err] = calc_tdoa_error(P, function_params)

    % P: estimated postion x, y, z, ...
    % function_params.T: the measured arrival time - row vector of arrival times for each station
    % function_params.S: the station position - each row represents x, y, z, ... locations for each stations
    % function_params.v: velocity of the signal
    % num stations == num measured_time
    
    % get the dimensions of the data
    N = size(function_params.S, 1);

    if(size(function_params.T,1) ~= N)
       fprintf("measured_time ~= stations: %d, %d", size(function_params.T,1), N);
    end

    % calculate the arrival times
    for idx=1:N
        T_est(idx, 1) = sqrt(sum((function_params.S(idx, :) - P).*(function_params.S(idx, :) - P)))/function_params.v;
    end
        
    err = sqrt(sum((function_params.T - T_est).*(function_params.T - T_est)));

end