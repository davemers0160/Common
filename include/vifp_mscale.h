#ifndef VIF_PIXEL_MSCALE_H_
#define VIF_PIXEL_MSCALE_H_

//#include <mutex>
//#include <vector>
#include <cstdint>

//#include <dlib/threads.h>
//#include <dlib/ref.h>

#include <dlib/matrix.h>
//#include "dlib/image_transforms/interpolation.h"
#include <dlib/image_transforms.h>

//#include "add_border.h"

template<
    typename img_type
    >
double vifp_mscale(
    img_type ref, 
    img_type dist
    )
    {
        // check the inputs to make sure that meet the input requirements
        DLIB_CASSERT(ref.size() == dist.size());
        
        float sigma_nsq = 2.0;
        double num = 0.0;
        double den = 0.0;
        std::vector<uint8_t> N = {17, 9, 5, 3};
        std::vector<double> sigma = {17.0/5.0, 9.0/5.0, 1.0, 3.0/5.0};
        
        dlib::matrix<float> ref_f;
        dlib::matrix<float> dist_f;
        dlib::assign_image(ref_f, ref);
        dlib::assign_image(dist_f, dist);
        
        
        for(uint8_t idx=0; idx<4; ++idx)
        {

            dlib::matrix<float> ref_f2;
            dlib::matrix<float> dist_f2;
            
            if(idx>0)
            {
                // ref=filter2(win,ref,'valid');
                // dist=filter2(win,dist,'valid');
                // ref=ref(1:2:end,1:2:end);
                // dist=dist(1:2:end,1:2:end);       
                dlib::gaussian_blur(ref_f, ref_f2, sigma[idx], N[idx]);
                dlib::gaussian_blur(dist_f, dist_f2, sigma[idx], N[idx]);
                
                ref_f.set_size(ref_f.nr()>>1,ref_f.nc()>>1);
                dist_f.set_size(dist_f.nr()>>1,dist_f.nc()>>1);
                
                dlib::resize_image(ref_f,ref_f2, dlib::interpolate_bilinear());
                dlib::resize_image(dist_f,dist_f2, dlib::interpolate_bilinear());               
            }
       

            dlib::matrix<float> mu1, mu2;
            
            dlib::gaussian_blur(ref_f, mu1, sigma[idx], N[idx]);
            dlib::gaussian_blur(dist_f, mu2, sigma[idx], N[idx]);
            

            // mu1_sq = mu1.*mu1;
            // mu2_sq = mu2.*mu2;
            // mu1_mu2 = mu1.*mu2;
            dlib::matrix<float> mu1_sq = dlib::squared(mu1);
            dlib::matrix<float> mu2_sq = dlib::squared(mu2);
            dlib::matrix<float> mu1_mu2 = dlib::pointwise_multiply(mu1, mu2);


            // sigma1_sq = filter2(win, ref.*ref, 'valid') - mu1_sq;
            // sigma2_sq = filter2(win, dist.*dist, 'valid') - mu2_sq;
            // sigma12 = filter2(win, ref.*dist, 'valid') - mu1_mu2;  
            //dlib::matrix<float> img1_sq = dlib::squared(img1f);
            //dlib::matrix<float> img2_sq = dlib::squared(img2f);
            //dlib::matrix<float> img12 = dlib::pointwise_multiply(ref_f, dist_f);            
            dlib::matrix<float> sig1_sq, sig2_sq, sig12;
            dlib::matrix<float> ref_sq = dlib::squared(ref_f);
            dlib::matrix<float> dist_sq = dlib::squared(dist_f);
            dlib::matrix<float> ref_dist = dlib::pointwise_multiply(ref_f, dist_f);   
                        
            dlib::gaussian_blur(ref_sq, sig1_sq, sigma[idx], N[idx]);
            dlib::gaussian_blur(dist_sq, sig2_sq, sigma[idx], N[idx]);
            dlib::gaussian_blur(ref_dist, sig12, sigma[idx], N[idx]);
            

            sig1_sq -= mu1_sq;
            sig2_sq -= mu2_sq;
            sig12 -= mu1_mu2;
            
            sig1_sq = dlib::lowerbound(sig1_sq,0.0);
            sig2_sq = dlib::lowerbound(sig2_sq,0.0);
            

            // g=sigma12./(sigma1_sq+1e-10);
            // sv_sq=sigma2_sq-g.*sigma12;            
            dlib::matrix<float> g = dlib::pointwise_multiply(sig12, 1.0/(sig1_sq+1.0e-10));
            dlib::matrix<float> sv_sq = sig2_sq - dlib::pointwise_multiply(g, sig12);
            

            for(int64_t r=0; r<sig1_sq.nr(); ++r)
            {
                for(int64_t c=0; c<sig1_sq.nc(); ++c)
                {
                    
                    if(sig1_sq(r,c) < 1.0e-10)
                    {
                        g(r,c) = 0;                 // g(sigma1_sq<1e-10)=0;
                        sv_sq(r,c) = sig2_sq(r,c);  // sv_sq(sigma1_sq<1e-10)=sigma2_sq(sigma1_sq<1e-10);
                        sig1_sq(r,c) = 0;           // sigma1_sq(sigma1_sq<1e-10)=0;
                    }
                    
                       
                    if(sig2_sq(r,c) < 1.0e-10)
                    {                        
                        g(r,c) = 0;                 // g(sigma2_sq<1e-10)=0;
                        sv_sq(r,c) = 0;             // sv_sq(sigma2_sq<1e-10)=0;
                    }
                    
                    if(g(r,c) < 0)
                    {
                        sv_sq(r,c) = sig2_sq(r,c);  // sv_sq(g<0)=sigma2_sq(g<0);
                        g(r,c) = 0;                 // g(g<0)=0;

                    }
                      
                    if(sv_sq(r,c) < 1.0e-10)
                        sv_sq(r,c) = 1.0e-10;       // sv_sq(sv_sq<=1e-10)=1e-10;                    
                    
                }
            }

            
            // num=num+sum(sum(log10(1+g.^2.*sigma1_sq./(sv_sq+sigma_nsq))));
            dlib::matrix<float> temp_num = dlib::pointwise_multiply(sig1_sq, 1.0/(sv_sq+sigma_nsq));
            dlib::matrix<float> g2 = dlib::squared(g);
            num += (double)dlib::sum(dlib::log10(dlib::pointwise_multiply(g2, temp_num) + 1));
            
            // den=den+sum(sum(log10(1+sigma1_sq./sigma_nsq)));
            den += (double)dlib::sum(dlib::log10(temp_num + 1));

        }
        
        return num/den;  
        
    }   // end of vifp_mscale


#endif  // VIF_PIXEL_MSCALE_H_