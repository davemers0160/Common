function [kernel] = create_box_filter(level,kernel_size)

%     kernel = ones(2*level+1, 2*level+1);
%     
%     kernel = 1/sum(kernel(:))*kernel;

    kernel = (1/level)*ones(kernel_size);
    %kernel = 1/sum(kernel(:))*kernel;
end