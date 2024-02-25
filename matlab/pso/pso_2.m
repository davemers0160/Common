function [Pg, G, g_best, P, itr, img] = pso_2(objective_function, pso_params, X_in)
%% set up the basic data structures

    pso_fig = figure;
    set(pso_fig,'position',([50,200,1000,600]),'color','w')
    set(gca,'fontweight','bold','FontSize',13);
    ax = gca;

    % F represents the results of evaluating the objective function
    F = zeros(pso_params.N, pso_params.itr_max+1);
    
    % X represents the population to be tested for a given iteration
    X = cell(pso_params.N, 1);
    
    % V represents the velocity vectors for a given iteration
    V = cell(pso_params.N, 1);

    % P represents the best poplation member for that iteration
%    P = cell(pso_params.N, pso_params.itr_max+1);
    P = cell(pso_params.N, 1);
    
    % G represents the best population member for all iterations
    G = cell(pso_params.itr_max+1, 1);
    
    % p_best contains the info about the best results for each iteration
    p_best = zeros(3, pso_params.itr_max+1);
    
    % g_best contains the info about the best results overall
    g_best = zeros(1, pso_params.itr_max+1);
    
    itr = 1;
    img_count = 1;
    img = {};
    
%% init X and V
    x_start = 1;
    if(~isempty(X_in))
        X{x_start, 1} = X_in;
        V{x_start, 1} = pso_params.velocity_limits(1,:) + (pso_params.velocity_limits(2,:)-pso_params.velocity_limits(1,:)).*rand(pso_params.ZN, pso_params.D);
        F(x_start, itr) = objective_function(X{x_start,1});
        x_start = 2;
    end
    
    for idx=x_start:pso_params.N
        X{idx, 1} = pso_params.position_limits(1,:) + (pso_params.position_limits(2,:)-pso_params.position_limits(1,:)).*rand(pso_params.ZN, pso_params.D);
        V{idx, 1} = pso_params.velocity_limits(1,:) + (pso_params.velocity_limits(2,:)-pso_params.velocity_limits(1,:)).*rand(pso_params.ZN, pso_params.D);
        F(idx, itr) = objective_function(X{idx,1});
    end
    
    % get the population statistics values
    [p_best(1, itr), f_min_idx] = min(F(:,itr));
    p_best(2, itr) = mean(F(:,itr));
    p_best(3, itr) = max(F(:,itr));
    g_best(itr) = p_best(1, itr);
    
    fprintf('Iteration: %04d   F_min(%04d): %2.14f\n', itr,  f_min_idx, F(f_min_idx, itr)); 
    
    % Update P and G
    for idx=1:pso_params.N
        P{idx,1} = X{idx,1};    
    end

    G{itr} = X{f_min_idx, 1};

%     img{end+1} = plot_pso(ax, P, G, p_best, itr, pso_params.N, pso_params.position_limits);
        
%% update V and X
    for idx=1:pso_params.N
        %V(idx, itr+1).con = kap * (V(idx,itr).con + (c1*R).*(P(idx,itr).con - X(idx,itr).con) + (c2*S).*(G(itr).con - X(idx,itr).con));
        R = rand(pso_params.ZN, pso_params.D);
        S = rand(pso_params.ZN, pso_params.D);
        V{idx, 1} = limit_velocity(pso_params.kap*(V{idx, 1} + (pso_params.c1*R).*(P{idx,1} - X{idx,1}) + (pso_params.c2*S).*(G{itr} - X{idx,1})), pso_params.velocity_limits);

        X{idx, 1} = limit_position(X{idx, 1} + V{idx, 1}, pso_params.position_limits);          
    end
     
