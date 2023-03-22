function [imgs] = generate_tiles(img, tile_w, tile_h, overlap_x, overlap_y)

    [img_h, img_w, ~] = size(img);

%     image_tile = struct('img', [], 'rect', []);
    imgs = {};

    row = 1;
    while (row <= img_h)
    
        col = 1;
        while (col <= img_w)
        
%             t_w = (col + tile_w >= img_w) ? img_w - col : tile_w;
            if(col + tile_w > img_w)
                t_w = img_w - col;
            else
                t_w = tile_w;
            end
            
%             t_h = (row + tile_h >= img_h) ? img_h - row : tile_h;
            if(row + tile_h > img_h)
                t_h = img_h - row;
            else
                t_h = tile_h;
            end    
            
            rx = col:(col+t_w);
            ry = row:(row+t_h);
            
%             tmp_img = img(ry, rx, :);

            tmp_tile = struct('img', img(ry, rx, :), 'rect', [col, row, t_w, t_h]);

            imgs{end+1} = tmp_tile;

            col = col + (tile_w - overlap_x);        
        end

        row = row + (tile_h - overlap_y);
    end

end