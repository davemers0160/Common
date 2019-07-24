format long g
format compact
clc
close all
clearvars

full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% load the mat file

start_path = 'D:\Projects\mnist_pso\';

mat_file_filter = {'*.mat','Mat Files';'*.*','All Files' };
[mat_save_file, mat_save_path] = uigetfile(mat_file_filter, 'Select Mat File', start_path);
if(mat_save_path == 0)
    return;
end

load(fullfile(mat_save_path,mat_save_file));

commandwindow;


%% create the patches

num_con = numel(G(1).con_map);
num_itr = itr-1;
x_off = 4.5;
y_off = 4.5;

c = cell(num_itr, num_con);

for idx=1:num_itr
    for jdx=1:num_con
    
        c{idx,jdx} = make_conv_patch(G(idx).con(jdx,:), x_off+10*(idx-1), y_off);
    end
end

%% plot the two convs for G

if(false)
figure(plot_num)
set(gcf,'position',([50,50,1200,700]),'color','w')

subplot(2,1,1);
hold on
box on
grid on

for idx=1:num_itr
    
    patch('Faces',[1 2 3 4], 'Vertices',c{idx,1},'FaceColor','blue','FaceAlpha',0.3, 'LineStyle','-','EdgeColor','b', 'LineWidth', 1);

end


