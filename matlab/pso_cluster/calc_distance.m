function [d, m_idx] = calc_distance(z, x)
% inputs:
% x: this is the particle (NxD) that contains N rows, where N is the
% maximum number of potential clusters
% z: this is the data to be clustered (1xD)
%
% d: the distance between z and x_i

N = size(x,1);
d = zeros(N,1);

for idx=1:N
    d(idx,1) = sum((x(idx,:) - z).^2);
    d(idx,1) = sqrt(d(idx,1));
end

[~,m_idx] = min(d);

