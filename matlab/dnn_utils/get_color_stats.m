format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;


%% select the data file with the images

file_filter = {'*.txt','Text Files';'*.*','All Files' };
startpath = 'D:\Projects\';

[input_file, input_path] = uigetfile(file_filter, 'Select Data Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% check to see if the inputs are normal or grouped

% Construct a questdlg with three options
%file_choice = questdlg('Select Input File Type:', 'File Type', 'Normal', 'Grouped', 'Cancel', 'Normal');

[param_type, file_index] = file_params_dialog;

switch param_type
    case 'Normal'
        params = parse_input_parameters(fullfile(input_path, input_file));

    case 'Grouped'
        params = parse_grouped_input_paramters(fullfile(input_path, input_file), {'{', '}'});
        
    case 'Cancel'
        return;
end

% get the directory for the data
data_directory = params{1}{1};
params(1) = [];

%% parse through the data
num_images = length(params);
hist_bins = 256;

red = 0;
green = 0;
blue = 0;
gray = 0;

r_hist = zeros(1, hist_bins);
g_hist = zeros(1, hist_bins);
b_hist = zeros(1, hist_bins);
gr_hist = zeros(1, hist_bins);

for idx=1:num_images    

    % this is expected to be a 3-channel color image
    img = imread(fullfile(data_directory, params{idx}{file_index}));
%     img = img(:,:,1:3);
    img_size = size(img,1) * size(img,2);

    if(size(img,3) == 1)
        r = mean(mean(img));
        g = mean(mean(img));
        b = mean(mean(img));
        gr = mean(mean(img));
        
    else
        gr_img = rgb2gray(img);
        r = mean(mean(img(:,:,1)));
        g = mean(mean(img(:,:,2)));
        b = mean(mean(img(:,:,3)));
        gr = mean(mean(gr_img));
        
        r_hist = r_hist + (histcounts(img(:,:,1), hist_bins)/img_size);
        g_hist = g_hist + (histcounts(img(:,:,2), hist_bins)/img_size);
        b_hist = b_hist + (histcounts(img(:,:,3), hist_bins)/img_size);
        gr_hist = gr_hist + (histcounts(gr_img, hist_bins)/img_size);
        
    end
    
    red = red + r;
    green = green + g; 
    blue = blue + b;
    gray = gray + gr;
    
    fprintf('%05d: %s - %3.4f, %3.4f, %3.4f\n', idx, params{idx}{file_index}, r, g, b);

end

red = red/num_images;
green = green/num_images;
blue = blue/num_images;
gray = gray/num_images;

r_hist = r_hist/num_images;
g_hist = g_hist/num_images;
b_hist = b_hist/num_images;
gr_hist = gr_hist/num_images;

fprintf('red:   %3.4f\n', red);
fprintf('green: %3.4f\n', green);
fprintf('blue:  %3.4f\n', blue);
fprintf('gray:  %3.4f\n', gray);

fprintf('%8.4f, %8.4f, %8.4f, %8.4f\n', red, green, blue, gray);

%% calculate the histograms CDF

gr_cdf = zeros(1, hist_bins);

for idx=1:hist_bins    
    gr_cdf(1,idx) = sum(gr_hist(1,1:idx));
    fprintf('%d, ', floor(gr_cdf(1,idx)*(hist_bins-1)));
end

fprintf('\n');





