function [Pg, G, g_best, itr] = pso_2(objective_function, pso_params)%, function_params)
%% set up the basic data structures

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
    
%% init X and V
    for idx=1:pso_params.N
        X{idx, 1} = limit_position(pso_params.position_limits(1) + (pso_params.position_limits(2)-pso_params.position_limits(1))*rand(pso_params.ZN, pso_params.D), pso_params.position_limits);
        V{idx, 1} = limit_velocity(pso_params.velocity_limits(1) + (pso_params.velocity_limits(2)-pso_params.velocity_limits(1))*rand(pso_params.ZN, pso_params.D), pso_params.velocity_limits);
        F(idx, itr) = objective_function(X{idx,1});
    end
    
    % get the population statistics values
    [p_best(1, itr), f_min_idx] = min(F(:,itr));
    p_best(2, itr) = mean(F(:,itr));
    p_best(3, itr) = max(F(:,itr));
    g_best(itr) = p_best(1, itr);
    
    fprintf('Iteration: %03d   F_min(%03d): %2.10f\n', itr,  f_min_idx, F(f_min_idx, itr)); 
    
    % Update P and G
    for idx=1:pso_params.N
        P{idx,itr} = X{idx,1};    
    end

    G{itr} = X{f_min_idx, 1};

        
%% update V and X
    for idx=1:pso_params.N
        %V(idx, itr+1).con = kap * (V(idx,itr).con + (c1*R).*(P(idx,itr).con - X(idx,itr).con) + (c2*S).*(G(itr).con - X(idx,itr).con));
        R = rand(pso_params.ZN, pso_params.D);
        S = rand(pso_params.ZN, pso_params.D);
        V{idx, 1} = limit_velocity(pso_params.kap*(V{idx, 1} + (pso_params.c1*R).*(P{idx,1} - X{idx,1}) + (pso_params.c2*S).*(G{itr} - X{idx,1})), pso_params.velocity_limits);

        X{idx, 1} = limit_position(X{idx, 1} + V{idx, 1}, pso_params.position_limits);          
    end
     
%% start the PSO loop
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

        fprintf('Iteration: %03d   F_min(%03d): %2.10f\n', itr,  f_min_idx, F(f_min_idx, itr));         
   
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

        
        % update V and X
        for idx=1:pso_params.N
            %V(idx, itr+1).con = kap * (V(idx,itr).con + (c1*R).*(P(idx,itr).con - X(idx,itr).con) + (c2*S).*(G(itr).con - X(idx,itr).con));
            R = rand(pso_params.ZN, pso_params.D);
            S = rand(pso_params.ZN, pso_params.D);
            V{idx, 1} = limit_velocity(pso_params.kap*(V{idx, 1} + (pso_params.c1*R).*(P{idx,1} - X{idx,1}) + (pso_params.c2*S).*(G{itr} - X{idx,1})), pso_params.velocity_limits);

            X{idx, 1} = limit_position(X{idx, 1} + V{idx, 1}, pso_params.position_limits);          
        end
         
    end
    
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
