#ifndef _TIME_MEDIAN_H
#define _TIME_MEDIAN_H

#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <algorithm>
#include <vector> 

// OpenCV Includes
#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  


void time_median_cv(std::vector<cv::Mat> src, cv::Mat &dst)
{
    std::vector<int32_t> median(src.size());
    
    dst = cv::Mat(src[0].size(),src[0].type(),cv::Scalar::all(0));
       
    for(uint32_t row=0; row<src[0].rows; ++row)
    {
        for(uint32_t col=0; col<src[0].cols; ++col)
        {
            for(uint32_t N=0; N<src.size(); ++N)
            {
                median[N] = src[N].at<int32_t>(row,col);
            }
            std::nth_element(median.begin(), median.begin() + (uint32_t)(median.size() / 2.0 + 0.5), median.end());
            
            dst.at<int32_t>(row,col) = median[(uint32_t)(median.size() / 2.0 + 0.5)];
        }   // end cols
        
    }   // end row
    
    
    
    
/*    
    
    for (idx = 0; idx < medMat_I[0].rows; idx++)
    {
        for (jdx = 0; jdx < medMat_I[0].cols; jdx++)
        {

            for (kdx = 0; kdx < num; kdx++)
            {
                //bgrPixel.val[0] = pixelPtr[i*foo.cols*cn + j*cn + 0]; // B
                //bgrPixel.val[1] = pixelPtr[i*foo.cols*cn + j*cn + 1]; // G
                //bgrPixel.val[2] = pixelPtr[i*foo.cols*cn + j*cn + 2]; // R
                medianVector_I[0][kdx] = medMat_I[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 0];
                medianVector_O[0][kdx] = medMat_O[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 0];
                medianVector_I[1][kdx] = medMat_I[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 1];
                medianVector_O[1][kdx] = medMat_O[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 1];
                medianVector_I[2][kdx] = medMat_I[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 2];
                medianVector_O[2][kdx] = medMat_O[kdx].data[idx*medMat_I[0].cols * 3 + jdx * 3 + 2];
            }

            // sort full vector
            //std::sort(medianVector_I[0].begin(), medianVector_I[0].end());
            //std::sort(medianVector_O[0].begin(), medianVector_O[0].end());
            //std::sort(medianVector_I[1].begin(), medianVector_I[1].end());
            //std::sort(medianVector_O[1].begin(), medianVector_O[1].end());
            //std::sort(medianVector_I[2].begin(), medianVector_I[2].end());
            //std::sort(medianVector_O[2].begin(), medianVector_O[2].end());

            // sort up the the middle point
            std::nth_element(medianVector_I[0].begin(), medianVector_I[0].begin() + (int)(medianVector_I[0].size() / 2 + 0.5), medianVector_I[0].end());
            std::nth_element(medianVector_O[0].begin(), medianVector_O[0].begin() + (int)(medianVector_O[0].size() / 2 + 0.5), medianVector_O[0].end());
            std::nth_element(medianVector_I[1].begin(), medianVector_I[1].begin() + (int)(medianVector_I[1].size() / 2 + 0.5), medianVector_I[1].end());
            std::nth_element(medianVector_O[1].begin(), medianVector_O[1].begin() + (int)(medianVector_O[1].size() / 2 + 0.5), medianVector_O[1].end());
            std::nth_element(medianVector_I[2].begin(), medianVector_I[2].begin() + (int)(medianVector_I[2].size() / 2 + 0.5), medianVector_I[2].end());
            std::nth_element(medianVector_O[2].begin(), medianVector_O[2].begin() + (int)(medianVector_O[2].size() / 2 + 0.5), medianVector_O[2].end());


            //infocusImage.at<unsigned char>(idx, jdx) = medianVector_I[(int)num / 2][0];
            //defocusImage.at<unsigned char>(idx, jdx) = medianVector_O[(int)num / 2][0];
            infocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 0] = medianVector_I[0][(int)(num / 2 + 0.5)];
            infocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 1] = medianVector_I[1][(int)(num / 2 + 0.5)];
            infocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 2] = medianVector_I[2][(int)(num / 2 + 0.5)];
            defocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 0] = medianVector_O[0][(int)(num / 2 + 0.5)];
            defocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 1] = medianVector_O[1][(int)(num / 2 + 0.5)];
            defocusImage.data[idx*medMat_I[0].cols * 3 + jdx * 3 + 2] = medianVector_O[2][(int)(num / 2 + 0.5)];
        }
    }

*/

}   //  end of time_median


#endif  // _TIME_MEDIAN_H
