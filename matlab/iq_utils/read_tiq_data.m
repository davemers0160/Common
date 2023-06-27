function [iqc] = read_tiq_data(filename, scale)

        % only supports the following data types: 'double', 'single',
        % u/int8, u/int16, u/int32, u/int64, float32, float64
        % ex: [iq, i_data, q_data] = read_binary_iq_data('iq_file.dat', 'double')
        % byte_order: 'ieee-le' or 'ieee-be' depending on how the data was
        % saved
        byte_order = 'ieee-le';
        data_type = 'int32';

        file_id = fopen(filename,'r');
        
        % get the file size
        fseek(file_id, 0, 'eof');
        file_stop = ftell(file_id);
        frewind(file_id);
        fseek(file_id, 637843, 'bof');
        file_start = ftell(file_id);
        % file_size = 0;
        
        % this sets the calculated files size for the expected data type
        file_size = floor((file_stop - file_start)/(4*2));
        
        % read the data into column format [I, Q]
        iq = fread(file_id, [2, file_size], data_type, byte_order);
        data = iq(:) * scale;
        data = 2048*data/max(abs(data));

        iqc = complex(data(1:2:end), data(2:2:end));

        fclose(file_id);
    
end