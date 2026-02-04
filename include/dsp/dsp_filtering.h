#ifndef DSP_FILTERING_DEFINITION_H_
#define DSP_FILTERING_DEFINITION_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
// need for VS for pi and other math constatnts
//#define _USE_MATH_DEFINES
#define _SILENCE_NONFLOATING_COMPLEX_DEPRECATION_WARNING

#elif defined(__linux__)

#endif

#include <cstdint>
#include <cmath>
#include <vector>
#include <complex>
#include <iostream>
#include <iomanip>
#include <deque>
#include <algorithm>

namespace DSP
{
    //-----------------------------------------------------------------------------
    //std::vector<std::complex<int16_t>> apply_rotation(std::vector<std::complex<float>>& src, std::vector<std::complex<float>>& f_rot)
    inline std::vector<std::complex<int16_t>> apply_rotation(std::vector<std::complex<int16_t>>& src, std::complex<double> channel_coeff)
    {
        uint32_t idx;

        std::vector<std::complex<int16_t>> iq_data(src.size(), std::complex<int16_t>(0, 0));

        for (idx = 0; idx < src.size(); ++idx)
        {
            iq_data[idx] = std::complex<int16_t>(std::exp((channel_coeff * (double)idx)) * std::complex<double>(src[idx].real(), src[idx].imag()));
        }

        return iq_data;

    }   // end of apply_rotation

    //-----------------------------------------------------------------------------
    //std::vector<std::complex<int16_t>> apply_filter_rotation(std::vector<std::complex<float>>& src, std::vector<std::complex<float>>& f_rot)
    inline std::vector<std::complex<int16_t>> apply_fir_filter_rotation(std::vector<std::complex<int16_t>>& src, const std::vector<double>& fir_filter, std::complex<double> channel_coeff)
    {
        uint32_t idx, jdx;
        int32_t dx = (int32_t)(fir_filter.size() >> 1);
        int32_t x;
        //int32_t temp = 0;

        std::complex<double> accum;

        std::vector<std::complex<int16_t>> iq_data(src.size(), std::complex<int16_t>(0, 0));


        for (idx = 0; idx < src.size(); ++idx)
        {
            accum = 0.0;

            for (jdx = 0; jdx < fir_filter.size(); ++jdx)
            {
                x = idx + jdx - dx;

                if (x >= 0 && x < src.size())
                    accum += std::complex<double>(src[x].real(), src[x].imag()) * fir_filter[jdx];
            }

            iq_data[idx] = std::complex<int16_t>(std::exp((channel_coeff * (double)idx)) * accum);

        }

        return iq_data;

    }   // end of apply_fir_filter_rotation

    //-----------------------------------------------------------------------------
    inline std::vector<std::complex<int16_t>> apply_fir_filter(std::vector<std::complex<int16_t>>& src, const std::vector<double> &fir_filter)
    {
        int32_t idx, jdx;
        int32_t dx = (int32_t)(fir_filter.size() >> 1);
        int32_t x;

        std::complex<double> accum;

        std::vector<std::complex<int16_t>> iq_data(src.size(), std::complex<int16_t>(0, 0));

        for (idx = 0; idx < src.size(); ++idx)
        {
            accum = 0.0;

            for (jdx = 0; jdx < fir_filter.size(); ++jdx)
            {
                x = idx + jdx - dx;

                if (x >= 0 && x < src.size())
                    accum += std::complex<double>(src[x].real(), src[x].imag()) * fir_filter[jdx];
            }

            iq_data[idx] = std::complex<int16_t>(accum);
        }

        return iq_data;

    }   // end of apply_fir_filter

    //----------------------------------------------------------------------------
    /*!
    @brief Apply SOS filter to a sequence of complex numbers.  Uses Direct Form II implementation

    @param input Input sequence of complex numbers
    @param sections Vector of SOS coefficients:[ [b0, b1, b2, a0, a1, a2], [...] ]
    @return Filtered output sequence

    x[n]-->(+)-----------+--->[b0]--->(+)--> y[n]
            ^            |             ^
            |            |             |
            |          [z^-1]          |
            |            |             |
            |            |             |
           (+)<--[-a1]<--+--->[b1]--->(+)
            ^          w[n-1]          ^
            |            |             |
            |          [z^-1]          |
            |            |             |
            |            |             |
           (+)<--[-a2]<--+--->[b2]--->(+)
                       w[n-2]

    */
    template <typename T>
    inline std::vector<std::complex<T>> apply_df2t_filter(const std::vector<std::complex<T>>& data, const std::vector<std::vector<std::complex<double>>> &sos_filter)
    {
        uint64_t idx, jdx;
        std::complex<double> current_input, section_output;

        uint32_t num_sections = (uint32_t)(sos_filter.size());

        // state variables for the filter: w1 --> w[n-1], w2 --> w[n-2]
        //std::vector<std::vector<std::complex<double>>> w(num_sections, std::vector<std::complex<double>>(2, { 0.0, 0.0 }));
        std::vector<std::complex<double>> w1(num_sections, std::complex<double>(0.0, 0.0));
        std::vector<std::complex<double>> w2(num_sections, std::complex<double>(0.0, 0.0));

        std::vector<std::complex<T>> output(data.size());

        // Iterate through each sample of the input sequence
        for (idx = 0; idx < data.size(); ++idx)
        {
            current_input = std::complex<double>((double)data[idx].real(), (double)data[idx].imag());

            // Direct Form II Transposed equations for a single section
            for (jdx = 0; jdx < num_sections; ++jdx)
            {
                section_output = sos_filter[jdx][0] * current_input + w1[jdx];

                // update state variables : Note: filter[jdx][3] is assumed to be 1 and not used in calculations
                // w[jdx][0] = sos_filter[jdx][1] * current_input - sos_filter[jdx][4] * section_output + w[jdx][1];
                // w[jdx][1] = sos_filter[jdx][2] * current_input - sos_filter[jdx][5] * section_output;
                w1[jdx] = sos_filter[jdx][1] * current_input - sos_filter[jdx][4] * section_output + w2[jdx];
                w2[jdx] = sos_filter[jdx][2] * current_input - sos_filter[jdx][5] * section_output;

                current_input = section_output;
            }

            output[idx] = static_cast<std::complex<T>>(current_input);
        }

        return output;
    }   // end of apply_df2t_filter


