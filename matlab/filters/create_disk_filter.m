function [kernel] = create_disk_filter(level, R, classes)

% r*r >= x*x + y*y    

    kernel = zeros(2*R,2*R);
    
    for r=-floor(R):1:floor(R)
        for c=-floor(R):1:floor(R)
            
            C1 = (classes-level)*R/classes;
            if((r*r+c*c)<=C1*C1)
                kernel(r+floor(R)+1,c+floor(R)+1) = level;
            end
        end
    end

    kernel = 1/sum(kernel(:))*kernel;
    
end