function [Pn, iter, err] = calc_tdoa_position(S, T, Po, v)
%   [Pn, iter, err] = calc_tdoa_position(S, T, Po, v)
%
%   Inputs: 
%   S - Matrix of listening station locations.  Each row contains the 
%       coordinates of the station.  The dimensions of S should be N x D, 
%       where N is the number of stations and D is the number of dimensions
%       (x,y,...).
%
%   T - Matrix of arrival times of the signal for each station.  Each row 
%       contains a single arrival time.  The dimensions of T should be N x
%       1, where N is the number of stations.
%
%   Po - The intial guess of the target location. The dimensions of Po 
%       should be 1 x D, where D is the number of dimensions (x,y,...).
%
%   v - The speed of the signal in the same units of S and T.
%
%   Returns: 
%   Pn - The calculated position.  The dimensions of Po should be 1 x D,
%       where D is the number of dimensions (x,y,...).
%       
%   iter - The number of iterations that were performed to calculate the
%       position solution.
%
%   err - The final change in position updates between iterations.
%       
%   This code is based on the geometry of a D dimension space, but has only
%   been tested to 3 dimensions.  The code uses the recursive least squares
%   method to iteratively solve for the location of the emitter.  
%
%   The initial guess is critical and bad initial guess can cause the
%   matrix to be singular which means that matrix will not have an inverse.
%   This will cause the solution to diverge instead.  This can be checked
%   by the return number of iterations and the final change in update
%   (err).
%

    % error limit
    de = 1e-3;
    err = 1000;

    % iteration limit
    max_iter = 50;
    iter = 0;

    % get the number of measurements
    [N, D] = size(S);

    % sort the S array in terms of the shortest to longest times
    [~, index] = sort(T);
    S = S(index, :);
    T = T(index);

    Pn = Po;

    while((iter < max_iter) && (err > de))

        % calcilate the R's
        R = zeros(N,1);
        for idx=1:N
            R(idx) = sqrt(sum((S(idx, :) - Pn).*(S(idx, :) - Pn)));
        end

        % build A and b
        A = zeros(N-1, D);
        b = zeros(N-1, 1);
        for idx = 2:N
            A(idx-1, :) = (S(idx, :) - Pn)/R(idx) - (S(1,:) - Pn)/R(1);
            b(idx-1) = v*(T(idx)-T(1)) - (R(idx) - R(1));
        end

        % invert A -> (AtA)^-1 At
        A_li = (pinv(A.' * A)*A.');

        % find the new delta P
        dP = A_li * b;

        % generate new Po
        Pn = Pn - dP.';

        % get the error
        err = sqrt(dP.' * dP);

        iter = iter + 1;

    end

end

