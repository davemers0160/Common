function [P_min, F_min] = nelder_mead(f, n, num_points, limits, max_itr)

    %limits = nx2 - [min, max]

    err = 1e-4;
    
    rho = 1;
    chi = 2;
    gamma = 0.5;
    
    %num_points = n + 2;

    % select n+1 starting points
    P = limits(:,1) + (limits(:,2) - limits(:,1)).*rand(n, num_points);
        
    for idx=1:max_itr        
        
        % evaluate each point
        for jdx=1:num_points
            
            % apply limits
            P(:, jdx) = max(min(P(:, jdx), limits(:,2)), limits(:,1));

            F(jdx) = f(P(:,jdx));

        end

        % sort the results: smallest to largest F
        [F, index] = sort(F, 'ascend');

        P = P(:, index);

        % compute pg, the centroid (center of gravity) of the best n points
        Pg = sum(P, 2)/n;

        % reflect the worst vertex, in pg using a reflection coefficient rho > 0 to obtain the reflection point
        Pr = Pg + rho*(Pg - P(:, end));

        % evaluate f at Pr to obtain Fr
        Fr = f(Pr);

        if((F(1) <= Fr) && (Fr < F(end-1)))

            P(end) = Pr;

        elseif(Fr < F(1))
            % increase the distance traveled using an expansion coefficient
            Pe = Pg + chi*(Pr - Pg);

            Fe = f(Pe);
            if(Fe < Fr)
                P(:,end) = Pe;
            else
                P(:,end) = Pr;
            end

        else
            if((Fr >= F(n)) && (Fr < F(end)))
                Pc = Pg + gamma*(Pr - Pg);
            else
                Pc = Pg + gamma*(P(:,end) - Pg);
            end

            Fc = f(Pc);

            if(Fc <= F(end))
                P(:,end) = Pc;
            else
                for jdx=2:num_points
                    P(:,jdx) = P(:,1) + 0.5*(P(:,jdx) - P(:,1));
                end
            end

        end
                
    end
    
    P_min = P(:,1);
    F_min = F(:,1);

end
