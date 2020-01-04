#ifndef DLIB_JET_FUNCTIONS_INCLUDE_
#define DLIB_JET_FUNCTIONS_INCLUDE_

#include <cstdint>

#include "ycrcb_pixel.h"

#include "dlib/pixel.h"
#include "dlib/matrix.h"

// ----------------------------------------------------------------------------------------
inline float jet_clamp(const float v)
{
    const float t = v < 0.0 ? 0.0 : v;
    return t > 1.0 ? 1.0 : t;
}

// ----------------------------------------------------------------------------------------
inline dlib::rgb_alpha_pixel val2rgba_jet(const float t, const float t_min, const float t_max)
{
    float t_range = t_max - t_min;
    float t_avg = (t_max + t_min) / 2.0;
    float t_m = (t_max - t_avg) / 2.0;

    float r = jet_clamp(1.5 - std::abs((4 / t_range)*(t - t_avg - t_m)));
    float g = jet_clamp(1.5 - std::abs((4 / t_range)*(t - t_avg)));
    float b = jet_clamp(1.5 - std::abs((4 / t_range)*(t - t_avg + t_m)));

    return dlib::rgb_alpha_pixel((uint8_t)(255 * r), (uint8_t)(255 * g), (uint8_t)(255 * b), 255);
}

// ----------------------------------------------------------------------------------------
inline dlib::rgb_pixel val2rgb_jet(const float t, const float t_min, const float t_max)
{
    float t_range = t_max - t_min;
    float t_avg = (t_max + t_min) / 2.0;
    float t_m = (t_max - t_avg) / 2.0;

    float r = jet_clamp(1.5 - std::abs((4.0 / t_range)*(t - t_avg - t_m)));
    float g = jet_clamp(1.5 - std::abs((4.0 / t_range)*(t - t_avg)));
    float b = jet_clamp(1.5 - std::abs((4.0 / t_range)*(t - t_avg + t_m)));

    return dlib::rgb_pixel((uint8_t)(255 * r), (uint8_t)(255 * g), (uint8_t)(255 * b));
}

// ----------------------------------------------------------------------------------------
inline dlib::matrix<dlib::rgb_pixel> mat_to_rgbjetmat(const dlib::matrix<float> t, const float t_min, const float t_max)
{
    dlib::matrix<dlib::rgb_pixel> jet_mat(t.nr(), t.nc());
    dlib::rgb_pixel p;

    for (uint64_t r = 0; r < (uint64_t)t.nr(); ++r)
    {
        for (uint64_t c = 0; c < (uint64_t)t.nc(); ++c)
        {
            p = val2rgb_jet(t(r, c), t_min, t_max);
            dlib::assign_pixel(jet_mat(r, c), p);
        }
    }

    return jet_mat;
}

#endif  // DLIB_JET_FUNCTIONS_INCLUDE_

