format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% set up each of the points
%rng(now);

% v = 161874.9773218;
v = 299792458/1000;

% estimating +/- position error
range_err = 0.1;

% estimating +/- arrival time error
time_err = 1e-7;

% set the station locations (S) and the emitter location (P)
% 3D
% S(1,:) = [100, 150, 89, 0];
% S(2,:) = [345, 212, 334, 0];
% S(3,:) = [212, 343, 121, 0];
% S(4,:) = [260, 564, 33, 0];
% P = [200, 100, 0];
 
% 2D
% receiver station locations
S(1,:) = [-66, 5];
S(2,:) = [0, 0];
S(3,:) = [66, 5];

% times
T = [0; 0; 0];

% target location
P = [0, 180];

% guess/calculate an initial position
Po = [20, 20];

% get the dimensions of the data
[N, D] = size(S);

% calculate the arrival times
for idx=1:N
    T(idx) = sqrt(sum((S(idx, :) - P).*(S(idx, :) - P)))/v;
end

% set teh number of trials
num_trials = 100;

P_new = zeros(num_trials, D);
iter = zeros(num_trials, 1);
err = zeros(num_trials, 1);
Sn = zeros(N, D, num_trials);

for idx=1:num_trials
    Sn(:, :, idx) = S + range_err*randn(N, D);
    Tn = T + time_err*randn(N,1);

    [P_new(idx,:), iter(idx,:), err(idx,:)]= calc_tdoa_position(Sn(:,:, idx), Tn, Po, v);
end


%% get the covariance matrix, just do 2D for now
Pn = P_new(:,1:2).';

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

fprintf('AOU = %2.5f\n', aou);
fprintf('Eccentricity = %2.5f\n', ecc);


%% plot the data
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

%scatter(reshape(Sn(:,1,:),[num_trials*N,1]), reshape(Sn(:,2,:),[num_trials*N,1]), 10, 'v', 'filled', 'k')
hold on
grid on
box on

for idx=1:N
    rectangle('Position',[S(idx,1)-range_err, S(idx,2)-range_err, 2*range_err, 2*range_err], 'FaceColor', [0.8 0.8 0.8 0.3], 'EdgeColor', [0 0 0], 'Curvature',[1,1]);  
end

scatter(S(:,1), S(:,2), 10, 'v', 'filled', 'k')
scatter(Po(1), Po(2), 20, 'd', 'filled', 'b')
scatter(P_new(:,1), P_new(:,2), '.', 'b')

% plot the center
scatter(C(1), C(2), 'o', 'filled', 'g')
scatter(P(1), P(2), 'o', 'filled', 'r')

% plot the ellipse
plot(r_ellipse(1,:) + C(1), r_ellipse(2,:) + C(2), '-g')

set(gca,'fontweight','bold','FontSize',13);
xlim([floor((min(S(:,1))-1)/10)*10, ceil((max(S(:,1))+1)/10)*10]);
xlabel('X (km)', 'fontweight','bold','FontSize',13);

ytickformat('%1.1f')
ylabel('Y (km)', 'fontweight','bold','FontSize',13);

ax = gca;
ax.Position = [0.07 0.09 0.90 0.86];


