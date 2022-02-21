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

% focal length (m)
f = 0.00212;

% camera baseline (distance between cameras) (m)
b = 0.120;

% lens aperature (m)
%a = 0.095;

% pixel size (m)
px_size = (2.0e-6);
half_px_size = px_size/2;

% number of pixels in the image - equivalent to image width or height
px_num = 1024;

% size of image (m)
imger_size = px_num * px_size;

% max angle for each lens
max_a = atan2(imger_size/2, f);

% number of measurements to try
num = 1000;

% min and max distances
z_min = ceil((b/2)/tan(max_a));       % intersection point of the limiting rays for the lenses
z_max = 20;

% distance from camera to object (m)
z = floor(((z_max-z_min)/60*randi([1 60], num, 1) + z_min)/1)*1;

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
x_l = ceil(x_l/half_px_size) * half_px_size;

x_r = f * tan(theta_r);
x_r = ceil(x_r/half_px_size) * half_px_size;

%% calculate the disparity

d = x_l - x_r;

Z = f * b ./ d;

%%
figure

hold on

plot([-imger_size/2, imger_size/2], [f,f], 'k')
plot([b - imger_size/2, b + imger_size/2], [f,f], 'k')

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

x_range = floor(z_max*tan(-max_a) + b):0.1:ceil(z_max*tan(max_a));
z_range = z_min:0.1:z_max;

[x_g, z_g] = meshgrid(x_range, z_range);

for idx=1:numel(z_range)
    x_map = (x_g(idx,:) >= (z_range(idx)*tan(-max_a))) & (x_g(idx,:) <= (z_range(idx)*tan(max_a)));
    
    x_g(idx, ~x_map) = NaN;
    z_g(idx, ~x_map) = NaN;
    bp = 1;
end

% calculate angles
theta_lg = atan2(x_g, z_g);
theta_rg = atan2(x_g-b, z_g);

% calculate the disparity parts
x_l = f*tan(theta_lg);
x_lq = ceil(x_l/half_px_size) * half_px_size;

x_r = f * tan(theta_rg);
x_rq = ceil(x_r/half_px_size) * half_px_size;

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


