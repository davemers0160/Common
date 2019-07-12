function [output_line] = parse_line(input, delimiter)

    output_line = strtrim(strsplit(input, delimiter, 'CollapseDelimiters', false));

end