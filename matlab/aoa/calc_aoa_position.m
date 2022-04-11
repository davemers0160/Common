function [Pn, iter, err] = calc_aoa_position(S, A, Po)
%   [Pn, iter, err] = calc_tdoa_position(S, T, Po, v)
%
%   Inputs: 
%   S - Matrix of listening station locations.  Each row contains the 
%       coordinates of the station.  The dimensions of S should be N x D, 
%       where N is the number of stations and D is the number of dimensions
%       (x,y,...).
%
%   A - Matrix of arrival angles of the signal for each station.  Each row 
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
    prev_err = realmax('double');

    % iteration limit
    max_iter = 50;
    iter = 0;

    % get the number of measurements
    [N, D] = size(S);

%     % sort the S array in terms of the shortest to longest times
%     [~, index] = sort(T);
%     S = S(index, :);
%     T = T(index);

    % preserve the original Po just in case
    Pn = Po;

    while((iter < max_iter) && (err > de))

        % build h
        h = S(:,1).*tand(A) - S(:,2);

        % build A
        G = cat(2, tand(A), -1*ones(N,1));

        
        % invert A -> ((AtA)^-1)At
        %G_pinv = (pinv(G.' * G)*G.');

        % find the new delta P
        P_delta = h - G*Pn.';

        % get the update error -  should be the same as the L2 norm
        err = norm(P_delta);
        
        % generate new Pn
        Pn = Pn - P_delta.';
       
        % check to see if the difference between updates is growing if it
        % is then the initial guess may not be a good one for the
        % configuration.  Try reflecting about a point and then try again
        if(err > prev_err)
            % get the distances between the initial guess and the receivers
            for idx=1:N
                R(idx) = sqrt(sum((S(idx, :) - Po).*(S(idx, :) - Po)));
            end
            
            % find the min distance
            [~, min_idx] = min(R);
            
            % use the index to get the point to reflect about
            SR = S(min_idx,:);
                                   
            % try a reflection
            Pn = (SR - Po);
            
            % reset the previous update difference
            prev_err = realmax('double');               
        else
            % save the last update difference
            prev_err = err;        
        end
        
        iter = iter + 1;

    end

end

