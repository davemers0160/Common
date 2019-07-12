#ifndef _DLIB_SET_LEARNING_RATES_H_
#define _DLIB_SET_LEARNING_RATES_H_

#include <type_traits>

#include <dlib/dnn.h>

// ----------------------------------------------------------------------------------------

namespace dlib
{
    namespace impl
    {
        // This is for the cases where begin != end
        template <size_t begin, size_t end>
        struct vllr_loop
        {
            // This is where the work gets done.  The odd decltype is used to check if layer contains
            // the set_learning_rate_multiplier() fucntion
            template<typename net_type>
            static decltype(std::declval<net_type>().layer_details().set_learning_rate_multiplier(0))
                set_value(net_type &net, double r1, double r2)
            {
                net.layer_details().set_learning_rate_multiplier(r1);
                net.layer_details().set_bias_learning_rate_multiplier(r2);
            }

            static void set_value(...)
            {
                // Intentionally left blank.  This handles the layers that don't have a 
                // set_learning_rate_multiplier() function
            }

            // This is the fuction to call within the struct 
            template <typename net_type>
            static void visit(net_type &net, double r1, double r2)
            {
                // set the values for the current layer
                set_value(layer<begin>(net), r1, r2);
                // move on and increment the begining layer
                vllr_loop<begin + 1, end>::visit(net, r1, r2);
            }
        };

        // This is for the cases where begin == end, i.e. the base case for the recursion
        template <size_t end>
        struct vllr_loop<end, end>
        {

            // This is where the work gets done.  The odd decltype is used to check if layer contains
            // the set_learning_rate_multiplier() fucntion
            template<typename net_type>
            static decltype(std::declval<net_type>().layer_details().set_learning_rate_multiplier(0))
                set_value(net_type &net, double r1, double r2)
            {
                net.layer_details().set_learning_rate_multiplier(r1);
                net.layer_details().set_bias_learning_rate_multiplier(r2);
            }

            static void set_value(...)
            {
                // Intentionally left blank.  This handles the layers that don't have a 
                // set_learning_rate_multiplier() function
            }

            // This is the fuction to call within the struct 
            template <typename net_type>
            static void visit(net_type &net, double r1, double r2)
            {
                // set the values for the current layer
                set_value(layer<end>(net), r1, r2);
            }
        };

    }   // end of impl namespace

    // This is the main function to call when you want to set the following:
    //   - set_learning_rate_multiplier
    //   - set_bias_learning_rate_multiplier
    // Call it like this: dlib::set_learning_rate<0, 3>(net, r1, r2);
    //   - where net is your net and r1,r2 are the learning rate multipliers
    template<size_t begin, size_t end, typename net_type>
    void set_learning_rate(net_type &net, double r1, double r2)
    {
        // this does a check of the input ranges to determine if they are out of range for the input network
        static_assert(begin <= end, "Invalid range");
        static_assert(end <= net_type::num_layers, "Invalid range");

        // begin the process of updating the learning rates
        impl::vllr_loop<begin, end>::visit(net, r1, r2);
    }

}   // end of dlib namespace

// ----------------------------------------------------------------------------------------


#endif  // _DLIB_SET_LEARNING_RATES_H_
