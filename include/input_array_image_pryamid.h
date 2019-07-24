#ifndef DLIB_DNN_INPUT_ARRAY_PYR_H_
#define DLIB_DNN_INPUT_ARRAY_PYR_H_

#include <cstdint>
#include <sstream>
#include <array>
#include <algorithm>

#include "dlib/matrix.h"
#include "dlib/pixel.h"
#include "dlib/image_processing.h"
#include "dlib/cuda/tensor_tools.h"

namespace dlib
{

    // ----------------------------------------------------------------------------------------

    template <typename PYRAMID_TYPE, uint32_t array_depth>
    class input_array_image_pyramid
    {
    public:
        //typedef matrix<rgb_pixel> input_type;
        typedef std::array<dlib::matrix<uint8_t>, array_depth> input_type;
        typedef PYRAMID_TYPE pyramid_type;

        input_array_image_pyramid() 
        {
            avg_color.fill(128.0);  // fill in the average color with 128
        }

        input_array_image_pyramid(std::array<float,array_depth> avg_color_) 
        {
            for (uint64_t idx = 0; idx < array_depth; ++idx)
                avg_color[idx] = avg_color_[idx];
        }

        // float get_avg_red()   const { return avg_red; }
        // float get_avg_green() const { return avg_green; }
        // float get_avg_blue()  const { return avg_blue; }

        std::array<float, array_depth> get_avg_color() const { return avg_color; }

        unsigned long get_pyramid_padding() const { return pyramid_padding; }
        void set_pyramid_padding(unsigned long value) { pyramid_padding = value; }

        unsigned long get_pyramid_outer_padding() const { return pyramid_outer_padding; }
        void set_pyramid_outer_padding(unsigned long value) { pyramid_outer_padding = value; }

        bool image_contained_point(
            const tensor& data,
            const point& p
        ) const
        {
            auto&& rects = any_cast<std::vector<rectangle>>(data.annotation());
            DLIB_CASSERT(rects.size() > 0);
            return rects[0].contains(p + rects[0].tl_corner());
        }

        drectangle tensor_space_to_image_space(
            const tensor& data,
            drectangle r
        ) const
        {
            auto&& rects = any_cast<std::vector<rectangle>>(data.annotation());
            return tiled_pyramid_to_image<pyramid_type>(rects, r);
        }

        drectangle image_space_to_tensor_space(
            const tensor& data,
            double scale,
            drectangle r
        ) const
        {
            DLIB_CASSERT(0 < scale && scale <= 1, "scale: " << scale);
            auto&& rects = any_cast<std::vector<rectangle>>(data.annotation());
            return image_to_tiled_pyramid<pyramid_type>(rects, scale, r);
        }

