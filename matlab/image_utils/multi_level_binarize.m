function binary_image = multi_level_binarize(img, levels)

    num_levels = size(levels, 1);

    % add 0 to the levels to make the looping easier
    % if(levels(1) ~= 0)
    %     levels = [0; levels];
    % end
    % 

    % get the image sie
    [img_h, img_w, img_c] = size(img);

    % only binarize one channel
    if(img_c > 1)
        img = img(:,:,1);
    end

    binary_image = zeros(img_h, img_w);
    % loop through the image
    for r = 1:img_h
        for c = 1:img_w

            for idx=1:num_levels

                if(img(r,c) <= levels(idx, 3))
                    if(img(r,c) >= levels(idx,2))
                        binary_image(r,c) = idx;
                    else
                        binary_image(r,c) = -num_levels+idx;
                    end
                    break;
                end

            end
        end
    end



end
