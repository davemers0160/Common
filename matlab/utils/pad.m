function output = pad(image, desired_h, desired_w, default_value)

    [h, w, ~] = size(image);

    output = ones(desired_h, desired_w) * default_value;    
    
    r1 = floor((desired_h - h)/2 + 0.5);
    c1 = floor((desired_w - w)/2 + 0.5);
    
    r2 = r1 + h - 1;
    c2 = c1 + w - 1;
    
    output(r1:r2,c1:c2) = image;
end