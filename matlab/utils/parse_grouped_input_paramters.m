function [params] = parse_grouped_input_paramters(input_file, group_delim)

    [fileID] = fopen(input_file,'r');

    if(fileID < 0)
        disp('Error opening file.');
        return;
    end
    
    %file_line = {};
    params = {};
    idx = 1;
    while(~feof(fileID))
        temp_line = fgetl(fileID);
        if(~isempty(temp_line))
            if((temp_line(1) ~= '%') && (temp_line(1) ~= ' ') && (temp_line(1) ~= '#'))
                %file_line{idx,1} = temp_line;
                params{idx,1} = parse_group_line(temp_line, group_delim);
                idx = idx + 1;
            end
        end
    end
    fclose(fileID);
    
end
