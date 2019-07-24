function [score] = get_dct_sharpness(img, threshold)

    [img_h, img_w, img_d]=size(img);
    
    if(img_d > 1)
        img = rgb2gray(img);
    end
    
    C = log(abs(dct2(img)));
    
    Tn = (C >= threshold);
    Tn = sum(Tn(:));
    
    score = Tn/(img_h*img_w);
    
end
