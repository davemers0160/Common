function [layer_img] = build_layer_image(ls, ld, cell_dim, padding, map_length)

    cm = jet(map_length);
    
    min_v = min(ld.Value);
    max_v = max(ld.Value);
    img_array = floor(map_length*(ld.Value - min_v)/(max_v - min_v));
    
    nr = ls.nr;
    nc = ls.nc;
    img_length = nr*nc;
    
    img_h = (nr + padding)*(cell_dim(1)-1) + nr;
    img_w = (nc + padding)*(cell_dim(2)-1) + nc;
    layer_img = zeros(img_h, img_w, 3);

    r = 1;
    c = 1;

    for idx=1:ls.k
        p1 = ((idx - 1)*(img_length)) + 1;
        p2 = (idx *(img_length));
        %tmp = floor(img_array([p1:p2]));
        layer_img(r:r+nr-1,c:c+nc-1,:) = ind2rgb(reshape(img_array([p1:p2]), nr, nc)', cm);

        %layer_img(r:r+ls_12.nr-1,c:c+ls_12.nc-1,:) = l12_img;

        c = c + (nc + padding);
        if(c > img_w)
            c = 1;
            r = r + (nr + padding);
        end

    end

end