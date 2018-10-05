#ifndef _DNN_SRELU_H
#define _DNN_SRELU_H

#include <cstdlib>
#include <atomic>
#include <algorithm>

//#include "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.0\include\cuda_runtime.h"
//#include "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.0\include\cudnn.h"

#include "dlib/dnn/core.h"
#include "dlib/cuda/cuda_dlib.h"
#include "dlib/cuda/cudnn_dlibapi.h"
#include "dlib/cuda/tensor.h"
#include "dlib/cuda/tensor_tools.h"
#include "dlib/algs.h"


// ----------------------------------------------------------------------------------------

// place this in cpu_dlib.h under namespace cpu
/*
    // ----------------------------------------------------------------------------------------

        void srelu (
            tensor& dest,
            const tensor& src,
            const tensor& param
        );

        void srelu_gradient (
            tensor& grad,
            const tensor& src,
            const tensor& gradient_input,
            const tensor& param,
            tensor& params_grad 
        );
        
*/

// place this in cpu_dlib.cpp under namespace cpu

/*

    // ----------------------------------------------------------------------------------------
    
        void srelu (
            tensor& dest,
            const tensor& src,
			const tensor& param
        )
        {
			//srelu(x) = tr+ar*(x-tr), when x>=tr; x, when tr>x>tl; tl+al*(x-tl), when x<=tl
            const float* p = param.host();  // p[0]=tl, p[1]=tr, p[2]=al, p[3]=ar
            const float* s = src.host();
            float* d = dest.host();
            for (size_t i = 0; i < dest.size(); ++i)
            {
                if (s[i] >= p[1])
                    d[i] = p[1] + p[3]*(s[i]-p[1]);
                else if(s[1] <= p[0])
                    d[i] = p[0] + p[2]*(s[i]-p[0]);
                else
                    d[i] = s[i];
            }
        }

        void srelu_gradient (
            tensor& grad,
            const tensor& dest,
            const tensor& gradient_input,
			const tensor& param,
            tensor& params_grad
        )
        {
			// srelu'(x) = ar, when x >= tr; x, when tr > x > tl; al, when x <= tl
            DLIB_CASSERT(is_same_object(grad, gradient_input) == false);
            const float* p = param.host();      // p[0]=tl, p[1]=tr, p[2]=al, p[3]=ar
            const float* gi = gradient_input.host();
            const float* s = src.host();
            float* out = grad.host();
            float tl_grad = 0;
            float tr_grad = 0;
            float al_grad = 0;
            float ar_grad = 0;
            
            for (size_t i = 0; i < src.size(); ++i)
            {
                if (s[i] >= p[1])
                {
                    out[i] += p[3]*gi[i];
                    tr_grad += gi[i]*(1-p[3]);
                    ar_grad += gi[i]*(s[i]-p[1]);
                }
                else if(s[1] <= p[0])
                {
                    out[i] += p[2]*gi[i];
                    tl_grad += gi[i]*(1-p[2]);
                    al_grad += gi[i]*(s[i]-p[0]);
                }
                else
                {
                    out[i] += gi[i];
                }
                
            }
            params_grad.host()[0] = tl_grad;
            params_grad.host()[1] = tr_grad;
            params_grad.host()[2] = al_grad;
            params_grad.host()[3] = ar_grad;
            
        }
        
*/


// ----------------------------------------------------------------------------------------

// place this in cuda_dlib.h under namespace cuda
/*

    // ----------------------------------------------------------------------------------------

    void srelu (
        tensor& dest,
        const tensor& src,
        const tensor& param
    );

    void srelu_gradient (
        tensor& grad,
        const tensor& src,
        const tensor& gradient_input,
        const tensor& param,
        tensor& params_grad 
    );

*/

// ----------------------------------------------------------------------------------------

// place this in cuda_dlib.cu under cuda namespace
/*

    // ----------------------------------------------------------------------------------------

        __global__ void _cuda_srelu(const float* s, float* d, size_t n, const float* pp)
        {
            const float* p = *pp;
            for (auto i : grid_stride_range(0, n))
            {
                if (s[i] >= p[1])
                    d[i] = p[1] + p[3]*(s[i]-p[1]);
                else if(s[1] <= p[0])
                    d[i] = p[0] + p[2]*(s[i]-p[0]);
                else
                    d[i] = s[i];
            }
        }

        void srelu (
            tensor& dest,
            const tensor& src,
            const tensor& param
        )
        {
            launch_kernel(_cuda_srelu, max_jobs(dest.size()), 
                src.device(), dest.device(), src.size(), param.device());
        }

    // ----------------------------------------------------------------------------------------

        __global__ void _cuda_srelu_gradient(float* out, const float* s, const float* gi, size_t n, const float* pp, float* ppgrad)
        {
            const float *p = *pp;
            float tl_grad = 0;
            float tr_grad = 0;
            float al_grad = 0;
            float ar_grad = 0;

            for(auto i : grid_stride_range(0, n))
            {
                if (s[i] >= p[1])
                {
                    out[i] += p[3]*gi[i];
                    tr_grad += gi[i]*(1-p[3]);
                    ar_grad += gi[i]*(s[i]-p[1]);
                }
                else if(s[1] <= p[0])
                {
                    out[i] += p[2]*gi[i];
                    tl_grad += gi[i]*(1-p[2]);
                    al_grad += gi[i]*(s[i]-p[0]);
                }
                else
                {
                    out[i] += gi[i];
                }
                
            }            
            
            // Then do the warp reduce add thing to merge into one output value.
            warp_reduce_atomic_add(ppgrad[0], tl_grad);
            warp_reduce_atomic_add(ppgrad[1], tr_grad);
            warp_reduce_atomic_add(ppgrad[2], al_grad);
            warp_reduce_atomic_add(ppgrad[3], ar_grad);

        }

        void srelu_gradient (
            tensor& grad,
            const tensor& src,
            const tensor& gradient_input,
            const tensor& param,
            tensor& params_grad 
        )
        {
            params_grad = 0;
            launch_kernel(_cuda_srelu_gradient, max_jobs(grad.size()), 
                grad.device(), src.device(), gradient_input.device(), grad.size(),
                param.device(), params_grad.device());
        }
        
        
*/


