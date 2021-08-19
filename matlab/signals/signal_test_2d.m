format long g
format compact
clc
close all
clearvars
global startpath

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%% load in an image and the desisered object to find

img = im2double(rgb2gray(imread('E:\data\circuit_board\circuit_board.png')));

hole = im2double(rgb2gray(imread('E:\data\circuit_board\circuit_board_hole.png')));


%% show the images
figure(plot_num)
imagesc(img);
colormap(gray(256));
plot_num = plot_num + 1;

figure(plot_num)
imagesc(hole);
colormap(gray(256));
plot_num = plot_num + 1;

%% run the correlations

img_map = conv2(img, hole(end:-1:1, end:-1:1));


%% display the results
figure(plot_num)
surf(img_map);
shading('flat');
view(0, 90);
colormap(gray(256));
plot_num = plot_num + 1;

colormap(jet(256))

%%

hole_sum = sum(hole(:).*hole(:))*0.9;

img_map(img_map < hole_sum) = 0;


figure(plot_num)
surf(img_map);
shading('flat');
view(0, 90);
colormap(gray(256));
plot_num = plot_num + 1;

colormap(jet(256))