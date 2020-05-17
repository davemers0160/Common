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
file_filter = {'*.txt','Text Files';'*.*','All Files' };

[input_file, input_path] = uigetfile(file_filter, 'Select Input File', startpath);
if(input_path == 0)
    return;
end

commandwindow;

%% check to see if the inputs are normal or grouped

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
file_index = file_index + 1;

%% run through the entries and build a groundTruth object
image_files = cell(numel(params),1);
box = cell(numel(params),1);
label = cell(numel(params),1);
ul = {};

for idx=1:numel(params)
    image_files{idx,1} = strcat(data_directory,params{idx}{1});
    
    index = 1;
    b = [];
    l = {};
    for jdx=file_index:numel(params{idx})
        gp = parse_csv_line(params{idx}{jdx});
%         box{idx,index} = [str2double(gp{1}), str2double(gp{2}), str2double(gp{3}), str2double(gp{4})];
        b = cat(1,b,[str2double(gp{1}), str2double(gp{2}), str2double(gp{3}), str2double(gp{4})]);
%         label{idx,index} = gp{5};
        l = cat(1, l, gp{5});
%         index = index + 1;
    end
    
    box{idx} = b;
    label{idx} = l;
    
    ul = cat(1, ul, unique(l));
end

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
