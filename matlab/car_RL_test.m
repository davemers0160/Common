format long g
format compact
clc
close all
clearvars

%% select the variables

f.x = 70;
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


map = zeros(100,100);
map(:,30) = 200;
map(30,[1:40, 60:end]) = 200;
map(60,1:60) = 200;
[map_height,map_width] = size(map);

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
%% extra functions

%fucntion [ranges, bearing] = get_ranges(map, f, b, laser_angles, max_range)


