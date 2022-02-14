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

%% 

% distance from camera to object (m)
z = 100:100:1000;
z = 1900*rand(1,20) + 100;

% focal length (m)
f = 1.45;

% camera baseline (distance between cameras) (m)
b = 0.3;

% lens aperature (m)
a = 0.095;

% pixel size
px_size = 3.45e-6;

% max angle for each lens
max_a = atan2(f, a/2);

% location of point on x-axis (m)
% x = 0.0*b;
x = 100*(2*rand(1,20)-1);


%%

% calculate angles
theta_l = atan2(x, z);

theta_r = atan2(x-b, z);


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

