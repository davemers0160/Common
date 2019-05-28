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
%start_path = 'D:\Projects\machineLearningResearch\gorgon_captures';
start_path = 'D:\IUPUI\PhD\Results\dfd_dnn\dnn_reduction\';

file_filter = {'*.xml','XML Files';'*.*','All Files' };
[filename, filepath] = uigetfile(file_filter, 'Select XML file', start_path);

if(filepath==0)
    return;
end

save_path = filepath;

commandwindow;

%%

fprintf('file name: %s\n',filename);

[gorgon_data, gorgon_struct] = read_gorgon_data(fullfile(filepath, filename));

fprintf('\nGorgon Data Capture:\n');
fprintf('  Layer:      %03d\n', gorgon_struct.layer);
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
    fprintf('max x(%d,:): %2.4f\n', idx, max(x(idx,:)));
end


mean_x = mean(x(:));
std_x = std(x(:));

min_x = min(x(:));
max_x = max(x(:));

%min_x = mean_x - 3*std_x;
%max_x = mean_x + 3*std_x;

fprintf('\nmin: %3.4f, max: %3.4f\n\n', min_x, max_x);

% get sub plot sizes
s_x = ceil(sqrt(gorgon_struct.k)*1.2);
s_y = ceil(gorgon_struct.k/s_x);

%% plot all of the outputs in one plot

if(false)
    
    %c = colormap(jet(numel(gorgon_data)));
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

            %image(255*(t(:,:,idx)-min_x)/(max_x-min_x));
            imagesc(t(:,:,idx));
            colormap(jet(5000));
            axis off
            title(strcat(num2str(idx,'%03d')));
        end
    end

    drawnow;
    plot_num = plot_num + 1;

end

%% plot all of the outputs

color_select = 2;

if(color_select == 1)
    cm = colormap(gray(256));
    color_name = 'gry';
else
    cm = colormap(jet(256));
    color_name = 'jet';
end

%index = [70, 84, 108];
%index = [69, 83, 107];

index = 1:numel(gorgon_data);

for idx=1:numel(index)
%     figure(plot_num)
%     set(gcf,'position',([100,100,1200,650]),'color','w', 'Name', 'Filter Output')
%     hold on
%     grid on
%     box on
    
    if(lt==1)       % ploting the outputs of the fully connected layers
        scatter(idx,t(:,:,idx), 15, 'b', 'filled');
        
    else            % ploting the outputs of the filters in raster row order

%         image(255*(t(:,:,index(idx))-min_x)/(max_x-min_x));
%         %imagesc(t(end:-1:1,:,index(idx)));
%         colormap(cm);
%         axis off
%         title(strcat(num2str(index(idx),'%03d')));
        
        tmp1 = t(:,:,index(idx));
        tmp2 = (t(:,:,index(idx))-min_x)/(max_x-min_x);
        tmp3 = floor(256*(t(:,:,index(idx))-min_x)/(max_x-min_x));
        
        
        img3 = 255*ind2rgb(tmp3, cm);        %cat(3, tmp_img, tmp_img, tmp_img);

        imshow(uint8(img3));
        axis off;
        
        save_file = strcat('filter_ouput_', color_name, '_L', num2str(gorgon_struct.layer, '%03d'), '_N', num2str(index(idx), '%03d'), '.png');   
        imwrite(tmp3, cm, fullfile(save_path, save_file));

    end
    
%     drawnow;
%     plot_num = plot_num + 1;
    
end

% figure(plot_num);
% set(gcf,'position',([100,100,1200,650]),'color','w')
% 
% %imshow(uint8(tmp3));
% colormap(cm);
% cb = colorbar('fontweight','bold','FontSize', 13, 'Location', 'eastoutside');
% %[cb.Ticks , cb.TickLabels] = calc_limits(0, nmae_plt_max, plt_step, '%1.2f');
% % cb.Label.String = '# of Pixels Chosen';
% cb.Ticks = [0:0.1:1];
% cb.TickLabels = num2str((255*cb.Ticks)','%1.1f');
% cb.Limits = [0 ceil(max_x-min_x)];

%print(plot_num, '-dpng', fullfile(save_path,strcat('colorbar.png')));

%% yet another way of looking at it


color_select = 1;

if(color_select == 1)
    cm = colormap(gray(256));
    color_name = 'gry';
else
    cm = colormap(jet(256));
    color_name = 'jet';
end

%index = [70, 84, 108];
index = 1:numel(gorgon_data);

for idx=1:numel(index)
    figure(plot_num)
    set(gcf,'position',([100,100,800,600]),'color','w')
    hold on
    grid on
    box on
    
    if(lt==1)       % ploting the outputs of the fully connected layers
        scatter(idx,t(:,:,idx), 15, 'b', 'filled');
        
    else            % ploting the outputs of the filters in raster row order

        tmp1 = t(:,:,index(idx));
        tmp2 = (t(:,:,index(idx))-min_x)/(max_x-min_x);
        tmp3 = floor(255*(t(:,:,index(idx))-min_x)/(max_x-min_x));

        image(tmp3);
        colormap(cm);
        
        xlim([1 size(tmp3,2)]);
        ylim([1 size(tmp3,1)]);
        
        axis off;
        
        
        ax = gca;
        ax.YDir = 'reverse';
        ax.Position = [0 0 0.88 1];
        
        cb = colorbar('fontweight','bold','FontSize', 13, 'Location', 'eastoutside');

        cb.Ticks = [0:25.5:255];
        cb.TickLabels = num2str(((max_x-min_x)*(cb.Ticks/255)+min_x)','%1.2f');
        cb.Limits = [0 255];
        
        cb.Position = [0.9 0.025 0.03 0.95];

        
        save_file = strcat('filter_ouput_', color_name, '_L', num2str(gorgon_struct.layer, '%03d'), '_N', num2str(index(idx), '%03d'), '.png');   
%         imwrite(tmp3, cm, fullfile(save_path, save_file));
        
        print(plot_num, '-dpng', fullfile(save_path, save_file));

    end
    
    close(plot_num);
    plot_num = plot_num + 1;
    
end
