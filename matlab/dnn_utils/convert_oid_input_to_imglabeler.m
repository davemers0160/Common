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
startpath = 'D:\Projects\';
file_filter = {'*.txt','Text Files'; '*.csv','CSV Files'; '*.*','All Files' };

[input_file, input_path] = uigetfile(file_filter, 'Select Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% check to see if the inputs are normal or grouped

% [param_type, file_index] = file_params_dialog;
% 
% switch param_type
%     case 'Normal'
         params = parse_input_parameters(fullfile(input_path, input_file));
% 
%     case 'Grouped'
%         params = parse_grouped_input_paramters(fullfile(input_path, input_file), {'{', '}'});
%         
%     case 'Cancel'
%         return;
% end

% get the directory for the data
data_directory = params{1}{1};
params(1) = [];

%% run through the entries and build a groundTruth object
%image_files = cell(numel(params),1);
%box = cell(numel(params),1);
%label = cell(numel(params),1);
image_files = {};
box = {};
label = {};
ul = {};


% read in the first image
% do this because the oid labeling scheme is one box per image, so if there
% where multiple objects in an image then there will be multiple lines for
% a single image
idx = 1;
image_id = params{idx}{1};
img_file = strcat(data_directory, image_id,'.jpg');

% label
l = {};
l = cat(1, l, params{idx}{3});

% box dimensions (left, top, right, bottom)
left = str2double(params{idx}{5});
right = str2double(params{idx}{6});
top = str2double(params{idx}{7});
bot = str2double(params{idx}{8});

img = imread(img_file);
[h,w,~] = size(img);

b = [];
b = cat(1,b,[floor(left*w), floor(top*h), ceil((right-left)*w), ceil((bot-top)*h) ]);

image_files{end+1,1} = img_file;



idx = idx + 1;


%while(idx <= numel(params))

for idx=2:numel(params)
    
    
    image_id = params{idx}{1};
    img_file = strcat(data_directory, image_id,'.jpg');
    
    if(strcmp(img_file, image_files{end,1}))
        
        % read in the image
        img = imread(img_file);
        [h,w,~] = size(img);
        
        % label
        l = cat(1, l, params{idx}{3});
    
        % box dimensions (left, top, right, bottom)
        left = str2double(params{idx}{5});
        right = str2double(params{idx}{6});
        top = str2double(params{idx}{7});
        bot = str2double(params{idx}{8});
        
        b = cat(1,b,[floor(left*w), floor(top*h), ceil((right-left)*w), ceil((bot-top)*h) ]);
  
    else
        % save the previous boxes
        box{end+1} = b;
        label{end+1} = l;     
        
        % read in the image
        img = imread(img_file);
        [h,w,~] = size(img);
                
        % label
        l = {};
        l = cat(1, l, params{idx}{3});
        
        % box dimensions (left, top, right, bottom)
        left = str2double(params{idx}{5});
        right = str2double(params{idx}{6});
        top = str2double(params{idx}{7});
        bot = str2double(params{idx}{8});
        
        b = [];
        b = cat(1,b,[floor(left*w), floor(top*h), ceil((right-left)*w), ceil((bot-top)*h) ]);
        
        image_files{end+1,1} = img_file;
    end
    
    
    ul = cat(1, ul, unique(l));
end

% save the previous boxes
box{end+1} = b;
label{end+1} = l;  


% get the unique labels
% lb = label(:);
% lb = lb(~cellfun('isempty',lb));
label_names = unique(ul);
num_classes = numel(label_names);
%label_names = cat(1,'imageFileName',ul);

%% create the table

C = cell(numel(image_files), numel(label_names));
for idx=1:numel(image_files)
    
    %C{idx,1} = image_files{idx};
    
    for jdx=1:size(box{idx},1)
        
        index = find(contains(label_names, label{idx}{jdx}));
        C{idx, index} = cat(1,C{idx, index}, box{idx}(jdx,:));
        
    end
    
end

T = cell2table(C);
T.Properties.VariableNames = label_names';

if(verLessThan('matlab','9.6'))
    label_types = [];
    for idx=1:numel(label_names)
        label_types = [label_types; labelType('Rectangle')];
    end

    label_description = table(label_names,label_types,'VariableNames',{'Name','Type'});
else
    ldc = labelDefinitionCreator();
    for idx=1:num_classes
        addLabel(ldc, label_names{idx}, labelType.Rectangle);
    end
    label_description = create(ldc);
end

% label_type = labelType(repmat({'Rectangle'}, num_classes, 1));
% description = repmat({''}, num_classes, 1);
% label_description = table(label_names, label_type, description);

gtSource = groundTruthDataSource(image_files);
gt = groundTruth(gtSource, label_description, T);

%% get the stats

for idx=1:size(gt.LabelDefinitions, 1)
    label = gt.LabelDefinitions.Name(idx);
    fprintf('Label Name: %s\n', label{1});
    get_bb_stats(gt.LabelData, idx);
    fprintf('\n');
end

%% start the imagelabeler app
imageLabeler;
