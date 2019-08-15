format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get the user input to the lidar scan
%file_filter = {'*.png','PNG Files'; '*.tif','TIF Files'; '*.*','All Files' };
file_filter = {'*.txt','Text Files';'*.*','All Files' };


startpath = 'D:\IUPUI\Test_Data\';
[log_file, log_path] = uigetfile(file_filter, 'Select Image File', startpath);
if(log_path == 0)
    return;
end

commandwindow;
%%

[params] = parse_cam_capture_logs(fullfile(log_path, log_file));

img_files = {params{25:end}};
img_files = img_files';

%% read in the image and crop 

r = 20;
c = 20;

distname = 'Normal';
    
for idx=1:numel(img_files)
    
    [~,  filename, ~] = fileparts(img_files{idx}{1});
    fprintf('%s, ', filename);
    
    img = double(rgb2gray(imread(img_files{idx}{1})));
    
    img_size = size(img);
    h = floor(img_size(1)/2 - r/2):1:floor(img_size(1)/2 + r/2)-1;
    w = floor(img_size(2)/2 - c/2):1:floor(img_size(2)/2 + c/2)-1;

    img_s = img(h, w);
    img_s = img_s(:);

    hist_bins = [0:1:256];
    h1 = histcounts(img_s, hist_bins);
    h2 = h1/(r*c);
    
    % fit the distribution
    pd = fitdist(img_s, distname);
    
    fprintf('%2.4f, %2.4f\n', pd.mu, pd.sigma);
    %disp(pd);

end


%% plot the histogram

% y = pdf(pd, hist_bins(1:end-1));
% 
% figure(plot_num)
% set(gcf,'position',([50,50,1200,700]),'color','w');
% hold on
% grid on
% box on
% 
% b1 = bar(hist_bins(1:end-1), h2, 'b');
% 
% p1 = plot(hist_bins(1:end-1), y, 'LineStyle', '-', 'Color', 'r', 'LineWidth', 1);
% 
% plot_num = plot_num + 1;

%%

return

distributionFitter