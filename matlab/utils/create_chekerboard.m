function [cb] = create_chekerboard(block_h, block_w, img_height, img_width, channels)

    cb = zeros(img_height + block_h, img_width + block_w, channels);
    white = 255*ones(block_h, block_w, channels);

    color_row = false;
    color_column = false;

    for idx = 1:block_h:img_height
        color_row = ~color_row;
        color_column = color_row;

        for jdx = 1:block_w:img_width
            if (color_column)
                cb(idx:idx+block_h-1, jdx:jdx+block_w-1, :) = white;
            end
            color_column = ~color_column;
        end
    end

end
