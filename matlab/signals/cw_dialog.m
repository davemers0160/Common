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
prompt = {'Sample Rate:', 'Pulse Width:', 'PRI:', 'Freq Offset:', 'Amplitude:', 'Number of Pulses:', 'Filter Cutoff Frequency:', 'Number of Taps:'};
dlgtitle = 'Input';
fieldsize = [1 30; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30; 1 30]; 
definput = {'20e6','1e-6', '2e-6', '0', '2047', '2', '10e6', '5'};

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

fprintf("----------------------------------------------------------\n");
fprintf("sample_rate: %d\n", sample_rate)
fprintf("pulse_width: %11.9f\n", pulse_width)
fprintf("pri: %11.9f\n", pri)
fprintf("fr: %d\n", fr)
fprintf("amplitude: %d\n", amplitude)
fprintf("num_pulses: %d\n", num_pulses)
fprintf("fc: %d\n", fc)
fprintf("num_taps: %d\n", num_taps)
fprintf("----------------------------------------------------------\n\n");


%% 

% number of samples for each pulse
samples_per_pulse =  floor(pulse_width * sample_rate);
fr = fr/sample_rate;

fprintf("samples_per_pulse: %d\n", samples_per_pulse)

iq = complex(ones(samples_per_pulse,1), 1e-6*ones(samples_per_pulse,1));
% iq = complex(amplitude*ones(samples_per_pulse,1), amplitude*ones(samples_per_pulse,1));

% get the number of samples in the pri
samples_per_pri = floor(pri * sample_rate);
fprintf("samples_per_pri: %d\n", samples_per_pri)

buffer_samples = max(0, samples_per_pri-samples_per_pulse);

% add the buffer on to the end
iq = cat(1,iq, complex(zeros(buffer_samples,1), zeros(buffer_samples,1)));

f_rot = exp(2*pi*1j*fr*(0:1:numel(iq)-1)).';
iq = iq .* f_rot;

% concatentate pulses
iq = repmat(iq, num_pulses, 1);

%% filter

if(num_taps > 0)
    w = blackman_nuttall_window(num_taps);
    lpf = create_fir_filter(fc/sample_rate, w);
    
    iq_p = cat(1, zeros(ceil(num_taps/2)+1,1), iq);
    
    iq_filt = conv(iq_p, lpf(end:-1:1), 'same');

    filt_fft = fft(lpf)/num_taps;
    
    f = linspace(-sample_rate/2, sample_rate/2, num_taps);
    figure(plot_num)
    set(gcf,'position',([50,50,1400,500]),'color','w')
    grid on
    box on
    plot(f/1e6, 20*log10(abs(fftshift(filt_fft))), 'b')
    
    xlabel('Frequency (MHz)', 'fontweight','bold');
    ylabel('amplitude', 'fontweight','bold');
    plot_num  = plot_num + 1;

else
    iq_filt = iq;
end

x = (0:numel(iq_filt)-1) * (1/sample_rate);

iq_scale = max(abs(real(iq_filt)));

iq_filt = (amplitude/iq_scale)*iq_filt;
% iq_filt = amplitude*iq_filt;

%% FFT
Y = fft(iq_filt)/numel(iq_filt);
% Y2 = fft(iq_p)/numel(iq_p);

f = linspace(-sample_rate/2, sample_rate/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
hold on
% plot(f, 20*log10(abs(fftshift(Y2))), 'g');
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1;


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
% plot(x, real(iq_filt2), 'g');
% plot(x, imag(iq_filt2), 'c');

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
spectrogram(iq_filt, 512, floor(0.75*512), 512, sample_rate, 'centered')
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

data = complex(int16(real(iq_pad)), int16(imag(iq_pad)));

fprintf("filename: %s\n", fullfile(filepath,filename))

write_binary_iq_data(fullfile(filepath,filename), data, data_type, byte_order);
