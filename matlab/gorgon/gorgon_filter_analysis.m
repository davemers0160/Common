function [layer, u] = gorgon_filter_analysis(filename)
    plot_num = 1;
    [gorgon_data, gorgon_struct] = read_gorgon_data(filename);
    [filepath,~,~] = fileparts(filename);

    %figure out the layer type based on the number of rows and columns
    if(gorgon_struct.nr==1 && gorgon_struct.nc==1)
        lt = 1;
    else
        lt = 2;
    end

    %% vectorize the results to perform various operations
    
    x=zeros([numel(gorgon_data), size(gorgon_data{1}.data(:),1)]);
    t=zeros([size(gorgon_data{1}.data), numel(gorgon_data)]);
    
    for idx=1:numel(gorgon_data)
        x(idx,:) = gorgon_data{idx}.data(:);   
        t(:,:,idx) = gorgon_data{idx}.data;
    end

%     min_x = min(x(:));
%     max_x = max(x(:));
    std_x = std(x(:));
    mean_x = mean(x(:));
    
    
    min_x = mean_x-3*std_x;
    max_x = mean_x+3*std_x;
    
    %fprintf('min: %3.4f, max: %3.4f\n\n', min_x, max_x);

    % get sub plot sizes
    s_x = ceil(sqrt(gorgon_struct.k)*1.2);
    s_y = ceil(gorgon_struct.k/s_x);

    %% plot all of the outputs
if(false)
    %c = colormap(jet(numel(gorgon_data)));
    figure(plot_num)
    set(gcf,'position',([100,100,1200,650]),'color','w', 'Name', 'Filter Output')
    hold on
    grid on
    box on
    for idx=1:numel(gorgon_data)

        if(lt==1)       % ploting the outputs of the fully connected layers
            scatter(idx,t(:,:,idx), 20, 'b', 'filled');
        else            % ploting the outputs of the filters in raster row order

            subplot(s_y,s_x,idx);

            image(255*(t(:,:,idx)-min_x)/(max_x-min_x));
            colormap(jet(256));
            axis off
            title(strcat(num2str(idx,'%03d')),'fontweight','bold', 'FontSize', 18);
        end
    end

    if(lt==1)
        step = 1;
        if(gorgon_struct.k>10)
            step = 10;
        end
        set(gca, 'fontweight','bold', 'FontSize', 13);
        xlim([0 gorgon_struct.k+1]);
        xticks([0:step:gorgon_struct.k]);
        xlabel('Filter Number');
        ylabel('Filter Output Value');
        ax = gca;
        ax.Position = [0.065 0.12 0.9 0.8];        
    end
    
    drawnow;
    print(plot_num, '-dpng', fullfile(filepath,strcat('filter_output_',num2str(gorgon_struct.layer,'%02d'),'.png')));

    plot_num = plot_num + 1;
end

%% SOM
    coverSteps = 100;
    initNeighbor = 2;
    topologyFcn = 'gridtop'; %'hextop'; %
    distanceFcn = 'linkdist';

    net = selforgmap([gorgon_struct.k,1], coverSteps, initNeighbor, topologyFcn, distanceFcn);
    net.performParam.regularization = 0.2;
    net.trainParam.epochs = 200;
    % net.biasConnect(1)=1;
    %g = gpuArray(single(x'));
    %net = train(net,g,'useParallel','yes');
    
    x = x';
    net = train(net,x);

    y = net(x);
    y_s = sum(y,2);

    classes = vec2ind(y);
    u = unique(classes);

    figure(plot_num)
    set(gcf,'position',([50,50,1000,500]),'color','w')
    %plotsomhits(net,x');
    b=bar(y_s);
    grid on
    box on
    b.FaceColor = 'b';
    set(gca, 'fontweight','bold', 'FontSize', 13);
    xlim([0 gorgon_struct.k+1]);
    %xticks([1:1:gorgon_struct.k]);
    ylim([0 (max(y_s)+1)]);
    yticks([0:1:(max(y_s)+1)]);
    xlabel('Filter Class Number');
    ylabel('Filters in Class');
    title(strcat('Layer:',32,num2str(gorgon_struct.layer),' - Unique Classes:',32,num2str(numel(u))));
    
    ax = gca;
    ax.Position = [0.08 0.12 0.9 0.8]; 
    
    print(plot_num, '-dpng', fullfile(filepath,strcat('som_results_',num2str(gorgon_struct.layer,'%02d'),'.png')));

    plot_num = plot_num + 1;
    layer = gorgon_struct.layer;

    %% Plot the SOM classification results
    
    if(false)
        classes = vec2ind(y);
        u = unique(classes);
        c = colormap(jet(numel(u)));

        figure(plot_num);
        set(gcf,'position',([100,100,1200,650]),'color','w', 'Name','SOM Cluster')
        count = 1;
        hold on
        box on
        grid on
        for idx=1:numel(u)

            index = find(classes==u(idx));

            for jdx=1:numel(index)
                if(lt==1)       % ploting the outputs of the fully connected layers
                    scatter(idx,t(:,:,index(jdx)), 15, c(idx,:), 'filled');
                else            % ploting the outputs of the filters in raster row order
        %             tmp = t(:,:,index(jdx));
        %             plot(tmp(:),'Color',c(idx,:));

                    subplot(s_y,s_x,count);
                    imshow(t(:,:,index(jdx)),[min_x,max_x]);
                    image(255*(t(:,:,index(jdx))-min_x)/(max_x-min_x));
                    axis off
                    colormap(jet(256));
                    title(strcat(num2str(u(idx)),':',num2str(index(jdx),'%03d')),'fontweight','bold','FontSize', 20);
                    count = count + 1;
                end
            end
            %drawnow;
        end

        if(lt==1)
            step = 1;
            if(gorgon_struct.k>10)
                step = 10;
            end
            set(gca, 'fontweight','bold', 'FontSize', 13);
    %         xlim([0 gorgon_struct.k+1]);
    %         xticks([0:step:gorgon_struct.k]);
            xlabel('Filter Number');
            ylabel('Filter Output Value');
            ax = gca;
            ax.Position = [0.065 0.12 0.9 0.8];        
        end

        drawnow;
        print(plot_num, '-dpng', fullfile(filepath,strcat('som_cluster_',num2str(gorgon_struct.layer,'%02d'),'.png')));

        plot_num = plot_num + 1;
    end
    %%
    
end
