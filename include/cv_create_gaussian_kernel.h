#ifndef CREATE_GAUSSIAN_KERNEL_H_
#define CREATE_GAUSSIAN_KERNEL_H_

#include <cstdint>
#include <cmath>

// OpenCV Includes
#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  

// ----------------------------------------------------------------------------
void create_gaussian_kernel(uint32_t size, double sigma, cv::Mat &kernel)
{
	// assumes a 0 mean Gaussian distribution
	uint32_t row, col;
    double s = sigma*sigma;

    kernel = cv::Mat::zeros(size, size, CV_64FC1);

    double t = (1.0 / (2 * CV_PI *s));

	for (row = 0; row < size; ++row)
	{
		for (col = 0; col < size; ++col)
		{
			kernel.at<double>(row, col) = t * std::exp((-((col - (size >> 1))*(col - (size >> 1))) - ((row - (size >> 1))*(row - (size >> 1)))) / (2 * s));
		}
	}

	double matsum = (double)cv::sum(kernel)[0];

	kernel = kernel * (1.0 / matsum);	// get the matrix to sum up to 1...

}	// end of create_gaussian_kernel

#endif  // CREATE_GAUSSIAN_KERNEL_H_
