function stacked_img = stack_images(input_img, depth_map)

    stacked_img = [];
    
    if((size(input_img,1) == size(depth_map,1)) && (size(input_img,2) == size(depth_map,2)))
       stacked_img = cat(3, input_img, depth_map);
    end

end
