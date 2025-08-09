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

%% get the number of repeat bursts
dlgtitle = 'Input';
prompt = {'Number of Bursts:'};
fieldsize = [1 30];
definput = {'1'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

num_busrts = str2double(res{1});

iq_data_n = repmat(iq_data, num_busrts, 1);

%% pad data

% answer = questdlg('Pad Data',' ', 'Yes','No','No');
% 
% pad_multiple = 1024*4;
% 
% switch answer
%     case 'Yes'
%         pad = ceil(numel(iq_data_n)/pad_multiple);
%         pad_n = (pad*pad_multiple) - numel(iq_data_n);
%         iq_pad = cat(1, iq_data_n, zeros(pad_n,1));
%         fprintf("adding samples: %d\n", pad_n);
%     case 'No'
%         % do nothing
         iq_pad = iq_data_n;
% end
% 
% fprintf("\n");
% fprintf("max real: %f\n", max(real(iq_pad)));
% fprintf("min real: %f\n", min(real(iq_pad)));
% fprintf("max imag: %f\n", max(imag(iq_pad)));
% fprintf("min imag: %f\n", min(imag(iq_pad)));
% fprintf("\n");

%% Plot the data
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
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

write_binary_iq_data(fullfile(save_path, save_file), iq_pad, data_type, byte_order)

fprintf('Complete!\n');
