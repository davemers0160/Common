#ifndef ADD_BORDER_
#define ADD_BORDER_


#include <dlib/pixel.h>
#include <dlib/image_transforms.h>

namespace dlib
{

    template<typename img_type1, typename img_type2>
    void add_border(img_type1 img_in, img_type2 &img_out, uint32_t border)
    {
        img_out.set_size(img_in.nr()+2*border, img_in.nc()+2*border);
       
        dlib::assign_all_pixels(img_out, 0);

        for(long r=0; r<img_in.nr(); ++r)
        {
            for(long c=0; c<img_in.nc(); ++c)
            {            
                dlib::assign_pixel(img_out(r+border,c+border), img_in(r,c));
            }       
        }    
    
    }   // end of add_border

    // add border adds a replicated border around the image
    template<typename img_type1, typename img_type2>
    void add_border(img_type1 img_in, img_type2 &img_out, uint32_t border, unsigned char border_type)
    {
        long row = 0;
        long col = 0;

        img_out.set_size(img_in.nr() + 2 * border, img_in.nc() + 2 * border);

        // copy the image with the border set to zero
        add_border(img_in, img_out, border);

        switch (border_type)
        {
        case 1:
            // cycle through the image in a CW manner and copy each successive row or column
            for (uint32_t idx = 0; idx < border; ++idx)
            {
                // top
                dlib::set_rowm(img_out, border - idx - 1) = dlib::rowm(img_out, border - idx);

                // right
                dlib::set_colm(img_out, border + img_in.nc() + idx) = dlib::colm(img_out, border + img_in.nc() - idx - 1);

                // bottom
                dlib::set_rowm(img_out, border + img_in.nr() + idx) = dlib::rowm(img_out, border + img_in.nr() - idx - 1);

                // left
                dlib::set_colm(img_out, border - idx - 1) = dlib::colm(img_out, border - idx);

            }
            break;

        default:
            break;
        }   // end of switch

    }


    template<typename img_type1, typename img_type2>
    void remove_border(img_type1 img_in, img_type2 &img_out, uint32_t border)
    {
        /*
        
        img_out.set_size(img_in.nr()-2*border, img_in.nc()-2*border);
        
        for(long r=0; r<img_out.nr(); ++r)
        {
            for(long c=0; c<img_out.nc(); ++c)
            {            
                dlib::assign_pixel(img_out(r,c), img_in(r+border,c+border));
            }      
        } 
        */

        img_out = dlib::subm(img_in, border, border, img_in.nr() - 2 * border, img_in.nc() - 2 * border);

    
    }   // end of remove_border



}   // end of namespace





#endif