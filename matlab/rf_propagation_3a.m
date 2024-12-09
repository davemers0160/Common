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
ft2yd = 1/3;
yd2m = 0.9144;
yd2ft = 3;
m2nmi = 0.000539957;
m2yd = 1/yd2m;
m2ft = 1/ft2m;

drive_letter = 'C';
tmp_path = strcat(drive_letter, ':/Projects/data/temp/');
save_path = strcat(drive_letter, ':/Projects/data/prop_analysis/');

clear tempdir
setenv('TMP', tmp_path);

%% load ITM library

lib_path = strcat(drive_letter, ':/Projects/ITM/x64/');
lib_name = 'itm';
hfile = 'itm_ml.h';

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
%frequency = 167.5;

x_range_min = -200;
x_range_max = 200;
x_range_step = 5;

y_range_min = -200;
y_range_max = 200;
y_range_step = 5;

z_max = 30;

x_range = x_range_min:x_range_step:x_range_max;
y_range = y_range_min:y_range_step:y_range_max;

[x, y, z] = meshgrid(x_range, y_range, z_max);

%% circle

r1 = 100;       % meters

% set the ellipse plotting segments
segments = 120;
theta = linspace(0, 2*pi, segments);

% calculate the ellipse
r1_ellipse = (r1 * eye(2)) * [cos(theta(:)).'; sin(theta(:)).'];

%% setup points

% points are X, Y, Z
tx_height = 30;         % meter
rx_height = 30;         % meters

TX = [
      100, 0, tx_height;
      50, 0, tx_height;
     ];

num_TX = size(TX, 1);


RX = [
    0, 0, rx_height;
    ];

num_RX = size(RX, 1);


if(size(TX,1) == 1)
    scenario = 'single';
else
    scenario = 'multi';
end

%% plot points and circles

figure(plot_num)
set(gcf,'position',([50,50,750,900]),'color','w')

hold on;
grid on;
box on;

