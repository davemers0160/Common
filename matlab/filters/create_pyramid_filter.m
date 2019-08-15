function [kernel] = create_pyramid_filter(level, R, classes)

% r*r >= x*x + y*y    

    kernel = zeros(2*R,2*R);
    
    for r=-floor(R):1:floor(R)
        for c=-floor(R):1:floor(R)
            for h=1:level
                C1 = (classes-h)*R/classes;
                if((r*r+c*c)<=C1*C1)
                    kernel(r+floor(R)+1,c+floor(R)+1) = h;
                end
            end
        end
    end

    kernel = 1/sum(kernel(:))*kernel;
    
end
% 
% H1=100;
% k = zeros(d,d);
% 
% for r=-floor(R):1:floor(R)
%     for c=-floor(R):1:floor(R)
%         
%         
%         for h=1:H1
%             C1 = (m-h)*R/m;
%             if(C1*C1>=(r*r+c*c))
%                 k(r+floor(R)+1,c+floor(R)+1) = h; 
%             end
%         end
%     end
% end
