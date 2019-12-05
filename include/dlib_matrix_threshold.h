#ifndef _THRESHOLD_DLIB_MATRIX_H_
#define _THRESHOLD_DLIB_MATRIX_H_

#include <cstdint>

#include <dlib/pixel.h>

template <typename image_type, typename thresh_type>
void truncate_threshold(image_type &src, image_type &dst, thresh_type threshold)
{
    uint64_t r, c;
    
    dst.set_size(src.nr(), src.nc());
    
    for(r = 0; r < (uint64_t)src.nr(); ++r)
    {
        for(c = 0; c < (uint64_t)src.nc(); ++c)
        {
            if(src(r,c)> threshold)
                dlib::assign_pixel(dst(r,c),threshold);
            else
                dlib::assign_pixel(dst(r,c),src(r,c));
        }
    }
    
}   // end of truncate_threshold

template <typename image_type, typename thresh_type>
void threshold_to_zero(image_type& src, image_type& dst, thresh_type threshold, bool invert)
{
    uint64_t r, c;
    //thresh_type value;

    dst.set_size(src.nr(), src.nc());

    for (r = 0; r < (uint64_t)src.nr(); ++r)
    {
        for (c = 0; c < (uint64_t)src.nc(); ++c)
        {
            switch (invert)
            {
            case true:
                if (src(r, c) > threshold)
                    dlib::assign_pixel(dst(r, c), 0);
                else
                    dlib::assign_pixel(dst(r, c), src(r, c));
                break;

            default:
                if (src(r, c) < threshold)
                    dlib::assign_pixel(dst(r, c), 0);
                else
                    dlib::assign_pixel(dst(r, c), src(r, c));
                break;
                //value = invert ? src(r, c) : 0;
            }
        }
    }


}   // end of threshold_to_zero

#endif  // _THRESHOLD_DLIB_MATRIX_H_
