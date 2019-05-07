function [x] = limit_check(x, x_lim, count)
   
    num_vars = size(x_lim, 1);
    for idx=1:count
        for jdx=1:num_vars
             if(x(jdx,idx) < x_lim(jdx,1))
                x(jdx,idx) = x_lim(jdx,1);
            elseif(x(jdx,idx) > x_lim(jdx,2))
                x(jdx,idx) = x_lim(jdx,2);
            end
        end        
    end

end