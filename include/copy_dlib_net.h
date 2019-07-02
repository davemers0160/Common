#ifndef COPY_DLIB_NET_H_
#define COPY_DLIB_NET_H_


#include <type_traits>




namespace dlib
{

    namespace cpnet
    {
        template <size_t begin, size_t end, size_t begin2>
        struct copy_layer_loop
        {
            // this version of the recursion templte checks to see if the layer is part of the "add_layer" class
            // layers like tag layers are not
            template <typename F, typename T>
            static typename std::enable_if<!is_add_layer<F>::value>::type invoke_functor(F&& from, T&& to)
            {
                // intentionally left empty
                std::cout << "skipping: layer<" << begin << ">" << std::endl;
            }

            // this version will operate on all layers in the "add_layer" class
            // the layer details will be copied from one layer to another
            template <typename F, typename T>
            static typename std::enable_if<is_add_layer<F>::value>::type invoke_functor(F&& from, T&& to)
            {
                std::cout << "copying: layer<" << begin << ">" << std::endl;
                to.layer_details() = from.layer_details();
            }

            // this is the recursive call
            template <typename net_type1, typename net_type2>
            static void visit(
                net_type1& from_net,
                net_type2& to_net
            )
            {
                invoke_functor(layer<begin>(from_net), layer<begin2>(to_net));

                copy_layer_loop<begin + 1, end, begin2 + 1>::visit(from_net, to_net);
            }
        };

        template <size_t end, size_t begin2>
        struct copy_layer_loop<end, end, begin2>
        {

            template <typename F, typename T>
            static typename std::enable_if<!is_add_layer<F>::value>::type invoke_functor(F&& from, T&& to)
            {
                // intentionally left empty
                std::cout << "skipping: layer<" << end << ">" << std::endl;
            }

            template <typename F, typename T>
            static typename std::enable_if<is_add_layer<F>::value>::type invoke_functor(F&& from, T&& to)
            {
                std::cout << "copying: layer<" << end << ">" << std::endl;
                to.layer_details() = from.layer_details();
            }

            // Base case of recursion, i.e. the last iteration
            template <typename net_type1, typename net_type2>
            static void visit(
                net_type1& from_net,
                net_type2& to_net
            )
            {
                invoke_functor(layer<end>(from_net), layer<begin2>(to_net));
                std::cout << "copying complete!" << std::endl;
            }
        };

    }   // end of cpnet namespace


        // this most likely will be the copy net function in the end
    template <size_t b1, size_t e1, size_t b2, typename net_type1, typename net_type2>
    void copy_net(net_type1 &from_net, net_type2 &to_net)
    {
        // this does a check of the input ranges to determine if they are out of range for the input network
        static_assert(b1 <= e1, "Invalid range");
        static_assert(e1 <= net_type1::num_layers, "Invalid range");

        // begin the layer copying process
        cpnet::copy_layer_loop<b1, e1, b2>::visit(from_net, to_net);
    }

}   // end of dlib namespace




#endif  // end of COPY_DLIB_NET_H_
