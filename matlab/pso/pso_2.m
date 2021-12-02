%function [g_best, err, itr] = pso_2(pso_params, object_function, particle_params, position_limits, velocity_limits)


    


    %% PSO params/member setup
    pso_params = struct();
    pso_params.c1 = 2.4;
    pso_params.c2 = 2.1;
    pso_params.phi = pso_params.c1 + pso_params.c2;
    pso_params.kap = 2/(abs(2 - pso_params.phi - sqrt(pso_params.phi^2 - 4*pso_params.phi)));
    pso_params.itr_max = 100;                                       % number of iterations
    pso_params.N = 40;                                              % population size         
    pso_params.position_limits = [0, 0, 0; 100, 100, 100];          % bounds to place on the search area
    pso_params.velocity_limits = [-1, -1, -0.5; 1, 1, 0.5];         % bounds to place on how fas the particle can move
    pso_params.D = 3;
    pso_params.ZN = 5;
    
    % used to define the data type for each of the members within the particle
    particle = struct('x', 'double', 'y', 'double', 'z', 'double');
    
    
    %% set up the basic data structures

    % F represents the results of evaluating the objective function
    F = zeros(pso_params.N, pso_params.itr_max+1);
    
    % X represents the population to be tested for a given iteration
    X = cell(pso_params.N, 1);
    
    % V represents the velocity vectors for a given iteration
    V = cell(pso_params.N, 1);

    % P represents the best poplation member for that iteration
    P = cell(pso_params.N, pso_params.itr_max+1);
    
    % G represents the best population member for all iterations
    G = cell(pso_params.itr_max+1, 1);
    
    % p_best contains the info about the best results for each iteration
    p_best = zeros(3, pso_params.itr_max+1);
    
    % g_best contains the info about the best results overall
    g_best = zeros(1, pso_params.itr_max+1);
    
    itr = 1;
    
    %% init X and V
    for idx=1:pso_params.N
        X{idx, 1} = pso_params.position_limits(1) + (pso_params.position_limits(2)-pso_params.position_limits(1))*rand(pso_params.ZN, pso_params.D);
        V{idx, 1} = pso_params.velocity_limits(1) + (pso_params.velocity_limits(2)-pso_params.velocity_limits(1))*rand(pso_params.ZN, pso_params.D);
        
        % [err] = calc_tdoa_error(P, T, S, v)
        %F(idx, itr) = calc_tdoa_error(X{idx,1}, );
    end

    bp = 1;
    


%end


