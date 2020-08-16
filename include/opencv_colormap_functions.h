#ifndef OPENCV_COLORMAP_FUNCTIONS_H_
#define OPENCV_COLORMAP_FUNCTIONS_H_

#include <cstdint>

// OpenCV Includes
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

// ----------------------------------------------------------------------------------------
inline cv::Vec3b float2rgb_jet(float t, const float t_min, const float t_max)
{
    float r;
    float g;
    float b;   

    float t_range = t_max - t_min;
    float p1 = t_min + t_range * (1 / 4);
    float p2 = t_min + t_range * (2 / 4);
    float p3 = t_min + t_range * (3 / 4);

    t = std::max(std::min(t, t_max), t_min);

    if (t <= p1)
    {
        r = 0.0f;
        b = 1.0f;
        g = (1.0f / (p1 - t_min)) * (t - t_min);
    }
    else if(t <= p2)
    {
        r = 0.0f;
        g = 1.0f;
        b = 1.0f - (1.0f / (p2 - p1)) * (t - p1);
    }
    else if (t <= p3)
    {
        r = (1.0f / (p3 - p2)) * (t - p2);
        b = 0.0f;
        g = 1.0f;
    }
    else
    {
        r = 1.0f;
        b = 0.0f;
        g = 1.0f - (1.0f / (t_max - p3)) * (t - p3);
    }
    
    return cv::Vec3b((uint8_t)(255 * b), (uint8_t)(255 * g), (uint8_t)(255 * r));

}   // end of float2rgb_jet

// ----------------------------------------------------------------------------------------
template <typename T>
inline cv::Mat cv_jet(const cv::Mat& img, const T t_min, const T t_max)
{
    int r, c;

    cv::Mat hm = cv::Mat(img.size(), CV_8UC3, cv::Scalar::all(0));

    for (r = 0; r < img.rows; ++r)
    {
        for (c = 0; c < img.cols; ++c)
        {
            hm.at<cv::Vec3b>(r, c) = float2rgb_jet(img.at<T>(r,c), t_min, t_max);
        }
    }

    return hm;
}   // end of cv_jet




#endif  // OPENCV_COLORMAP_FUNCTIONS_H_
