plot_num = 1;

ld_file = 'D:\IUPUI\Test_Data\rw\Lab2\lidar\lidar_rng_00000_xcrop.bin';

[data] = read_binary_lidar_data(ld_file);

data_sr = imresize(data,[size(data,1)*18,size(data,2)*6],'nearest');

figure(plot_num)
set(gcf,'position',([100,100,1200,400]),'color','w')
image(data_sr);
%colormap(jet(max_data));
colormap(jet(11000));
axis off
plot_num = plot_num + 1;


%%
im_file_l = 'D:\IUPUI\Test_Data\real_world_raw\Lab2\left\exp_40\image_134_40.00_15356234_20180921_075333.png';
im_file_r = 'D:\IUPUI\Test_Data\real_world_raw\Lab2\right\exp_40\image_133_40.00_16024674_20180921_075332.png';

img_l = imread(im_file_l);
img_r = imread(im_file_r);

img_l2 = img_l(8:8+1007,2:2+1259,:);
img_r2 = img_r(8:8+1007,2:2+1259,:);

figure();image(img_r); axis off
figure();image(img_l); axis off


%%



l_crop_h = [106:106+1007];
l_crop_w = [210:210+1259];
r_crop_h = [106:106+1007];
r_crop_w = [330:330+1259];

ld_l = data_sr(l_crop_h,l_crop_w);
ld_r = data_sr(r_crop_h,r_crop_w);

RGB = depthOverlay(img_l2(300:700,20:end-20,:), 12000-ld_l(300:700,20:end-20));
title('depth overlay');

figure();
imshowpair(img_l2,ld_l);








