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

%% setup a bunch of the parameters to describe the problem

% number of measurements to try
num = 1000;

% min and max distances
z_min = 500;
z_max = 1100;

% distance from camera to object (m)
z = 10*randi([0 60], num, 1) + z_min;

% focal length (m)
f = .45;

% camera baseline (distance between cameras) (m)
b = 0.5;

% lens aperature (m)
a = 0.095;

% pixel size
px_size = (3.45e-6)/2;

% max angle for each lens
max_a = atan2(a/2, f);

% location of point on x-axis (m)
% r = a + (b-a).*rand(N,1).
x = zeros(num, 1);
for idx=1:num
    x(idx) = (z(idx) * tan(-max_a) + b) + ((z(idx)*tan(max_a)) - (z(idx)*tan(-max_a) + b))*(rand(1));
end

%%

% calculate angles
theta_l = atan2(x, z);
theta_r = atan2(x-b, z);

% calculate the disparity parts
x_l = f*tan(theta_l);
x_l = ceil(x_l/px_size) * px_size;

x_r = f * tan(theta_r);
x_r = ceil(x_r/px_size) * px_size;

%% calculate the disparity

d = x_l - x_r;

Z = f * b ./ d;

%%
figure

hold on

plot([-a/2,a/2], [f,f], 'k')
plot([b-a/2, b+a/2], [f,f], 'k')


for idx=1:numel(z)
    
    plot([0, x(idx)], [0, z(idx)], 'b')

    plot([b, x(idx)], [0, z(idx)], 'r')
end

scatter(x_l, f*ones(numel(x_l),1), 15, 'ob', 'filled');

scatter(x_r + b, f*ones(numel(x_r),1), 15, 'or', 'filled');

scatter(x, z, 20, 'ok', 'filled');

scatter(x, Z, 10, 'og', 'filled');

plot([0, -z_max*tan(max_a)], [0, z_max], 'k')
plot([0, z_max*tan(max_a)], [0, z_max], 'k')

plot([b, b-z_max*tan(max_a)], [0, z_max], 'k')
plot([b, b+z_max*tan(max_a)], [0, z_max], 'k')

%% create an error map with 1 meter increments in x and 5 meter increments in z

x_range = floor(z_max*tan(-max_a) + b):0.5:ceil(z_max*tan(max_a));
z_range = z_min:0.5:z_max;

[x_g, z_g] = meshgrid(x_range, z_range);

% calculate angles
theta_lg = atan2(x_g, z_g);
theta_rg = atan2(x_g-b, z_g);

% calculate the disparity parts
x_l = f*tan(theta_lg);
x_lq = ceil(x_l/px_size) * px_size;

x_r = f * tan(theta_rg);
x_rq = ceil(x_r/px_size) * px_size;

% calculate the quantized distance
d_q = x_lq - x_rq;

Z_q = f * b ./ d_q;


% calculate the error (L1)
Z_err = abs(z_g - Z_q);

figure;
surf(x_range, z_range, Z_err)
shading flat
colormap(jet(100));
colorbar;
view(90,90);


