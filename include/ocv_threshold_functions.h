#ifndef THRESHOLD_FUNCTIONS_H
#define	THRESHOLD_FUNCTIONS_H

// OPENCV Includes
#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  

template<typename T>
void advanced_threshold(cv::Mat &src, cv::Mat &dst, T threshold, T min_val, T max_val)
{
	// accept only single channel char type matrices
	//CV_Assert(inputImage.depth() == CV_8U);

	//int channels = inputImage.channels();
    dst = cv::Mat::zeros(src.rows, src.cols, src.type());

	cv::MatIterator_<T> it, end;
    cv::MatIterator_<T> thresh_it = dst.begin<T>();

	for (it = src.begin<T>(), end = src.end<T>(); it != end; ++it, ++thresh_it)
	{
		if (*it >= threshold)
		{
			*thresh_it = max_val;
		}
		else
		{
			*thresh_it = min_val;
		}
	}

}	// end of advanced_threshold

template<typename T>
void ranged_threshold(cv::Mat &src, cv::Mat &dst, T min_val, T max_val)
{
    //CV_Assert(src.depth() == CV_8U);

    dst = cv::Mat::zeros(src.rows, src.cols, src.type());

    cv::MatIterator_<T> it, end;
    cv::MatIterator_<T> thresh_it = dst.begin<T>();
    
    for (it = src.begin<T>(), end = src.end<T>(); it != end; ++it, ++thresh_it)
    {
        if (*it < min_val) 
        {
            *thresh_it = min_val;
        }
        else if(*it > max_val)
        {
            *thresh_it = max_val;
        }
        else
        {
            *thresh_it = *it;
        }
    }

}   // end of ranged_threshold

void energy_threshold(cv::Mat &src, cv::Mat &dst, double energyVal, int &threshVal, int method)
{
    //CV_Assert(src.depth() == CV_8U);

    int idx;
	//double totalEnergy = (double)cv::sum(src)[0];
	double intialEnergy = (double)cv::sum(src)[0];
	double currentEnergy = 0.0;
	double result = 0.0;
	double min, max;

    dst = cv::Mat::zeros(src.rows, src.cols, src.type());

	cv::minMaxIdx(src, &min, &max);

	switch (method)
	{
        // can be done over the entire image or image patches
        case 1:
            for (threshVal = (int)(min + 1); threshVal < max-1; ++threshVal)
            {
                // cycle from min+1 to max-1 on threshold values to find the tipping point
                // where ratio of the current energy to the initial energy is l.t. the
                // energy value threshold
                cv::threshold(src, dst, threshVal, 255, cv::THRESH_TOZERO);
                currentEnergy = (double)cv::sum(dst)[0];
                result = currentEnergy / intialEnergy;
                if (result < energyVal)
                {
                    break;
                }
            }
            cv::threshold(src, dst, threshVal, 255, cv::THRESH_BINARY);

            break;

        case 2:
            // check for the threshold value that produces a change ...
            for (threshVal = (int)(min + 1.0); threshVal < max; ++threshVal)
            {
                // cycle from min+1 to max-1 on threshold values to find the tipping point
                // where abs(1 - ratio of the current energy to the initial energy) is g.t. the
                // energy value threshold
                cv::threshold(src, dst, threshVal, 255, cv::THRESH_TOZERO);
                currentEnergy = (double)cv::sum(dst)[0];
                result = currentEnergy / intialEnergy;
                // 
                if (abs(1 - result) > energyVal)
                {
                    break;
                }

            }
            cv::threshold(src, dst, threshVal, 255, cv::THRESH_BINARY);

            break;
            
        default:
            break;

	}
	
}	// end of energy_threshold

#endif	// end of THRESHOLD_FUNCTIONS_H