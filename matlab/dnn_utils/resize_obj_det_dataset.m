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

%% select a save location

%save_path = 'D:\Projects\';
save_path = uigetdir(input_path, 'Select Save Location');
if(save_path == 0)
    return;
end

commandwindow;

%% load in the data from the file

params = parse_grouped_input_paramters(fullfile(input_path, input_file), {'{', '}'});

gt_det_data = struct('file_name','', 'bbox',[], 'label','');

% get the directory for the data
data_directory = params{1}{1};
params(1) = [];

gt_det_data = repmat(gt_det_data, length(params),1);

for idx=1:length(params)    

    gt_det_data(idx).file_name = params{idx}{1};

    for jdx=2:numel(params{idx})

        tmp_box = parse_line(params{idx}{jdx}, ',');
        gt_det_data(idx).bbox(end+1,:) = [ str2double(tmp_box{1}), str2double(tmp_box{2}), str2double(tmp_box{3}), str2double(tmp_box{4}) ];
        gt_det_data(idx).label{end+1,1} = tmp_box{5};

    end

end

%% parse through the data struct and resize the image and then write the file
% get the new image scale
answer = inputdlg({'Enter Image Scale:', 'Enter Image Folder Name'}, 'Image Scale Dialog', [1 20; 1 40], {'0.25', 'quarter'});

if(isempty(answer))
    return;
end

scale = str2double(answer{1});
scale_folder_name = answer{2};

save_path2 = strcat(save_path,'/',scale_folder_name,'/');
save_path2 = strrep(save_path2, '\', '/');
fprintf('Creating directory: %s\n', save_path2);

warning('off');
mkdir(save_path2);
warning('on');

[~, ip_name, ip_ext] = fileparts(input_file);

save_file_name = strcat(ip_name,'_',scale_folder_name, ip_ext);
file_id = fopen(fullfile(save_path, save_file_name),'w');

% write the basic info to the input file
fprintf(file_id, '# Data Directory: \n');
fprintf(file_id, '%s\n\n', save_path2);
fprintf(file_id, '# file location, {x,y,w,h,label}, {x,y,w,h,label}, ...\n');  

fprintf('\nimages to parse: %05d\n', numel(gt_det_data));

for idx=1:numel(gt_det_data)
    
    % get the image
    fprintf('parsing image[%05d]: %s\n', idx, gt_det_data(idx).file_name);
    s_line = strcat(gt_det_data(idx).file_name, ',');
    img = imread(fullfile(data_directory, gt_det_data(idx).file_name));
    
    [img_path, ~, ~] = fileparts(gt_det_data(idx).file_name);
    
    warning('off');
    mkdir(strcat(save_path2, img_path));
    warning('on');
    
    % get the reduction factor for the height and width
    [img_h, img_w, ~] = size(img);
    image_size = floor([img_h*scale, img_w*scale]);
    
    % resize the image
    img2 = imresize(img, image_size, 'lanczos3', 'Antialiasing', true);
      
    % resize the bounding boxes
    for jdx=1:numel(gt_det_data(idx).label)
        
        tmp_box = [floor(gt_det_data(idx).bbox(jdx,1)*scale), floor(gt_det_data(idx).bbox(jdx,2)*scale), min(ceil(gt_det_data(idx).bbox(jdx,3)*scale),image_size(2)) , min(ceil(gt_det_data(idx).bbox(jdx,4)*scale),image_size(1))];       
        s_line = strcat(s_line, num2str(tmp_box, '{%d,%d,%d,%d,'), gt_det_data(idx).label{jdx,1}, '},');
           
    end    
    s_line = s_line(1:end-1);
       
    % save the image
    imwrite(img2, fullfile(save_path2, gt_det_data(idx).file_name));
    
    % write the info to the input file
    fprintf(file_id, '%s\n', s_line);
      
end

fprintf('Complete!\n');

% close the file
fclose(file_id);





