#ifndef GAUSSIAN_KERNEL_H
#define GAUSSIAN_KERNEL_H

#include <cmath>
#include <cstdint>

// dlib includes
#include "dlib/matrix.h"
#include "dlib/numeric_constants.h"

namespace dlib
{

    void create_gaussian_kernel(uint64_t height, uint64_t width, double sigma, dlib::matrix<float> &kernel)
    {

        kernel.set_size(height, width);
        float pre = (1.0 / (2 * dlib::pi *sigma*sigma));

        for (long row = 0; row < height; row++)
        {
            for (long col = 0; col < width; col++)
            {
                kernel(row, col) = pre * std::exp((-((col - (long)(width >> 1))*(col - (long)(width >> 1))) - ((row - (long)(height >> 1))*(row - (long)(height >> 1)))) / (2 * sigma*sigma));

            }
        }

        double matsum = (double)dlib::sum(kernel);
        kernel = kernel * (1.0 / matsum);	// get the matrix to sum up to 1...

    }   // end of createGaussianKernel

}   // end of namespace

#endif  // GAUSSIAN_KERNEL_H