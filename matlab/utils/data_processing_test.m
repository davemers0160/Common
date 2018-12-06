format long g
format compact
clc
close all
clearvars

plot_num = 1;

%% get the mat file with the lidar data
file_filter = {'*.mat';'*.*'};
data_path = 'D:\Common\matlab\lidar';
[lidar_file, data_path] = uigetfile(file_filter, 'Select LIDAR data file', data_path);
if(data_path == 0)
    return;
end

load(fullfile(data_path,lidar_file));

%%

data_directory = 'D:\IUPUI\Test_Data\real_world\';

ld_file = 'Lab2\lidar\lidar_rng_00000_20180921_075338.bin';
%ld_file = 'Library3\lidar\lidar_rng_00000_20180919_081532.bin';

[data] = read_binary_lidar_data(fullfile(data_directory,ld_file));
[lx, ly, lz] = convert_lidar_to_xyz(lidar_struct, data);

l_xyz(:,:,1) = lx;
l_xyz(:,:,2) = ly;
l_xyz(:,:,3) = lz;

%data_sr = imresize(data,[size(data,1)*18,size(data,2)*6],'nearest');

% figure()
% set(gcf,'position',([100,100,1200,400]),'color','w')
% image(data_sr);
% %colormap(jet(max_data));
% colormap(jet(11000));
% axis off
% plot_num = plot_num + 1;


%%

im_file_l = 'Lab2\left\exp_40\image_134_40.00_15356234_20180921_075333.png';
im_file_r = 'Lab2\right\exp_40\image_133_40.00_16024674_20180921_075332.png';

%im_file_l = 'Library3/left/exp_40/image_136_40.00_15356234_20180919_081526.png';
%im_file_r = 'Library3/right/exp_40/image_134_40.00_16024674_20180919_081528.png';

img_l = imread(fullfile(data_directory,im_file_l));
img_r = imread(fullfile(data_directory,im_file_r));
img_r = imrotate(img_r,-0.5);
figure();image(img_l); axis off
figure();image(img_r); axis off

im_w = 900;
im_h = 720;

% left crop numbers
x_l_off = 10;
y_l_off = 0;
x_l = floor(size(img_l,2)/2 - im_w/2) + x_l_off;
y_l = floor(size(img_l,1)/2 - im_h/2) + y_l_off;
crop_w_l = [x_l:x_l+im_w-1];
crop_h_l = [y_l:y_l+im_h-1];

% right crop numbers
x_r_off = 10;
y_r_off = -10;
x_r = floor(size(img_l,2)/2 - im_w/2) + x_r_off;
y_r = floor(size(img_l,1)/2 - im_h/2) + y_r_off;
crop_w_r = [x_r:x_r+im_w-1];
crop_h_r = [y_r:y_r+im_h-1];

% crop the images
img_l = img_l(crop_h_l, crop_w_l, :);
img_r = img_r(crop_h_r, crop_w_r, :);

figure();image(img_l); axis off
figure();image(img_r); axis off


%% Lidar cropping parameters

cr_w = floor(im_w/6)-1;
cr_h = floor(im_h/18)-1;

max_data = (floor(max(lx(:))/1000) + 1)*1000;

% left crop numbers
% x_l_off = 10;
% y_l_off = 0;
x_l = 944;
y_l = 16;
ld_crop_w_l = [x_l:x_l+cr_w-1];
ld_crop_h_l = [y_l:y_l+cr_h-1];

% right crop numbers
% x_r_off = 10;
% y_r_off = 0;
x_r = 957;
y_r = 15;
ld_crop_w_r = [x_r:x_r+cr_w-1];
ld_crop_h_r = [y_r:y_r+cr_h-1];

% crop the lidar data
ld_l = lx(ld_crop_h_l,ld_crop_w_l);
ld_r = lx(ld_crop_h_r,ld_crop_w_r);

ptCloud = pointCloud(l_xyz(ld_crop_h_l,ld_crop_w_l,:));

%figure(); pcshow(ptCloud,'MarkerSize',10);
figure(); image(ld_l); colormap(jet(max_data)); axis off;
figure(); image(ld_r); colormap(jet(max_data)); axis off;

%%  


imgl_g = rgb2gray(img_r);
ld_sr=imresize(ld_r,size(imgl_g));

ld_sr = floor((ld_sr-min(ld_sr(:)))*255/(max(ld_sr(:)) - min(ld_sr(:))));
figure(); image(cat(3,ld_sr,imgl_g,imgl_g)); axis off;



%%
% l_crop_h = [106:106+1007];
% l_crop_w = [210:210+1259];
% r_crop_h = [106:106+1007];
% r_crop_w = [330:330+1259];
% 
% ld_l = data_sr(l_crop_h,l_crop_w);
% ld_r = data_sr(r_crop_h,r_crop_w);
% 
% RGB = depthOverlay(img_l2(300:700,20:end-20,:), 12000-ld_l(300:700,20:end-20));
% title('depth overlay');
% 
% figure();
% imshowpair(img_l2,ld_l);








