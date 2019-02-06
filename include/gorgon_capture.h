#ifndef GORGON_CAPTURE_H
#define GORGON_CAPTURE_H

#include <cstdint>
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>

#include "gorgon_common.h"

// dlib includes
#include <dlib/dnn.h>
#include <dlib/image_transforms/interpolation.h>
#include <dlib/dnn/layers.h>
#include <dlib/serialize.h>



using namespace std;

//template <long L, long N, long K, long NR, long NC>
template<int64_t L>
//class gorgon<L, N, NR, NC, K>
class gorgon_capture
{

public:

    float t_min, t_max;

    template <typename net_type>
    gorgon_capture(net_type &net)
    {
        const auto& temp = dlib::layer<L>(net).get_output();
        n = temp.num_samples();
        k = 1;// temp.k();
        nr = temp.nr();
        nc = temp.nc();
        l = L;
        data_size = n * nr * nc * k;
    }
    //gorgon_capture(const gorgon_capture&) {}
    
    //template<typename net_type>
    gorgon_capture(
        uint64_t N,
        uint64_t K,
        uint64_t NR,
        uint64_t NC
    )
    {
        n = N;
        k = K;
        nr = NR;
        nc = NC;
        l = L;
        data_size = n*nr*nc*k;
    }



    //void set_savefile(std::string filename_) { filename = filename_; }

// ----------------------------------------------------------------------------------------
    // this function is used to initialize the metadata and binary file
    // just set the savefile without an extension
    void init(std::string filename)
    {
        write_xml(filename + ".xml");
        open_stream(filename + ".dat");

    }   // end of init



// ----------------------------------------------------------------------------------------

    void open_stream(std::string savefile)
    {
        try
        {
            gorgonStream.open(savefile, ios::out | ios::app | ios::binary);
            uint32_t magic_number = 0x00FF;
            gorgonStream.write(reinterpret_cast<const char*>(&magic_number), sizeof(magic_number));
        }
        catch(std::exception &e)
        {
            std::cout << e.what() << std::endl;
        }
    }   // end of open_stream
    
// ----------------------------------------------------------------------------------------
   
    void close_stream()
    {
        std::cout << "Closing gorgon stream for layer " << l << " ..." << std::endl;
        gorgonStream.close();
    }   // end of close_stream
    
// ----------------------------------------------------------------------------------------
/*
    template <typename net_type,
              typename image_type1>
    void view_net_params(
        net_type& net,
        image_type1& out_img,
        const uint64_t padding = 3,
        const uint64_t outer_padding = 3
    )
    {
        //const auto& layer_C = dlib::layer<L>(net);
        const auto& layer_details = dlib::layer<L>(net).layer_details();
        const auto& layer_params = layer_details.get_layer_params(); // dlib::layer<L>(net).layer_details().get_layer_params();
        const float* params_data = layer_params.host();

        //This section is designed to work with con layers or other layers with the 
        //same structure only.  Need to figure out how to add checks for the con_ and 
        //similar layers. 

        //long n = N;
        //long nr = NR;
        //long nc = NC;
        //long k = K;
        //long l = L;

        uint64_t data_size = n*k*nr*nc;

        std::vector<float> param_vec = convert_ptr(params_data, data_size);
        view_params(out_img, param_vec, n, k, nr, nc, padding, outer_padding);

    }   // end of view_net_params
*/
// ----------------------------------------------------------------------------------------

