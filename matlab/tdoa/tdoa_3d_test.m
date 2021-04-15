format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% set up each of the 4 points
rng(now);

N = 4;
v = 100;

S = zeros(N, 4);

S(1,:) = [100, 150, 89, 0];
S(2,:) = [345, 212, 334, 0];
S(3,:) = [212, 343, 121, 0];
S(4,:) = [260, 564, 33, 0];

% set P
P = [200, 100, 100];

% get the base time
t = 100;

% calculate the arrival times
for idx=1:N
    %S(idx, 4) = sqrt((S(idx,1)-P(1))^2 + (S(idx,2)-P(2))^2 + (S(idx,3)-P(3))^2)/v + t;
    S(idx, 4) = sqrt(sum((S(idx, 1:3) - P).*(S(idx, 1:3) - P)))/v + t;
end

% calculate an initial position
Po = [250, 150, 244];

P_new = zeros(100,3);
iter = zeros(100,1);
err = zeros(100,1);

rt = zeros(4,100);


for idx=1:100
    rt(:,idx) = 0.000001*randn(4,1);
    S(:,4) = S(:,4) + rt(:,idx);

    [P_new(idx,:), iter(idx,:), err(idx,:)]= calc_3d_tdoa_position(S, Po, v);

end


%% get the covariance matrix
Pn = P_new(:,1:2).';

% get the center/means in each direction
C = mean(Pn, 2);

% calculate the covariance matrix
Rp = (1/100)*((Pn-C)*(Pn-C).');

% find the eigenvalues (V) and the eigenvectors (E)
[Ep, Vp] = eig(Rp, 'vector');

% get the confidence interval 
p = 0.80;
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



%% plot the data
figure(plot_num)
set(gcf,'position',([50,50,1200,700]),'color','w')

scatter(S(:,1), S(:,2), '*', 'k')
hold on

scatter(P(1), P(2), 'o', 'filled', 'r')
scatter(P_new(:,1), P_new(:,2), '.', 'b')

grid on
box on

% plot the center
scatter(C(1), C(2), 'o', 'filled', 'g')

plot(r_ellipse(1,:) + C(1), r_ellipse(2,:) + C(2), '-g')

%h = plot_ellipses(cnt, [Vp(1)*Ep(:,1), Vp(2)*Ep(:,2)])
% scatter(C(1)+sm1(1), C(2)+sm1(2), '+', 'k')
% scatter(C(1)-sm1(1), C(2)-sm1(2), '+', 'k')
% scatter(C(1)+sm2(1), C(2)+sm2(2), '+', 'g')
% scatter(C(1)-sm2(1), C(2)-sm2(2), '+', 'g')

bp = 1;
return;

%%
function h = plot_ellipses(cnt,rads,axh)
% cnt is the [x,y] coordinate of the center (row or column index).
% rads is the [horizontal, vertical] "radius" of the ellipses (row or column index).
% axh is the axis handle (if missing or empty, gca will be used)
% h is the object handle to the plotted rectangle.
% The easiest approach IMO is to plot a rectangle with rounded edges. 
% EXAMPLE
%    center = [1, 2];         %[x,y] center (mean)
%    stdev = [1.2, 0.5];      %[x,y] standard dev.
%    h = plotEllipses(center, stdev)
%    axis equal
% get axis handle if needed
if nargin < 3 || isempty(axh)
   axh = gca();  
end
% Compute the lower, left corner of the rectangle.
llc = cnt(:)-rads(:);
% Compute the width and height
wh = rads(:)*2; 
% Draw rectangle 
h = rectangle(axh,'Position',[llc(:).',wh(:).'],'Curvature',[1,1]); 
end