for idx=1:num_RX
    scatter(RX(idx, 1), RX(idx, 2), 30, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
    plot(r1_ellipse(1,:) + RX(idx, 1), r1_ellipse(2,:) + RX(idx, 2), '--', 'Color', 'w', 'LineWidth', line_width);
    text(RX(idx, 1)+100, RX(idx, 2),num2str(idx,'%01d'),"Color",'w','FontSize',11,'FontWeight','bold');
end

for idx=1:num_TX
    scatter(TX(idx, 1), TX(idx, 2), 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
end

set(gca,'fontweight','bold','FontSize', 13, 'Color',[0.3,0.7,1.0]);

xlim([x_range_min, x_range_max]);
ylim([y_range_min, y_range_max]);

xticks(x_range_min:500:x_range_max);
xtickangle(45);
yticks(y_range_min:500:y_range_max);


xlabel('Distance (yds)', 'fontweight','bold','FontSize', 13)
ylabel('Distance (yds)', 'fontweight','bold','FontSize', 13)

% title(strcat('Laydown:', 32, scenario), 'fontweight','bold','FontSize', 14);

ax = gca;
ax.Position = [0.11, 0.09, 0.87, 0.89];

set(gcf, 'InvertHardCopy', 'off');
print(plot_num, '-dpng', fullfile(save_path, strcat('slc_laydown_',scenario,'.png')));

plot_num = plot_num + 1;

%% loss mapping
frequency = 20e3;

dist_tx_rx = cell(num_TX, 1);
loss_tx_rx = cell(num_TX, 1);


% calculate TX to RX distance and loss
for idx=1:num_TX
    dist_tx_rx{idx,1} = sqrt((x-TX(idx, 1)).*(x-TX(idx, 1)) + (y-TX(idx, 2)).*(y-TX(idx, 2)) + (z-TX(idx, 3)).*(z-TX(idx, 3))); 
    % loss_tx_rx{idx,1} = -(20*log10(dist_tx_rx{idx,1}) + 20*log10(frequency) - 27.55);

    for y_r = 1:numel(y_range)
        for x_r = 1:numel(x_range)
            res = calllib(lib_name,'ITM_AREA_TLS', TX(idx, 3), RX(3), site_criteria, site_criteria, dist_tx_rx{idx,1}(y_r, x_r)/1000, delta_h, climate, N_0, frequency, polarization, sw_permitivity, sw_conductivity, mdvar, time_var, location_var, situation_var, loss_t, warn_t);
            loss_tx_rx{idx,1}(y_r, x_r) = -loss_t.Value;
        end
    end
end

% calculate the loss delta between entities
% loss_delta_tx_rx = cell(num_TX, num_RX);
% z_plot = -1e6;
% for idx=1:num_TX
%     for jdx=1:num_RX
%         loss_delta_tx_rx{idx, jdx} = loss_tx_rx{idx,1} - loss_ax_rx{jdx,1};
%         z_plot = max(z_plot, loss_delta_tx_rx{idx, jdx}(:));
%     end
% end

% for plotting
z_plot = max(z_max);

%% close lib
unloadlibrary(lib_name);

%% ploting the loss map
for jdx=1:numel(loss_tx_rx)

    figure(plot_num)
    set(gcf,'position',([50,50,750,900]),'color','w')

    hold on;
    grid on;
    box on;

    surf(x, y, loss_tx_rx{jdx}, 'EdgeColor','none');

    % surf(x, y, loss_tx_rx{1, 1}, 'EdgeColor','none');
    % surf(x, y, loss_ax_rx{5, 1}, 'EdgeColor','none');

    for idx=1:num_TX
        scatter3(TX(idx, 1), TX(idx, 2), z_plot, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
    end

    for idx=1:num_RX
        scatter3(RX(idx, 1), RX(idx, 2), z_plot, 30, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
        if idx == jdx
            plot3(r1_ellipse(1,:) + RX(idx, 1), r1_ellipse(2,:) + RX(idx, 2), z_plot*ones(1,segments), '--', 'Color', 'k', 'LineWidth', line_width)
        else
            plot3(r1_ellipse(1,:) + RX(idx, 1), r1_ellipse(2,:) + RX(idx, 2), z_plot*ones(1,segments), '--', 'Color', 'w', 'LineWidth', line_width)
        end
    end

    set(gca,'fontweight','bold','FontSize', 13);

    xlim([x_range_min, x_range_max]);
    ylim([y_range_min, y_range_max]);

    xlabel('Distance (m)', 'fontweight','bold','FontSize', 13)
    ylabel('Distance (m)', 'fontweight','bold','FontSize', 13)

    ax = gca;
    ax.Layer = 'top';

    plot_num = plot_num + 1;

end

%% 
% figure(plot_num)
% set(gcf,'position',([50,50,750,900]),'color','w')
% 
% hold on;
% grid on;
% box on;
% 
% % surf(x, y, loss_tx_rx{1}, 'EdgeColor','none');
% % surf(x, y, loss_ax_rx{5}, 'EdgeColor','none');
% 
% surf(x, y, loss_delta_tx_ax{1, 5}, 'EdgeColor','none');
% 
% for idx=1:num_TX
%     scatter3(TX(idx, 1), TX(idx, 2), z_plot, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
% end
% 
% set(gca,'fontweight','bold','FontSize', 13);
% 
% xlim([x_range_min, x_range_max]);
% ylim([y_range_min, y_range_max]);
% 
% xlabel('Distance (yds)', 'fontweight','bold','FontSize', 13)
% ylabel('Distance (yds)', 'fontweight','bold','FontSize', 13)
% 
% ax = gca;
% ax.Layer = 'top';
% 
% plot_num = plot_num + 1;

%% loss map stop light generation

% tx_s = 10 * log10(1000 * 180);
tx_s = 20;          % dBm

num_channels = 1;
channel_loss = 20*log10(num_channels);
tx_source = tx_s - channel_loss;

required_level = -70;
over_under = 2;

% stop_light_map = cell(num_TX * num_AX, 1);
stop_light_map = cell(num_RX, 1);
index = 1;
for jdx=1:num_RX

    tmp_power_map = -1e6*ones(size(loss_tx_rx{jdx,1}));
    for idx=1:num_TX

        %                                   power at rx from tx               
        tmp_power_map = max(tmp_power_map, (tx_source + loss_tx_rx{idx,1}));

     end   

        tmp_stop_light = zeros(size(loss_tx_rx{jdx,1}));
        tmp_stop_light = tmp_stop_light + 2 * (tmp_power_map >= (required_level + over_under));
        tmp_stop_light = tmp_stop_light + ( (tmp_power_map < (required_level + over_under)) &  (tmp_power_map >= (required_level - over_under)) );

        stop_light_map{index} = tmp_stop_light;
        index = index + 1;

end

zb_plot = 2;

%% plot the stop lights

for jdx=1:numel(stop_light_map)

    vals = unique(stop_light_map{jdx});

    cm = [];
    for idx=1:numel(vals)
        switch(vals(idx))
            case 0
                cm = cat(1, cm, [1, 0, 0]);
            case 1
                cm = cat(1, cm, [1, 1, 0]);
            case 2
                cm = cat(1, cm, [0, 1, 0]);
        end
    end

    figure(plot_num)
    set(gcf,'position',([50,50,750,900]),'color','w')
    surf(x, y, stop_light_map{jdx}, 'edgecolor', 'none');
    colormap(cm)
    hold on
    box on
    grid on

    for idx=1:num_RX
        scatter3(RX(idx, 1), RX(idx, 2), zb_plot, 30, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
        text(RX(idx, 1)+100, RX(idx, 2), zb_plot, num2str(idx,'%01d'),"Color",'w','FontSize',11,'FontWeight','bold');

        % plot the ellipse
        if idx == jdx
            plot3(r1_ellipse(1,:) + RX(idx, 1), r1_ellipse(2,:) + RX(idx, 2), zb_plot*ones(1,segments), '--', 'Color', 'k', 'LineWidth', line_width)
        else
            plot3(r1_ellipse(1,:) + RX(idx, 1), r1_ellipse(2,:) + RX(idx, 2), zb_plot*ones(1,segments), '--', 'Color', 'w', 'LineWidth', line_width)
        end
    end    

    for idx=1:num_TX
        scatter3(TX(idx, 1), TX(idx, 2), zb_plot, 30, '^', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
    end
     
    set(gca,'fontweight','bold','FontSize', 13);
    
    xlim([x_range_min, x_range_max]);
    ylim([y_range_min, y_range_max]);
    
    xticks(x_range_min:500:x_range_max);
    xtickangle(45);
    yticks(y_range_min:500:y_range_max);

    xlabel('Distance (yds)', 'fontweight','bold','FontSize', 13);
    ylabel('Distance (yds)', 'fontweight','bold','FontSize', 13);

    z_name = num2str(floor(z_max),'%04d');
    ch_name = num2str(num_channels,'%02d');
    title(strcat('Stop Light Chart:', 32, z_name, 32, 'ft, Channels:', 32, ch_name), 'fontweight','bold','FontSize', 14);
    
    view(0,90);
    
    ax = gca;
    ax.Layer = 'top';
    ax.Position = [0.11, 0.09, 0.87, 0.87];

    print(plot_num, '-dpng', fullfile(save_path, strcat('slc_',scenario,'_',z_name,'ft_',ch_name,'ch_', num2str(jdx,'%02d'),'.png')));
    
    plot_num = plot_num + 1;

end

