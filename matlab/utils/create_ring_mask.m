% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
% imageSizeX = 640;
% imageSizeY = 480;
% 
% % Next create the circle in the image.
% centerX = 320;
% centerY = 400;
% radius = 100;
% radius2 = 90;

% ring_center
%   [X,Y]
% img_size
%   [rosw, cols]
%
function [mask] = create_ring_mask(img_size, ring_center, r1, r2)

    if(r1<r2)
        fprintf('warning r1 < r2\n');
        mask = zeros(img_size);
        return;
    end

    [columnsInImage, rowsInImage] = meshgrid(1:img_size(2), 1:img_size(1));

    d1 = (rowsInImage - ring_center(2)).^2 + (columnsInImage - ring_center(1)).^2 <= r1.^2;
    d2 = (rowsInImage - ring_center(2)).^2 + (columnsInImage - ring_center(1)).^2 <= r2.^2;
    
    mask = d1-d2; 
    
end
% figure;
% imagesc(circlePixels);
% %
% 
% figure;
% imagesc(circlePixels2);
% 
% figure;
% imagesc(d1-d2);
% colormap([0 0 0; 1 1 1]);
% 
% title('Binary image of a circle');



