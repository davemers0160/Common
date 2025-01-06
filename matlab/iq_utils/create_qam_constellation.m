function [iq_map, gray_code] = create_qam_constellation(num_bits)

    if(mod(num_bits,2) ~= 0)
        fprintf('number of bit must be even.\n');
        iq_map = [];
        return;
    end
    
    M = bitshift(1, num_bits);
    side_length = floor(sqrt(M)+0.5);
    
    scale = 1/(side_length-1);
    
    % create the gray code
    gray_code = zeros(M,1);
    for idx=0:M-1
        gray_code(idx+1,1) = bitxor(idx, bitshift(idx, -1)); 
    end
      
    iq_map = zeros(M,1);

    for r = 0:side_length-1
        for c = 0:side_length-1

            if(mod(r,2) == 0)
                index = c + (side_length*r);            
            else            
                index = (side_length*(r+1)-1) - c;
            end

            iq_map(gray_code(index+1)+1, 1) = scale*complex(-(side_length-1) + 2*r, -(side_length-1) + 2*c);
        end
    end

end
