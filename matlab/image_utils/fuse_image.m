function [img] = fuse_image(img1, img2, a1, a2)

    % check the image size to make sure they are similar.  If not then crop
    % acordingly
    [img_h1, img_w1, img_c1] = size(img1);
    [img_h2, img_w2, img_c2] = size(img2);
    
    if((img_h1 ~= img_h2) || (img_w1 ~= img_w2))
        img_h = min(img_h1,img_h2);
        img_w = min(img_w1,img_w2);
        img1 = img1(1:img_h, 1:img_w,:);
        img2 = img2(1:img_h, 1:img_w,:);        
    end
    
    % check the channels
    if(img_c1 ~= img_c2)
        if(img_c1 < 3)
            img1 = cat(3,img1,img1,img1);
        end
        
        if(img_c2 < 3)
            img2 = cat(3,img2,img2,img2);
        end
    end

    img = a1*double(img1) + a2*double(img2);

end
