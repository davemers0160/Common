format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% set up each of the points
%rng(now);

% v = 161874.9773218;
v = 299792458/1000;         %km/s

% estimating +/- position error
% range_err = 0.0;
range_err = 0.1;

% estimating +/- arrival time error
% time_err = 0.0;
time_err = 2e-7;

% set the receiver station locations (S) and the emitter location (P)

% 2D
% receiver station locations
S(1,:) = [20, 20];
S(2,:) = [80, 5];
S(3,:) = [140, 20];

% get the dimensions of the data
[N, D] = size(S);

% set teh number of trials
num_trials = 100;

% guess/calculate an initial position
Po = [80, 80];

% times
T = [0; 0; 0];

P_new = zeros(num_trials, D);
iter = zeros(num_trials, 1);
err = zeros(num_trials, 1);
Sn = zeros(N, D, num_trials);

aou = zeros(240, 160);
%aou=[];

r = 1;
c = 1;
for y=0:5:240-1
    c = 1;
    for x=0:5:160-1
        
        % target location
        P = [x, y];

        % calculate the arrival times
        for idx=1:N
            T(idx) = sqrt(sum((S(idx, :) - P).*(S(idx, :) - P)))/v;
        end     
        
        % generate noise in both the position space and time space to find a
        % general area of uncertainty 
        for idx=1:num_trials
            Sn(:, :, idx) = S + range_err*randn(N, D);
            Tn = T + time_err*randn(N,1);

            [P_new(idx,:), iter(idx,:), err(idx,:)]= calc_tdoa_position(Sn(:,:, idx), Tn, Po, v);
        end

        % get the center/means in each direction
        C = mean(P_new(:,1:2).', 2);

%         [tmp_aou, ecc, r_ellipse] = calc_aou(P_new);

        tmp_error = sqrt(sum((P-C').*(P-C')));
        aou((y:y+5-1)+1, (x:x+5-1)+1) = tmp_error*ones(5);
        c = c + 1;
        
    end
    r = r + 1;
end

% %% get the covariance matrix, just do 2D for now
% Pn = P_new(:,1:2).';
% 
% 
% 
% % calculate the covariance matrix
% Rp = (1/num_trials)*((Pn-C)*(Pn-C).');
% 
% % find the eigenvalues (V) and the eigenvectors (E)
% [Ep, Vp] = eig(Rp, 'vector');
% 
% % get the confidence interval 
% p = 0.95;
% s = -2 * log(1 - p);
% Vp = Vp*s;
% 
% % get the max eigen value
% [max_eig_val, max_eig_ind] = max(Vp);
% [min_eig_val, min_eig_ind] = min(Vp);
% 
% max_eig_vec = Ep(:, max_eig_ind);
% min_eig_vec = Ep(:, min_eig_ind);
% 
% % calculate the angle between the x-axis and the largest eigenvector
% angle = atan2(max_eig_vec(2), max_eig_vec(1));
% 
% % This angle is between -pi and pi.
% % Let's shift it such that the angle is between 0 and 2pi
% if(angle < 0)
%     angle = angle + 2*pi;
% end
% 
% % set the ellipse plotting segments
% theta = linspace(0, 2*pi, 100);
% 
% % calculate the ellipse
% r_ellipse = (Ep * (sqrt(diag(Vp)))) * [cos(theta(:))'; sin(theta(:))'];
% 
% % [V, D] = eig(Rp * s);
% % r_ellipse = (V * sqrt(D)) * [cos(theta(:))'; sin(theta(:))'];
% ecc = sqrt(1-(min(Vp)/max(Vp)));
% aou = prod(sqrt(Vp))*pi();

% fprintf('AOU = %2.5f\n', aou);
% fprintf('Eccentricity = %2.5f\n', ecc);

bp = 1;
%% plot the data
figure(plot_num)
set(gcf,'position',([50,100,1200,800]),'color','w')

hold on
grid on
box on

aou(aou(:,:)>52) = 50;
% surf(abs(aou), 'FaceAlpha',0.5)
surf(abs(aou), 'FaceAlpha',1.0)

colormap(blues(100))
shading flat
colorbar

% for idx=1:N
%     rectangle('Position',[S(idx,1)-range_err, S(idx,2)-range_err, 2*range_err, 2*range_err], 'FaceColor', [0.8 0.8 0.8 0.3], 'EdgeColor', [0 0 0], 'Curvature',[1,1]);  
% end

% plot each of the receiver stations and the intial guess
% scatter(S(:,1), S(:,2), 20, 'v', 'filled', 'r')
% scatter(Po(1), Po(2), 20, 'd', 'filled', 'b')
scatter3(S(:,1), S(:,2), 50*ones(N,1), 20, 'v', 'filled', 'r')
scatter3(Po(1), Po(2), 50, 20, 'd', 'filled', 'b')

% plot the results of num_trials
% scatter(P_new(:,1), P_new(:,2), '.', 'b')

% plot the center point of the solution and the actual target location
% scatter(C(1), C(2), 'o', 'filled', 'g')
% scatter(P(1), P(2), 'o', 'filled', 'r')

% plot the ellipse
% plot(r_ellipse(1,:) + C(1), r_ellipse(2,:) + C(2), '-g')

% make the graph look pretty
set(gca,'fontweight','bold','FontSize',13);
% xlim([floor((min(S(:,1))-1)/10)*10, ceil((max(S(:,1))+1)/10)*10]);
xlim([0,160]);
xticks(0:5:160)
xtickangle(45)
xlabel('X (km)', 'fontweight','bold','FontSize',13);

% ytickformat('%1.1f')
ylim([0,240]);
yticks(0:5:240)
ylabel('Y (km)', 'fontweight','bold','FontSize',13);

ax = gca;
% ax.Position = [0.08 0.09 0.89 0.86];
ax.Position = [0.08 0.09 0.84 0.86];

