format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

line_width = 1.5;

cd(startpath);
commandwindow;

%% conversions

ft2m = 0.3048001109472;
m2nmi = 0.000539957;
yd2m = 0.9144;
m2yd = 1/yd2m;
m2ft = 1/ft2m;

%% load ITM library

lib_path = '../ITM/x64/';
lib_name = 'itm';
hfile = 'itm.h';

if(~libisloaded(lib_name))
    [notfound, warnings] = loadlibrary(strcat(lib_path, lib_name,'.dll'), strcat(lib_path,hfile));
end

if(~libisloaded(lib_name))
   fprintf('\nThe %s library did not load correctly!',  strcat(lib_path, lib_name,'.dll'));    
end

%% ITM parameters

sw_conductivity = 5.5;
sw_permitivity = 68;

N_0 = 301;
delta_h = 0.1;

time_var = 50;
location_var = 50;
situation_var = 50;

site_criteria = int32(1);

climate = int32(7);

polarization = int32(0);

mdvar = int32(0);

loss_t = libpointer('doublePtr', 0.0);
warn_t = libpointer('longPtr', 0);

pfl_t = libpointer('doublePtr', [10, 100, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]);

%% Loss - 20*LOG(R)+20*LOG(F)-27.55	
frequency = 100;

x_range_min = -8000;
x_range_max = 8000;
x_range_step = 50;

y_range_min = -6000;
y_range_max = 6000;
y_range_step = 50;

z_max = 1000;

x_range = x_range_min:x_range_step:x_range_max;
y_range = y_range_min:y_range_step:y_range_max;

[x, y, z] = meshgrid(x_range, y_range, z_max);

%% circle

r1 = 1000;
r2 = 4000;

% set the ellipse plotting segments
segments = 120;
theta = linspace(0, 2*pi, segments);

% calculate the ellipse
r1_ellipse = (r1 * eye(2)) * [cos(theta(:)).'; sin(theta(:)).'];
r2_ellipse = (r2 * eye(2)) * [cos(theta(:)).'; sin(theta(:)).'];

%% setup points

% points are X, Y, Z
TX = [-4000, 0, 1];

num_TX = size(TX, 1);

AX = [0, -1000, 0.5;
      0, 0, 0.5;
      0, 1000, 0.5;
      1000, -1000, 0.5;
      1000, 0, 0.5;
      1000, 1000, 0.5];

num_AX = size(AX, 1);

%% plot points and circles

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')

hold on;
grid on;
box on;

