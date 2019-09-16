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

save_path = 'D:\Projects\';
save_path = uigetdir(save_path, 'Select Save Location');
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

[~, ip_name, ip_ext] = fileparts(input_file);

save_file_name = strcat(ip_name,'_resize', ip_ext);
file_id = fopen(fullfile(save_path, save_file_name),'w');

% new image size [height, width]
image_size = [360, 640];    % [270, 480]  [360, 640]  [540, 960]

% write the basic info to the input file
fprintf(file_id, '# Full data listing for the real world dataset\n# Data Directory: \n');
fprintf(file_id, '%s/\n', strrep(save_path,'\','/'));
fprintf(file_id, '# Data: \n');  

fprintf('\nimages to parse: %05d\n', numel(gt_det_data));

for idx=1:numel(gt_det_data)
    
    % get the image
    fprintf('parsing image[%05d]: %s\n', idx, gt_det_data(idx).file_name);
    s_line = strcat(gt_det_data(idx).file_name, ',');
    img = imread(fullfile(data_directory, gt_det_data(idx).file_name));
    
    % get the reduction factor for the height and width
    [img_h, img_w, ~] = size(img);
    scale_y = img_h/image_size(1);
    scale_x = img_w/image_size(2);
    
    % resize the image
    img2 = imresize(img, image_size, 'lanczos3', 'Antialiasing', true);
      
    % resize the bounding boxes
    for jdx=1:numel(gt_det_data(idx).label)
        
        tmp_box = [floor(gt_det_data(idx).bbox(jdx,1)/scale_x), floor(gt_det_data(idx).bbox(jdx,2)/scale_y), min(ceil(gt_det_data(idx).bbox(jdx,3)/scale_x),image_size(2)) , min(ceil(gt_det_data(idx).bbox(jdx,4)/scale_y),image_size(1))];       
        s_line = strcat(s_line, num2str(tmp_box, '{%d,%d,%d,%d,'), gt_det_data(idx).label{jdx,1}, '},');
           
    end    
    s_line = s_line(1:end-1);
       
    % save the image
    imwrite(img2, fullfile(save_path, gt_det_data(idx).file_name));
    
    % write the info to the input file
    fprintf(file_id, '%s\n', s_line);
      
end

fprintf('Complete!\n');

% close the file
fclose(file_id);





