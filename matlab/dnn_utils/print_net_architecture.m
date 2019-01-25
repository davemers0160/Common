function print_net_architecture(net, varargin)

    sep = '------------------------------------------------------------------------------'; 
    
    input_sz = numel(net);
    
    if(input_sz <= 2)
        msg = evalc('disp(net.Layers)');
    else
        msg = evalc('disp(net)');
    end
    
    msg2 = strsplit(msg, newline);
    
    if(nargin == 2)    
        fprintf(varargin{1},'\n%s\nNetwork Architecture: \n',sep);
        for idx=2:numel(msg2)-1
            fprintf(varargin{1},'%s\n',msg2{idx});
        end
        fprintf(varargin{1},'%s\n',sep);
    else
        fprintf('\n%s\nNetwork Architecture: \n',sep);
        for idx=2:numel(msg2)-1
            fprintf('%s\n',msg2{idx});
        end
        fprintf('%s\n',sep);
    end


end