        template <typename forward_iterator>
        void to_tensor(
            forward_iterator ibegin,
            forward_iterator iend,
            resizable_tensor& data
        ) const
        {
            auto d = std::distance(ibegin, iend);
            DLIB_CASSERT(std::distance(ibegin, iend) > 0);
            auto nr = ibegin[0][0].nr();
            auto nc = ibegin[0][0].nc();

            // make sure all the input matrices have the same dimensions
            for (auto i = ibegin; i != iend; ++i)
            {
                DLIB_CASSERT(i[0][0].nr() == nr && i[0][0].nc() == nc,
                    "\t input_array_image_pyramid::to_tensor()"
                    << "\n\t All matrices given to to_tensor() must have the same dimensions."
                    << "\n\t nr: " << nr
                    << "\n\t nc: " << nc
                    << "\n\t i->nr(): " << i[0][0].nr()
                    << "\n\t i->nc(): " << i[0][0].nc()
                );

            }

            long NR, NC;
            pyramid_type pyr;
            auto& rects = data.annotation().get<std::vector<rectangle>>();
            impl::compute_tiled_image_pyramid_details(pyr, nr, nc, pyramid_padding, pyramid_outer_padding, rects, NR, NC);

            // initialize data to the right size to contain the stuff in the iterator range.
            data.set_size(std::distance(ibegin, iend), ibegin->size(), NR, NC);

            // We need to zero the image before doing the pyramid, since the pyramid
            // creation code doesn't write to all parts of the image.  We also take
            // care to avoid triggering any device to hosts copies.
            auto ptr = data.host_write_only();
            for (size_t i = 0; i < data.size(); ++i)
                ptr[i] = 0;

            if (rects.size() == 0)
                return;

            // copy the first raw image into the top part of the tiled pyramid.  We need to
            // do this for each of the input images/samples in the tensor.
            for (auto i = ibegin; i != iend; ++i)
            {
                auto& img = *i;
                long nr_ = img[0].nr();
                long nc_ = img[0].nc();
                for (uint64_t idx = 0; idx < array_depth; ++idx)
                {
                    ptr += rects[0].top()*data.nc();
                    for (long r = 0; r < nr_; ++r)
                    {
                        auto p = ptr + rects[0].left();
                        for (long c = 0; c < nc_; ++c)
                            p[c] = (img[idx](r, c) - avg_color[idx]) / 256.0;
                        ptr += data.nc();
                    }
                    ptr += data.nc()*(data.nr() - rects[0].bottom() - 1);
                }

                //ptr += rects[0].top()*data.nc();
                //for (long r = 0; r < img.nr(); ++r)
                //{
                //    auto p = ptr + rects[0].left();
                //    for (long c = 0; c < img.nc(); ++c)
                //        p[c] = (img(r, c).green - avg_green) / 256.0;
                //    ptr += data.nc();
                //}
                //ptr += data.nc()*(data.nr() - rects[0].bottom() - 1);

                //ptr += rects[0].top()*data.nc();
                //for (long r = 0; r < img.nr(); ++r)
                //{
                //    auto p = ptr + rects[0].left();
                //    for (long c = 0; c < img.nc(); ++c)
                //        p[c] = (img(r, c).blue - avg_blue) / 256.0;
                //    ptr += data.nc();
                //}
                //ptr += data.nc()*(data.nr() - rects[0].bottom() - 1);
            }

            // now build the image pyramid into data.  This does the same thing as
            // create_tiled_pyramid(), except we use the GPU if one is available. 
            for (size_t i = 1; i < rects.size(); ++i)
            {
                alias_tensor src(data.num_samples(), data.k(), rects[i - 1].height(), rects[i - 1].width());
                alias_tensor dest(data.num_samples(), data.k(), rects[i].height(), rects[i].width());

                auto asrc = src(data, data.nc()*rects[i - 1].top() + rects[i - 1].left());
                auto adest = dest(data, data.nc()*rects[i].top() + rects[i].left());

                tt::resize_bilinear(adest, data.nc(), data.nr()*data.nc(),
                    asrc, data.nc(), data.nr()*data.nc());
            }
        }

        friend void serialize(const input_array_image_pyramid& item, std::ostream& out)
        {
            serialize("input_array_image_pyramid", out);
            serialize(item.avg_color[0], out);
            // serialize(item.avg_green, out);
            // serialize(item.avg_blue, out);
            serialize(item.pyramid_padding, out);
            serialize(item.pyramid_outer_padding, out);
        }

        friend void deserialize(input_array_image_pyramid& item, std::istream& in)
        {
            std::string version;
            deserialize(version, in);
            if (version != "input_array_image_pyramid")
                throw serialization_error("Unexpected version found while deserializing dlib::input_array_image_pyramid.");
            deserialize(item.avg_color[0], in);
            // deserialize(item.avg_green, in);
            // deserialize(item.avg_blue, in);
            deserialize(item.pyramid_padding, in);
            deserialize(item.pyramid_outer_padding, in);
        }

        friend std::ostream& operator<<(std::ostream& out, const input_array_image_pyramid& item)
        {
            out << "input_array_image_pyramid(" << item.avg_color[0] << ")";
            out << " array_depth=" << array_depth;
            out << " pyramid_padding=" << item.pyramid_padding;
            out << " pyramid_outer_padding=" << item.pyramid_outer_padding;
            return out;
        }

        friend void to_xml(const input_array_image_pyramid& item, std::ostream& out)
        {
            out << "<input_array_image_pyramid r='" << item.avg_red << "' g='" << item.avg_green
                << "' b='" << item.avg_blue
                << "' pyramid_padding='" << item.pyramid_padding
                << "' pyramid_outer_padding='" << item.pyramid_outer_padding
                << "'/>";
        }

    private:
        std::array<float, array_depth> avg_color;

        // float avg_red;
        // float avg_green;
        // float avg_blue;

        unsigned long pyramid_padding = 10;
        unsigned long pyramid_outer_padding = 11;
    };

// ----------------------------------------------------------------------------------------
}   // end of namespce

#endif // DLIB_DNN_INPUT_ARRAY_PYR_H_

