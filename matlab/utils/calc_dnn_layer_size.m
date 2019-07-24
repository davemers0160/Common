format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%%




%%
% img_width = 6*9;
% img_height = 18*3;
img_width = 4:1:640;
img_height = 4:1:640;

% filter_nr, filter_nc, stride_y, stride_x 
%conv_params = [[2,2,2,2];[2,2,2,2]];
%conv_params = [[3,3,3,3];[3,2,3,2];[2,1,2,1]]; % current dfd_dnn_rw downsampling scheme
%conv_params = [[3,3,2,3];[2,2,2,2];[2,1,2,1];[2,1,2,1]];   %works, but not reciprical back up
%conv_params = [[2,3,2,3];[4,2,2,2];[4,2,2,2];[4,2,2,2]];
%conv_params = [[3,3,3,3];[3,2,3,2];[2,1,2,1];[2,2,2,2]]; % current dfd_dnn_rw downsampling scheme
%conv_params = [[3,2,3,2];[2,1,2,1];[2,2,2,2];[2,2,2,2]]; % current dfd_dnn_rw downsampling scheme
%conv_params = [[3,2,3,2];[2,1,2,1];[2,2,2,2]]; % current dfd_dnn_rw downsampling scheme
%conv_params = [[5,5,3,3];[5,2,3,2];[3,1,2,1];[2,2,2,2]]; 
%conv_params = [[11,6,1,1];[4,6,1,1];[3,3,1,1]];
%conv_params = [[18,6,18,6]];
%conv_params = [[5,5,2,3];[3,3,2,2];[2,2,2,2];[2,2,2,2]];
%conv_params = [[4,4,2,2];[4,4,2,2]];    % new dfd_net with 4x4 downsamplers - v21
%conv_params = [[6,6,2,2];[6,6,2,2]];    % new dfd_net with 6x6 downsamplers - v22
%conv_params = [[8,8,2,2];[8,8,2,2]];    % new dfd_net with 8x8 downsamplers - v24
%conv_params = [[3,3,2,2];[3,3,2,2]];    % new dfd_net with 3x3 downsamplers - v25
%conv_params = [[1,1,2,2];[1,1,2,2]];    % new dfd_net with 1x1 downsamplers - v26
%conv_params = [[5,5,2,2];[5,5,2,2]];    % new dfd_net with 3x3 downsamplers - v27
conv_params = [[7,7,2,3];[2,2,2,2];[2,2,2,2];[2,2,2,2];[2,2,2,2]];      % ~resnet101~

cont_params = [];
%cont_params = [[2,2,2,2]];
%cont_params = [[2,2,2,2];[2,2,2,2]];
%cont_params = [[2,2,2,2];[2,2,2,2];[2,2,2,2]];
%cont_params = [[4,4,2,2];[4,4,2,2]];    % new dfd_net with 4x4 downsamplers
%cont_params = [[6,6,2,2];[6,6,2,2]];    % new dfd_net with 6x6 downsamplers - v22
%cont_params = [[8,8,2,2];[8,8,2,2]];    % new dfd_net with 8x8 downsamplers - v24
%cont_params = [[3,3,2,2];[3,3,2,2]];    % new dfd_net with 3x3 downsamplers - v25
%cont_params = [[1,1,2,2];[1,1,2,2]];    % new dfd_net with 1x1 downsamplers - v26
%cont_params = [[5,5,2,2];[5,5,2,2]];    % new dfd_net with 3x3 downsamplers - v27

fprintf('\n-------------------------------------------------\n');
nri = [];
nci = [];
nri(1,:) = img_height;
nci(1,:) = img_width;

for idx=1:size(conv_params,1)
    [nri(idx+1,:),nci(idx+1,:)] = get_conv_output_size(nri(idx,:), nci(idx,:), conv_params(idx,1), conv_params(idx,2), conv_params(idx,3), conv_params(idx,4));
end

jdx=1;
for idx=size(conv_params,1)+1:size(conv_params,1)+size(cont_params,1)
    [nri(idx+1,:),nci(idx+1,:)] = get_cont_output_size(nri(idx,:), nci(idx,:), cont_params(jdx,1), cont_params(jdx,2), cont_params(jdx,3), cont_params(jdx,4));   
    jdx = jdx + 1;
end


%% Plot the results

color_str = {'.-g','.-b','.-r','.-c','.-m','.-y', '.-k', '.-g','.-b','.-r'};

figure(plot_num)
hold on
for idx=1:size(nri,1)
    plot(img_height, nri(idx,:), color_str{idx})
end
%plot(img_width,img_width,'.-k')

title('rows')
plot_num = plot_num + 1;

figure(plot_num)
hold on

for idx=1:size(nci,1)
    plot(img_width, nci(idx,:), color_str{idx})
end
% plot(img_width,img_width,'.-k')

title('cols')
plot_num = plot_num + 1;

%%
% img_width = 1:1:180;
% img_height = 1:1:180;
% 
% filter_nr = 2;
% filter_nc = 2;
% stride_y = 2;
% stride_x = 2;
% 
% fprintf('\n-------------------------------------------------\n');
% 
% fprintf('Level 0: Image Size: %d x %d\n', img_width(64), img_height(64));
% 
% %get_conv_output_size(height, width, filter_nr, filter_nc, stride_y, stride_x, padding_y, padding_x)
% [nr1,nc1] = get_conv_output_size(img_height, img_width, filter_nr, filter_nc, stride_y, stride_x);
% 
% fprintf('Level 1: Image Size: %d x %d\n', nc1(64), nr1(64));
% 
% [nr2,nc2] = get_conv_output_size(nr1, nc1, filter_nr, filter_nc, stride_y, stride_x);
% fprintf('Level 2: Image Size: %d x %d\n', nc2(64), nr2(64));
% 
% [nr3,nc3] = get_conv_output_size(nr2, nc2, filter_nr, filter_nc, stride_y, stride_x);
% fprintf('Level 3: Image Size: %d x %d\n', nc3(64), nr3(64));
% 
% filter_nr = 2;
% filter_nc = 2;
% [nr4,nc4] = get_cont_output_size(nr3, nc3, filter_nr, filter_nc, stride_y, stride_x, 0, 0);
% fprintf('Level 4: Image Size: %d x %d\n', nc4(64), nr4(64));
% 
% [nr5,nc5] = get_cont_output_size(nr4, nc4, filter_nr, filter_nc, stride_y, stride_x, 0, 0);
% fprintf('Level 5: Image Size: %d x %d\n', nc5(64), nr5(64));
% 
% [nr6,nc6] = get_cont_output_size(nr5, nc5, filter_nr, filter_nc, stride_y, stride_x, 0, 0);
% fprintf('Level 6: Image Size: %d x %d\n', nc6(64), nr6(64));
% 
% fprintf('-------------------------------------------------\n');
% 
% 
% %% Plot the results
% figure(plot_num)
% hold on
% plot(img_width,nr1,'.-g')
% plot(img_width,nr5,'og')
% 
% plot(img_width,nr2,'.-b')
% plot(img_width,nr4,'ob')
% 
% plot(img_width,img_width,'.-r')
% plot(img_width,nr6,'or')
% 
% plot(img_width,nr3,'.-k')
% 
% plot_num = plot_num + 1;
% 
% %%
% 
% figure(plot_num)
% hold on
% plot(nr1,img_width,'.-g')
% plot(nr5,img_width,'og')
% 
% plot(nr2,img_width,'.-b')
% plot(nr4,img_width,'ob')
% 
% plot(img_width,img_width,'.-r')
% plot(nr6,img_width,'or')
% 
% plot_num = plot_num + 1;

