function [img] = read_tiff_stack(filename, varargin)

    info = imfinfo(filename);
    num_images = numel(info);
    img = cell(num_images,1);
    
    norm_img = false;
    
    if(nargin==2)
        norm_img = varargin{1};
    end
    
    if(norm_img == true)
        for idx = 1:num_images
            tmp = double(imread(filename, idx, 'Info', info));
            img{idx,1} = floor( 255*(tmp - min(tmp(:))) / (max(tmp(:)) - min(tmp(:))) );
        end
    else
        for idx = 1:num_images
            img{idx,1} = double(imread(filename, idx, 'Info', info));
        end
    end
    


end