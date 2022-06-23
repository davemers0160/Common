function [t_img, t_val] = energy_threshold(img, energy_val, method)

    t_img = [];
    if((energy_val > 1.0) || (energy_val <= 0))
        fprintf('energy value must be in the following range: 0 < ev <= 1\n'); 
        return;
    end
        
    [~, ~, c] = size(img);

    if(c > 1)
        img = rgb2gray(img);
    end
    
    % this is the total energy of the input image
    intial_energy = sum(img(:));
    
    % get the min and max values for the input image
    img_min = floor(min(img(:)));
    img_max = ceil(max(img(:))); 
    
    %t_val = img_min + 1;    
    %result = 1.0;
    
    img = double(img);
    
    switch method
        case 0
            %   cycle from min+1 to max-1 on threshold values to find the tipping point
            %   where ratio of the current energy to the initial energy is l.t. the
            %   energy value threshold
            for t_val = (img_min + 1):(img_max-1)
            %while((result < energy_val) && (t_val < img_max))
                b_img = (img >= t_val);
                t_img = img .* b_img;
                current_energy = sum(t_img(:));

                result = current_energy / intial_energy;
                if(result < energy_val)
                    break;
                end
                
                %t_val = t_val + 1;
               
            end

            t_img = (img > (t_val-1));
        
        case 1
            % same as case 0, except the return image is not binary
            for t_val = (img_min + 1):(img_max-1)
            %while((result < energy_val) && (t_val < img_max))
                b_img = (img >= t_val);
                t_img = img .* b_img;
                current_energy = sum(t_img(:));

                result = current_energy / intial_energy;
                if(result < energy_val)
                    break;
                end
                
                %t_val = t_val + 1;
            end

        case 2
            % 
            for t_val = (img_min + 1):(img_max-1)
            %while((abs(1-result) > energy_val) && (t_val < img_max))
                b_img = (img >= t_val);
                t_img = img .* b_img;
                current_energy = sum(t_img(:));

                result = current_energy / intial_energy;
                if(abs(1-result) > energy_val)
                    break;
                end
                
                %t_val = t_val + 1;
            end            
            
    end
    
end