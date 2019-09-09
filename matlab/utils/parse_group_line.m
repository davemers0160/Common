function [output_line] = parse_group_line(input, delimiter)

    output_line = {};
    grp{1} = regexp(input, delimiter{1});
    grp{2} = regexp(input, delimiter{2});
    
    if(numel(grp{1}) ~= numel(grp{2}))
        return;
    end
       
    if(isempty(grp{1}))
        output_line = parse_line(input, ',');
        
    else
        tmp_param = strtrim(input(1:grp{1}(1)-1));
        output_line = parse_line(tmp_param, ',');

        if(isempty(output_line{end}))
            output_line(end) = [];
        end

        %output_line{index} = strtrim(input(1:g1(index)-1));
        %index = numel(output_line) + 1;

        for idx=1:numel(grp{1})
            output_line{end+1} = strtrim(input(grp{1}(idx)+1:grp{2}(idx)-1));
            %index = index + 1;
        end

        tmp_str = strtrim(input(grp{2}(end)+1:end));
        if(~isempty(tmp_str))
            output_line{end+1} = tmp_str;
        end
    end
    
end