// ----------------------------------------------------------------------------------------


// place this in tensor_tools.h under tt namespace
/*
    // ----------------------------------------------------------------------------------------

    void srelu (
        tensor& dest,
        const tensor& src,
        const tensor& param
    );

    void srelu_gradient (
        tensor& grad,
        const tensor& src,
        const tensor& gradient_input,
        const tensor& param,
        tensor& params_grad 
    );
*/


// place this in tensor_tools.cpp under tt namespce
/*

// ----------------------------------------------------------------------------------------

    void srelu (
        tensor& dest,
        const tensor& src,
        const tensor& param
    )
    {
#ifdef DLIB_USE_CUDA
        cuda::srelu(dest, src, param);
#else
        cpu::srelu(dest, src, param);
#endif
    }

    void srelu_gradient (
        tensor& grad,
        const tensor& src,
        const tensor& gradient_input,
        const tensor& param,
        tensor& params_grad 
    )
    {
#ifdef DLIB_USE_CUDA
        cuda::srelu_gradient(grad, src, gradient_input, param, params_grad);
#else
        cpu::srelu_gradient(grad, src, gradient_input, param, params_grad);
#endif
    }

*/
// ----------------------------------------------------------------------------------------

namespace dlib
{

    class srelu_
    {
    public:
        explicit srelu_(
            float tl_ = -1.0, 
            float al_ = 0.1,
            float tr_ = 1.0,
            float ar_ = 0.1
        ) : tl(tl_),al(al_),tr(tr_),ar(ar_)
        {
        }

        // float get_initial_param_value(
        // ) const {
            // return initial_param_value;
        // }

        template <typename SUBNET>
        void setup(const SUBNET& /*sub*/)
        {
            params.set_size(4);
            params.host()[0] = tl;
            params.host()[1] = al;
            params.host()[2] = tr;
            params.host()[3] = ar;
        }

        template <typename SUBNET>
        void forward(
            const SUBNET& sub, 
            resizable_tensor& data_output
        )
        {
            data_output.copy_size(sub.get_output());
            tt::srelu(data_output, sub.get_output(), params);
        }
        
        template <typename SUBNET>
        void backward(
            const tensor& gradient_input, 
            SUBNET& sub, 
            tensor& params_grad
        )
        {
            tt::srelu_gradient(sub.get_gradient_input(), sub.get_output(), 
                gradient_input, params, params_grad);
        }
        
        inline dpoint map_input_to_output(const dpoint& p) const { return p; }
        inline dpoint map_output_to_input(const dpoint& p) const { return p; }

        const tensor& get_layer_params() const { return params; }
        tensor& get_layer_params() { return params; }

        friend void serialize(const srelu_& item, std::ostream& out)
        {
            serialize("srelu_", out);
            serialize(item.params, out);
            serialize(item.tl, out);
            serialize(item.al, out);
            serialize(item.tr, out);
            serialize(item.ar, out);
        }

        friend void deserialize(srelu_& item, std::istream& in)
        {
            std::string version;
            deserialize(version, in);
            if (version != "srelu_")
                throw serialization_error("Unexpected version '" + version + "' found while deserializing dlib::srelu_.");
            deserialize(item.params, in);
            deserialize(item.tl, in);
            deserialize(item.al, in);
            deserialize(item.tr, in);
            deserialize(item.ar, in);
        }

        friend std::ostream& operator<<(std::ostream& out, const srelu_& item)
        {
            out << "srelu\t ("
                << "tl=" << item.tl
                << ", al=" << item.al
                << ", tr=" << item.tr
                << ", ar=" << item.ar                
                << ")";
            return out;
        }

        friend void to_xml(const srelu_& item, std::ostream& out)
        {
            out << "<srelu tl='" << item.tl 
                << "', al='" << item.al 
                << "', tr='" << item.tr 
                << "', ar='" << item.ar << "'>\n";
            out << mat(item.params);
            out << "</srelu>\n";
        }

    private:
        resizable_tensor params;
        float tl,al,tr,ar;
    };

    template <typename SUBNET>
    using srelu = add_layer<srelu_, SUBNET>;

// ----------------------------------------------------------------------------------------
}


#endif	// _DNN_SRELU_H