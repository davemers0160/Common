function J = calc_fitness(d, m)

    N = size(d,1);
    J = 0;
    
    for idx=1:N
        
        % cluster loop - looking at each cluster
        count = 0;
        tmp_j = 0;
        for jdx=1:N
            if(m(jdx,1) == idx)
                %tmp_j = tmp_j + d{idx}(m(jdx,1));
                J = J + d{idx}(m(jdx,1));
                count = count + 1;
            end          
        end
        
        if(count ~= 0)
            J = J + (tmp_j/count);
        end    
    end
    
    J = J/numel(unique(m));

end