    //----------------------------------------------------------------------------
    /*!
    @brief Apply SOS filter and frequency shift to a sequence of complex numbers.  Uses Direct Form II implementation

    @param input Input sequence of complex numbers
    @param sections Vector of SOS coefficients:[ [b0, b1, b2, a0, a1, a2], [...] ]
    @return Filtered output sequence

    x[n]-->(+)-----------+--->[b0]--->(+)--> y[n]
            ^            |             ^
            |            |             |
            |          [z^-1]          |
            |            |             |
            |            |             |
           (+)<--[-a1]<--+--->[b1]--->(+)
            ^          w[n-1]          ^
            |            |             |
            |          [z^-1]          |
            |            |             |
            |            |             |
           (+)<--[-a2]<--+--->[b2]--->(+)
                       w[n-2]

    */
    template <typename T>
    inline std::vector<std::complex<T>> apply_df2t_filter_rotation(const std::vector<std::complex<T>>& data, const std::vector<std::vector<std::complex<double>>>& sos_filter, std::complex<double> channel_coeff)
    {
        uint64_t idx, jdx;
        std::complex<double> current_input, section_output;

        uint32_t num_sections = (uint32_t)(sos_filter.size());

        // state variables for the filter: w1 --> w[n-1], w2 --> w[n-2]
        //std::vector<std::vector<std::complex<double>>> w(num_sections, std::vector<std::complex<double>>(2, { 0.0, 0.0 }));
        std::vector<std::complex<double>> w1(num_sections, std::complex<double>(0.0, 0.0));
        std::vector<std::complex<double>> w2(num_sections, std::complex<double>(0.0, 0.0));

        std::vector<std::complex<T>> output(data.size());

        // Iterate through each sample of the input sequence
        for (idx = 0; idx < data.size(); ++idx)
        {
            current_input = std::complex<double>((double)data[idx].real(), (double)data[idx].imag());

            // Direct Form II Transposed equations for a single section
            for (jdx = 0; jdx < num_sections; ++jdx)
            {
                section_output = sos_filter[jdx][0] * current_input + w1[jdx];

                // update state variables : Note: filter[jdx][3] is assumed to be 1 and not used in calculations
                w1[jdx] = sos_filter[jdx][1] * current_input - sos_filter[jdx][4] * section_output + w2[jdx];
                w2[jdx] = sos_filter[jdx][2] * current_input - sos_filter[jdx][5] * section_output;

                current_input = section_output;
            }

            // apply the frequency shift after the filtering - does not affect the internal state variables
            output[idx] = static_cast<std::complex<T>>(std::exp((channel_coeff * (double)idx)) * current_input);
        }

        return output;
    }   // end of apply_df2t_filter_rotation

    //-----------------------------------------------------------------------------
    inline std::vector<std::complex<double>> calculate_sos_impulse_response(std::vector<std::vector<std::complex<double>>> sos_filter)
    {
        std::vector<std::complex<double>> x(500, std::complex<double>(0.0, 0.0));
        x[20] = { 1.0, 1.0 };

        return apply_df2t_filter(x, sos_filter);

    }   // end of calculate_sos_impulse_response

    //-----------------------------------------------------------------------------
    inline void adjust_iir_filter_overshoot(std::vector<std::vector<std::complex<double>>>& sos_filter, uint32_t samples_per_symbol)
    {
        // run filter through a high speed step transition to get the maximum overshoot value for the data rate
        std::vector<std::complex<double>> step(4 * samples_per_symbol, { -1.01, 0.0 });
        std::vector<std::complex<double>> step_1(2 * samples_per_symbol, { 1.01, 0.0 });
        std::vector<std::complex<double>> step_0(2 * samples_per_symbol, { -1.01, 0.0 });
        step.insert(step.end(), step_1.begin(), step_1.end());
        step.insert(step.end(), step_0.begin(), step_0.end());
        step.insert(step.end(), step_1.begin(), step_1.end());

        // filter the result to get the response
        std::vector<std::complex<double>> results = apply_df2t_filter(step, sos_filter);

        // get the max value of the step response
        double max_step = std::abs(std::real(*std::max_element(results.begin(), results.end(), [](const std::complex<double>& a, const std::complex<double>& b) {
            return std::abs(a.real()) < std::abs(b.real());
            })));

        // adjust b values in the first section of the filter
        sos_filter[0][0] /= max_step;
        sos_filter[0][1] /= max_step;
        sos_filter[0][2] /= max_step;

    }   // end of adjust_iir_filter_overshoot

}  // end of namespace DSP

#endif  // end of DSP_FILTERING_DEFINITION_H_
