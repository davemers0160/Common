%% Angle of Arrival Calculations
% Assumptions:
% 1. Everything is 3-D but if we assume that the Z component is at 0 height
% we can project everything to a 2-D hyper-plane (either project to z=0 or 
% a plane that passes through all points)
% 2. We are working in a Cartesian Coordinate System (CCS) (Local Tangent Plane,
% ECEF, etc...)
% 3. The conversion from the CCS to a Polar Coordinate System and back is
% well defined
% 4. Solution uses Least Squares to solve and assumes we have all of the
% data.  A Recursive Least Squares solution can be used as well.

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

% estimating +/- position error (kilometers)
position_err = 0.005;

% estimating +/- angle of arrival error (degrees)
angle_err = 1.3;

% set the receiver locations (P) and the emitter location (T)
% 2D
% receiver measurement locations (km)
P(:,1) = linspace(-60, -30, 31);
P(:,2) = linspace(35, 0, 31);

% target location (km)
T = [10, 180];

% get the dimensions of the data
[N, D] = size(P);

% calculate the angles of arrival 
AoA = zeros(N, 1);
for idx=1:N
    AoA(idx) = atan2d(T(2)-P(idx,2), T(1)-P(idx,1));
end

%% setup the measurement collection with errors
% set the number of trials
num_trials = 100;

T_est = zeros(num_trials, D);
P_n = zeros(N, D, num_trials);

for idx=1:num_trials
    % introduce random sensor and position noise
    P_n(:, :, idx) = P + (position_err * randn(N, D));
    AoA_n = AoA + (angle_err * randn(N,1));

    % build b
    b = P_n(:,1, idx).*sind(AoA_n) - P_n(:,2, idx).*cosd(AoA_n);
    
    % build G
    G = cat(2, sind(AoA_n), -cosd(AoA_n));
    
    % invert G: G^-1 ~= ((GtG)^-1)Gt, Gt = G transpose
    G_pinv = (pinv(G.' * G)*G.');
    
    % x = G^-1 * b
    T_est(idx, :) = (G_pinv * b).';
    
end

%% get the covariance matrix, just do 2D for now
Tn = T_est(:,1:2).';

% get the center/means in each direction
C = mean(Tn, 2);

% calculate the covariance matrix
Rp = (1/num_trials)*((Tn-C)*(Tn-C).');

% find the eigenvalues (V) and the eigenvectors (E)
[Ep, Vp] = eig(Rp, 'vector');

% get the confidence interval 
p = 0.95;
s = -2 * log(1 - p);
Vp = Vp*s;

% get the max eigen value
[max_eig_val, max_eig_ind] = max(Vp);
[min_eig_val, min_eig_ind] = min(Vp);

% set the ellipse plotting segments
theta = linspace(0, 2*pi, 100);

% calculate the ellipse
r_ellipse = (Ep * (sqrt(diag(Vp)))) * [cos(theta(:))'; sin(theta(:))'];

ecc = sqrt(1-(min(Vp)/max(Vp)));
aou = prod(sqrt(Vp))*pi();

fprintf('AOU = %2.5f\n', aou);
fprintf('Eccentricity = %2.5f\n', ecc);


%% plot the data
figure(plot_num)
set(gcf,'position',([50,80,1400,700]),'color','w')

%scatter(reshape(Sn(:,1,:),[num_trials*N,1]), reshape(Sn(:,2,:),[num_trials*N,1]), 10, 'v', 'filled', 'k')
hold on
grid on
box on

% plot the true measurement positions
s1 = scatter(P(:,1), P(:,2), 20, 'v', 'filled', 'k');
% plot the estimated target locations
s2 = scatter(T_est(:,1), T_est(:,2), '.', 'b');

% plot the center of the AoU
s3 = scatter(C(1), C(2), 'o', 'filled', 'g');
% plot the actual target location
s4 = scatter(T(1), T(2), 'o', 'filled', 'r');

% plot the AoU ellipse
p1 = plot(r_ellipse(1,:) + C(1), r_ellipse(2,:) + C(2), '-g');

set(gca,'fontweight','bold','FontSize',13);
xlabel('X (km)', 'fontweight','bold','FontSize',13);

ytickformat('%1.1f')
ylabel('Y (km)', 'fontweight','bold','FontSize',13);

legend([s1, s2, s4, p1, s3], {'Measurement Points', 'Location Estimates', 'Target Location', strcat('AoU =', 32, num2str(aou, '%2.5f')), 'AoU Center'}, 'Location', 'southoutside', 'Orientation','horizontal');

ax = gca;
ax.Position = [0.07 0.15 0.90 0.81];


