function gorgon_filter_analysis(filename)
    plot_num = 1;
    [gorgon_data, gorgon_struct] = read_gorgon_data(filename);
    [filepath,~,~] = fileparts(filename);
    
%     fprintf('\nGorgon Data Capture:\n');
%     fprintf('  Layer:      %03d\n',gorgon_struct.layer);
%     fprintf('  N:         %04d\n', gorgon_struct.n);
%     fprintf('  K:         %04d\n', gorgon_struct.k);
%     fprintf('  NR:        %04d\n', gorgon_struct.nr);
%     fprintf('  NC:        %04d\n', gorgon_struct.nc);
%     fprintf('\n');

    %figure out the layer type based on the number of rows and columns
    if(gorgon_struct.nr==1 && gorgon_struct.nc==1)
        lt = 1;
    else
        lt = 2;
    end

    %% vectorize the results to perform various operations
    x=[];
    t=[];
    for idx=1:numel(gorgon_data)
        x(idx,:) = gorgon_data{idx}.data(:);   
        t(:,:,idx) = gorgon_data{idx}.data;
    end

    min_x = min(x(:));
    max_x = max(x(:));

    %fprintf('min: %3.4f, max: %3.4f\n\n', min_x, max_x);

    % get sub plot sizes
    s_x = ceil(sqrt(gorgon_struct.k)*1.2);
    s_y = ceil(gorgon_struct.k/s_x);

    %% plot all of the outputs

    c = colormap(jet(numel(gorgon_data)));
    figure(plot_num)
    set(gcf,'position',([100,100,1200,650]),'color','w', 'Name', 'Filter Output')
    hold on
    grid on
    box on
    for idx=1:numel(gorgon_data)

        if(lt==1)       % ploting the outputs of the fully connected layers
            scatter(idx,t(:,:,idx), 15, 'b', 'filled');
        else            % ploting the outputs of the filters in raster row order

            subplot(s_y,s_x,idx);

            image(255*(t(:,:,idx)-min_x)/(max_x-min_x));
            colormap(jet(256));
            axis off
            title(strcat(num2str(idx,'%03d')));
        end
    end

    drawnow;
    print(plot_num, '-dpng', fullfile(filepath,strcat('filter_output_',num2str(gorgon_struct.layer,'%02d'),'.png')));

    plot_num = plot_num + 1;
    
%% SOM
    coverSteps = 100;
    initNeighbor = 3;
    topologyFcn = 'gridtop'; %'hextop'; %
    distanceFcn = 'linkdist';

    net = selforgmap([gorgon_struct.k,1], coverSteps, initNeighbor, topologyFcn, distanceFcn);
    net.performParam.regularization = 0.2;
    net.trainParam.epochs = 200;

    net = train(net,x');

    y = net(x');
    y_s = sum(y,2);

    classes = vec2ind(y);
    u = unique(classes);

    figure(plot_num)
    set(gcf,'position',([50,50,1000,500]),'color','w')

    %plotsomhits(net,x');
    b=bar(y_s);
    b.FaceColor = 'b';
    title(strcat('Layer:',32,num2str(gorgon_struct.layer),' - Unique Classes:',32,num2str(numel(u))));
    print(plot_num, '-dpng', fullfile(filepath,strcat('som_results_',num2str(gorgon_struct.layer,'%02d'),'.png')));

    plot_num = plot_num + 1;
    
    fprintf('Layer: %03d\t Unique Classes: %03d\n',gorgon_struct.layer, numel(u));

    %% Plot SOM

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
                title(strcat(num2str(u(idx)),':',num2str(index(jdx),'%03d')));
                count = count + 1;
            end
        end
        %drawnow;
    end
    drawnow;
    print(plot_num, '-dpng', fullfile(filepath,strcat('som_cluster_',num2str(gorgon_struct.layer,'%02d'),'.png')));

    plot_num = plot_num + 1;
    

end