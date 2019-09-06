format long g
format compact
clc
close all
%clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% convert the ground truth table 
data = Data2Train.Variables;

label_names = Data2Train.Properties.VariableNames;

%% parse through the ground truth object detection table labels
data_directory = 'D:/Projects/yellow_jacket/data/capture1/';

num_images = size(data,1);
num_classes = size(data,2);

cm = rand(num_classes,3);

for idx=1:num_images
    
    fprintf('%s\n', data{idx,1});
    [startpath,  filename, ext] = fileparts(data{idx,1});
    % read in the image
    img = imread(strcat(data_directory,filename,ext));
    [im_r, im_c] = size(img);
    nm = [im_c, im_r, im_c, im_r];
    
    figure(plot_num)
%     hold on
        
    % cycle through the classes
    for jdx=2:num_classes
        
        if(~isempty(data{idx,jdx}))
            
            num_boxes = size(data{idx,jdx},1);
            
            for kdx = 1:num_boxes

                img = insertObjectAnnotation(img,'rectangle',data{idx,jdx}(kdx,:), label_names{jdx}, 'Color',floor(255*cm(jdx,:)), 'TextBoxOpacity',0.9,'FontSize',9, 'TextColor','black');
               
            end           
        end        
    end
    
    imshow(img);
    
    %keyboard;
    pause(0.2);
    %plot_num = plot_num + 1;
      
end

