format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);
%mkdir(strcat(scriptpath,'\Images'));
plot_num = 1;

%% get the filename and read in the data

file_filter = {'*.xml','XML Files';'*.*','All Files' };
[filename, filepath] = uigetfile(file_filter, 'Select XML file', scriptpath);

if(filepath==0)
    return;
end


[gorgon_data, gorgon_struct] = read_gorgon_data(fullfile(filepath, filename));

fprintf('\nGorgon Data Capture:\n');
fprintf('  Layer:      %03d\n',gorgon_struct.layer);
fprintf('  N:         %04d\n', gorgon_struct.n);
fprintf('  K:         %04d\n', gorgon_struct.k);
fprintf('  NR:        %04d\n', gorgon_struct.nr);
fprintf('  NC:        %04d\n', gorgon_struct.nc);
fprintf('\n');

%figure out the layer type based on the number of rows and columns
if(gorgon_struct.nr==1 && gorgon_struct.nc==1)
    lt = 1;
else
    lt = 2;
end

%% vectorize the results to perform various operations
for idx=1:numel(gorgon_data)
    x(idx,:) = gorgon_data{idx}.data(:);   
    t(:,:,idx) = gorgon_data{idx}.data;
end

min_x = min(x(:));
max_x = max(x(:));

fprintf('min: %3.4f, max: %3.4f\n\n', min_x, max_x);

% get sub plot sizes
s_x = ceil(sqrt(gorgon_struct.k)*1.2);
s_y = ceil(gorgon_struct.k/s_x);

%% plot all of the outputs

c = colormap(jet(numel(gorgon_data)));
figure(plot_num)
set(gcf,'position',([100,100,1200,650]),'color','w', 'Name', 'Filter Output')
hold on
grid on
box on
for idx=1:numel(gorgon_data)

    if(lt==1)       % ploting the outputs of the fully connected layers
        scatter(idx,t(:,:,idx), 15, 'b', 'filled');
    else            % ploting the outputs of the filters in raster row order

        subplot(s_y,s_x,idx);

        image(255*(t(:,:,idx)-min_x)/(max_x-min_x));
        colormap(jet(256));
        axis off
        title(strcat(num2str(idx,'%03d')));
    end
end

drawnow;
plot_num = plot_num + 1;
