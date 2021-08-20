format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%% load in an image and the desisered object to find

% start_path = 'E:\data';
start_path = 'C:\Projects\data';

img = imread(strcat(start_path, '\circuit_board\circuit_board.png'));

hole = imread(strcat(start_path, '\circuit_board\circuit_board_hole.png'));


%% show the images
figure(plot_num)
image(img);
axis off
plot_num = plot_num + 1;

figure(plot_num)
image(hole);
axis off
plot_num = plot_num + 1;


%% convert to grayscale for the main work to be done
img = im2double(rgb2gray(img));
hole = im2double(rgb2gray(hole));

%% show the images
figure(plot_num)
imagesc(img);
colormap(gray(256));
axis off
plot_num = plot_num + 1;

figure(plot_num)
imagesc(hole);
colormap(gray(256));
axis off
plot_num = plot_num + 1;

%% run the correlations

img_map = conv2(img, hole(end:-1:1, end:-1:1));


%% display the results
figure(plot_num)
set(gcf,'position',([50,50,1000,500]),'color','k')

surf(img_map);
shading('flat');

xlim([0, size(img_map,2)]);
ylim([0, size(img_map,1)]);
ylim([0, size(img_map,1)]);

axis off
view(0, 90);

colormap(jet(256));
plot_num = plot_num + 1;

%% clip the image to remove some of the clutter
img_map_clip = img_map;
hole_sum = sum(hole(:).*hole(:))*0.9;

img_map_clip(img_map_clip < hole_sum) = -1;

figure(plot_num)
set(gcf,'position',([50,50,1000,500]),'color','k')

surf(img_map_clip);
shading('flat');

xlim([0, size(img_map,2)]);
ylim([0, size(img_map,1)]);
zlim([1, hole_sum * 2]);

axis off
view(0, 90);
colormap(jet(256));
plot_num = plot_num + 1;

