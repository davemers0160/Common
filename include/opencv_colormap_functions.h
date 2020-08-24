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
    float t_range = t_max - t_min;
    float p1 = t_min + t_range * (0.25);
    float p2 = t_min + t_range * (0.50);
    float p3 = t_min + t_range * (0.75);

    float r = (float)std::max(std::min((1.0 / (p3 - p2)) * ((t - p2)), 1.0), 0.0);
    float g = (float)std::max(std::min(2.0 - (1.0 / (p1 - t_min)) * abs(t - p2), 1.0), 0.0);
    float b = (float)std::max(std::min((1.0 / (p1 - p2)) * (t - p2), 1.0), 0.0);

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

// ----------------------------------------------------------------------------------------
template <typename T>
inline cv::Mat cv_gray(const cv::Mat& img, const T t_min, const T t_max)
{
    int r, c;
    float nt;
    float t_range = 255.0 / (t_max - t_min);

    cv::Mat hm = cv::Mat(img.size(), CV_8UC3, cv::Scalar::all(0));

    for (r = 0; r < img.rows; ++r)
    {
        for (c = 0; c < img.cols; ++c)
        {
            nt = std::max(std::min(img.at<T>(r, c), t_max), t_min);
            nt = (nt - t_min) * t_range;
            hm.at<cv::Vec3b>(r, c) = cv::Vec3b((uint8_t)(nt), (uint8_t)(nt), (uint8_t)(nt));
        }
    }

    return hm;
}   // end of cv_jet


#endif  // OPENCV_COLORMAP_FUNCTIONS_H_
