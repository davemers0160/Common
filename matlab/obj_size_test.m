format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% set up some variables

pix_size = 1.4e-6;              % from the camera specs
object_size = 2.390775/pi;      % c = pi*d
f_num = 1.7;                    % from the camera specs

%% get the folder

start_path = 'c:\Projects\';
training_data = uigetdir(start_path, 'Select Data Folder');

if(training_data==0)
    return;
end

commandwindow;

%% go through the image and load them

img = {};

listing = dir(training_data);
listing = listing(3:end);

img_count = numel(listing);

for idx=1:img_count

    if(listing(idx).isdir)
        continue;
    end
    img_file = fullfile(listing(idx).folder, listing(idx).name);

    tmp = imread(img_file);
    img{end+1} = rot90(tmp, -1);
    
end

%% img{1} 117, 1847

% A/A_p = B/B_p

A_p = (1847-117)*pix_size;
A = 1;

B = 1;

B_p = B*(A_p/A)


%% img{2} 466, 1496
% img{3} 612, 1349
% img{10} 892, 1122

B_p = 0.002422;

A_p = (1122-892)*pix_size;

A = 1;

B = B_p*(A/A_p)

%% try to find the limits


A_p = pix_size:pix_size:20*pix_size;

b_p = 0.002422;

A = 1;

B = B_p*(A./A_p);








