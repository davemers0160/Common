#ifndef DSP_WINDOW_DEFINITION_H_
#define DSP_WINDOW_DEFINITION_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
// need for VS for pi and other math constatnts
#define _USE_MATH_DEFINES

#elif defined(__linux__)

#endif

#include <cstdint>
#include <cmath>
#include <vector>
#include <complex>

namespace DSP
{

const double M_1PI = 3.14159265358979323846;            // pi
const double M_2PI = 2.0 * 3.14159265358979323846;      // 2pi
const double M_4PI = 4.0 * 3.14159265358979323846;      // 4pi
const double M_6PI = 6.0 * 3.14159265358979323846;      // 6pi

//-----------------------------------------------------------------------------
inline uint64_t factorial(int64_t n){

     return (n==0) || (n==1) ? 1 : n* factorial(n-1);
}

//-----------------------------------------------------------------------------
inline std::vector<float> rectangular_window(int64_t N)
{
    std::vector<float> w(N+1, 1.0f);
    
    return w;
}   // end of rectangular_window

//-----------------------------------------------------------------------------
inline std::vector<float> triangular_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = 1.0f - std::abs((idx-(N/2.0))/((N)/2.0));
    }
    
    return w;
}   // end of triangular_window

//-----------------------------------------------------------------------------
inline std::vector<float> hann_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = 0.5f*(1.0f - std::cos(M_2PI * idx/(double)(N-1)));
    }
    
    return w;
}   // end of hann_window

//-----------------------------------------------------------------------------
inline std::vector<float> hamming_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);
    
    float a0 = 25.0f/46.0f;
    float a1 = 1.0f - a0;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx/(double)(N-1));
    }
    
    return w;
}   // end of hamming_window

//-----------------------------------------------------------------------------
inline std::vector<float> blackman_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);
    
    float a0 = (1.0 - 0.16) / 2.0f;
    float a1 = 1.0 / 2.0f;
    float a2 = 0.16 / 2.0f;   

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1));
    }

    return w;
}   // end of blackman_window

//-----------------------------------------------------------------------------
inline std::vector<float> nuttall_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);
    float a0 = 0.355768;
    float a1 = 0.487396;
    float a2 = 0.144232;
    float a3 = 0.012604;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1)) - a3 * std::cos(M_6PI * idx / (double)(N-1));
    }
    
    return w;
}   // end of nuttall_window


//-----------------------------------------------------------------------------
inline std::vector<float> blackman_nuttall_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);
    float a0 = 0.3635819;
    float a1 = 0.4891775;
    float a2 = 0.1365995;
    float a3 = 0.0106411;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1)) - a3 * std::cos(M_6PI * idx / (double)(N-1));
    }

    return w;
}   // end of blackman_nuttall_window

//-----------------------------------------------------------------------------
inline std::vector<float> blackman_harris_window(int64_t N)
{
    std::vector<float> w(N, 0.0f);
    float a0 = 0.35875;
    float a1 = 0.48829;
    float a2 = 0.14128;
    float a3 = 0.01168;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N - 1)) + a2 * std::cos(M_4PI * idx / (double)(N - 1)) - a3 * std::cos(M_6PI * idx / (double)(N - 1));
    }

    return w;
}   // end of blackman_nuttall_window

//-----------------------------------------------------------------------------
template <typename T, typename funct>
std::vector<T> create_fir_filter(int64_t N, float fc, funct window_function, float scale = 1.0)
{
    int32_t idx;
    std::vector<T> g(N, 0);

    std::vector<float> w = window_function(N);

    double t = 0.0;
    double g_sum = 0.0;

    for (idx = 0; idx < N; ++idx)
    {
        t = M_1PI * fc * (double)(idx - ((N - 1) >> 1));
        if (abs(t) < 1e-6)
            g[idx] = scale * w[idx];
        else
            g[idx] = scale * w[idx] * (std::sin(t) / t);

        g_sum += g[idx];
    }

    g_sum = 1.0 / g_sum;

    // scale the filter to result in 0 gain
    std::transform(g.begin(), g.end(), g.begin(), [&](T element) { return element * g_sum; });

    return g;

}   // end of create_fir_filter

//-----------------------------------------------------------------------------
template <typename T>
std::vector<T> create_fir_filter(int64_t N, float fc, std::vector<float> w, float scale = 1.0)
{
    int32_t idx;
    std::vector<T> g(N, 0);

    double t = 0.0;
    double g_sum = 0.0;

    if (w.size() != N)
    {
        std::cout << "Window size is not correct!" << std::endl;
        return g;
    }

    for (idx = 0; idx < N; ++idx)
    {
        t = M_1PI * fc * (double)(idx - ((N - 1) >> 1));

        if (abs(t) < 1e-6)
            g[idx] = scale * w[idx];
        else
            g[idx] = scale * w[idx] * (std::sin(t) / t);

        g_sum += g[idx];
    }

    g_sum = 1.0 / g_sum;

    // scale the filter to result in 0 gain
    std::transform(g.begin(), g.end(), g.begin(), [&](T element) { return element * g_sum; });

    return g;

}   // end of create_fir_filter

