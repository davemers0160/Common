function write_latex_table_head(caption, label, format)
    fprintf('%%----------------------------------------------------------------------\n');
    fprintf('\\begin{table}[!htb] \\centering \n');
    fprintf('\\caption{%s}\n',caption);
    fprintf('\\label{%s}\n',label);
    fprintf('\\begin{tabular}{%s} \\hline \n', format);

end
