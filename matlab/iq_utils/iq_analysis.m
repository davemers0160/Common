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
file_filter = {'*.sc16','SC16 Files';'*.fc32','FC32 Files';'*.*','All Files' };

[data_file, data_filepath] = uigetfile(file_filter, 'Select File', startpath, 'MultiSelect', 'on');
if(data_filepath == 0)
    return;
end

[~,  fn, ext] = fileparts(data_file);

if (strcmp(ext,'.fc32') == 1)
    scale = 32768/2048;
    data_type = 'single';
else
    scale = 1/2048;
    data_type = 'int16';
end

byte_order = 'ieee-le';


%%

[~, iqc_in] = read_binary_iq_data(fullfile(data_filepath, data_file), data_type, byte_order);

%% get sample rate
prompt = {'Sample Rate:'};
dlgtitle = 'Input';
fieldsize = [1 30];
definput = {'20e6'};

res = inputdlg(prompt, dlgtitle, fieldsize, definput);

if(isempty(res))
    return;
end

fs = str2double(res{1});

%%
t = 0:1/fs:(numel(iqc_in)-1)/fs;

% iqc = iqc()
max(real(iqc_in))
min(real(iqc_in))

max(imag(iqc_in))
min(imag(iqc_in))

iqc = scale * iqc_in;

%%
iq(:,1) = real(iqc);
iq(:,2) = imag(iqc);

ph = atan2(imag(iqc),real(iqc))/pi;
ph = angle(iqc);

%%
Y = fft(iqc)/numel(iqc);
f = linspace(-fs/2, fs/2, numel(Y));

figure(plot_num)
plot(f, 20*log10(abs(fftshift(Y))), 'b');
plot_num = plot_num + 1;
drawnow;

%%
figure(plot_num)
plot(t, real(iqc),'b')
hold on
plot(t, imag(iqc),'r')
plot_num = plot_num + 1;
drawnow;

%%
[s, f, ts] = spectrogram(iqc, 512, 480, 512, fs, 'centered');

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;
drawnow;

%%
figure(plot_num)
set(gcf,'position',([50,50,800,500]),'color','w')
scatter(iq(:,1),iq(:,2),'o','filled', 'b')
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([-1, 1]);
ylim([-1, 1]);

xlabel('I', 'fontweight','bold','FontSize',12);
ylabel('Q', 'fontweight','bold','FontSize',12);

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
plot_num = plot_num + 1;

%% filtered

num_taps = 31;
w = hamming(num_taps);
fc = 2.5e6/fs;
lpf = create_fir_filter(fc, w);

iqc_f = conv(iqc, lpf(end:-1:1),'same');

[s, f, ts] = spectrogram(iqc_f, 512, 480, 512, fs, 'centered');

figure(plot_num)
set(gcf,'position',([50,50,1000,800]),'color','w')
surf(ts, f/1e6, 20*log10(abs(s)), 'EdgeColor', 'none')
colormap(jet(100));

grid on
box on

set(gca,'fontweight','bold','FontSize',12);

xlabel('Time (s)', 'fontweight','bold','FontSize',12);
ylabel('Frequency (MHz)', 'fontweight','bold','FontSize',12);

view(90,-90);
plot_num = plot_num + 1;
drawnow;

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

iq_start = 1;
iq_stop = numel(iqc);

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

scatter3(t(iq_start:iq_stop), real(iqc(iq_start:iq_stop)), imag(iqc(iq_start:iq_stop)), 20, 'o', 'b', 'filled');
hold on
plot3(t(iq_start:iq_stop), real(iqc(iq_start:iq_stop)), imag(iqc(iq_start:iq_stop)), 'b');

set(gca,'fontweight','bold','FontSize',11);

xlabel('time (s)', 'fontweight','bold');
ylabel('I', 'fontweight','bold');
zlabel('Q', 'fontweight','bold');

plot_num = plot_num + 1;
drawnow;

%%
return;
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