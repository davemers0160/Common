function [params] = parse_input_parameters(input_file)
%% this section reads the file into a cell array of strings
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
                params{idx,1} = parse_csv_line(temp_line);
                idx = idx + 1;
            end
        end
    end
    fclose(fileID);
    
end