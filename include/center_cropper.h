#ifndef CENTER_CROPPER_H_
#define CENTER_CROPPER_H_

#include <cstdlib>
#include <cstdint>
#include <vector>

#include "ycrcb_pixel.h"

// dlib includes
#include "dlib/matrix.h"
#include "dlib/image_transforms/interpolation.h"

template <typename img_type>
dlib::rectangle get_center_crop_rect(const img_type& src, uint32_t crop_w, uint32_t crop_h)
{
    uint64_t x = 0, y = 0;
    
    if(crop_w >= (uint32_t)(src.nc()-1))
    {
        crop_w = src.nc();
    }
    else
    {
        x = (uint32_t)((src.nc()>>1)-(crop_w>>1));
    }
    
    if(crop_h >= (uint32_t)(src.nr()-1))
    {
        crop_h = src.nr();
    }
    else
    {
        y = (uint32_t)((src.nr()>>1)-(crop_h>>1));
    }
    
    dlib::rectangle rect(crop_w, crop_h);

    // shift the box around
    dlib::point offset(x, y);   
    return dlib::move_rect(rect, offset);
    
}	// end get_cropping_rect  

//-----------------------------------------------------------------------------

template<typename img_type, uint64_t D>
void center_cropper(std::array<img_type, D> &src, std::array<img_type, D> &dst, uint32_t crop_w, uint32_t crop_h)
{

    dlib::rectangle crop_rect = get_center_crop_rect(src[0], crop_w, crop_h);
    
    for(uint64_t idx=0; idx<D; ++idx)
    {
        dst[idx] = dlib::subm(src[idx], crop_rect);
    }
    
}

//-----------------------------------------------------------------------------

template<typename img_type>
void center_cropper(img_type src, img_type &dst, uint32_t crop_w, uint32_t crop_h)
{

    dlib::rectangle crop_rect = get_center_crop_rect(src, crop_w, crop_h);
    
    dst = dlib::subm(src, crop_rect);
    
}


#endif  // CENTER_CROPPER_H_
