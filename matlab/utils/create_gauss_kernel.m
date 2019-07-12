function [kernel] = create_gauss_kernel(kernel_size, sigma)

	for row = 1:kernel_size
		for col = 1:kernel_size	
            scale = 1.0/(2*pi*sigma*sigma);
            x = ((col-1) - floor(kernel_size/2));
            y = ((row-1) - floor(kernel_size/2));
			kernel(row, col) = scale * exp((-x*x - y*y) / (2 * sigma*sigma));
        end
    end

	kernel_sum = sum(kernel(:));

	kernel = kernel * (1.0 / kernel_sum);
    
end