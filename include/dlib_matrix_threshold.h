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
    
}

#endif  // _THRESHOLD_DLIB_MATRIX_H_
