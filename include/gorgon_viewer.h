#ifndef GORGON_VIEWER_H
#define GORGON_VIEWER_H

#include <vector>
#include <cmath>

// dlib includes
#include <dlib/dnn.h>
#include <dlib/image_transforms/interpolation.h>
#include <dlib/dnn/layers.h>
#include <dlib/serialize.h>
#include <dlib/xml_parser.h>

#include "gorgon_common.h"


using namespace std;
// ----------------------------------------------------------------------------------------

class gorgon_doc_handler : public dlib::document_handler
{
    std::vector<std::string> ts;
    gorgon_param_struct &gp;

public:

    gorgon_doc_handler(
        gorgon_param_struct& gp_
    ) :
        gp(gp_)
    {}

    virtual void start_document(
    )
    {
        ts.clear();
        gp = gorgon_param_struct();
    }

    virtual void end_document(
    )
    {
    }

    virtual void start_element(
        const unsigned long line_number,
        const std::string& name,
        const dlib::attribute_list& atts
    )
    {
        try
        {
            if (ts.size() == 0)
            {
                if (name != "gorgon_data")
                {
                    std::ostringstream sout;
                    sout << "Invalid XML document.  Root tag must be <dataset>.  Found <" << name << "> instead.";
                    throw dlib::error(sout.str());
                }
                else
                {
                    ts.push_back(name);
                    return;
                }
            }

            if (name == "version")
            {
                if (atts.is_in_list("major")) gp.version.first = dlib::sa = atts["major"];
                else throw dlib::error("<version> missing required attribute 'major'");

                if (atts.is_in_list("minor")) gp.version.second = dlib::sa = atts["minor"];
                else throw dlib::error("<version> missing required attribute 'minor'");
            }
            else if (name == "layer")
            {
                if (atts.is_in_list("number")) gp.l = dlib::sa = atts["number"];
                else throw dlib::error("<layer> missing required attribute 'number'");

            }
            else if (name == "filter")
            {
                if (atts.is_in_list("n")) gp.n = dlib::sa = atts["n"];
                else throw dlib::error("<filter> missing required attribute 'n'");

                if (atts.is_in_list("rows")) gp.nr = dlib::sa = atts["rows"];
                else throw dlib::error("<filter> missing required attribute 'rows'");

                if (atts.is_in_list("cols")) gp.nc = dlib::sa = atts["cols"];
                else throw dlib::error("<filter> missing required attribute 'cols'");

                if (atts.is_in_list("k")) gp.k = dlib::sa = atts["k"];
                else throw dlib::error("<filter> missing required attribute 'k'");
            }

            ts.push_back(name);
        }
        catch (dlib::error& e)
        {
            throw dlib::error("Error on line " + dlib::cast_to_string(line_number) + ": " + e.what());
        }
    }

    virtual void end_element(
        const unsigned long,
        const std::string& name
    )
    {
        ts.pop_back();
        if (ts.size() == 0)
            return;
    }

    virtual void characters(
        const std::string& data
    )
    {
    }

    virtual void processing_instruction(
        const unsigned long,
        const std::string&,
        const std::string&
    )
    {
    }

};

// ----------------------------------------------------------------------------------------

class gorgon_viewer
{

public:

    gorgon_viewer() {}
    gorgon_viewer(const gorgon_viewer&) {}
    
