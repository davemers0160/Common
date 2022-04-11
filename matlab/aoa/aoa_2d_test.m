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


% estimating +/- position error (kilometers)
position_err = 0.005;

% estimating +/- angle of arrival error (degrees)
angle_err = 1.3;

% set the receiver locations (P) and the emitter location (T)
 
% 2D
% receiver measurement locations
P(:,1) = linspace(-60, -20, 51);
P(:,2) = linspace(50, 15, 51);


% target location
T = [10, 180];

% get the dimensions of the data
[N, D] = size(P);

% calculate the angles of arrival 
AoA = zeros(N, 1);
for idx=1:N
    AoA(idx) = atan2d(T(2)-P(idx,2), T(1)-P(idx,1));
end

% set the number of trials
num_trials = 100;

T_est = zeros(num_trials, D);
iter = zeros(num_trials, 1);
err = zeros(num_trials, 1);
P_n = zeros(N, D, num_trials);


for idx=1:num_trials
    % introduce random sensor and position noise
    P_n(:, :, idx) = P + (position_err * randn(N, D));
    AoA_n = AoA + (angle_err * randn(N,1));

    % build b
    b = P_n(:,1, idx).*sind(AoA_n) - P_n(:,2, idx).*cosd(AoA_n);
    
    % build G
    G = cat(2, sind(AoA_n), -cosd(AoA_n));
    
    % invert G -> ((GtG)^-1)Gt
    G_pinv = (pinv(G.' * G)*G.');
    
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

max_eig_vec = Ep(:, max_eig_ind);
min_eig_vec = Ep(:, min_eig_ind);

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
set(gcf,'position',([50,80,1400,700]),'color','w')

%scatter(reshape(Sn(:,1,:),[num_trials*N,1]), reshape(Sn(:,2,:),[num_trials*N,1]), 10, 'v', 'filled', 'k')
hold on
grid on
box on

% for idx=1:N
%     rectangle('Position',[P(idx,1)-position_err, P(idx,2)-position_err, 2*position_err, 2*position_err], 'FaceColor', [0.8 0.8 0.8 0.3], 'EdgeColor', [0 0 0], 'Curvature',[1,1]);  
% end

s1 = scatter(P(:,1), P(:,2), 20, 'v', 'filled', 'k');
%scatter(Po(1), Po(2), 20, 'd', 'filled', 'b')
s2 = scatter(T_est(:,1), T_est(:,2), '.', 'b');

% plot the center
s3 = scatter(C(1), C(2), 'o', 'filled', 'g');
s4 = scatter(T(1), T(2), 'o', 'filled', 'r');

% plot the ellipse
p1 = plot(r_ellipse(1,:) + C(1), r_ellipse(2,:) + C(2), '-g');

set(gca,'fontweight','bold','FontSize',13);
%xlim([floor((min(P(:,1))-1)/10)*10, ceil((max(P(:,1))+1)/10)*10]);
xlabel('X (km)', 'fontweight','bold','FontSize',13);

ytickformat('%1.1f')
ylabel('Y (km)', 'fontweight','bold','FontSize',13);

legend([s1, s2, s4, p1, s3], {'Measurement Points', 'Location Estimates', 'Target Location', strcat('AoU =', 32, num2str(aou, '%2.5f')), 'AoU Center'}, 'Location', 'southoutside', 'Orientation','horizontal');

ax = gca;
ax.Position = [0.07 0.15 0.90 0.81];


