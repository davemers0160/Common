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
% 13-bit barker code
% x = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];
x = maxmimal_length_seq(4);

% exapnd signal
x = repelem(x, 10);

x_length = length(x);

% convert to complex
% circular complex
% xc = x.*((1j).^(0:x_length-1));
xc = complex(x, zeros(1, x_length));

ang = angle(xc)*180/pi;
ang(ang < 0) = ang(ang < 0) + 360;

% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,400]),'color','w')
plot(x, 'b')
grid on
box on
hold on
% stairs(ang/360, '--r');

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(x)]);
ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];

plot_num  = plot_num + 1;

%% start offset
start = 50;

% number of samples to place between pulses
pulse_spacing = 1000 - x_length;

% number of pulses
pulse_num = 12;

% build the pulse train
%space = 0.1*complex(randn(1, pulse_spacing), randn(1, pulse_spacing));
signal = [];
for idx=1:pulse_num
    signal = cat(2, signal, xc, 0.01*complex(randn(1, pulse_spacing), randn(1, pulse_spacing)));
end
signal = cat(2, 0.01*complex(randn(1, start), randn(1, start)), signal);

%% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,400]),'color','w')
grid on
box on
hold on
plot(real(signal), 'b')
plot(imag(signal), 'r')

set(gca,'fontweight','bold','FontSize',12);
xlim([0, numel(signal)]);
ax = gca;
ax.Position = [0.05 0.1 0.92 0.83];
ylabel('Base Signal', 'fontweight','bold','FontSize',12);

plot_num  = plot_num + 1;

%% generate 4 pulse trains that vary in start time
num = 3;
max_offset = 100;
noise_factor = 0.1;
fs = 1e6;

% generate a random offset
off = [];
while(length(off) < num) 
    off = unique(randi([0,max_offset], num, 1), 'stable');
end

% create the signals with some noise
fprintf('offsets: ');
for idx=1:num
    
    % generate noise
    noise = noise_factor*complex(randn(1,length(signal) + max_offset), randn(1,length(signal) + max_offset));
    
    % build the signal
    sn(idx, :) = [zeros(1, off(idx)) signal zeros(1, max_offset-off(idx))]  + noise;
    
    fprintf('%d ', off(idx)+start+1);
    
end

figure(plot_num);
spectrogram(sn(1,:), 512, 256, 1024, fs, 'centered');
plot_num = plot_num + 1;

fprintf('\n\n');

%% plot the signals
cm = ['r', 'g', 'b', 'k'];

figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    grid on
    box on
    hold on
    plot(real(sn(idx,:)), cm(idx))
    plot(imag(sn(idx,:)), '--', 'Color', cm(idx))
   
    
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
    rxy(idx, :) = conv(sn(idx, :), conj(xc(end:-1:1)), 'valid');
end


%% plot the auto correlation signals
figure(plot_num)
set(gcf,'position',([50,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    plot(abs(rxy(idx,:)), cm(idx))
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
            bxy{idx,jdx} = conv(sn(idx, 1:bxy_length), conj(sn(jdx, bxy_length:-1:1)), 'same');
        %end
    end
end

% plot the blind auto cross correlations
% figure(plot_num)
% set(gcf,'position',([50,50,1400,700]),'color','w')
% 
% for idx=1:num
%     subplot(4,1,idx);
%     plot(bxy{idx,idx}, cm(idx))
%     grid on
%     box on
%     
%     set(gca,'fontweight','bold','FontSize',12);
%     xlim([0, bxy_length]);
%     ax = gca;
%     ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
%     ylabel(strcat('Bxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);
% 
% end
% 
% plot_num  = plot_num + 1;

%% plot the auto cross correlations 

figure(plot_num)
set(gcf,'position',([350,50,1400,700]),'color','w')

for idx=1:num
    subplot(num,1,idx);
    grid on
    box on
    hold on
    
    for jdx=1:num
        if(idx ~= jdx)
            plot(abs(bxy{idx,jdx}), cm(jdx));
        end
    end
    
    set(gca,'fontweight','bold','FontSize',12);
    xlim([0, bxy_length]);
    ax = gca;
    ax.Position = [0.05 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('Bxy',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;