    float t_min, t_max;

// ----------------------------------------------------------------------------------------
    void load_params(
        std::istream& in,
        gorgon_param_struct &params,
        std::vector<gorgon_data_struct> &data
    )
    {
        // clear out the existing data
        data.clear();

        // get the file size
        in.seekg(0, in.end);
        uint64_t file_size = in.tellg();
        in.seekg(0, in.beg);

        std::string version = params.get_version();

        if (version != "3.0")
        {
            throw dlib::serialization_error("Unexpected version found while deserializing gorgon.");
        }

        uint64_t data_size = params.get_data_size();
        std::vector<float> step_data;

        // get the magic number
        uint32_t magic_number;
        in.read(reinterpret_cast<char*>(&magic_number), sizeof(magic_number));

        //std::cout << "Magic Number: " << magic_number << std::endl;

        while (in.peek() != EOF)
        {

            gorgon_data_struct g_data;

            in.read(reinterpret_cast<char*>(&g_data.step), sizeof(g_data.step));
            //cout << "Step: " << g_data.step << endl;

            // get the current file position
            uint64_t curr_pos = in.tellg();

            // read in float values... should be 4 bytes total per float value
            if ((file_size - curr_pos) >= data_size * 4)
            {
                for (uint64_t idx = 0; idx < (params.n*params.k); ++idx)
                {
                    dlib::matrix<float> tmp_filt(params.nr, params.nc);
                    //tmp_filt.set_size(params.nr, params.nc);

                    for (uint16_t r = 0; r < params.nr; ++r)
                    {
                        for (uint16_t c = 0; c < params.nc; ++c)
                        {
                            float val;
                            in.read(reinterpret_cast<char*>(&val), sizeof(val)); 
                            tmp_filt(r, c) = val;
                        }

                    }

                    g_data.data.push_back(tmp_filt);
                }

                data.push_back(g_data);
                
            }
            else
            {
                in.seekg(0, in.end);
            }

        }   // end of while


    }

// ----------------------------------------------------------------------------------------

    void load_old_params(       
        std::istream& in,
        gorgon_param_struct &params,
        std::vector<gorgon_data_struct>& data
    )
    {
        // clear out the existing data
        data.clear();

        // get the file size
        in.seekg(0, in.end);
        uint64_t file_size = in.tellg();
        in.seekg(0, in.beg);
        //std::vector<dlib::matrix<float>> data2;
        while (in.peek() != EOF)
        {
            gorgon_data_struct g_data;

            std::string version;
            dlib::deserialize(version, in);
            if (version != "gorgon_v1")
                throw dlib::serialization_error("Unexpected version found while deserializing gorgon.");
            //int length = in.tellg();

            dlib::deserialize(g_data.step, in);
            dlib::deserialize(params.l, in);
            dlib::deserialize(params.n, in);
            dlib::deserialize(params.k, in);
            dlib::deserialize(params.nr, in);
            dlib::deserialize(params.nc, in);

            uint64_t data_size = params.n*params.k*params.nr*params.nc;
            uint64_t curr_pos = in.tellg();
            

            // read in float values... should be 6 bytes total per float value
            if ((file_size - curr_pos) >= data_size*6)
            {
                //for (uint64_t idx = 0; idx < data_size; ++idx)
                for (uint64_t idx = 0; idx < (params.n*params.k); ++idx)
                {
                    dlib::matrix<float> tmp_filt(params.nr, params.nc);
                    //tmp_filt.set_size(params.nr, params.nc);

                    for (uint16_t r = 0; r < params.nr; ++r)
                    {
                        for (uint16_t c = 0; c < params.nc; ++c)
                        {
                            float tmp;
                            dlib::deserialize(tmp, in);                            
                            //g_data.data.push_back(tmp);
                            tmp_filt(r, c) = tmp;
                        }

                    }

                    g_data.data.push_back(tmp_filt);
                }

                data.push_back(g_data);
            }
            else
            {
                in.seekg(0, in.end);
            }

        }   // end of while

    }   // end of load_params

// ----------------------------------------------------------------------------------------

    template <typename image_type1>
    void view_params(
        image_type1& out_img,
        gorgon_param_struct params,
        gorgon_data_struct data,
        const uint8_t padding = 2,
        const uint8_t outer_padding = 2
    )
    {
        //view_params(out_img, data.data, params.n, params.k, params.nr, params.nc, padding, outer_padding);
        view_params(out_img, data.data, params.n, params.k, params.nr, params.nc, padding, outer_padding);

    }


