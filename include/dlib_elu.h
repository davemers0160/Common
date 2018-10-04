#ifndef _DNN_ELU_H
#define _DNN_ELU_H

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

        void elu (
            tensor& dest,
            const tensor& src,
			const tensor& param
        );

        void elu_gradient (
            tensor& grad,
            const tensor& dest,
            const tensor& gradient_input,
			const tensor& param
        );
        
*/

// place this in cpu_dlib.cpp under namespace cpu

/*

    // ----------------------------------------------------------------------------------------
    
        void elu (
            tensor& dest,
            const tensor& src,
			const tensor& param
        )
        {
			//ELU(x)=max(0,x)+min(0,p*(exp(x)−1))
			const float p = param.host()[0];
            const auto d = dest.host();
            const auto s = src.host();

			for (size_t i = 0; i < src.size(); ++i)
                d[i] = std::max(s[i],0.0f) + std::min(0.0f,p*std::exp(s[i])-1);
        }

        void elu_gradient (
            tensor& grad,
            const tensor& dest,
            const tensor& gradient_input,
			const tensor& param
        )
        {
			// f'(x) = f(p,x) + p for x<0, 1 for x>=0
			const float p = param.host()[0];
            const float* gi = gradient_input.host();
            const float* in = dest.host();
            float* out = grad.host();
            if (is_same_object(grad, gradient_input))
            {
                for (size_t i = 0; i < dest.size(); ++i)
                {
                    if (in[i] > 0)
                        out[i] = gi[i];
                    else
                        out[i] = gi[i]*(std::max(in[i],0.0f) +  std::min(0.0f,p*std::exp(in[i])-1) + p);
                }
            }
            else
            {
                for (size_t i = 0; i < dest.size(); ++i)
                {
                    if (in[i] > 0)
                        out[i] += gi[i];
					else
						out[i] += gi[i]*(std::max(in[i],0.0f) +  std::min(0.0f,p*std::exp(in[i])-1) + p);
                }
            }
        }
        
*/


// ----------------------------------------------------------------------------------------

// place this in cudnn_dlibapi.h under namespace cuda
/*

    // ----------------------------------------------------------------------------------------

    void elu(
        tensor& dest,
        const tensor& src,
        const tensor& param
    );

    void elu_gradient(
        tensor& grad,
        const tensor& dest,
        const tensor& gradient_input,
        const tensor& param
    );

*/


// ----------------------------------------------------------------------------------------

// place this in cudnn_dlibapi.cpp under cuda namespace
/*
    static cudnnActivationDescriptor_t elu_activation_descriptor()
    {
        thread_local dlib::cuda::cudnn_activation_descriptor des(CUDNN_ACTIVATION_ELU, CUDNN_PROPAGATE_NAN,0);
        return des.get_handle();
    }

*/

// ----------------------------------------------------------------------------------------


// place this in cudnn_dlibapi.cpp under cuda namespace
/*

// ------------------------------------------------------------------------------------

    void elu(
        tensor& dest,
        const tensor& src,
        const tensor& param
    )
    {
        DLIB_CASSERT(have_same_dimensions(dest, src));
        if (src.size() == 0)
            return;

        const float alpha = param.host()[0];
        const float beta = 0;
        CHECK_CUDNN(cudnnActivationForward(context(),
            elu_activation_descriptor(),
            &alpha,
            descriptor(src),
            src.device(),
            &beta,
            descriptor(dest),
            dest.device()));
    }

    void elu_gradient(
        tensor& grad,
        const tensor& dest,
        const tensor& gradient_input,
        const tensor& param
    )
    {
        DLIB_CASSERT(
            have_same_dimensions(dest, gradient_input) == true &&
            have_same_dimensions(dest, grad) == true);
        if (dest.size() == 0)
            return;

        const float alpha = param.host()[0];
        const float beta = is_same_object(grad, gradient_input) ? 0 : 1;
        CHECK_CUDNN(cudnnActivationBackward(context(),
            elu_activation_descriptor(),
            &alpha,
            descriptor(dest),
            dest.device(),
            descriptor(gradient_input),
            gradient_input.device(),
            descriptor(dest),
            dest.device(),
            &beta,
            descriptor(grad),
            grad.device()));
    }

*/




// place this in tensor_tools.h under tt namespace
/*
    // ----------------------------------------------------------------------------------------

    void elu(
        tensor& dest,
        const tensor& src,
        const tensor& param
    );


    void elu_gradient(
        tensor& grad,
        const tensor& src,
        const tensor& gradient_input,
        const tensor& param
    );

*/


// place this in tensor_tools.cpp under tt namespce
/*

		// ----------------------------------------------------------------------------------------

		void elu (
			tensor& dest,
			const tensor& src,
			const tensor& param
		)
		{
		#ifdef DLIB_USE_CUDA
			dlib::cuda::elu(dest, src, param);
		#else
			cpu::elu(dest, src, param);
		#endif
		}

		void elu_gradient (
			tensor& grad,
			const tensor& src,
			const tensor& gradient_input,
			const tensor& param
		)
		{
		#ifdef DLIB_USE_CUDA
			cuda::elu_gradient(grad, src, gradient_input, param);
		#else
			cpu::elu_gradient(grad, src, gradient_input, param);
		#endif
		}

*/
// ----------------------------------------------------------------------------------------

namespace dlib
{

    class elu_
    {
    public:
        explicit elu_(
            float initial_param_value_ = 1.0
        ) : initial_param_value(initial_param_value_)
        {
        }

        float get_initial_param_value(
        ) const {
            return initial_param_value;
        }

        template <typename SUBNET>
        void setup(const SUBNET& /*sub*/)
        {
            params.set_size(1);
            params = initial_param_value;
        }

        void forward_inplace(const tensor& input, tensor& output)
        {
            tt::elu(output, input, params);
        } 
        
        void backward_inplace(
            const tensor& computed_output,
            const tensor& gradient_input, 
            tensor& data_grad, 
            tensor& 
        )
        {
            tt::elu_gradient(data_grad, computed_output, gradient_input, params);
        }
        
        inline dpoint map_input_to_output(const dpoint& p) const { return p; }
        inline dpoint map_output_to_input(const dpoint& p) const { return p; }

        const tensor& get_layer_params() const { return params; }
        tensor& get_layer_params() { return params; }

        friend void serialize(const elu_& item, std::ostream& out)
        {
            serialize("elu_", out);
            serialize(item.params, out);
            serialize(item.initial_param_value, out);
        }

        friend void deserialize(elu_& item, std::istream& in)
        {
            std::string version;
            deserialize(version, in);
            if (version != "elu_")
                throw serialization_error("Unexpected version '" + version + "' found while deserializing dlib::elu_.");
            deserialize(item.params, in);
            deserialize(item.initial_param_value, in);
        }

        friend std::ostream& operator<<(std::ostream& out, const elu_& item)
        {
            out << "elu\t ("
                << "initial_param_value=" << item.initial_param_value
                << ")";
            return out;
        }

        friend void to_xml(const elu_& item, std::ostream& out)
        {
            out << "<elu initial_param_value='" << item.initial_param_value << "'>\n";
            out << mat(item.params);
            out << "</elu>\n";
        }

    private:
        resizable_tensor params;
        float initial_param_value;
    };

    template <typename SUBNET>
    using elu = add_layer<elu_, SUBNET>;

// ----------------------------------------------------------------------------------------
}


#endif	// _DNN_ELU_H