xlim([0,10*num_itr + 5]);
xticks([4.5:10:10*num_itr]);
xticklabels(num2str([1:1:num_itr]'));

ylim([0 9]);
yticks([1:0.5:9]);
yticklabels(num2str(abs(-3.5:0.5:3.5)','%1.1f'));


subplot(2,1,2);
hold on
box on
grid on

for idx=1:num_itr
    
    patch('Faces',[1 2 3 4], 'Vertices',c{idx,2},'FaceColor','blue','FaceAlpha',0.3, 'LineStyle','-','EdgeColor','b', 'LineWidth', 1);

end


xlim([0,10*num_itr + 5]);
xticks([4.5:10:10*num_itr]);
xticklabels(num2str([1:1:num_itr]'));

ylim([0, 9]);
yticks([1:0.5:9]);
yticklabels(num2str(abs(-3.5:0.5:3.5)','%1.1f'));

plot_num = plot_num + 1;

end

%%

N = size(P,1);
num_itr = itr;
X_con = [];
X_fc = [];
X_act = [];
X_bn = [];

con_index = find(strcmp('con',net_description.net_structure));
fc_index = find(strcmp('fc',net_description.net_structure));

con_num = numel(X(1,1).con(:,1));
fc_num = numel(X(1,1).fc(:,1));
act_num = numel(X(1,1).act(:,1));
bn_num = numel(X(1,1).bn(:,1));

for idx=1:N
   
    for jdx=1:num_itr

        for kdx=1:con_num
            X_con(idx,jdx,kdx) = X(idx,jdx).con(kdx,1);
        end
        
        for kdx=1:fc_num
            X_fc(idx,jdx,kdx) = X(idx,jdx).fc(kdx);
        end
        
        for kdx=1:act_num
            X_act(idx,jdx,kdx) = X(idx,jdx).act(kdx);
        end
        
        for kdx=1:bn_num
            X_bn(idx,jdx,kdx) = X(idx,jdx).bn(kdx);
        end
        
    end
    
end

%% plots

for idx=1:con_num

    figure(plot_num);
    set(gcf,'position',([50,50,1200,600]),'color','w')
    box on;
    grid on;
    surf(X_con(:,:,idx));

    set(gca,'fontweight','bold', 'fontsize',13);

    xlim([0,num_itr+1]);
    xticks([0:5:num_itr]);
    %xticklabels(num2str([1:1:num_itr]'));
    xtickangle(35);
    xlabel('Iterations', 'fontweight','bold', 'fontsize',13);

    ylim([0, N+1]);
    yticks([0:1:N]);
    %yticklabels({'con 2', 'con 1'});
    ylabel('Particle Number', 'fontweight','bold', 'fontsize',13);


    zlim([0 250]);
    zticks([0:25:250]);
    ztickformat('%2.1f');
    zlabel('Number of Filters', 'fontweight','bold', 'fontsize',13);

    view(45,30);
    ax = gca;
    ax.Position = [0.08 0.1 0.9 0.88];
    plot_num = plot_num + 1;

end

%%

for idx=2:fc_num
    
    figure(plot_num);
    set(gcf,'position',([50,50,1200,600]),'color','w')
    box on;
    grid on;
    surf(X_fc(:,:,idx));

    set(gca,'fontweight','bold', 'fontsize',13);

    xlim([0,num_itr+1]);
    xticks([0:5:num_itr]);
    %xticklabels(num2str([1:1:num_itr]'));
    xtickangle(35);
    xlabel('Iterations', 'fontweight','bold', 'fontsize',13);

    ylim([0, N+1]);
    yticks([0:1:N]);
    %yticklabels({'con 2', 'con 1'});
    ylabel('Particle Number', 'fontweight','bold', 'fontsize',13);


    zlim([0 1000]);
    zticks([0:100:1000]);
    ztickformat('%2.1f');
    zlabel('Number of Filters', 'fontweight','bold', 'fontsize',13);

    view(45,30);
    ax = gca;
    ax.Position = [0.08 0.1 0.9 0.88];
    plot_num = plot_num + 1;
    
end


%%

for idx=1:act_num
    
    figure(plot_num);
    set(gcf,'position',([50,50,1200,600]),'color','w')
    box on;
    grid on;
    surf(X_act(:,:,idx));

    set(gca,'fontweight','bold', 'fontsize',13);

    xlim([0,num_itr+1]);
    xticks([0:2:num_itr]);
    %xticklabels(num2str([1:1:num_itr]'));
    xtickangle(35);
    xlabel('Iterations', 'fontweight','bold', 'fontsize',13);

    ylim([0, N+1]);
    yticks([0:1:N]);
    %yticklabels({'con 2', 'con 1'});
    ylabel('Particle Number', 'fontweight','bold', 'fontsize',13);


    zlim([0 7]);
    zticks([0:1:7]);
    ztickformat('%2.1f');
    zlabel('Number of Filters', 'fontweight','bold', 'fontsize',13);

    view(45,30);
    ax = gca;
    ax.Position = [0.08 0.1 0.9 0.88];
    plot_num = plot_num + 1;
    
end


%%

for idx=1:bn_num
    
    figure(plot_num);
    set(gcf,'position',([50,50,1200,600]),'color','w')
    box on;
    grid on;
    surf(X_bn(:,:,idx));

    set(gca,'fontweight','bold', 'fontsize',13);

    xlim([0,num_itr+1]);
    xticks([0:2:num_itr]);
    %xticklabels(num2str([1:1:num_itr]'));
    xtickangle(35);
    xlabel('Iterations', 'fontweight','bold', 'fontsize',13);

    ylim([0, N+1]);
    yticks([0:1:N]);
    %yticklabels({'con 2', 'con 1'});
    ylabel('Particle Number', 'fontweight','bold', 'fontsize',13);


    zlim([0 2]);
    zticks([0:1:2]);
    ztickformat('%2.1f');
    zlabel('Number of Filters', 'fontweight','bold', 'fontsize',13);

    view(45,30);
    ax = gca;
    ax.Position = [0.08 0.1 0.9 0.88];
    plot_num = plot_num + 1;
    
end

%% Plot the path of a single parameter within a particle

particle_num = 6;
particle_name = 'FC Layer';
param_index = 3;

p = X_fc(particle_num,:,param_index);
pb = [P(particle_num,:).fc];
pb = pb(param_index,:);

gb = [G.fc];
gb = gb(param_index,:);

y_plt_step = 10;

x_min = 90;
x_max = num_itr;
y_min = floor(min(p(x_min:end))/y_plt_step)*y_plt_step;
y_max = ceil(max(p(x_min:end))/y_plt_step)*y_plt_step;

figure(plot_num)
set(gcf,'position',([50,50,1200,600]),'color','w')
hold on
grid on
box on

plot([1:num_itr], p, 'LineStyle','-', 'LineWidth', 1, 'Color','b', 'Marker', '.');

set(gca,'fontweight','bold', 'fontsize',13);

xlim([x_min x_max]);
xticks([x_min:2:x_max]);
xtickangle(90);
xlabel('Iteration', 'fontweight', 'bold', 'FontSize', 13);
set(gca,'XMinorTick','on', 'XMinorGrid','on');

ylim([y_min y_max]);
yticks([y_min:y_plt_step:y_max]);
ylabel('Value', 'fontweight', 'bold', 'FontSize', 13);
set(gca,'YMinorTick','on', 'YMinorGrid','on');

title(strcat('Particle',32,num2str(particle_num),32,'-',32,particle_name,32,'Convergence Track'),'fontweight','bold','FontSize', 16)

ax = gca;
ax.Position = [0.06 0.12 0.92 0.8];
ax.XAxis.MinorTickValues = x_min:1:x_max;
ax.YAxis.MinorTickValues = y_min:1:y_max;

plot_num = plot_num + 1;

%%
figure(plot_num);
set(gcf,'position',([50,50,1200,600]),'color','w')
box on;
grid on;

plot(g_best*100,'.-b')

plot_num = plot_num + 1;




