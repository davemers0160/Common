format long g
format compact
clc
close all
clearvars
global startpath

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];

commandwindow;

%% simple signals

s = [];
sc = [];

% sine wave
s(1, :) = cat(2, zeros(1,100), sin(2*pi*0.05*(0:100-1)), zeros(1,100));

% square wave
s(2, :) = cat(2, zeros(1,100), ones(1,100), zeros(1,100));

% triangle wave
s(3, :) = cat(2, zeros(1,100), (0:0.01:1-0.01), zeros(1,100));

% random noise
s(4, :) = cat(2, zeros(1,100), 2*rand(1,100)-1, zeros(1,100));

num_sig = size(s,1);

% plot the auto correlations
for idx=1:num_sig
    sc(idx, :) = conv(s(idx, :), s(idx, end:-1:1), 'same');
end

x_sc = cell(num_sig, num_sig);
for idx=1:num_sig
    for jdx=1:num_sig
        x_sc{idx, jdx} = conv(s(jdx, :), s(idx, end:-1:1), 'same');
    end
end

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);
    hold on
    grid on
    box on
    plot(s(idx, :), cm(idx), 'LineWidth', line_width)
    set(gca,'fontweight','bold','FontSize',11);
    ax = gca;
    ax.Position = [0.06 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

% plot the auto correlation of the signals 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);hold on
    grid on
    box on
    plot(sc(idx, :), cm(idx), 'LineWidth', line_width)
    set(gca,'fontweight','bold','FontSize',11);
    ax = gca;
    ax.Position = [0.06 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

% plot the cross correlation of the signals
figure(plot_num)
set(gcf,'position',([350,50,1400,700]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);
    grid on
    box on
    hold on
    
    for jdx=1:num_sig
        if(idx ~= jdx)
            plot(x_sc{idx,jdx}, cm(jdx), 'LineWidth', line_width);
        end
    end
    
    set(gca,'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% generate the base pulse train

% barker codes
b5 = [1, 1, 1, -1, 1];
b7 = [1, 1, 1, -1, -1, 1, 1];
b11 = [1, 1, 1, -1, -1, -1, 1, -1, -1, 1, -1];
b13 = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];

% standard barker codes
x = b13;
sig_noise = 0.38;

% nested barker B5XB13 
% x = (b13' * b5)';
% x = x(:)';
% sig_noise = 0.7;

% maximal length sequence
x = maxmimal_length_seq(6);
sig_noise = 0.75;

x_length = length(x);

x2 = cat(2, zeros(1,20), x, zeros(1,20));
x2c = conv(x2, x2(end:-1:1), 'same');

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')

subplot(2,1,1)
hold on
grid on
box on
plot(x2, 'b', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',11);
xlim([0, numel(x2)]);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

subplot(2,1,2)
hold on
grid on
box on
plot(x2c, 'g', 'LineWidth', line_width)
set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(x2)]);
ax = gca;
ax.Position = [0.04 ax.Position(2) 0.92 ax.Position(4)];

plot_num  = plot_num + 1;

%% start offset
start = 50;

% number of samples to place between pulses
pulse_spacing = 200 - x_length;

% number of pulses
pulse_num = 12;

% build the pulse train
space = zeros(1, pulse_spacing);
signal = repmat([x space], 1, pulse_num);
signal = [zeros(1, start) signal];

%% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,500]),'color','w')
plot(signal, 'b', 'LineWidth', line_width)
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(signal)]);
ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];
ylabel('Base Signal', 'fontweight','bold','FontSize',12);

plot_num  = plot_num + 1;

%% generate 4 pulse trains that vary in start time
num = 3;
max_offset = 100;

% generate a random offset
off = [];
while(length(off) < num) 
    off = unique(randi([0,max_offset], num, 1), 'stable');
end

% create the signals with some noise
fprintf('offset: ');
for idx=1:num
    
    % generate noise
    noise = sig_noise * randn(1,length(signal) + max_offset);
    
    % build the signal
    sn(idx, :) = [zeros(1, off(idx)) signal zeros(1, max_offset-off(idx))]  + noise;
    
    fprintf('%d ', off(idx)+start+1);
    
end

fprintf('\n\n');

%% plot the signals

figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    plot(sn(idx,:), cm(idx), 'LineWidth', line_width)
    grid on
    box on
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, numel(sn(idx,:))]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Signal',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% run the correlation
rxy = [];
for idx=1:num
    rxy(idx, :) = conv(sn(idx, :), x(end:-1:1), 'valid');
end


%% plot the auto correlation signals
figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    plot(rxy(idx,:), cm(idx), 'LineWidth', line_width)
    grid on
    box on
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, numel(rxy(idx,:))]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Rxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% run a blind correlation

bxy_length = 200;
bxy = cell(num, num);

for idx=1:size(sn,1)
    for jdx=1:size(sn,1)
        bxy{idx,jdx} = conv(sn(jdx, 1:bxy_length), sn(idx, bxy_length:-1:1), 'same');
    end
end

%% plot the blind cross correlations 

figure(plot_num)
set(gcf,'position',([350,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    grid on
    box on
    hold on
    
    for jdx=1:num
        if(idx ~= jdx)
            plot(bxy{idx,jdx}, cm(jdx), 'LineWidth', line_width);
        end
    end
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, bxy_length]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Bxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;


