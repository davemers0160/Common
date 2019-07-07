#ifndef GET_IMAGE_ROI_CV_H
#define GET_IMAGE_ROI_CV_H

#include <cstdint>

#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  


void get_image_ROI_cv(cv::Mat inputImage, cv::Size ROI, cv::Mat &outputImage)
{
	uint32_t x = (inputImage.cols >> 1) - (ROI.width >> 1);
	uint32_t y = (inputImage.rows >> 1) - (ROI.height >> 1);

	cv::Rect ROI_Rect = cv::Rect(cv::Point(x, y), ROI);

	inputImage(ROI_Rect).copyTo(outputImage);

}	// end of getImageROI

#endif


