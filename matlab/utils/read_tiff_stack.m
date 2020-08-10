function [img] = read_tiff_stack(filename)

    info = imfinfo(filename);
    num_images = numel(info);
    img = cell(num_images,1);
    
    for idx = 1:num_images
        img{idx,1} = imread(filename, idx, 'Info', info);
    end


end