% format long g
% format compact
% clc
% close all
% clearvars
% 
% % get the location of the script file to save figures
% full_path = mfilename('fullpath');
% [startpath,  filename, ext] = fileparts(full_path);
% plot_num = 1;
% 
% % this will only work with log files v2.0 or greater
% 
% %%  get the log file
% file_filter = {'*.txt','Text Files';'*.*','All Files' };
% 
% startpath = 'D:\IUPUI\Test_Data\';
% [log_file, log_path] = uigetfile(file_filter, 'Select Camera Capture Log File', startpath);
% if(log_path == 0)
%     return;
% end
% 
% commandwindow;

%% 
function [params] = parse_cam_capture_logs(input_file)

    % open the file
    file_id = fopen(input_file,'r');

    index = 1;
    params = {};
    while ~feof(file_id)

        temp_line = fgetl(file_id);
        if(~isempty(temp_line))
            if((temp_line(1) ~= '%') && (temp_line(1) ~= '#'))
                params{index,1} = parse_line(temp_line, '');
                index = index + 1;
            end
        end


    end

    fclose(file_id);

end