//-----------------------------------------------------------------------------
template <typename OUTPUT, typename INPUT>
std::vector<std::complex<OUTPUT>> apply_filter(std::vector<std::complex<INPUT>>& src, std::vector<float> &filter)
{
    int32_t idx, jdx;
    int32_t dx = filter.size() >> 1;
    int32_t x;

    std::complex<float> accum;

    std::vector<std::complex<OUTPUT>> iq_data(src.size(), std::complex<OUTPUT>(0, 0));

    for (idx = 0; idx < src.size(); ++idx)
    {
        accum = 0.0;

        for (jdx = 0; jdx < filter.size(); ++jdx)
        {
            x = idx + jdx - dx;

            if (x >= 0 && x < src.size())
                accum += std::complex<float>(src[x].real(), src[x].imag()) * filter[jdx];
        }

        iq_data[idx] = std::complex<OUTPUT>(accum);
    }

    return iq_data;

}   // end of apply_filter

//-----------------------------------------------------------------------------
template <typename OUTPUT>
inline std::vector<std::complex<OUTPUT>> create_freq_rotation(uint64_t N, double fr)
{
    uint64_t idx;
    std::vector<std::complex<OUTPUT>> res(N, 0.0);
    const std::complex<double> j(0,1);

    for (idx = 0; idx < N; ++idx)
    {
        res[idx] = std::exp(j * M_2PI * fr * (double)idx);
    }

    return res;

}   // end of create_freq_rotation

//-----------------------------------------------------------------------------
inline std::vector<float> create_rrc_filter(uint32_t span, double beta, double symbol_length, uint32_t sample_rate, float scale = 1.0)
{
    int32_t idx;

    double samples_per_symbol = floor(sample_rate * symbol_length + 0.5);
    uint64_t N = span * samples_per_symbol + 1;

    double a0 = 1.0 / sqrt(samples_per_symbol);
    double a1 = (4.0 * beta) / samples_per_symbol;
    double a2 = M_1PI * (1.0 + beta) / samples_per_symbol;
    double a3 = M_1PI * (1.0 - beta) / samples_per_symbol;

    double t = 0.0;
    std::vector<float> g(N, 0);

    for (idx = 0; idx < N; ++idx)
    {
        t = (double)(idx - ((N - 1) >> 1));

        if (abs(t) < 1e-6)
            g[idx] = scale * a0 * ((1 - beta) + (4 * beta / M_1PI));

        else if(abs(t * 4 * beta) == samples_per_symbol)
            g[idx] = scale * (beta / sqrt(2 * samples_per_symbol)) * ((1 + (2 / M_1PI)) * std::sin(M_1PI / (4 * beta)) + (1 - (2 / M_1PI)) * std::cos(M_1PI / (4 * beta)));

        else
            g[idx] = scale * a0 * ((std::sin(a3 * t)) + (a1 * t) * (std::cos(a2 * t))) / ((M_1PI / samples_per_symbol) * t * (1 - a1 * a1 * t * t));
        
    }

    return g;

}   // end of create_rrc_filter

//-----------------------------------------------------------------------------
/**
 * Calculate IIR filter coefficients using Butterworth design
 * 
 * @param cutoff_frequency Normalized cutoff frequency (0 to 0.5, where 0.5 = Nyquist)
 * @param order Filter order (number of poles, typically 2-8)
 * @return std::vector<std::pair<float,float>> structure containing first (denominator) and second (numerator) coefficients
 */
std::vector<std::pair<float,float>> calculate_iir_filter(double cutoff_frequency, int32_t order = 12) 
{
    int32_t idx, jdx;
    std::vector<std::pair<float, float>> coeffs(order + 1, { 0.0, 0.0 });    // a = first, b = second
    coeffs[0].first = 1.0;    

    std::complex<double> digital_pole;
    double a_sum = 0.0, b_sum = 0.0;

    // Prewarp the cutoff frequency for bilinear transform
    double omega_warped = 2.0 * std::tan(M_1PI * cutoff_frequency);
    
    // Calculate analog Butterworth poles
    std::vector<std::complex<double>> digital_poles;
    for (idx = 0; idx < order; ++idx) 
    {
        double theta = M_PI * (2.0 * idx + order + 1.0) / (2.0 * order);
        std::complex<double> pole(std::cos(theta), std::sin(theta));
        pole *= omega_warped;

        // Apply bilinear transform to convert analog poles to digital
        digital_pole = (2.0 + pole) / (2.0 - pole);

        // Calculate denominator coefficients from poles
        for (jdx = order; jdx >= 1; --jdx)
        {
            //coeffs.a[idx] = coeffs.a[idx] - pole.real() * coeffs.a[idx - 1];
            coeffs[jdx].first -= digital_pole.real() * coeffs[jdx - 1].first;
        }

    }
    
    // For Butterworth lowpass: all zeros at z = -1
    // Numerator has all zeros at -1, giving coefficients [1, order, ...]
    double binom_coeff = 1.0;
    for (idx = 0; idx <= order; ++idx) 
    {
        //coeffs.b[i] = binom_coeff;
        coeffs[idx].second = binom_coeff;
        binom_coeff = binom_coeff * (order - idx) / (double)(idx + 1);

        a_sum += coeffs[idx].first;
        b_sum += coeffs[idx].second;
    }
    
    // Normalize to get unity gain at DC    
    double gain = a_sum / b_sum;
    for (idx = 0; idx <= order; ++idx) 
    {
        coeffs[idx].second *= gain;
    }
    
    return coeffs;

}   // end of calculate_iir_filter


}  // end of namespace DSP

#endif  // DSP_WINDOW_DEFINITION_H_
