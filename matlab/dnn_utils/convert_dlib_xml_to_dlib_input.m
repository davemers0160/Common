format long g
format compact
clc
close all
clearvars

%% get the input file

file_filter = {'*.xml','XML Data File';'*.*','All Files' };

data_path = 'D:\Projects';
[gt_file, gt_path] = uigetfile(file_filter, 'Select XML Ground Truth File', data_path, 'MultiSelect', 'off');
if(gt_path == 0)
    return;
end

commandwindow;

%% read in the xml file

data = xml2struct(fullfile(gt_path, gt_file));

images = data.dataset.images.image;

folder = 'mod_orange';

%% run through each image
for idx=1:numel(images)
    
    img = images{1,idx};
    % get the filename
    filename = img.Attributes.file;
    
    % get the bounding boxes
    if(isfield(img,'box'))
        boxes = images{1,idx}.box;

        box_str = '';

        if(iscell(boxes))
            for jdx = 1:numel(boxes)
                b = boxes{jdx}.Attributes;
                box_str = strcat(box_str, 32, '{', b.left, ',', b.top, ',', b.width, ',', b.height,',face},');
            end

        else
            b = boxes.Attributes;
            box_str = strcat(box_str, 32, '{', b.left, ',', b.top, ',', b.width, ',', b.height,',face},');        
        end

        if(~isempty(box_str))
            box_str = box_str(1:end-1);
        end

        fprintf('%s/%s,%s\n', folder, filename, box_str);
    else
        fprintf('%s/%s\n', folder, filename);
    end
end

