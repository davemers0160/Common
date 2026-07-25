function [canvas, layout_info] = pack_spectrogram_levels(spectrograms, pad, pad_val)
    num_levels = length(spectrograms);
    
    % Pre-allocate metadata struct
    layout_info = struct('level', [], 'fft_size', [], 'bbox', []);
    
    % Gather dimensions [height, width] of each raw spectrogram
    dims = zeros(num_levels, 2);
    for i = 1:num_levels
        dims(i, :) = size(spectrograms{i});
    end
    
    % Total padded dimensions for each level
    padded_dims = dims + 2 * pad;
    
    % Estimate target shelf width (approx sqrt of total area for a balanced layout)
    total_area = sum(padded_dims(:,1) .* padded_dims(:,2));
    target_width = ceil(sqrt(total_area) * 1.2); 
    
    % Place rectangles onto shelves
    x_cursor = 0;
    y_cursor = 0;
    current_shelf_height = 0;
    
    positions = zeros(num_levels, 2); % [x, y] top-left coordinates (1-indexed)
    
    for i = 1:num_levels
        w = padded_dims(i, 2);
        h = padded_dims(i, 1);
        
        % Move to next shelf if current width exceeds target width
        if (x_cursor + w > target_width) && (x_cursor > 0)
            x_cursor = 0;
            y_cursor = y_cursor + current_shelf_height;
            current_shelf_height = 0;
        end
        
        positions(i, :) = [x_cursor + 1, y_cursor + 1];
        x_cursor = x_cursor + w;
        current_shelf_height = max(current_shelf_height, h);
    end
    
    % Calculate total canvas dimensions needed
    canvas_w = max(positions(:,1) + padded_dims(:,2) - 1);
    canvas_h = max(positions(:,2) + padded_dims(:,1) - 1);
    
    % Initialize Canvas
    canvas = ones(canvas_h, canvas_w) * pad_val;
    
    % Paste padded spectrograms into canvas
    for i = 1:num_levels
        px = positions(i, 1);
        py = positions(i, 2);
        
        % Unpadded spectrogram coordinates
        x_start = px + pad;
        x_end   = x_start + dims(i, 2) - 1;
        y_start = py + pad;
        y_end   = y_start + dims(i, 1) - 1;
        
        % Insert magnitude data
        canvas(y_start:y_end, x_start:x_end) = spectrograms{i};
        
        % Store bounding box [x, y, width, height] including padding
        layout_info(i).level = i;
        layout_info(i).bbox = [px, py, padded_dims(i, 2), padded_dims(i, 1)];
    end
end
