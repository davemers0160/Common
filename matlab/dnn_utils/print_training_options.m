function print_training_options(options, varargin)

    %fn = fieldnames(options);
    sep = '------------------------------------------------------------------------------';    
    msg = evalc('disp(options)');
    msg2 = strsplit(msg,newline);
    
    if(nargin == 2)        
        fprintf(varargin{1},'\n%s\nTraining Options: \n',sep);
        for idx=2:numel(msg2)-1
            fprintf(varargin{1},'%s\n',msg2{idx});
        end
        fprintf(varargin{1},'%s\n',sep);
        
    else
        fprintf('\n%s\nTraining Options: \n',sep);
        for idx=2:numel(msg2)-1
            fprintf('%s\n',msg2{idx});
        end
        fprintf('%s\n',sep);
        
    end

end