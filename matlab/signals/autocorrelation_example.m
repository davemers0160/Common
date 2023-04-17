format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[scriptpath,  filename, ext] = fileparts(full_path);

plot_num = 1;
line_width = 1.0;
cm = ['r', 'g', 'b', 'k'];
titles = {'Sine Wave', 'Square Wave', 'Ramp', 'Random Noise'};
y_offset = [0.02, 0.005, -0.02, -0.035];

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

% calculate the auto correlations
for idx=1:num_sig
    sc(idx, :) = conv(s(idx, :), s(idx, end:-1:1), 'same');
end

% calculate the cross correlations
x_sc = cell(num_sig, num_sig);
for idx=1:num_sig
    for jdx=1:num_sig
        x_sc{idx, jdx} = conv(s(jdx, :), s(idx, end:-1:1), 'same');
    end
end

%% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);
    hold on
    grid on
    box on
    plot(s(idx, :), cm(idx), 'LineWidth', line_width)
    set(gca,'fontweight','bold','FontSize',11);
    title(titles{idx}, 'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2)+y_offset(idx) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% plot the auto correlation of the signals 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);hold on
    grid on
    box on
    plot(sc(idx, :), cm(idx), 'LineWidth', line_width)
    set(gca,'fontweight','bold','FontSize',11);
    title(strcat(titles{idx}, 32, 'Auto Correlation'), 'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2)+y_offset(idx) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% plot the cross correlation of the signals
figure(plot_num)
set(gcf,'position',([350,50,1400,600]),'color','w')

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
    
    title(strcat(titles{idx}, 32, 'Cross Correlation'), 'fontweight','bold','FontSize',12);
    set(gca,'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2)+y_offset(idx) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1;

%% generate the barker code
x = [];
xc =[];

% barker codes
b5 = [1, 1, 1, -1, 1];
b7 = [1, 1, 1, -1, -1, 1, 1];
b11 = [1, 1, 1, -1, -1, -1, 1, -1, -1, 1, -1];
b13 = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];

b_titles = {'Barker Code (13)', 'MLS (n=4)'};

% standard barker codes
x(1,:) = cat(2, zeros(1,101), b13, zeros(1,101));

% maximal length sequence
x(2,:) = cat(2, zeros(1,100), maxmimal_length_seq(4, [1,4]), zeros(1,100));

num_sig = size(x,1);

% calculate the auto correlations
for idx=1:num_sig
    xc(idx, :) = conv(x(idx, :), x(idx, end:-1:1), 'same');
end

% calculate the cross correlations
x_xc = cell(num_sig, num_sig);
for idx=1:num_sig
    for jdx=1:num_sig
        x_xc{idx, jdx} = conv(x(jdx, :), x(idx, end:-1:1), 'same');
    end
end

%% plot the base signal 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);
    hold on
    grid on
    box on
    stairs(x(idx, :), cm(idx), 'LineWidth', line_width)
    xlim([0, length(x(idx,:))]);
    set(gca,'fontweight','bold','FontSize',11);
    title(b_titles{idx}, 'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);

end

plot_num  = plot_num + 1; 

%% plot the auto correlation of the signals 
figure(plot_num)
set(gcf,'position',([50,50,1400,600]),'color','w')

for idx=1:num_sig
    subplot(num_sig,1,idx);hold on
    grid on
    box on
    hold on
    plot(xc(idx, :), cm(idx+1), 'LineWidth', line_width)
    for jdx=1:num_sig
        if(idx ~= jdx)
            plot(x_xc{idx,jdx}, cm(jdx+1), 'LineWidth', line_width);
        end
    end
    xlim([0, length(x(idx,:))]);
    set(gca,'fontweight','bold','FontSize',11);
    title(b_titles{idx}, 'fontweight','bold','FontSize',12);
    ax = gca;
    ax.Position = [0.06 ax.Position(2) 0.92 ax.Position(4)];
    ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);
    legend('auto correlation','cross correlation')

end

plot_num  = plot_num + 1;

%% plot the cross correlation of the signals
% figure(plot_num)
% set(gcf,'position',([350,50,1400,600]),'color','w')
% 
% for idx=1:num_sig
%     subplot(num_sig,1,idx);
%     grid on
%     box on
%     hold on
%     
%     for jdx=1:num_sig
%         if(idx ~= jdx)
%             plot(x_xc{idx,jdx}, cm(jdx), 'LineWidth', line_width);
%         end
%     end
%     
%     title(b_titles{idx}, 'fontweight','bold','FontSize',12);
%     set(gca,'fontweight','bold','FontSize',12);
%     ax = gca;
%     ax.Position = [0.06 ax.Position(2)+y_offset(idx) 0.92 ax.Position(4)];
%     ylabel(strcat('S',32, num2str(idx)), 'fontweight','bold','FontSize',12);
% 
% end
% 
% plot_num  = plot_num + 1;

