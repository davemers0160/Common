format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

% pause(0.5);

%%
prompt = {'Sample Rate:', 'Pulse Width:','PRI:', 'Freq Offset:', 'Amplitude:', 'Number of Pulses:', 'Filter Cutoff Frequency:', 'Number of Taps:'};
dlgtitle = 'Input';
fieldsize = [1 30; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30]; 
definput = {'20e6','1e-6', '2e-6', '0', '2047', '2', '1e6', '3'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

sample_rate = str2double(res{1});

pulse_width = str2double(res{2});

pri = str2double(res{3});

fr = str2double(res{4});

amplitude = str2double(res{5});

num_pulses = str2double(res{6});

fc = str2double(res{7});

num_taps = str2double(res{8});


%% 

% number of samples for each pulse
samples_per_pulse =  floor(pulse_width * sample_rate);
fr = fr/sample_rate;

iq = complex(amplitude*ones(samples_per_pulse,1), amplitude*ones(samples_per_pulse,1));

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);

buffer_samples = max(0, samples_per_pri-samples_per_pulse);

% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

f_rot = exp(2*pi*1j*fr*(0:1:numel(iq)-1)).';
iq = iq .* f_rot;

% concatentate pulses
iq = repmat(iq, num_pulses, 1);

%% filter

w = blackman_nuttall_window(num_taps);
lpf = create_fir_filter(fc/sample_rate, w);

iq_p = cat(1, zeros(ceil(num_taps/2)+1,1), iq);

iq_filt = conv(iq_p, lpf(end:-1:1), 'same');

x = (0:numel(iq_filt)-1) * (1/sample_rate);


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
% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
grid on
box on 
plot(x, real(iq_filt), 'b');
hold on
plot(x, imag(iq_filt), 'r');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');

plot_num  = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(x, real(iq_filt), imag(iq_filt), 20, 'o', 'b', 'filled');
hold on
plot3(x, real(iq_filt), imag(iq_filt), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num  = plot_num + 1;

figure(plot_num)
spectrogram(iq, 128, 120, 128, sample_rate, 'centered')
plot_num  = plot_num + 1;

%% save data

answer = questdlg('Pad Data',' ', 'Yes','No','No');


pad_multiple = 1024*4;

switch answer
    case 'Yes'
        pad = ceil(numel(iq_filt)/pad_multiple);
        pad_n = (pad*pad_multiple) - numel(iq_filt);
        iq_pad = cat(1, iq_filt, zeros(pad_n,1));
    case 'No'
        % do nothing
        iq_pad = iq_filt;
end

data_type = 'int16';

byte_order = 'ieee-le';

file_filter = {'*.sc16','SC16 Files (*.sc16)';
 '*.sc32','SC32 Files (*.sc32)';
 '*.*',  'All Files (*.*)'};

[filename, filepath] = uiputfile(file_filter,'File Selection');

if(filepath == 0)
    return;
end

data = complex(int16(real(iq_pad)), int16(imag(iq_pad)));

write_binary_iq_data(fullfile(filepath,filename), data, data_type, byte_order);
