format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% load in data
file_filter = {'*.sc16;*.fc32;*.iq;*.sigmf-data','IQ Files';'*.*','All Files' };

[data_file, data_filepath] = uigetfile(file_filter, 'Select File', startpath, 'MultiSelect', 'on');
if(data_filepath == 0)
    return;
end

[~,  fn, ext] = fileparts(data_file);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
elseif(strcmp(ext,'.sc16') == 1)
    scale = 1/2048;
    data_type = 'int16';
elseif(strcmp(ext,'.sigmf-data') == 1)
    scale = 1/2048;
    data_type = 'int16';
elseif(strcmp(ext,'.iq') == 1)
    scale = 1/2048;
    data_type = 'int16';
else
    return;
end

byte_order = 'ieee-le';

fprintf('file: %s\n\n', fullfile(data_filepath, data_file));

%%

[~, iqc_in] = read_binary_iq_data(fullfile(data_filepath, data_file), data_type, byte_order);

%% get sample rate
dlgtitle = 'Input';
prompt = {'Sample Rate:', 'Down Samples Rate:', 'num taps:'};
fieldsize = [1 30; 1 30; 1 30];
definput = {'10e6', '1', '1'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

fs_o = str2double(res{1});
ds_rate = str2double(res{2});
num_taps = str2double(res{3});


% t = 0:1/fs_o:(numel(iqc_in)-1)/fs_o;

%%
% iqc = iqc()
fprintf('max real: %f\n', max(real(iqc_in)));
fprintf('min real: %f\n', min(real(iqc_in)));

fprintf('max imag: %f\n', max(imag(iqc_in)));
fprintf('min imag: %f\n', min(imag(iqc_in)));

max_v = max([max(real(iqc_in)), max(imag(iqc_in)), abs(min(real(iqc_in))), abs(min(imag(iqc_in)))]);
fprintf('overal max: %f\n\n', max_v);

fprintf('file length: %d\n', numel(iqc_in));
fprintf('file time: %2.14f\n', numel(iqc_in)/fs_o);

iqc_o = scale * iqc_in;
% tmt = timetable(seconds(t.'), iqc_o);

%% filter and downsample

w = hamming(num_taps);
fc = 0.2e6/fs_o;
lpf = create_fir_filter(fc, w);

iqc_f = conv(iqc_o, lpf(end:-1:1),'same');

iqc = iqc_f(1:ds_rate:end);
fs = fs_o/ds_rate;

t = 0:1/fs:(numel(iqc)-1)/fs;

%%
iq(:,1) = real(iqc);
iq(:,2) = imag(iqc);

ph = atan2(imag(iqc),real(iqc))/pi;
ph = angle(iqc);

%% FFT
Y = fft(iqc)/numel(iqc);
f = linspace(-fs/2, fs/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f*1e-6, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (MHz)', 'fontweight','bold');
ylabel('amplitude', 'fontweight','bold');
plot_num = plot_num + 1;

%%
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(t, real(iqc),'b')
hold on
box on
grid on
plot(t, imag(iqc),'r')
xlabel('Time (s)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
ylim([-1.2, 1.2]);

plot_num = plot_num + 1;
drawnow;

%%
[s, f, ts] = spectrogram(iqc, 512, 256, 512, fs, 'centered');

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, max(-110, 20*log10(abs(s))), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);

view(90,-90);
colormap(jet(100));
plot_num = plot_num + 1;
drawnow;

%%
figure(plot_num)
set(gcf,'position',([50,50,800,500]),'color','w')
scatter(iq(:,1),iq(:,2),'o','filled', 'b')
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([-1.2, 1.2]);
ylim([-1.2, 1.2]);

xlabel('I', 'fontweight','bold','FontSize',12);
ylabel('Q', 'fontweight','bold','FontSize',12);

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
plot_num = plot_num + 1;

%% filtered

% step = 1;
% num_taps = 5;
% w = hamming(num_taps);
% fc = 0.2e6/fs;
% lpf = create_fir_filter(fc, w);
% 
% iqc_f = conv(iqc, lpf(end:-1:1),'same');
% 
% [s, f, ts] = spectrogram(iqc_f(1:step:end), 512, 480, 512, fs/step, 'centered');
% 
% figure(plot_num)
% set(gcf,'position',([50,50,1000,800]),'color','w')
% surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
% colormap(jet(100));
% 
% grid on
% box on
% 
% set(gca,'fontweight','bold','FontSize',12);
% 
% xlabel('Time (s)', 'fontweight','bold','FontSize',12);
% ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);
% 
% view(90,-90);
% plot_num = plot_num + 1;
% drawnow;
% 
% 
% figure(plot_num)
% plot(t(1:step:end), real(iqc_f(1:step:end)),'b')
% hold on
% plot(t(1:step:end), imag(iqc_f(1:step:end)),'r')
% plot_num = plot_num + 1;
% drawnow;

%%
% const_diag = comm.ConstellationDiagram;
% 
% step = 40;
% const_diag(iqc(1:step:end));


%% eye diagram

% prompt = {'samples per symbol:'};
% dlgtitle = 'Input';
% fieldsize = [1 30];
% definput = {'6'};
% 
% res = inputdlg(prompt, dlgtitle, fieldsize, definput);
% 
% if(isempty(res))
%     return;
% end
% 
% samples_per_symbol = str2double(res{1});
% 
% step = 1;
% eyediagram(iqc_f(1:step:min(10000,numel(iqc_f))), samples_per_symbol)
% 
% plot_num = plot_num + 1;


%%
% figure(plot_num)
% set(gcf,'position',([50,50,1400,500]),'color','w')
% plot(iq(:,1),'b');
% hold on; 
% plot(iq(:,2),'r');
% grid on
% box on
% set(gca,'fontweight','bold','FontSize',12);
% xlim([0, (numel(iqc))]);
% ylim([-1, 1]);
% 
% xlabel('Samples', 'fontweight','bold','FontSize',12);
% ylabel('Value', 'fontweight','bold','FontSize',12);
% plot_num = plot_num + 1;

% figure(plot_num)
% set(gcf,'position',([50,50,1400,500]),'color','w')
% plot(ph,'g');
% grid on
% box on
% set(gca,'fontweight','bold','FontSize',12);
% xlim([0, (numel(iqc))]);
% ylim([-1, 1]);
% set(gca,'YTick',-1:1/2:1)
% yticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
% 
% xlabel('Samples', 'fontweight','bold','FontSize',12);
% ylabel('Phase', 'fontweight','bold','FontSize',12);
% plot_num = plot_num + 1;

% figure;
% set(gcf,'position',([50,50,1400,500]),'color','w')
% plot(unwrap(ph),'g');
% grid on
% box on
% set(gca,'fontweight','bold','FontSize',12);
% xlim([0, (numel(iqc))]);
% % ylim([-1, 1]);
% % set(gca,'YTick',-1:1/2:1)
% % yticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
% 
% xlabel('Samples', 'fontweight','bold','FontSize',12);
% ylabel('Phase', 'fontweight','bold','FontSize',12);
% plot_num  = plot_num + 1;

% figure(plot_num)
% scatter(iqb(:,1),iqb(:,2),'o','filled')
% plot_num = plot_num + 1;
% 
% figure(plot_num)
% plot(iqb(:,1),'b');
% hold on; 
% plot(iqb(:,2),'r')
% plot_num = plot_num + 1;

%%

iq_start = max(floor(fs*0.000001), 1);
iq_stop = min(iq_start + ceil(fs*0.1), numel(iqc));
step = 1;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(t(iq_start:step:iq_stop), real(iqc(iq_start:step:iq_stop)), imag(iqc(iq_start:step:iq_stop)), 20, 'o', 'b', 'filled');
hold on
plot3(t(iq_start:step:iq_stop), real(iqc(iq_start:step:iq_stop)), imag(iqc(iq_start:step:iq_stop)), 'b');

set(gca,'fontweight','bold','FontSize',11,'Ydir','reverse');

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;
drawnow;

%% constellation histogram

% const_x = 50;
% const_y = 50;

% x_edges = linspace(-1.1,1.1,const_x+1);
% y_edges = linspace(-1.1,1.1,const_y+1);

x_edges = -1.1:0.05:1.1;
y_edges = -1.1:0.05:1.1;

iq_start = 1; %max(1, ceil(fs*0.01));
iq_stop = min(iq_start + ceil(fs*0.0005), numel(iqc));
step = 1;

iq_section = iqc(iq_start:step:iq_stop);

[iq_hist, Xedges, Yedges, binx, biny] = histcounts2(real(iq_section), imag(iq_section), x_edges, y_edges);

figure;
% histogram2(real(iq_section), imag(iq_section), [const_x, const_y], 'DisplayStyle','tile','ShowEmptyBins','on');
s1 = surf(Xedges(1:end-1), Yedges(1:end-1), iq_hist.');
set(s1,'edgecolor','none');
colormap(jet(100));

xlim([-1.1, 1.1]);
ylim([-1.1, 1.1]);

xlabel('I', 'fontweight','bold');
ylabel('Q', 'fontweight','bold');

view(0, 90)

%%
return;

%%

iq_start = max(floor(fs*1.57), 1);
iq_stop = min(iq_start + ceil(fs*0.1), numel(iqc));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(t(iq_start:step:iq_stop), real(iqc(iq_start:step:iq_stop)),'b')
hold on
box on
grid on
plot(t(iq_start:step:iq_stop), imag(iqc(iq_start:step:iq_stop)),'r')
xlabel('Time (s)', 'fontweight','bold');
ylabel('Amplitude', 'fontweight','bold');
ylim([-1.2, 1.2]);

plot_num = plot_num + 1;
drawnow;

%% Limited FFT

% iq_start = ceil(fs*9)+15500;
% iq_stop = numel(iqc);
iq_start = ceil(5.1*fs);
iq_stop = ceil(5.6*fs);
step = 1;

iqc_s = (iqc(iq_start:step:iq_stop));
iqc_sm = mean(iqc_s);
iqc_s = iqc_s - iqc_sm;

Y = fft(iqc_s)/numel(iqc_s);
f = linspace(-fs/2, fs/2, numel(Y));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f, 20*log10(abs(fftshift(Y))), 'b');
box on
grid on
xlabel('Frequency (Hz)', 'fontweight','bold');
ylabel('Amplitude (dBfs)', 'fontweight','bold');
plot_num = plot_num + 1;

%% real FFT

% iq_start = ceil(fs*9)+15500;
% iq_stop = numel(iqc);
iq_start = ceil(5.1*fs);
iq_stop = ceil(5.6*fs);
step = 1;

iqc_s = abs(iqc(iq_start:step:iq_stop));
iqc_sm = mean(iqc_s);
iqc_s = iqc_s - iqc_sm;

Y = fft(iqc_s)/numel(iqc_s);
f = linspace(0, fs/2, floor(numel(Y)/2));

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(f, 20*log10(abs((Y(1:floor(numel(Y)/2))))), 'b');
box on
grid on
xlabel('Frequency (Hz)', 'fontweight','bold');
ylabel('Amplitude (dBfs)', 'fontweight','bold');
plot_num = plot_num + 1;


%% comet plot

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on
set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

view(-70,15);

for idx=1:numel(iqc)
    scatter3(t(idx), real(iqc(idx)), imag(iqc(idx)), 20, 'o', 'b', 'filled');
    % plot3(t(iq_start:step:iq_stop), real(iqc(iq_start:step:iq_stop)), imag(iqc(iq_start:step:iq_stop)), 'b');
    % pause(0.0001);
    drawnow;
end


plot_num = plot_num + 1;
drawnow;

%% comet3
step = 1;
figure;
set(gcf,'position',([50,50,1400,500]),'color','w')

set(gca,'fontweight','bold','FontSize',11);
grid on
box on

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

view(-70,15);

f1 = gcf;
tailFormat = struct('LineWidth',1,'Color','b','LineStyle','none', 'Marker','o','MarkerSize',6,'MarkerFaceColor', 'b');
headFormat = struct('LineStyle','none','Marker','o','MarkerSize',6,'Color','r', 'MarkerFaceColor', 'r');
PlotComet_3D(t(1:step:end), real(iqc(1:step:end)), imag(iqc(1:step:end)), 'cFigure', f1, 'Frequency', 1000000, 'blockSize', 2000, 'tailFormat',tailFormat, 'headFormat',headFormat);
% PlotComet_3D(t(1:step:end), real(iqc_r(1:step:end)), imag(iqc_r(1:step:end)), 'cFigure', f1, 'Frequency', 1000000, 'blockSize', 500, 'tailFormat',tailFormat, 'headFormat',headFormat);
% PlotComet_3D(real(iqc), imag(iqc), t, 'Frequency', 100000, 'blockSize', 1000, 'tailFormat',tailFormat, 'headFormat',headFormat);

plot_num = plot_num + 1;

%% FM demod

fmdemod = comm.FMDemodulator("SampleRate",fs, "FrequencyDeviation", 100e3)

z = fmdemod(iqc);
mz = max(abs(z));
ap=audioplayer(z/mz, 44100);
play(ap);

%% rotation
fr = 10/fs;

f_rot = exp(2*pi*1j*fr*(0:numel(iqc)-1)).';

iqc_r = f_rot.*iqc;




%%
% figure;
% h = animatedline;
% 
% for idx=1:size(iq,1)
%     % addpoints(h, iq(idx,1), iq(idx,2));
%     addpoints(h, idx, ph(idx));
%     pause(0.01);
%     drawnow;
% end

%%
[iq_eq] = iq_equalization(iqc);

figure;
scatter(real(iq_eq), imag(iq_eq),'o','filled')