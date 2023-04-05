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

x_range_max = 10000;
x_range_step = 20;
x_range_min = 0;

y_range_max = 4000;
y_range_step = 20;
y_range_min = -4000;

x_range = x_range_min:x_range_step:x_range_max;
y_range = y_range_min:y_range_step:y_range_max;


[x, y, z] = meshgrid(x_range, y_range, 5000);

%%

range_map = sqrt(x.*x + y.*y + z.*z);

loss_map1 = -(20*log10(range_map) + 20*log10(frequency) - 27.55);


%%
x_range2 = x_range - 4000;
y_range2 = y_range_min:y_range_step:y_range_max;


[x2, y2, z2] = meshgrid(x_range2, y_range2, 1);

%%

range_map2 = sqrt(x2.*x2 + y2.*y2 + z2.*z2);

loss_map2 = -(20*log10(range_map2) + 20*log10(frequency) - 27.55);

%%

loss_map = loss_map1 - loss_map2;

figure(plot_num)

surf(x_range, y_range, loss_map, 'edgecolor', 'none');

colormap(jet(256))
colorbar
