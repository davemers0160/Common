format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% get the location of the data
data_path = uigetdir(startpath, 'Select directory where the IQ files are stored');

if(data_path == 0)
    return;
end

%% loop through the directory and read in each file

file_type = '*.sc16';
data_type = 'int16';
byte_order = 'ieee-le';

% get the listing of the folder
listing = get_listing(data_path, file_type);

iq_data = [];
fprintf('scanning...\n');
for idx=1:numel(listing)
    
    fprintf('%s\n', fullfile(listing(idx).folder, listing(idx).name));
    
    [~, iqc_in] = read_binary_iq_data(fullfile(listing(idx).folder, listing(idx).name), data_type, byte_order);
    
    iq_data = cat(1, iq_data, iqc_in);
end

%% Plot the data
figure(plot_num)
plot(real(iq_data),'b')
hold on
plot(imag(iq_data),'r')
plot_num = plot_num + 1;
drawnow;

%% save the stitched file

file_filter = {'*.sc16','SC16 Files'; '*.*','All Files'};

[save_file, save_path] = uiputfile(file_filter, 'Enter the IQ File Name', data_path);
if(save_path == 0)
    return;
end

write_binary_iq_data(fullfile(save_path, save_file), iq_data, data_type, byte_order)

fprintf('Complete!\n');
