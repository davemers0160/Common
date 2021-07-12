function rgb = blues(n)

    index = (0:1:n-1)*(12/(n-1));
    
    r = -0.0724*index + 0.9;
    g = -0.0541*index + 0.92;
    b = -0.0350*index + 1.0;

    rgb = cat(2,r',g',b');
end
