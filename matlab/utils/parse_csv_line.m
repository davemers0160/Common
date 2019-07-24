function [csv_line] = parse_csv_line(input)
    delimiter = ',';
    csv_line = strtrim(strsplit(input, delimiter, 'CollapseDelimiters', false));

end