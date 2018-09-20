format long g
format compact
clc
%close all
%clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ~] = fileparts(full_path);
plot_num = 1;

%% get the location for the data
file_filter = {'*.mp4','Video Files';'*.*','All Files' };
startpath = 'D:\Projects\MATAS\data\training';
[data_file, data_path] = uigetfile(file_filter, 'Select Video File', startpath);

if(data_path == 0)
    return;
end

video_file = fullfile(data_path,data_file);

%% instantiate a version of the network 
net_type = 2;           % pick which one 

switch net_type
    % resnet18
    case 1
        net_name = '_resnet18';
        net = resnet18();
        layer_index = 69;
    case 2
        net_name = '_resnet50';
        net = resnet50();
        layer_index = 174;        
end

sz = net.Layers(1).InputSize;

%% start processing the video

v = VideoReader(video_file);

index = 1;
while hasFrame(v)
    vf = readFrame(v);
    vidFrame(:,:,:,index) = imresize(vf,[sz(1) sz(2)]);
    index = index + 1;
end
data = single(activations(net, vidFrame, net.Layers(layer_index).Name, 'MiniBatchSize', 128, 'OutputAs', 'columns', 'ExecutionEnvironment', 'gpu'));
index = index - 1;

%% plot the video and the resulting conversion



fig = figure;
set(gcf,'position',([50,500,1100,250]),'color','w')

for idx=2:index
    subplot(1,2,1)
    image(vidFrame(:,:,:,idx))
    axis off
    ax = gca;
    ax.Position = [0.02 0.05 0.4 0.9];

    %data2(idx,:) = data(idx,:);
    subplot(1,2,2)
    surf(data(:,1:idx))
    xlim([1 size(data,2)])
    ylim([1 size(data,1)])
    zlim([0 max(data(:))])
    colormap(jet(2000))
    box on
    xlabel('Frame #', 'fontweight','bold')
    ylabel('Feature', 'fontweight','bold')
    shading interp
    view(-45,70)
    ax = gca;
    ax.Position = [0.55 0.08 0.4 0.85];
    
    %pause(1)
    drawnow;
    frame = getframe(fig);
    im{idx-1} = frame2im(frame);   
end

%% run teh saved data to get an animated gif

filename = 'd:\projects\matas\boxing50_3.gif';
delay = 0.1*ones(index-1,1);

create_animated_gif(filename, delay, im, 0)















            