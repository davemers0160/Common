function write_binary_iq_data(filename, data, data_type, byte_order)
% only supports the following data types: 'double', 'single', 'uint8', 'int8', 'uint16', int16', 'uint32', 'int32', 'uint64, 'int64'
% byte_order: 'ieee-le' or 'ieee-be' depending on how the data was saved
%
% ex: [iq, i_data, q_data] = write_binary_iq_data('iq_file.dat', iq_data, 'double', 'ie-leee')

    file_id = fopen(filename,'w');
    
    % check to see if the data is complex or real
    if(isreal(data))        
        
        
        % assumes that the data is written column form [I, Q]
        iq = data.';
        fwrite(file_id, iq(:), data_type, byte_order);
        
        
%         for idx=1:size(data,1)
%             fwrite(file_id, data(idx,:), data_type, 'ieee-le');
%         end
    else
        data = data(:);
        iq = cat(1, real(data).', imag(data).');
        fwrite(file_id, iq(:), data_type, byte_order);
      
    end
    
    fclose(file_id);

end
