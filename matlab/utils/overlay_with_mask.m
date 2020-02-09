function img = overlay_with_mask(img, block, mask, x, y)
    
    for r = 1:size(block,1)
        for c = 1:size(block,2)
            if(mask(r,c) == 1)
                img(r+y, c+x, :) = block(r, c, :);
            end
        end
    end
    
end