    template <typename image_type1>
    void view_params(
        image_type1& out_img,
        std::vector<dlib::matrix<float>> filter_data,
        uint64_t n,
        uint64_t k,
        uint64_t nr,
        uint64_t nc,
        const uint8_t padding = 2,
        const uint8_t outer_padding = 2
    )
    {

        // arrange the new image in a slightly different format
        // make the image n filters by k filters

        uint64_t width = k*nc + (k - 1)*padding + 2 * outer_padding;
        uint64_t height = n*nr + (n - 1)*padding + 2 * outer_padding;

        // @mem((out_imag.data).data, FLOAT32, 1, width, height, width*4)
        dlib::set_image_size(out_img, height, width);
        dlib::assign_all_pixels(out_img, 0);

        //dlib::matrix<dlib::rgb_alpha_pixel> tmp_img2(height, width);
        dlib::matrix<float> tmp_img2(height, width);
        dlib::assign_all_pixels(tmp_img2, 0);

        uint64_t index = 0;

        for (uint64_t r = outer_padding; r < height; r+=(nr+padding))
        {
            for (uint64_t c = outer_padding; c < width; c+=(nc+padding))
            {
                dlib::set_subm(out_img, r, c, nr, nc) = mat_to_rgbjetmat(filter_data[index], t_min, t_max);
                ++index;
            }
        }




    }

    template <typename image_type1>
    void view_params(
        image_type1& out_img,
        std::vector<float> params_data,
        uint64_t n,
        uint64_t k,
        uint64_t nr,
        uint64_t nc,
        const uint8_t padding = 2,
        const uint8_t outer_padding = 2
    )
    {
   
        //Finally, the convention in dlib code is to interpret the tensor as a set of
        //num_samples() 3D arrays, each of dimension k() by nr() by nc().  Also,
        //while this class does not specify a memory layout, the convention is to
        //assume that indexing into an element at coordinates (sample,k,r,c) can be
        //accomplished via:
        //host()[((sample*t.k() + k)*t.nr() + r)*t.nc() + c]

        // try to get the dimensions of the image to show each filter
        // make a square image with padding
        uint64_t num_filters = n*k;
        float tmp = sqrtf(num_filters);
        uint64_t s = (uint64_t)tmp;

        if (tmp - s > 0)
        {
            ++s;
        }

        uint64_t width = s*nc + (s - 1)*padding + 2 * outer_padding;
        uint64_t height = s*nr + (s - 1)*padding + 2 * outer_padding;

        // @mem((out_imag.data).data, FLOAT32, 1, width, height, width*4)
        set_image_size(out_img, height, width);
        dlib::assign_all_pixels(out_img, 0);

        //dlib::matrix<dlib::rgb_alpha_pixel> tmp_img2(height, width);
        dlib::matrix<float> tmp_img2(height, width);
        dlib::assign_all_pixels(tmp_img2, 0);

        // index through the 4-D tensor 
        uint64_t row = outer_padding;
        uint64_t col = outer_padding;

        for (uint64_t idx = 0; idx < n; ++idx)
        {
            for (uint64_t jdx = 0; jdx < k; ++jdx)
            {
                for (uint64_t r = 0; r < nr; ++r)
                {
                    for (uint64_t c = 0; c < nc; ++c)
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



        //float min_value;// = dlib::min(tmp_img2);
        //float max_value;// = dlib::max(tmp_img2);

        //dlib::find_min_and_max(tmp_img2, min_value, max_value);

        //auto tmp2 = dlib::jet(tmp_img2, max_value, min_value);
        //dlib::matrix<float> tmp2 = (tmp_img2 - min_value)*(255.0 / (max_value - min_value));

        //auto tmp3 = dlib::jet(tmp2, 255, 0);

        //dlib::assign_image(out_img, tmp3);

        int bp_stop = 0;
    }   // end of view_params

// ----------------------------------------------------------------------------------------

};

#endif  // GORGON_VIEWER_H