    template <typename net_type>
    void save_params(
        net_type& net,
        uint64_t step
    )
    {
        try
        {
            if(gorgonStream.is_open())
            {
                const auto& layer_details = dlib::layer<L>(net).layer_details();
                const auto& layer_params = layer_details.get_layer_params(); 
                const float* params_data = layer_params.host();

                //uint64_t data_size = n*nr*nc*k;

                //dlib::serialize("gorgon_v1", gorgonStream);
                //dlib::serialize(step, gorgonStream);
                //dlib::serialize(L, gorgonStream);
                //dlib::serialize(n, gorgonStream);
                //dlib::serialize(k, gorgonStream);
                //dlib::serialize(nr, gorgonStream);
                //dlib::serialize(nc, gorgonStream);
                gorgonStream.write(reinterpret_cast<const char*>(&step), sizeof(step));

                for (uint64_t idx=0; idx < data_size; ++idx)
                {
                    //dlib::serialize(params_data[idx], gorgonStream);
                    gorgonStream.write(reinterpret_cast<const char*>(&params_data[idx]), sizeof(params_data[idx]));
                }

            }
        }
        catch(dlib::error& e)
        {
            std::cout << "Error saving parameters.  Check to make sure the layer is one that has parameters" << std::endl;
            std::cout << e.what() << std::endl;
        }

    }   // end of save_params

// ----------------------------------------------------------------------------------------

    template <typename net_type>
    void save_net_output(
        net_type& net
    )
    {
        uint64_t idx, jdx;

        try
        {
            if (gorgonStream.is_open())
            {
                const auto& layer_output = dlib::layer<L>(net).get_output();
                const float* data = layer_output.host();

                uint64_t img_size = nr * nc;

                for (idx = 0; idx < (uint64_t)layer_output.k(); ++idx)
                {
                    gorgonStream.write(reinterpret_cast<const char*>(&idx), sizeof(idx));

                    for (jdx = 0; jdx < img_size; ++jdx)
                    {
                        gorgonStream.write(reinterpret_cast<const char*>(&data[jdx+(idx*img_size)]), sizeof(float));
                    }
                }

            }   // end if
        }
        catch (dlib::error& e)
        {
            std::cout << "Error saving parameters.  Check to make sure the layer is one that has parameters" << std::endl;
            std::cout << e.what() << std::endl;
        }

    }   // end of save_params

// ----------------------------------------------------------------------------------------

/*
    template <typename image_type1>
    void view_params(
        image_type1& out_img,
        gorgon_param_struct params,
        const unsigned long padding = 3,
        const unsigned long outer_padding = 3
    )
    {
        view_params(out_img, params.data, params.n, params.k, params.nr, params.nc, padding, outer_padding);
    }

    template <typename image_type1>
    void view_params(
        image_type1& out_img,
        std::vector<float> params_data,
        long n, 
        long k, 
        long nr, 
        long nc,
        const unsigned long padding = 3,
        const unsigned long outer_padding = 3
    )
    {

        
        // Finally, the convention in dlib code is to interpret the tensor as a set of
        // num_samples() 3D arrays, each of dimension k() by nr() by nc().  Also,
        // while this class does not specify a memory layout, the convention is to
        // assume that indexing into an element at coordinates (sample,k,r,c) can be
        // accomplished via:
        // host()[((sample*t.k() + k)*t.nr() + r)*t.nc() + c]
        

        // try to get the dimensions of the image to show each filter
        // make a square image with padding
        long num_filters = n*k;
        float tmp = sqrtf(num_filters);
        long s = (long)tmp;

        if (tmp - s > 0)
        {
            ++s;
        }

        long width = s*nc + (s - 1)*padding + 2 * outer_padding;
        long height = s*nr + (s - 1)*padding + 2 * outer_padding;

        // @mem((out_imag.data).data, FLOAT32, 1, width, height, width*4)
        set_image_size(out_img, height, width);
        dlib::assign_all_pixels(out_img, 0);

        //dlib::matrix<dlib::rgb_alpha_pixel> tmp_img2(height, width);
        dlib::matrix<float> tmp_img2(height, width);
        dlib::assign_all_pixels(tmp_img2, 0);

        // index through the 4-D tensor 
        long row = outer_padding;
        long col = outer_padding;

        for (long idx = 0; idx < n; ++idx)
        {
            for (long jdx = 0; jdx < k; ++jdx)
            {
                for (long r = 0; r < nr; ++r)
                {
                    for (long c = 0; c < nc; ++c)
                    {
                        // host()[((sample*t.k() + k)*t.nr() + r)*t.nc() + c]

                        // convert 32-bit float to a 4-channel color image
                        //uint32_t pxf = *reinterpret_cast<uint32_t*>(&params_data[((idx*k + jdx)*nr + r)*nc + c]);
                        //dlib::rgb_alpha_pixel px = dlib::rgb_alpha_pixel((uint8)((pxf >> 24) & 0x00FF), (uint8)((pxf >> 16) & 0x00FF), (uint8)((pxf >> 8) & 0x00FF), (uint8)(pxf & 0x00FF));

                        // use the 32-bit float directly
                        float px = params_data[((idx*k + jdx)*nr + r)*nc + c];
                        dlib::assign_pixel(out_img(row + r, col + c), val2rgba_jet(px, t_min, t_max));

                        //-------------------------------------------------------------------
                        dlib::assign_pixel(tmp_img2(row + r, col + c), px);
                    }
                }

                if (col >= (width - nc - outer_padding))
                {
                    col = outer_padding;
                    row += (padding + nr);
                }
                else
                {
                    col += (padding + nc);
                }

            }

        }   // end of index looping operations



        float min_value;// = dlib::min(tmp_img2);
        float max_value;// = dlib::max(tmp_img2);

        dlib::find_min_and_max(tmp_img2, min_value, max_value);

        //auto tmp2 = dlib::jet(tmp_img2, max_value, min_value);
        //dlib::matrix<float> tmp2 = (tmp_img2 - min_value)*(255.0 / (max_value - min_value));

        //auto tmp3 = dlib::jet(tmp2, 255, 0);

        //dlib::assign_image(out_img, tmp3);

        int bp_stop = 0;
    }   // end of view_params
*/
// ----------------------------------------------------------------------------------------