for idx=1:num_TX
    scatter(TX(idx, 1), TX(idx, 2), 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
end

for idx=1:num_AX
    scatter(AX(idx, 1), AX(idx, 2), 30, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
    plot(r1_ellipse(1,:) + AX(idx, 1), r1_ellipse(2,:) + AX(idx, 2), '-', 'Color', 'r', 'LineWidth', line_width)
    plot(r2_ellipse(1,:) + AX(idx, 1), r2_ellipse(2,:) + AX(idx, 2), '--', 'Color', 'r', 'LineWidth', line_width)
end

set(gca,'fontweight','bold','FontSize', 13);

xlim([x_range_min, x_range_max]);
ylim([y_range_min, y_range_max]);

xlabel('meters (m)', 'fontweight','bold','FontSize', 13)
ylabel('meters (m)', 'fontweight','bold','FontSize', 13)

plot_num = plot_num + 1;

%% loss mapping

RX = [0, 0, z_max];

dist_tx_rx = cell(num_TX, 1);
loss_tx_rx = cell(num_TX, 1);
dist_ax_rx = cell(num_AX, 1);
loss_ax_rx = cell(num_AX, 1);

% calculate TX to RX distance and loss
for idx=1:num_TX
    dist_tx_rx{idx,1} = sqrt((x-TX(idx, 1)).*(x-TX(idx, 1)) + (y-TX(idx, 2)).*(y-TX(idx, 2)) + (z-TX(idx, 3)).*(z-TX(idx, 3))); 
%     loss_tx_rx{idx,1} = -(20*log10(dist_tx_rx{idx,1}) + 20*log10(frequency) - 27.55);

    for y_r = 1:numel(y_range)
        for x_r = 1:numel(x_range)
            res = calllib(lib_name,'ITM_AREA_TLS', TX(idx, 3), z_max, site_criteria, site_criteria, dist_tx_rx{idx,1}(y_r, x_r)/1000, delta_h, climate, N_0, frequency, polarization, sw_permitivity, sw_conductivity, mdvar, time_var, location_var, situation_var, loss_t, warn_t);
            loss_tx_rx{idx,1}(y_r, x_r) = -loss_t.Value;
        end
    end
end

% calculate AX to RX distance and loss
for idx=1:num_AX
    dist_ax_rx{idx,1} = sqrt((x-AX(idx, 1)).*(x-AX(idx, 1)) + (y-AX(idx, 2)).*(y-AX(idx, 2)) + (z-AX(idx, 3)).*(z-AX(idx, 3))); 
    loss_ax_rx{idx,1} = -(20*log10(dist_ax_rx{idx,1}) + 20*log10(frequency) - 27.55);
end

% calculate the loss delta between entities
loss_delta_tx_ax = cell(num_TX, num_AX);
z_plot = -1e6;
for idx=1:num_TX
    for jdx=1:num_AX
        loss_delta_tx_ax{idx, jdx} = loss_tx_rx{idx,1} - loss_ax_rx{jdx,1};
        z_plot = max(z_plot, loss_delta_tx_ax{idx, jdx}(:));
    end
end

% for plotting
z_plot = max(z_plot);

%% close lib
unloadlibrary(lib_name);

%% ploting the loss delta map

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')

hold on;
grid on;
box on;

surf(x, y, loss_tx_rx{1, 1}, 'EdgeColor','none');
surf(x, y, loss_ax_rx{5, 1}, 'EdgeColor','none');

for idx=1:num_TX
    scatter3(TX(idx, 1), TX(idx, 2), -70, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
end

set(gca,'fontweight','bold','FontSize', 13);

xlim([x_range_min, x_range_max]);
ylim([y_range_min, y_range_max]);

xlabel('meters (m)', 'fontweight','bold','FontSize', 13)
ylabel('meters (m)', 'fontweight','bold','FontSize', 13)

ax = gca;
ax.Layer = 'top';

plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')

hold on;
grid on;
box on;

% surf(x, y, loss_tx_rx{1}, 'EdgeColor','none');
% surf(x, y, loss_ax_rx{5}, 'EdgeColor','none');

surf(x, y, loss_delta_tx_ax{1, 5}, 'EdgeColor','none');

for idx=1:num_TX
    scatter3(TX(idx, 1), TX(idx, 2), z_plot, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
end

set(gca,'fontweight','bold','FontSize', 13);

xlim([x_range_min, x_range_max]);
ylim([y_range_min, y_range_max]);

xlabel('meters (m)', 'fontweight','bold','FontSize', 13)
ylabel('meters (m)', 'fontweight','bold','FontSize', 13)

ax = gca;
ax.Layer = 'top';

plot_num = plot_num + 1;

%% test

source = 0;
over = 3;

loss_map_s =  -loss_delta_tx_ax{1, 5} + source + over;

limit = 10;

loss_map_b = double(loss_map_s<=limit);

zm = max(loss_map_s(:));

figure(plot_num)
set(gcf,'position',([100,100,1000,500]),'color','w')
surf(x_range, y_range, loss_map_b, 'edgecolor', 'none');
hold on
box on
grid on

for idx=1:num_TX
    scatter3(TX(idx, 1), TX(idx, 2), zm, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
end

for idx=1:num_AX
    scatter3(AX(idx, 1), AX(idx, 2), zm, 30, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
    plot3(r1_ellipse(1,:) + AX(idx, 1), r1_ellipse(2,:) + AX(idx, 2), zm*ones(1,segments), '-', 'Color', 'w', 'LineWidth', line_width)
    plot3(r2_ellipse(1,:) + AX(idx, 1), r2_ellipse(2,:) + AX(idx, 2), zm*ones(1,segments), '--', 'Color', 'w', 'LineWidth', line_width)
end

% plot the ellipse
% plot3(r1_ellipse(1,:) + p2(1), r1_ellipse(2,:) + p2(2), ones(1,segments), '--k')

set(gca,'fontweight','bold','FontSize', 13);

xlim([x_range_min, x_range_max]);
ylim([y_range_min, y_range_max]);

xlabel('meters (m)', 'fontweight','bold','FontSize', 13)
ylabel('meters (m)', 'fontweight','bold','FontSize', 13)


colormap([1,0,0;0,1,0])
% axis equal
view(0,90);

ax = gca;
ax.Layer = 'top';

plot_num = plot_num + 1;







