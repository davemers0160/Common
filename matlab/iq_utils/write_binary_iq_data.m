function write_binary_iq_data(filename, data, data_type)

    file_id = fopen(filename,'w');
    
    % check to see if the data is complex or real
    if(isreal(data))        
        
        
        % assumes that the data is written column form [I, Q]
        iq = data.';
        fwrite(file_id, iq(:), data_type, 'ieee-le');
        
        
%         for idx=1:size(data,1)
%             fwrite(file_id, data(idx,:), data_type, 'ieee-le');
%         end
    else
        iq = cat(1, real(data), imag(data));
        fwrite(file_id, iq(:), data_type, 'ieee-le');
      
    end
    
    fclose(file_id);

end
