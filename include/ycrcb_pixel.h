#ifndef YCRCB_PIXEL_INCLUDE_
#define YCRCB_PIXEL_INCLUDE_

//#include <dlib/pixel.h>
#include <iostream>
#include <cmath>
#include <limits>
#include <complex>

//#include "dlib/pixel.h"
#include "dlib/serialize.h"
#include "dlib/algs.h"
#include "dlib/uintn.h"
#include "dlib/enable_if.h"



/*
Full range RGB to YCrCb color conversion

delta = 128

Y = 0.299*R+0.587*G+0.114*B
Cr = (R−Y)*0.713+delta
Cb = (B−Y)*0.564+delta


R = Y+1.403*(Cr−delta)
G = Y−0.714*(Cr−delta)−0.344*(Cb−delta)
B = Y+1.773*(Cb−delta)
*/

namespace dlib
{
    template <typename T>
    struct pixel_traits;

// ----------------------------------------------------------------------------------------

    struct ycrcb_pixel
    {
        /*!
            WHAT THIS OBJECT REPRESENTS
                This is a simple struct that represents an YCrCb colored graphical pixel.
        !*/

        ycrcb_pixel (
        ) {}

        ycrcb_pixel (
            unsigned char y_,
            unsigned char cr_,
            unsigned char cb_
        ) : y(y_), cr(cr_), cb(cb_) {}

        unsigned char y;
        unsigned char cr;
        unsigned char cb;
    };

// ----------------------------------------------------------------------------------------

    template <>
    struct pixel_traits<ycrcb_pixel>
    {
        constexpr static bool rgb = false;
        constexpr static bool rgb_alpha = false;
        constexpr static bool grayscale = false;
        constexpr static bool hsi = false;
        constexpr static bool lab = false;
        constexpr static bool ycrcb = true;
        constexpr static long num = 3;
        typedef unsigned char basic_pixel_type;
        static basic_pixel_type min() { return 0; }
        static basic_pixel_type max() { return 255; }
        constexpr static bool is_unsigned = true;
        constexpr static bool has_alpha = false;
    };

// ----------------------------------------------------------------------------------------
    
    namespace assign_pixel_helpers
    {

        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::ycrcb>::type
            assign(P1& dest, const P2& src)
        {
            dest.y = src.y;
            dest.cr = src.cr;
            dest.cb = src.cb;
        }


        // Grayscale to YCrCB
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::grayscale>::type
            assign(P1& dest, const P2& src)
        {
            unsigned char delta = 128;

            dest.y = 0.299*src + 0.587*src + 0.114*src;
            dest.cr = (src - dest.y)*0.713 + delta;
            dest.cb = (src - dest.y)*0.564 + delta;
        }

        // convert from RGB to YCrCb
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::rgb>::type
        assign(P1& dest, const P2& src)
        {
            unsigned char delta = 128;

            dest.y = 0.299*src.red + 0.587*src.green + 0.114*src.blue;
            dest.cr = (src.red - dest.y)*0.713 + delta;
            dest.cb = (src.blue - dest.y)*0.564 + delta;

        }
        
        // RGBA to YCrCb
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::rgb_alpha>::type
        assign(P1& dest, const P2& src)
        {
            unsigned char delta = 128;

            dest.y = 0.299*src.red + 0.587*src.green + 0.114*src.blue;
            dest.cr = (src.red - dest.y)*0.713 + delta;
            dest.cb = (src.blue - dest.y)*0.564 + delta;

        }        
        
        // HSI to YCrCb
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::hsi>::type
        assign(P1& dest, const P2& src)
        {
            //dlib::rgb_pixel temp;

            //assign_pixel_helpers::assign(temp, src);
            //assign_pixel_helpers::assign(dest, temp);

        }   
        
        // LAB to YCrCb
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::ycrcb && pixel_traits<P2>::lab>::type
        assign(P1& dest, const P2& src)
        {
            //dlib::rgb_pixel temp;

            //assign_pixel_helpers::assign(temp, src);
            //assign_pixel_helpers::assign(dest, temp);
        }          
        
// ----------------------------------------------------------------------------------------

        // YCrCb to Grayscale
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::grayscale && pixel_traits<P2>::YCrCb>::type
        assign(P1& dest, const P2& src)
        {
            assign_pixel_helpers::assign(dest, src.y);
        }



        // Convert from YCrCb to RGB
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::rgb && pixel_traits<P2>::ycrcb>::type
        assign(P1& dest, const P2& src)
        {
            unsigned char delta = 128;

            dest.red = src.y + 1.403*(src.cr - delta);
            dest.green = src.y - 0.714*(src.cr - delta) - 0.344*(src.cb - delta);
            dest.blue = src.y + 1.773*(src.cb - delta);

        }
        
        // Convert from YCrCb to RGBA
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::rgb_alpha && pixel_traits<P2>::ycrcb>::type
        assign(P1& dest, const P2& src)
        {
            unsigned char delta = 128;

            dest.red = src.y + 1.403*(src.cr - delta);
            dest.green = src.y - 0.714*(src.cr - delta) - 0.344*(src.cb - delta);
            dest.blue = src.y + 1.773*(src.cb - delta);
            dest.alpha = 255;
        }        
             
        // Convert from YCrCb to HSI
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::hsi && pixel_traits<P2>::ycrcb>::type
        assign(P1& dest, const P2& src)
        {
            //dlib::rgb_pixel temp;

            //assign_pixel_helpers::assign(temp, src);
            //assign_pixel_helpers::assign(dest, temp);
        } 
        
        // Convert from YCrCb to LAB
        template < typename P1, typename P2 >
        typename enable_if_c<pixel_traits<P1>::lab && pixel_traits<P2>::ycrcb>::type
        assign(P1& dest, const P2& src)
        {
            //dlib::rgb_pixel temp;

            //assign_pixel_helpers::assign(temp, src);
            //assign_pixel_helpers::assign(dest, temp);
        }         
        

    }   // end of assign_pixel_helpers namespace


// ----------------------------------------------------------------------------------------

    inline void serialize (
        const dlib::ycrcb_pixel& item, 
        std::ostream& out 
    )   
    {
        try
        {
            dlib::serialize(item.y,out);
            dlib::serialize(item.cr,out);
            dlib::serialize(item.cb,out);
        }
        catch (dlib::serialization_error& e)
        {
            throw dlib::serialization_error(e.info + "\n   while serializing object of type ycrcb_pixel"); 
        }
    }

// ----------------------------------------------------------------------------------------

    inline void deserialize (
        dlib::ycrcb_pixel& item, 
        std::istream& in
    )   
    {
        try
        {
            dlib::deserialize(item.y,in);
            dlib::deserialize(item.cr,in);
            dlib::deserialize(item.cb,in);
        }
        catch (dlib::serialization_error& e)
        {
            throw dlib::serialization_error(e.info + "\n   while deserializing object of type ycrcb_pixel"); 
        }
    }

// ----------------------------------------------------------------------------------------


}// end of namespace

#endif  // YCRCB_PIXEL_INCLUDE_

