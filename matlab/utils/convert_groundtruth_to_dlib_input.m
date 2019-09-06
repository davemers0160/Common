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
data = gTruth.Variables;

label_names = gTruth.Properties.VariableNames;



% Scell = data(:,1);
% Schar = char(Scell(:));
% all_rows_same = all(diff(Schar,1,1),1);
% common_cols = find(all_rows_same, 1, 'first');
% if isempty(common_cols)
%   common_to_use = '?'
% else
%   common_to_use = Scell{1}(1:common_cols);
% end


%% parse through the ground truth object detection table labels

% write the data in the following format:
% file location, {x,y,w,h,label}, {x,y,w,h,label},...

num_images = size(data,1);
num_labels = size(data,2);

for idx=1:num_images
    
    % print out the image file name
    s_line = strcat(data{idx,1}, ',');
    
    % print out the boxes
    for jdx=2:num_labels
        
        if(~isempty(data{idx,jdx}))
            
            num_boxes = size(data{idx,jdx},1);
            
            for kdx = 1:num_boxes         
                s_line = strcat(s_line, num2str(data{idx,jdx}(kdx,:), '{%d,%d,%d,%d,'), label_names{jdx}, '},');
                %fprintf('{%d,%d,%d,%d,%s}, ', data{idx,jdx}(kdx,:), label_names{jdx});                
            end           
        end        
    end
    
    s_line = s_line(1:end-1);
    
    fprintf('%s\n',s_line);
    
    
    
end