    friend std::ostream& operator<<(std::ostream& out, const gorgon_capture& item)
    {
        out << "Gorgon Capture<L>(N, K, NR, NC): <" << L << ">" 
            << "(" << item.n << ", " 
            << item.k << ", " << item.nr << ", " << item.nc << ")" << std::endl;          
        return out;
    }
    
// ----------------------------------------------------------------------------------------

private:

    std::ofstream gorgonStream;
    //std::string filename;

    uint64_t n = 0;
    uint64_t k = 0;
    uint64_t nr = 0;
    uint64_t nc = 0;
    uint64_t l = 0;
    uint64_t data_size = 0;
    
    //std::vector<float> convert_ptr(
    //    const float *data_in,
    //    const unsigned long length
    //)
    //{
    //    std::vector<float> data_out(data_in, data_in + length);
    //    return data_out;
    //}   // end of convert_ptr

// ----------------------------------------------------------------------------------------

    void write_xml(std::string filename)
    {
        std::ofstream xmlStream;

        //uint64_t l = 1, n = 2, nr = 3, nc = 3, k = 2;

        try
        {
            xmlStream.open(filename, ios::out);
            xmlStream << "<?xml version='1.0' encoding='ISO-8859-1'?>\n";
            xmlStream << "<?xml-stylesheet type='text/xsl' href='image_metadata_stylesheet.xsl'?>\n";
            xmlStream << "<gorgon_data>\n";
            xmlStream << "    <version major='3' minor='0' />\n";
            xmlStream << "    <layer number='" << l << "'/>\n"; 
            xmlStream << "    <filter n='" << n << "' rows='" << nr << "' cols='" << nc << "' k='" << k << "'/>\n";
            xmlStream << "</gorgon_data>\n\n";
            xmlStream.close();

        }
        catch (std::exception &e)
        {
            std::cout << "Error saving XML metadata..." << std::endl;
            std::cout << e.what() << std::endl;
        }
    }   // end of write_xml

};  // end of gorgon_capture class


#endif // GORGON_CAPTURE_H
