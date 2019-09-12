function write_binary_iq_data(filename, data, data_type)

    file_id = fopen(filename,'w');
    
    % check to see if the data is complex or real
    if(isreal(data))        
        % assumes that the data is written column form [I, Q]
        for idx=1:size(data,1)
            fwrite(file_id, data(idx,:), data_type, 'ieee-le');
        end
    else
        for idx=1:numel(data)
            iq = [real(data(idx)) imag(data(idx))];
            fwrite(file_id, iq, data_type, 'ieee-le');
        end
      
    end
    
    fclose(file_id);

end
