function [lt] = get_layer_type(layer)

    msg = evalc('disp(layer)');
    msg = strsplit(msg, newline);
    msg = strsplit(msg{1},'>');
    msg = strsplit(msg{2},'<');

    lt = msg{1};

end