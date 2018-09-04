function write_net_data(data, file_name)

    file_id = fopen(file_name, 'w', 'l');
    fs = size(data);
    
    fwrite(file_id,fs(1),'uint32');
    fwrite(file_id,fs(2),'uint32');
    
    for row=1:fs(1)       
        for col=1:fs(2)           
            fwrite(file_id, single(data(row,col)), 'float32');
        end       
    end

    fclose(file_id);

end