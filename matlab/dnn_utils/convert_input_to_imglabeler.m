format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% get the data file
startpath = 'D:\Projects\object_detection_data';
file_filter = {'*.txt','Text Files';'*.*','All Files' };

[input_filename, file_path] = uigetfile(file_filter, 'Select Input File', startpath);
if(file_path == 0)
    return;
end

%% read the file

[params] = parse_input_parameters(fullfile(file_path, input_filename));

data_directory = params{1}{1}; 
params(1) = [];


%% run through the entries and build a groundTruth object
imageFiles = cell(numel(params),1);
box = cell(numel(params),1);
T = table;

for idx=1:numel(params)
    imageFiles{idx,1} = strcat(data_directory,params{idx}{1});
    
    for jdx=3:5:numel(params{idx})
        box{idx,1} = [str2double(params{idx}{jdx}), str2double(params{idx}{jdx+1}), str2double(params{idx}{jdx+2}), str2double(params{idx}{jdx+3})];
        %label = params{idx}{jdx+4};
    end
end

T.biplane = box;

Name = {'biplane'};
Type = labelType({'Rectangle'});
Description = {''};
labelDescription = table(Name,Type,Description);

gtSource = groundTruthDataSource(imageFiles);

gt = groundTruth(gtSource,labelDescription,T);

return;
%% run this after using the image labeler to get the new labels


for idx=1:numel(gTruth.LabelData)
   
    new_boxes(idx,:) = gTruth.LabelData.biplane{idx};
    
   
end