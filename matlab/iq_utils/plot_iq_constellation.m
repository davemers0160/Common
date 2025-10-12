format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%%

k = 7;
M = 2^k;
side_length = bitshift(M, -3);

pre_const = comm.internal.qam.getSquareConstellation(M);

gray = comm.internal.utilities.bin2gray([0:M-1], 'qam', M);

gc = zeros(M,1);
for idx=0:M-1

    gc(idx+1,1) = bitxor(idx, bitshift(idx, -1)); 
    
end

const = pre_const(gc+1);

for idx=1:numel(const)
    fprintf('%02d,\t [%d, %di],\t %02d, %s,\t [%d, %di]\n',idx-1, real(pre_const(idx)), imag(pre_const(idx)), gc(idx), dec2base(gc(idx),2, k), real(const(idx)), imag(const(idx)));
end

%% plot the data
max_I = max(abs(real(const)));
max_Q = max(abs(imag(const)));

figure(plot_num)
set(gcf,'position',([50,80,1400,700]),'color','w')

box on
hold on
grid on 

for idx=1:numel(const)

    x = real(const(idx));
    y = imag(const(idx));
    text( x-0.6,y-0.3, strcat(dec2base(idx-1,2, k), 32,'(', num2str(idx-1,"%03d"),')'),'Color',[1 0 0]);
%     text( y-0.3,x-0.6, strcat('(', num2str(-(side_length-1) + 2*c),',',num2str(-(side_length-1) + 2*r),')'),'Color',[0 0 0]);
    scatter(x, y, 30, '*', 'k');

end


set(gca,'fontweight','bold','FontSize',12);
xlim([-max_I-1, max_I+1]);
ylim([-max_Q-1, max_Q+1]);

xlabel('I', 'fontweight','bold','FontSize',12);
ylabel('Q', 'fontweight','bold','FontSize',12);

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

plot_num = plot_num + 1;

