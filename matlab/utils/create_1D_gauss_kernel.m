function [kernel] = create_1D_gauss_kernel(kernel_size, sigma)

    if(sigma == 0)
        sigma = 1e-10;
    end
    
    for col = 1:kernel_size	
        scale = 1.0/(sigma*sqrt((2*pi)));
        x = ((col-1) - floor(kernel_size/2));
        kernel(col) = scale * exp((-x*x) / (2 * sigma*sigma));
    end

	kernel_sum = sum(kernel(:));
	kernel = kernel * (1.0 / kernel_sum);
    
end