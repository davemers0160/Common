format long g
format compact
clc
close all
clearvars

%% select the variables

f.x = 10;
f.y = 20;

b.x = f.x+5*cos(45*pi()/180);
b.y = f.y+5*sin(45*pi()/180);

threshold = 100;
max_range = 40;

%laser_angles = [-135:10:135]*pi()/180;
laser_angles = [135:-22.5:-135]*pi()/180;
%laser_angles = [0]*pi()/180;

detection_range = zeros(1, numel(laser_angles));

commandwindow;

%% run some things

map_name = 'D:\Projects\Play_Ground\test_map.png';

map = imread(map_name);



% map = zeros(100,100);
% map(:,30) = 200;
% map(30,[1:40, 60:end]) = 200;
% map(60,1:60) = 200;
[map_height,map_width, map_ch] = size(map);

if(map_ch > 1)
    map = map(:,:,1);
end

%% cycle through many bearings
figure(1)

for a=0:5:360

b.x = f.x+5*cos(a*pi()/180);
b.y = f.y+5*sin(a*pi()/180);
%[ranges, bearing] = get_ranges(map, f, b, laser_angles, max_range);
bearing = atan2(f.y - b.y, f.x - b.x);
% if(bearing < 0)
%     bearing = bearing + 2*pi();
% end

% fprintf('bearing: %3.6f\n',bearing*180/pi());

for idx=1:numel(laser_angles)

    detection_range(idx) = max_range;

    for r=1:max_range

        x = floor(r*cos(bearing + laser_angles(idx)) + f.x);
        y = floor(r*sin(bearing + laser_angles(idx)) + f.y);
        
        if(x<1 || x>map_width)
            detection_range(idx) = r;
            break;            
        end
        
        if(y<1 || y>map_height)
            detection_range(idx) = r;
            break; 
        end
        
%         x = min(max(x,1), map_width);
%         y = min(max(y,1), map_height);

        if(map(y,x) > threshold)

            detection_range(idx) = r;
            break;
        end

    end

end
    
    
%% plot the results

surf(map)
colormap(gray(256))
shading interp
view(0,90);
hold on
grid on
box on
scatter([b.x], [b.y], 10, 'b', 'filled');
scatter([f.x], [f.y], 10, 'g', 'filled');
plot([b.x, f.x], [b.y, f.y],'b');

for idx=1:numel(laser_angles)
    quiver(f.x, f.y, detection_range(idx)*cos(bearing+laser_angles(idx)), detection_range(idx)*sin(bearing+laser_angles(idx)));
end

xlim([1,map_width+10])
ylim([1,map_height+10])
pause(0.1)
hold off
end

return
%% extra functions

%fucntion [ranges, bearing] = get_ranges(map, f, b, laser_angles, max_range)
d = cat(4, detection_range, detection_range, detection_range);
m = [1,0,0]; %1,0,0];
m = cat(4, m', m');
m = categorical([1:3]');

layers = [ ...
    %imageInputLayer([28 28 1], 'Name','Input')
    imageInputLayer([1 13], 'Name','Input', 'Normalization', 'None', 'DataAugmentation', 'None')
%     sequenceInputLayer(1,'Name','seq1')
    fullyConnectedLayer(10, 'Name','FC 1')
    reluLayer('Name','ReLU 1')
    fullyConnectedLayer(3, 'Name','FC 2')
    softmaxLayer('Name','Softmax')
    classificationLayer('Name','classOutput')]
    %regressionLayer('Name','routput') ]
    
layers(2,1).Weights = randn(layers(2,1).OutputSize, prod(layers(1,1).InputSize))*.0001;   
layers(2,1).Bias = randn(layers(2,1).OutputSize,1)*.0001;    

layers(4,1).Weights = randn(layers(4,1).OutputSize, prod(layers(2,1).OutputSize))*.0001;   
layers(4,1).Bias = randn(layers(4,1).OutputSize,1)*.0001;

% layers(6,1).ClassNames = {'0','1','2','3','4','5','6','7','8','9'}

n = SeriesNetwork(layers);
lgraph = layerGraph(layers);
figure
plot(lgraph)

options = trainingOptions('sgdm',...
'MaxEpochs',1,...
'Shuffle','every-epoch',...
'ValidationFrequency',20,...
'Verbose',false,...
'Plots','training-progress');


net = trainNetwork(d,m,lgraph,options);

y = predict(net, detection_range)
y = classify(n, detection_range)

X = XTrain(:,:,1,1);
y = predict(n, XTrain)

features = activations(net,detection_range,'FC 2')


net.Layers(2,1).Weights = randn(net.Layers(2,1).OutputSize, prod(net.Layers(1,1).InputSize))*.0001;   
net.Layers(2,1).Bias = randn(net.Layers(2,1).OutputSize,1)*.0001; 

net.Layers(4,1).Weights = randn(net.Layers(4,1).OutputSize, prod(net.Layers(2,1).OutputSize))*.0001;   
net.Layers(4,1).Bias = randn(net.Layers(4,1).OutputSize,1)*.0001;



