
function data_line = generate_apt_line(sync_bits, line_num, img)

    data_line = [];
    frame_line = mod(line_num, 128);
    
    [img_h, img_w, ~] = size(img);
    
    % Sync
    for idx=1:numel(sync_bits)
        data_line(end+1) = 255*sync_bits(idx);
    end
    
    % Space
    for idx=1:47
        data_line(end+1) = 0;
    end

    % Image
    if (line_num <= img_h)
        for idx=1:img_w
            data_line(end+1) = img(line_num, idx);
        end
    else
        for idx=1:img_w
            data_line(end+1) = 0;
        end
    end

    % Telemetry
    for idx=1:45
        wedge = floor(frame_line / 8);
        v = 0;
        if (wedge < 8) 
            wedge = wedge + 1;
            v = floor(255.0 * (mod(wedge, 8) / 8.0));
        end
        data_line(end+1) = v;
    end
    
end
    