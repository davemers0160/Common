function [aou, ecc, r_ellipse] = calc_aou(Pn)
    %% get the covariance matrix, just do 2D for now
    Pn = Pn(:,1:2).';

    num_trials = size(Pn, 2);
    
    % get the center/means in each direction
    C = mean(Pn, 2);

    % calculate the covariance matrix
    Rp = (1/num_trials)*((Pn-C)*(Pn-C).');

    % find the eigenvalues (V) and the eigenvectors (E)
    [Ep, Vp] = eig(Rp, 'vector');

    % get the confidence interval 
    p = 0.95;
    s = -2 * log(1 - p);
    Vp = Vp*s;

    % get the max eigen value
    [max_eig_val, max_eig_ind] = max(Vp);
    [min_eig_val, min_eig_ind] = min(Vp);

    max_eig_vec = Ep(:, max_eig_ind);
    min_eig_vec = Ep(:, min_eig_ind);

    % calculate the angle between the x-axis and the largest eigenvector
    angle = atan2(max_eig_vec(2), max_eig_vec(1));

    % This angle is between -pi and pi.
    % Let's shift it such that the angle is between 0 and 2pi
    if(angle < 0)
        angle = angle + 2*pi;
    end

    % set the ellipse plotting segments
    theta = linspace(0, 2*pi, 100);

    % calculate the ellipse
    r_ellipse = (Ep * (sqrt(diag(Vp)))) * [cos(theta(:))'; sin(theta(:))'];

    % [V, D] = eig(Rp * s);
    % r_ellipse = (V * sqrt(D)) * [cos(theta(:))'; sin(theta(:))'];
    ecc = sqrt(1-(min(Vp)/max(Vp)));
    aou = prod(sqrt(Vp))*pi();
    
end