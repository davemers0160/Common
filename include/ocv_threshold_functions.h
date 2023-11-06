#ifndef THRESHOLD_FUNCTIONS_H
#define	THRESHOLD_FUNCTIONS_H

// OPENCV Includes
#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  


//-----------------------------------------------------------------------------
template<typename T>
inline void advanced_threshold(cv::Mat& src, double threshold, T min_val, T max_val)
{
    // accept only single channel char type matrices
    //CV_Assert(inputImage.depth() == CV_8U);

    cv::MatIterator_<T> itr, end;

    for (itr = src.begin<T>(), end = src.end<T>(); itr != end; ++itr)
    {
        if (*itr >= threshold)
        {
            *itr = max_val;
        }
        else
        {
            *itr = min_val;
        }
    }

}	// end of advanced_threshold

//-----------------------------------------------------------------------------
template<typename T>
inline void advanced_threshold(cv::Mat &src, cv::Mat &dst, double threshold, T min_val, T max_val)
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

//-----------------------------------------------------------------------------
template<typename T>
inline void ranged_threshold(cv::Mat &src, cv::Mat &dst, T min_val, T max_val)
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

//-----------------------------------------------------------------------------
inline void energy_threshold(cv::Mat &src, cv::Mat &dst, double energyVal, int &threshVal, int method)
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
                cv::threshold(src, dst, threshVal, 1, cv::THRESH_TOZERO);
                currentEnergy = (double)cv::sum(dst)[0];
                result = currentEnergy / intialEnergy;
                if (result < energyVal)
                {
                    break;
                }
            }
            cv::threshold(src, dst, threshVal, 1, cv::THRESH_BINARY);

            break;

        case 2:
            // check for the threshold value that produces a change ...
            for (threshVal = (int)(min + 1.0); threshVal < max; ++threshVal)
            {
                // cycle from min+1 to max-1 on threshold values to find the tipping point
                // where abs(1 - ratio of the current energy to the initial energy) is g.t. the
                // energy value threshold
                cv::threshold(src, dst, threshVal, 1, cv::THRESH_TOZERO);
                currentEnergy = (double)cv::sum(dst)[0];
                result = currentEnergy / intialEnergy;
                // 
                if (abs(1 - result) > energyVal)
                {
                    break;
                }

            }
            cv::threshold(src, dst, threshVal, 1, cv::THRESH_BINARY);

            break;
            
        default:
            break;

	}
	
}	// end of energy_threshold

//-----------------------------------------------------------------------------
inline void calculate_energy_threshold(cv::Mat& src, double& threshold, double energy_threshold = 0.87, int32_t hist_size = 256)
{
    uint32_t idx, jdx;

    // this assumes we are given 8-bit image
    float hist_ranges[] = { 0, hist_size-1 };
    const float* ranges[] = { hist_ranges };

    double ch;
    cv::Mat hist;
    std::vector<double> cdf(hist_size, 0);

    std::vector<double> hl(hist_size, 0);
    std::vector<double> hh(hist_size, 0);
    std::vector<double> energy(hist_size, 0);

    double scale = 1.0 / ((double)src.rows * (double)src.cols);

    cv::calcHist(&src, 1, 0, cv::Mat(), hist, 1, &hist_size, ranges, true, false);

    // nromalize the histogram
    hist.convertTo(hist, CV_32FC1, scale);

    // calculate the CDF
    cdf[0] = hist.at<float>(0,0);
    for (idx = 1; idx < hist_size; ++idx)
    {
        cdf[idx] = cdf[idx - 1] + hist.at<float>(idx,0);

        if (cdf[idx] >= energy_threshold)
        {
            threshold = idx;
            break;
        }
    }

    //// find the energy ranges
    //for (idx = 0; idx < hist_size; ++idx)
    //{
    //    // low range
    //    if (cdf[idx] > 0.0)
    //    {
    //        for (jdx = 0; jdx < idx; ++jdx)
    //        {
    //            if (hist.at<float>(jdx,0) > 0.0)
    //                hl[idx] -= (hist.at<float>(jdx,0) / cdf[idx]) * log(hist.at<float>(jdx,0) / cdf[idx]);
    //        }
    //    }

    //    // high range
    //    ch = 1.0 - cdf[idx];
    //    if (ch > 0.0)
    //    {
    //        for (jdx = (idx + 1); jdx < hist_size; ++jdx)
    //        {
    //            if (hist.at<float>(jdx,0) > 0.0)
    //                hh[idx] -= (hist.at<float>(jdx,0) / ch) * log(hist.at<float>(jdx,0) / ch);
    //        }
    //    }

    //}

    //// find the threshold
    //double h_max = hl[0] + hh[0];
    //threshold = 0;

    //energy[0] = h_max;

    ////for t = 2:256
    //for (idx = 1; idx < hist_size; ++idx)
    //{
    //    energy[idx] = hl[idx] + hh[idx];

    //    if (energy[idx] > h_max)
    //    {
    //        h_max = energy[idx];
    //        threshold = idx;
    //    }

    //}

    //advanced_threshold(src, dst, thresh_val, min_val, max_val);

}   // end of advanced_energy_threshold


//-----------------------------------------------------------------------------
inline void binarize_image(cv::Mat& src, cv::Mat& dst, double threshold, uint8_t se_size)
{
    advanced_threshold(src, dst, threshold, -1.0f, 1.0f);
    cv::Mat SE = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(se_size, se_size));
    //cv::Mat SE = (cv::Mat_<uint8_t>(5, 5) << 0, 0, 1, 0, 0,   0, 1, 1, 1, 0,   1, 1, 1, 1, 1,   0, 1, 1, 1, 0,   0, 0, 1, 0, 0);

    cv::morphologyEx(dst, dst, cv::MORPH_CLOSE, SE);
}


#endif	// end of THRESHOLD_FUNCTIONS_H