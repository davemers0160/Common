function lut_img = apply_false_color(img_in, lut)

    [img_h, img_w] = size(img_in);
    img_w = floor(img_w/2);
    
    
    % break up the image into vis and ir
    vis_img = img_in(:, 1:img_w);
    ir_img = img_in(:, (img_w+1):end);
    
    lut_img = zeros(img_h, img_w, 3);
    
    
    % run through the images and the lut, us ir as x and vis as y
    for r=1:img_h
        for c=1:img_w
            x = ir_img(r,c) + 1;            % +1 for matlab
            y = vis_img(r,c) + 1;           % +1 for matlab
            
            lut_img(r,c,:) = lut(y,x,:);
        end
    end



end