#include "cuda_utils.h"
#include "cuda_dlib.h"
#include "cudnn_dlibapi.h"


namespace dlib 
{ 
    namespace cuda 
    {
	
    // ----------------------------------------------------------------------------------------
/*
        __global__ void _cuda_elu(const float* s, float* d, size_t n, const float* pp)
        {
            const float p = *pp;
            for (auto i : grid_stride_range(0, n))
            {
                if (s[i] > 0)
                    d[i] = s[i];
                else
                    d[i] = p*s[i];
            }
        }

        void elu (
            tensor& dest,
            const tensor& src,
            const tensor& param
        )
        {
            launch_kernel(_cuda_elu, max_jobs(dest.size()), 
                src.device(), dest.device(), src.size(), param.device());
        }
*/
    // ----------------------------------------------------------------------------------------
/*
        __global__ void _cuda_elu_gradient(float* out, const float* s, const float* gi, size_t n, const float* pp)
        {
            const float p = *pp;
            float pgrad = 0;
            for(auto i : grid_stride_range(0, n))
            {
                if (s[i] > 0)
                {
                    out[i] += gi[i];
                }
                else
                {
                    out[i] += p*gi[i];
                    pgrad += gi[i]*s[i];
                }
            }

            // Then do the warp reduce add thing to merge into one output value.
            warp_reduce_atomic_add(*ppgrad, pgrad);
        }

        void elu_gradient (
            tensor& grad,
            const tensor& src,
            const tensor& gradient_input,
            const tensor& param,
            tensor& params_grad 
        )
        {
            params_grad = 0;
            launch_kernel(_cuda_prelu_gradient, max_jobs(grad.size()), 
                grad.device(), src.device(), gradient_input.device(), grad.size(),
                param.device(), params_grad.device());
        }
*/
    // ----------------------------------------------------------------------------------------	
	}
	
}
	