%% start the PSO loop

    ZN = pso_params.ZN;
    D = pso_params.D;

    while((itr <= pso_params.itr_max) && (g_best(itr) > pso_params.min_error))  
        
        itr = itr + 1; 
     
        % evaluate F(X,Z)
        %d = cell(pso_params.ZN, pso_params.N);
        %m_idx = zeros(pso_params.ZN, pso_params.N);
        for idx=1:pso_params.N
            F(idx, itr) = objective_function(X{idx,1});
        end        
        
        % get the population statistics values
        [p_best(1, itr), f_min_idx] = min(F(:,itr));
        p_best(2, itr) = mean(F(:,itr));
        p_best(3, itr) = max(F(:,itr));

        fprintf('Iteration: %04d   F_min(%04d): %2.14f\n', itr,  f_min_idx, F(f_min_idx, itr));         
   
        % Update P and G
        for idx=1:pso_params.N
            if(F(idx,itr) < F(idx,itr-1))
                P{idx,1} = X{idx,1};
%             else
%                 P{idx,1} = P{idx,itr-1};
            end
        end

        if(p_best(1, itr) < g_best(itr-1))
            G{itr} = X{f_min_idx, 1};
            g_best(itr) = p_best(1, itr);
        else
            G{itr} = G{itr-1};
            g_best(itr) = g_best(itr-1);
        end         

        if (mod(itr, 10) == 0)
%             img{end+1} = plot_pso(ax, P, G, p_best, itr, pso_params.N, pso_params.position_limits);
        end
        
        % update V and X
        parfor idx=1:pso_params.N
            %V(idx, itr+1).con = kap * (V(idx,itr).con + (c1*R).*(P(idx,itr).con - X(idx,itr).con) + (c2*S).*(G(itr).con - X(idx,itr).con));
            R = rand(ZN, D);
            S = rand(ZN, D);
            V{idx, 1} = limit_velocity(pso_params.kap*(V{idx, 1} + (pso_params.c1*R).*(P{idx,1} - X{idx,1}) + (pso_params.c2*S).*(G{itr} - X{idx,1})), pso_params.velocity_limits);

            X{idx, 1} = limit_position(X{idx, 1} + V{idx, 1}, pso_params.position_limits);          
        end
         
    end
    
%     img{end+1} = plot_pso(ax, P, G, p_best, itr, pso_params.N, pso_params.position_limits);

    Pg = G{itr};

end

%% particle limiting function
function X = limit_position(X, position_limits)
      
    X = max(min(X, position_limits(2,:)), position_limits(1,:));
        
end

%% velocity limiting function
function V = limit_velocity(V, velocity_limits)

    %for idx=1:numel(V)
    V = max(min(V, velocity_limits(2,:)), velocity_limits(1,:));
    %end

end

%%
function [img] = plot_pso(fig_handle, P, G, p_best, itr, N, position_limits)

    P = cell2mat(P);
    hold off
    s1 = scatter3(fig_handle, P(:,1), P(:,2), P(:,3), 5, 'filled', 'b');
    hold on
    s2 = scatter3(fig_handle, G{itr,1}(1), G{itr,1}(2), G{itr,1}(3), 25, 'filled', 'r');
    set(gca,'fontweight','bold','FontSize',13);
    xlim(position_limits(:,1))
    ylim(position_limits(:,2))
    zlim(position_limits(:,3))
    
    xlabel('X (mi)','fontweight','bold','FontSize',13);
    ylabel('Y (mi)','fontweight','bold','FontSize',13);
    zlabel('Z (mi)','fontweight','bold','FontSize',13);
    
    title(strcat('Population:', 32, num2str(N), ', Iteration:', 32, num2str(itr, '%04d'), ', Error:', 32, num2str(p_best(1, itr), '%2.5g')), 'FontSize',13);
    legend([s1, s2], {'Candidate Solutions', strcat('Global Best Solution: [', num2str(G{itr,1}(1),'%2.5f'),',',32,num2str(G{itr,1}(2),'%2.5f'),',',32,num2str(G{itr,1}(3),' %2.5f'),']')}, 'fontweight','bold', 'location', 'southoutside', 'orientation','horizontal'); 
    drawnow
    
    img = frame2im(getframe(gcf));

end