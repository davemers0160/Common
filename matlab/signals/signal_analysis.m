format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%%

file_filter = {'*.fc32','FC32 Files';'*.sc16','SC16 Files';'*.*','All Files' };

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

fs = 50e6;

%% read in the data

[~, iqc] = read_binary_iq_data(fullfile(data_filepath, data_file), data_type, byte_order);

iqc = iqc * scale;

t = (0:1:(numel(iqc)-1))/fs;

%%
window_size = 32;
overlap = 16;
nfft = 32;

fbw = 20e6/fs;

n_taps = 15;
w = nuttall_window(n_taps);
g = create_fir_filter(fbw, w);

iq_f = conv(iqc, g(end:-1:1), 'same');

[s, f, ts] = spectrogram(iq_f, window_size, overlap, nfft, fs, 'centered');

%%
ds = 20*log10(abs(s(floor(window_size/2),:)));
mean_s = mean(ds);

g = create_fir_filter(0.02, w);

ds = ds - mean_s;

ds_c = conv(ds, g(end:-1:1), 'same');

%%
step = 200;
tss = ts(1:step:end);
dss = ds_c(1:step:end);

adss = abs(dss);

threshold = 11.8;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(tss, adss, 'b')
hold on
grid on
box on

[~, y_coord]=ginput(plot_num);

threshold = floor(y_coord);


% adss(adss<threshold) = 0;
[index] = get_indecies(adss, threshold, 14);

tssi = tss(index);

delta_tssi = (tssi(2:end) - tssi(1:end-1))*1000;
%% plot
% figure(plot_num)
% set(gcf,'position',([50,50,1400,500]),'color','w')
% plot(tss, adss, 'b')
% hold on
% grid on
% box on
stem(tss(index), 20*ones(numel(index),1), 'r');
set(gca,'fontweight','bold','FontSize',12);
xlabel('time (s)', 'fontweight','bold','FontSize',12);
ylabel(' ', 'fontweight','bold','FontSize',12);

savefig(strcat(data_filepath, '\', fn, '_bursts.fig'));
plot_num = plot_num + 1;

figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

stairs(delta_tssi, 'b')
hold on
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlabel('burst', 'fontweight','bold','FontSize',12);
ylabel('burst to burst times (ms)', 'fontweight','bold','FontSize',12);
savefig(strcat(data_filepath, '\', fn, '_b2b_timing.fig'));

plot_num = plot_num + 1;

return;
%%
% figure(plot_num)
% set(gcf,'position',([50,50,800,500]),'color','w')
% plot(ts, ds, 'b');
% hold on
% grid on
% box on
% 
% plot_num = plot_num + 1;

%%
% figure(plot_num)
% set(gcf,'position',([50,50,800,500]),'color','w')
% surf(ts, f/10e6, 20*log10(abs(s)), 'EdgeColor', 'none')
% hold on
% box on
% grid on
% 
% yticks([-2.5:0.1:2.5])
% 
% ax = gca;
% ax.Layer = 'top';
% 
% view(0,90);
% 
% plot_num = plot_num + 1;

%%
t1 = 1/fs;
% t2 = t1+2850/fs;

s1 = ceil(t1*fs);
% s2 = ceil(t2*fs);
s2 = s1 + 2850;

iq_n = iqc(s1:s2);

fc = 3e6/fs;
fbw = 2.5e6/fs;

n_taps = 15;
w = nuttall_window(n_taps);
g = create_fir_filter(fbw, w);
% g = g.*exp(1j*2*pi*fc*(0:(numel(g)-1)));

fr = exp(1j*2*pi*-fc*(0:(numel(iqc)-1)));
iq_n = iqc.*fr.';


iq_nf = conv(iq_n, g(end:-1:1), 'same');
% iq_nf = iq_n;

%%
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
hold on; 
plot(real(iqc),'--b');
plot(real(iq_nf),'b');

plot(imag(iq_nf),'r');
grid on
box on
set(gca,'fontweight','bold','FontSize',12);
xlim([0, (numel(iqc))]);
ylim([-1, 1]);
plot_num = plot_num + 1;

%%
figure(plot_num)
set(gcf,'position',([50,50,800,500]),'color','w')
scatter(real(iq_n),imag(iq_n),'o','filled', 'b')
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([-1.5, 1.5]);
ylim([-1.5, 1.5]);

xlabel('I', 'fontweight','bold','FontSize',12);
ylabel('Q', 'fontweight','bold','FontSize',12);

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
plot_num = plot_num + 1;

%%

[sn, fn, tsn] = spectrogram(iq_nf, window_size, 500, nfft, fs, 'centered');

figure(plot_num)
set(gcf,'position',([50,50,800,500]),'color','w')
surf(tsn, fn/10e6, 20*log10(abs(sn)), 'EdgeColor', 'none')
hold on
box on
grid on

yticks([-2.5:0.1:2.5])

ax = gca;
ax.Layer = 'top';

view(0,90);

plot_num = plot_num + 1;



