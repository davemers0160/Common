format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

pause(0.5);

%%
prompt = {'Sample Rate:', 'Pulse Width:','PRI:', 'Amplitude:', 'Number of Pulses:'};
dlgtitle = 'Input';
fieldsize = [1 30; 1 30; 1 30; 1 30; 1 30];
definput = {'20e6','1e-6', '2e-6', '2024', '3'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

sample_rate = str2double(res{1});

pulse_width = str2double(res{2});

pri = str2double(res{3});

amplitude = str2double(res{4});

num_pulses = str2double(res{5});

%% 

% number of samples for each pulse
samples_per_pulse =  floor(pulse_width * sample_rate);

iq = complex(amplitude*ones(samples_per_pulse,1), zeros(samples_per_pulse,1));

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);

% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

% concatentate pulses
iq = repmat(iq, num_pulses, 1);

x = (0:numel(iq)-1) * (1/sample_rate);

% plot the base signal 
% figure(plot_num)
% set(gcf,'position',([50,50,1400,500]),'color','w')
% grid on
% box on 
% plot(x, real(iq), 'b');
% hold on
% plot(x, imag(iq), 'r');
% 
% set(gca,'fontweight','bold','FontSize',11);
% 
% xlabel('time (s)', 'fontweight','bold');
% ylabel('amplitude', 'fontweight','bold');
% 
% plot_num  = plot_num + 1;
% 
% 
% figure(plot_num)
% set(gcf,'position',([50,50,1400,500]),'color','w')
% grid on
% box on 
% scatter(real(iq), imag(iq), 20, 'o', 'b', 'filled');
% 
% 
% set(gca,'fontweight','bold','FontSize',11);
% 
% xlabel('I', 'fontweight','bold');
% ylabel('Q', 'fontweight','bold');
% 
% plot_num  = plot_num + 1;

%%
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq), imag(iq), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq), imag(iq), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;

figure(plot_num)
spectrogram(iq, 32, 16, 32, sample_rate, 'centered')
plot_num  = plot_num + 1;

%% save data

data_type = 'int16';

byte_order = 'ieee-le';

file_filter = {'*.sc16','SC16 Files (*.sc16)';
 '*.sc32','SC32 Files (*.sc32)';
 '*.*',  'All Files (*.*)'};

[filename, filepath] = uiputfile(file_filter,'File Selection');

if(filepath == 0)
    return;
end

data = complex(int16(real(iq)), int16(imag(iq)));

write_binary_iq_data(fullfile(filepath,filename), data, data_type, byte_order);
