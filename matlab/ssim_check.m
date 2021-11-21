format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);
plot_count = 1;
line_width = 1.0;

commandwindow;

%% setup parameters

b_w = 32;
b_h = 32;

img_w = 1024;
img_h = 1024;

ch = 1;

cm = colormap(jet(100));

%% run through the combos

cb = create_chekerboard(b_h, b_w, img_h+2*b_h, img_w+2*b_w, ch);

% create the baseline image
base_img = uint8(cb(1:img_h, 1:img_w, :));

ssim_val = zeros(2*b_h, 2*b_w);

for y_off=0:1:(2*b_h-1)
    pt = zeros(1, 2*b_w);
    parfor x_off=0:1:(2*b_w-1)
        
        off_img = uint8(cb((1:img_h)+y_off, (1:img_w)+x_off, :));
        pt(1, x_off+1) = ssim(off_img, base_img);
        
    end
    ssim_val(y_off+1, :) = pt;
end

%% plot the results

figure(plot_count)
set(gcf,'position',([50,50,1400,700]),'color','w')
box on
grid on
hold on

b1 = bar3(ssim_val);
% s1 = surf(ssim_val);


for k = 1:length(b1)
    zdata = b1(k).ZData;
    b1(k).CData = zdata;
    b1(k).FaceColor = 'interp';
end

% for i = 1:2*b_h
%     zdata = ones(6*2*b_h,4);
%     k = 1;
%     for j = 0:6:(6*2*b_h-6)
%       zdata(j+1:j+6,:) = Z(k,i);
%       k = k+1;
%     end
%     set(b1(i),'Cdata',zdata)
% end
colormap(jet(100));

set(gca,'fontweight','bold','FontSize',12);

xlim([0, 2*b_w+1]);
xlabel('X Offset', 'fontweight','bold','FontSize',12);
ylim([0, 2*b_w+1]);
ylabel('Y Offset', 'fontweight','bold','FontSize',12);

zlabel('SSIM Value', 'fontweight','bold','FontSize',12);

view(-25, 25);
