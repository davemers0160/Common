#ifndef SSIM_INCLUDE_
#define SSIM_INCLUDE_

#include <cstdint>

#include <dlib/threads.h>
#include <dlib/ref.h>
//#include "dlib/numeric_constants.h"
//#include <mutex>
//#include <vector>
#include "dlib/image_transforms/interpolation.h"
#include "dlib/image_transforms/spatial_filtering.h"
//#include "..///full_object_detection.h"
//#include "dlib/rand.h"
#include "add_border.h"

// https://ece.uwaterloo.ca/~z70wang/publications/ssim.html
// Single scale version of the SSIM indexing measure, which is most effective 
// if used at the appropriate scale.The precisely “right” scale depends on 
// both the image resolution and the viewing distance and is usually difficult 
// to be obtained.In practice, we suggest to use the following empirical 
// formula to determine the scale for images viewed from a typical distance 
// (say 3~5 times of the image height or width) : 1) Let 
// F = max(1, round(N / 256)), where N is the number of pixels in image height 
// (or width); 2) Average local F by F pixels and then downsample the image by 
// a factor of F; and 3) apply the ssim_index.m program.For example, for an 
// 512 x 512 image, F = max(1, round(512 / 256)) = 2, so the image should be 
// averaged within a 2 by 2 window and downsampled by a factor of 2 before 
// applying

//template <typename array_type>
struct ssim_struct {
    dlib::matrix<float> img_in;
    dlib::matrix<float> img_out;
    long size = 11;
    float sigma = 1.5;
};

//template <typename array_type>
void apply_gaussian_blur(ssim_struct &ss)
{
    dlib::gaussian_blur(ss.img_in, ss.img_out, ss.sigma, ss.size);
}


template <typename array_type1, typename array_type2, typename array_type3>
double ssim(
    const array_type1 img1,
    const array_type2 img2,
    array_type3 &ssim_map,
    float K1 = 0.01,
	float K2 = 0.03,
	uint32_t L = 255
    )
    {
        // check the inputs to make sure that meet the input requirements
        DLIB_CASSERT(img1.size() == img2.size(), "img1 size: " << img1.nr() << "x" << img1.nc() << "; img2 size: " << img2.nr() << "x" << img2.nc());
        DLIB_CASSERT(L > 0);
        DLIB_CASSERT(K1 > 0);
        DLIB_CASSERT(K2 > 0);

        float C1 = (K1*L)*(K1*L);
        float C2 = (K2*L)*(K2*L);

        // gaussian kernel size and sigma value
        long size = 11;
        float sigma = 1.5;

        uint32_t border = (uint32_t)((size >> 1) - 1);

        dlib::matrix<float> img1f;// = add_border(dlib::matrix_cast<float>(img1), 4);
        add_border(dlib::matrix_cast<float>(img1), img1f, 4, 1);
        dlib::matrix<float> img2f;// = add_border(dlib::matrix_cast<float>(img2), 4);
        add_border(dlib::matrix_cast<float>(img2), img2f, 4, 1);
        //ssim_struct img_s1, img_s2;


        // convert input image to float
        //dlib::assign_image(img1f, img1);
        //dlib::assign_image(img2f, img2);
        //dlib::assign_image(img_s1.img_in, img1);
        //dlib::assign_image(img_s2.img_in, img2);

        
        dlib::matrix<float> img1_sq = dlib::squared(img1f);
        dlib::matrix<float> img2_sq = dlib::squared(img2f);
        dlib::matrix<float> img12 = dlib::pointwise_multiply(img1f, img2f);

        dlib::matrix<float> mu1, mu2;

        dlib::gaussian_blur(img1f, mu1, sigma, size);
        dlib::gaussian_blur(img2f, mu2, sigma, size);

        //dlib::thread_function t1(apply_gaussian_blur, dlib::ref(s1));
        //dlib::thread_function t2(apply_gaussian_blur, dlib::ref(s2));
        //t1.wait();
        //t2.wait();

        dlib::matrix<float> mu1_sq = dlib::squared(mu1);
        dlib::matrix<float> mu2_sq = dlib::squared(mu2);
        dlib::matrix<float> mu1_mu2 = dlib::pointwise_multiply(mu1, mu2);

        dlib::matrix<float> sig1, sig2, sig12;

        dlib::gaussian_blur(img1_sq, sig1, sigma, size);
        dlib::gaussian_blur(img2_sq, sig2, sigma, size);
        dlib::gaussian_blur(img12, sig12, sigma, size);

        //dlib::thread_function  t3(dlib::gaussian_blur, img1_sq, dlib::ref(sig1), sigma, size);
        //dlib::thread_function  t4(dlib::gaussian_blur, img2_sq, dlib::ref(sig2), sigma, size);
        //dlib::thread_function  t5(dlib::gaussian_blur, img12, dlib::ref(sig12), sigma, size);
        //t3.wait();
        //t4.wait();
        //t5.wait();

        sig1 -= mu1_sq;
        sig2 -= mu2_sq;
        sig12 -= mu1_mu2;

        dlib::matrix<float> ssim_num = dlib::pointwise_multiply(2.0f * mu1_mu2 + C1, 2.0f * sig12 + C2);
        //dlib::matrix<float> ssim_den = 1.0/dlib::pointwise_multiply(mu1_sq + mu2_sq + C1,sig1 + sig2 + C2);
        dlib::matrix<float> ssim_den = dlib::reciprocal(dlib::pointwise_multiply(mu1_sq + mu2_sq + C1, sig1 + sig2 + C2));

        //// ssim_map = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))./((mu1_sq + mu2_sq + C1).*(sigma1_sq + sigma2_sq + C2));
        //ssim_map = dlib::pointwise_multiply(ssim_num, ssim_den);
        remove_border(dlib::pointwise_multiply(ssim_num, ssim_den), ssim_map, 4);

        return dlib::mean(ssim_map);

    }   // end of ssim


#endif  // SSIM_INCLUDE_