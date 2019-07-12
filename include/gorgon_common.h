#ifndef GORGON_COMMON_H
#define GORGON_COMMON_H

#include <cstdint>

#include "ycrcb_pixel.h"

#include <dlib/pixel.h>
#include <dlib/matrix.h>

struct gorgon_param_struct
{
    //uint64_t step;
    uint64_t l;
    uint64_t n;
    uint64_t k;
    uint64_t nr;
    uint64_t nc;
    //std::vector<float> data;
    std::pair<uint16_t, uint16_t> version;

    uint64_t get_data_size()
    {
        return (uint64_t)(n*nr*nc*k);
    }

    std::string get_version()
    {
        return std::to_string(version.first) + "." + std::to_string(version.second);
    }
};

struct gorgon_data_struct
{
    uint64_t step;
    std::vector<dlib::matrix<float>> data;
};

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

inline dlib::matrix<dlib::rgb_pixel> mat_to_rgbjetmat(const dlib::matrix<float> t, const float t_min, const float t_max)
{
    dlib::matrix<dlib::rgb_pixel> jet_mat(t.nr(), t.nc());

    for (uint64_t r = 0; r < (uint64_t)t.nr(); ++r)
    {
        for (uint64_t c = 0; c < (uint64_t)t.nc(); ++c)
        {
            //jet_mat(r, c) = val2rgb_jet(t(r, c), t_min, t_max);
            dlib::assign_pixel(jet_mat(r, c), val2rgb_jet(t(r, c), t_min, t_max));
        }
    }

    return jet_mat;
}
#endif  // end of GORGON_COMMON_H

