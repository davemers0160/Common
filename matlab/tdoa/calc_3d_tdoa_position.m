function [Po, iter, err] = calc_3d_tdoa_position(S, Po, v)
% Inputs: S - Array of positions (x,y,z,t)
%         Po - Intial guess position (x,y,z)
%         v - speed of the signal
%
% Returns: P - position (x,y,z)

% error limit
de = 1e-3;

% iteration limit
max_iter = 50;

% get the number of measurements
N = size(S, 1);
num_dim = size(Po, 2);

% sort the S array in terms of the shortest to longest times
[~, index] = sort(S(:,end));
S = S(index, :);

iter = 0;
err = 1000;

while((iter < max_iter) && (err > de))

    % calcilate the R's
    R = zeros(N,1);
    for idx=1:N
        %R(idx) = sqrt((S(idx,1) - Po(1))^2 + (S(idx,2) - Po(2))^2 + (S(idx,3) - Po(3))^2);
        R(idx) = sqrt(sum((S(idx, 1:end-1) - Po).*(S(idx, 1:end-1) - Po)));
    end

    % build A and b
    A = zeros(N-1, num_dim);
    b = zeros(N-1, 1);
    for idx = 2:N
        A(idx-1, :) = (S(idx, 1:end-1) - Po)/R(idx) - (S(1,1:end-1) - Po)/R(1);
        b(idx-1) = v*(S(idx, end)-S(1, end)) - (R(idx) - R(1));
    end

    % invert A -> (AtA)^-1 At
    A_li = (pinv(A.' * A)*A.');

    % find the new delta P
    dP = A_li * b;

    % generate new Po
    Po = Po - dP.';

    % get the error
    err = sqrt(dP.' * dP);
    
    iter = iter + 1;

end

end

