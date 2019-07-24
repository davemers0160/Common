function [nr,nc] = get_cont_output_size(height, width, filter_nr, filter_nc, stride_y, stride_x)
% function to determine the final size of a cont convolutional layer used 
% in the DLIb library
%
% INPUTS
%   - height:    Number of rows in the input tensor.  Inputs must be an
%                integer value.
%   - width:     Number of columns in the input tensor.  Inputs must be an
%                integer value.
%   - padding_y: Convolutional padding in the y-direction.  Inputs must be
%                an integer value.
%   - padding_x: Convolutional padding in the x-direction.  Inputs must be
%                an integer value.
%   - filter_nr: Number of rows in the convolution filter.  Inputs must be
%                an integer value.
%   - filter_nc: Number of columns in the convolution filter.  Inputs must
%                be an integer value.
%   - stride_y:  Number of elements to skip in the y-direction when 
%                performing the convolution.  Inputs must be an integer 
%                value.
%   - stride_x:  Number of elements to skip in the x-direction when 
%                performing the convolution.  Inputs must be an integer 
%                value.
%
% OUPUTS
%   - nr:        The number of rows of the output tensor
%   - nc:        The number of cloumns of the output tensor
%

padding_x = (stride_x == 1)*floor(filter_nc/2);
padding_y = (stride_y == 1)*floor(filter_nr/2);

nr = floor(floor(stride_y)*(floor(height)-1) + floor(filter_nr) - 2*floor(padding_y));
nc = floor(floor(stride_x)*(floor(width)-1) + floor(filter_nc) - 2*floor(padding_x));



