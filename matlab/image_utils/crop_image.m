function img_crop = crop_image(img, crop_c, crop_h, crop_w)

    top = max(floor(crop_c(1) - crop_h/2), 0);
    bottom = min(ceil(crop_c(1) + crop_h/2) - 1, size(img,1));
    left = max(floor(crop_c(2) - crop_w/2), 0);
    right = min(ceil(crop_c(2) + crop_w/2) - 1, size(img,2));    

    img_crop = img(top:bottom, left:right);

end

% function img_crop = crop_image(img, crop_t, crop_b, crop_l, crop_r)
% 
% %     top = max(floor(crop_c(1) - crop_h/2), 0);
% %     bottom = min(ceil(crop_c(1) + crop_h/2), size(img,1));
% %     left = max(floor(crop_c(2) - crop_w/2), 0);
% %     right = min(ceil(crop_c(2) + crop_w/2), size(img,2));    
% 
%     img_crop = img(crop_t:crop_b, crop_l:crop_r);
% 
% end