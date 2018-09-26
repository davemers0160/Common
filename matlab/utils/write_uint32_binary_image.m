function write_uint32_binary_image(filename, data)

    % write the data in little endian format
    file_id = fopen(filename, 'w', 'l');

    [h, w] = size(data);
    
    fwrite(file_id, uint32(h), 'uint32');
    fwrite(file_id, uint32(w), 'uint32');
    
    for r=1:h
        for c=1:w
            fwrite(file_id, uint32(data(r,c)), 'uint32');  
        end
    end
    
    fclose(file_id);
    
end
