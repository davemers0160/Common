format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;


%% Loss - 20*LOG(R)+20*LOG(F)-27.55	
frequency = 100;

x_range_min = -8000;
x_range_max = 8000;
x_range_step = 50;

y_range_min = -4000;
y_range_max = 4000;
y_range_step = 50;

z_max = 1000;

x_range = x_range_min:x_range_step:x_range_max;
y_range = y_range_min:y_range_step:y_range_max;

[x, y, z] = meshgrid(x_range, y_range, z_max);

%% setup points

p1 = [-4000, 0, 1];
p2 = [0, 0, 1];

range_p1 = sqrt((x-p1(1)).^2 + (y-p1(2)).^2 + (z-p1(3)).^2);
range_p2 = sqrt((x-p2(1)).^2 + (y-p2(2)).^2 + (z-p2(3)).^2);

%% calculate the losses
loss_map1 = -(20*log10(range_p1) + 20*log10(frequency) - 27.55);
loss_map2 = -(20*log10(range_p2) + 20*log10(frequency) - 27.55);

%% circle

radius = 1000;

% set the ellipse plotting segments
segments = 120;
theta = linspace(0, 2*pi, segments);

% calculate the ellipse
r_ellipse = (radius * eye(2)) * [cos(theta(:)).'; sin(theta(:)).'];


%%


loss_map = loss_map1 - loss_map2;
zm = max(loss_map(:));

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')

surf(x_range, y_range, -loss_map, 'edgecolor', 'none');
hold on
box on
grid on

s1 = scatter3(p2(1), p2(2), zm, 25, '^', 'k', 'filled');
s1.MarkerEdgeColor = 'w';

s2 = scatter3(p1(1), p1(2), zm, 25, 'o', 'k', 'filled');
s2.MarkerEdgeColor = 'w';

% plot the ellipse
el1 = plot3(r_ellipse(1,:) + p2(1), r_ellipse(2,:) + p2(2), zm*ones(1,segments), '--k');

set(gca,'fontweight','bold','FontSize', 13);

colormap(jet(256))
colorbar

view(0,90);
plot_num = plot_num + 1;

%% test

source = 0;
over = 3;

loss_map_s = -loss_map + source + over;

limit = 10;

loss_map_b = double(loss_map_s<=limit);

zm = max(loss_map_s(:));

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')
surf(x_range, y_range, loss_map_b, 'edgecolor', 'none');
hold on
box on
grid on

s1 = scatter3(p2(1), p2(2), 1, 30, '^', 'k', 'filled');
s1.MarkerEdgeColor = 'w';

s2 = scatter3(p1(1), p1(2), 1, 30, 'o', 'k', 'filled');
s2.MarkerEdgeColor = 'w';

% plot the ellipse
plot3(r_ellipse(1,:) + p2(1), r_ellipse(2,:) + p2(2), ones(1,segments), '--k')

set(gca,'fontweight','bold','FontSize', 13);

colormap([1,0,0;0,1,0])
% axis equal
view(0,90);
plot_num = plot_num + 1;







