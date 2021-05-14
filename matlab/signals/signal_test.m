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

commandwindow;

%% generate the base pulse train

x = maxmimal_length_seq(6);
x_length = length(x);

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,400]),'color','w')
plot(x, 'b')
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(x)]);
ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];

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
set(gcf,'position',([50,50,1400,400]),'color','w')
plot(signal, 'b')
grid on
box on

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(signal)]);
ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];
ylabel('Base Signal', 'fontweight','bold','FontSize',12);

plot_num  = plot_num + 1;

%% generate 4 pulse trains that vary in start time
num = 4;
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
    noise = 0.7*randn(1,length(signal) + max_offset);
    
    % build the signal
    sn(idx, :) = [zeros(1, off(idx)) signal zeros(1, max_offset-off(idx))]  + noise;
    
    fprintf('%d ', off(idx)+start+1);
    
end

fprintf('\n\n');

%% plot the signals
cm = ['r', 'g', 'b', 'k'];

figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(4,1,idx);
    plot(sn(idx,:), cm(idx))
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
    subplot(4,1,idx);
    plot(rxy(idx,:), cm(idx))
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
        %if jdx ~= idx
            bxy{idx,jdx} = conv(sn(idx, 1:bxy_length), sn(jdx, bxy_length:-1:1), 'same');
        %end
    end
end

% plot the blind auto cross correlations
figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(4,1,idx);
    plot(bxy{idx,idx}, cm(idx))
    grid on
    box on
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, bxy_length]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Bxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% plot the auto cross correlations 

figure(plot_num)
set(gcf,'position',([250,50,1400,700]),'color','w')

for idx=1:num
    subplot(4,1,idx);
    grid on
    box on
    hold on
    
    for jdx=1:num
        if(idx ~= jdx)
            plot(bxy{idx,jdx}, cm(jdx));
        end
    end
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, bxy_length]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Bxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;


