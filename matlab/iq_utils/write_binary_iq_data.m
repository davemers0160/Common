function write_binary_iq_data(filename, data, data_type, byte_order)
% only supports the following data types: 'double', 'single', 'uint8', 'int8', 'uint16', int16', 'uint32', 'int32', 'uint64, 'int64'
% byte_order: 'ieee-le' or 'ieee-be' depending on how the data was saved
%
% ex: [iq, i_data, q_data] = write_binary_iq_data('iq_file.dat', iq_data, 'double', 'ieee-le')

    file_id = fopen(filename,'w');
    
    % check to see if the data is complex or real
    if(isreal(data))        
                
        % assumes that the data is written column form [I, Q]
        iq = data.';
        fwrite(file_id, iq(:), data_type, byte_order);
        
    else
        % if the imaginary componet is 0 this operations removes that component wrongly!!!
        data = data(:);     

        % do this step because matlab doesn't handle imaginary numbers worth a shit
        iq = cat(1, real(data).', imag(data).');
        fwrite(file_id, iq(:), data_type, byte_order);
      
    end
    
    fclose(file_id);

end
