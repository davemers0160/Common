#ifndef DSP_WINDOW_DEFINITION_H_
#define DSP_WINDOW_DEFINITION_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
// need for VS for pi and other math constatnts
#define _USE_MATH_DEFINES
//#define _USE_MATH_DEFINES
#define _SILENCE_NONFLOATING_COMPLEX_DEPRECATION_WARNING

#elif defined(__linux__)

#endif

#include <cstdint>
#include <cmath>
#include <vector>
#include <complex>
#include <stdexcept>
#include <iostream>
#include <iomanip>

namespace DSP
{

	
// constansts
const double M_1PI = 3.14159265358979323846;            							//* pi
const double M_2PI = 2.0 * 3.14159265358979323846;      							//* 2pi
const double M_4PI = 4.0 * 3.14159265358979323846;      							//* 4pi
const double M_6PI = 6.0 * 3.14159265358979323846;      							//* 6pi
const double SQRT_2 = 1.4142135623730951454746218587388284504413604736328125;	    //* sqrt(2.0)
const double SQRT_2_INV = 0.707106781186547461715008466853760182857513427734375;	//* 1.0/sqrt(2.0)
const double COS_3PI_8 = 0.3826834323650898372903839117498137056827545166015625; 	//* cos(3pi/8)
const double SIN_3PI_8 = 0.9238795325112867384831361050601117312908172607421875;	//* sin(3pi/8)
const std::complex<double> j(0.0, 1.0);

//-----------------------------------------------------------------------------
inline uint64_t factorial(int64_t n){

     return (n==0) || (n==1) ? 1 : n* factorial(n-1);
}

//-----------------------------------------------------------------------------
inline std::vector<double> rectangular_window(int64_t N)
{
    std::vector<double> w(N+1, 1.0f);
    
    return w;
}   // end of rectangular_window

//-----------------------------------------------------------------------------
inline std::vector<double> triangular_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = 1.0f - std::abs((idx-(N/2.0))/((N)/2.0));
    }
    
    return w;
}   // end of triangular_window

//-----------------------------------------------------------------------------
inline std::vector<double> hann_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = 0.5f*(1.0f - std::cos(M_2PI * idx/(double)(N-1)));
    }
    
    return w;
}   // end of hann_window

//-----------------------------------------------------------------------------
inline std::vector<double> hamming_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);
    
    double a0 = 25.0f/46.0f;
    double a1 = 1.0f - a0;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx/(double)(N-1));
    }
    
    return w;
}   // end of hamming_window

//-----------------------------------------------------------------------------
inline std::vector<double> blackman_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);
    
    double a0 = (1.0 - 0.16) / 2.0f;
    double a1 = 1.0 / 2.0f;
    double a2 = 0.16 / 2.0f;   

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1));
    }

    return w;
}   // end of blackman_window

//-----------------------------------------------------------------------------
inline std::vector<double> nuttall_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);
    double a0 = 0.355768;
    double a1 = 0.487396;
    double a2 = 0.144232;
    double a3 = 0.012604;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1)) - a3 * std::cos(M_6PI * idx / (double)(N-1));
    }
    
    return w;
}   // end of nuttall_window


//-----------------------------------------------------------------------------
inline std::vector<double> blackman_nuttall_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);
    double a0 = 0.3635819;
    double a1 = 0.4891775;
    double a2 = 0.1365995;
    double a3 = 0.0106411;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N-1)) + a2 * std::cos(M_4PI * idx / (double)(N-1)) - a3 * std::cos(M_6PI * idx / (double)(N-1));
    }

    return w;
}   // end of blackman_nuttall_window

inline std::vector<double> blackman_harris_window(int64_t N)
{
    std::vector<double> w(N, 0.0f);
    double a0 = 0.35875;
    double a1 = 0.48829;
    double a2 = 0.14128;
    double a3 = 0.01168;

    for (int64_t idx = 0; idx < N; ++idx)
    {
        w[idx] = a0 - a1 * std::cos(M_2PI * idx / (double)(N - 1)) + a2 * std::cos(M_4PI * idx / (double)(N - 1)) - a3 * std::cos(M_6PI * idx / (double)(N - 1));
    }

    return w;
}   // end of blackman_nuttall_window

//-----------------------------------------------------------------------------
template <typename T, typename funct>
std::vector<T> create_fir_filter(int64_t N, double fc, funct window_function, double scale = 1.0)
{
    int32_t idx;
    std::vector<T> g(N, 0);

    std::vector<double> w = window_function(N);

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
std::vector<T> create_fir_filter(int64_t N, double fc, std::vector<double> w, double scale = 1.0)
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
std::vector<std::complex<OUTPUT>> apply_filter(std::vector<std::complex<INPUT>>& src, std::vector<double> &filter)
{
    int32_t idx, jdx;
    int32_t dx = filter.size() >> 1;
    int32_t x;

    std::complex<double> accum;

    std::vector<std::complex<OUTPUT>> iq_data(src.size(), std::complex<OUTPUT>(0, 0));

    for (idx = 0; idx < src.size(); ++idx)
    {
        accum = 0.0;

        for (jdx = 0; jdx < filter.size(); ++jdx)
        {
            x = idx + jdx - dx;

            if (x >= 0 && x < src.size())
                accum += std::complex<double>(src[x].real(), src[x].imag()) * filter[jdx];
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
inline std::vector<double> create_rrc_filter(uint32_t span, double beta, double symbol_length, uint32_t sample_rate, double scale = 1.0)
{
    int32_t idx;

    double samples_per_symbol = floor(sample_rate * symbol_length + 0.5);
    uint64_t N = span * samples_per_symbol + 1;

    double a0 = 1.0 / sqrt(samples_per_symbol);
    double a1 = (4.0 * beta) / samples_per_symbol;
    double a2 = M_1PI * (1.0 + beta) / samples_per_symbol;
    double a3 = M_1PI * (1.0 - beta) / samples_per_symbol;

    double t = 0.0;
    std::vector<double> g(N, 0);

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
// to use filter signal (x) and consruct complex version: y = x + j*h(x)
inline std::vector<double> create_hilbert_filter(uint32_t N)
{
    uint32_t idx;

    // make sure the number is odd
    if ((N & 0x01) == 0)
        ++N;

    std::vector<double> g(N, 0);
    std::vector<double> w = hamming_window(N);

    // The center point(non - causal index m = 0)
    int32_t delay = (N - 1) >> 1;

    // The non - causal index vector m, centered around 0
    std::vector<int32_t> m(N, 0);
    std::iota(m.begin(), m.end(), -delay);

    for (idx = 0; idx < N; ++idx)
    {
        if((m[idx] & 0x01) == 1)
        {
            g[idx] = w[idx] * (2.0 / (M_1PI * m[idx]));
        }
        else
        {
            g[idx] = 0.0;
        }
    }

    return g;

}   // end of create_hilbert_filter

//-----------------------------------------------------------------------------
/**
 * Calculate IIR filter coefficients using Butterworth design
 * 
 * @param cutoff_frequency Normalized cutoff frequency (0 to 0.5, where 0.5 = Nyquist)
 * @param order Filter order (number of poles, typically 2-8)
 * @return std::vector<std::pair<double,double>> structure containing first (denominator) and second (numerator) coefficients
 */
std::vector<std::pair<double,double>> calculate_iir_filter(double cutoff_frequency, int32_t order = 12) 
{
    int32_t idx, jdx;
    std::vector<std::pair<double, double>> coeffs(order + 1, { 0.0, 0.0 });    // a = first, b = second
    coeffs[0].first = 1.0;    

    std::complex<double> digital_pole;
    double a_sum = 0.0, b_sum = 0.0;

    // Prewarp the cutoff frequency for bilinear transform
    double omega_warped = 2.0 * std::tan(M_1PI * cutoff_frequency);
    
    // Calculate analog Butterworth poles
    std::vector<std::complex<double>> digital_poles;
    for (idx = 0; idx < order; ++idx) 
    {
        double theta = M_1PI * (2.0 * idx + order + 1.0) / (2.0 * order);
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

//-----------------------------------------------------------------------------
inline std::vector<std::complex<double>> sort_conjugate_pairs(std::vector<std::complex<double>>& vec) 
{
    const double tolerance = 1.0e-9;

    std::vector<std::complex<double>> sorted;

    while (!vec.empty()) 
    {
        // Take first element
        std::complex<double> val = vec[0];
        sorted.push_back(val);
        vec.erase(vec.begin());

        // If complex, find and add conjugate
        if (std::abs(val.imag()) > tolerance) 
        {
            std::complex<double> conj_val = std::conj(val);

            // Find conjugate in remaining elements
            auto it = std::find_if(vec.begin(), vec.end(), [&conj_val, &tolerance](const std::complex<double>& x) 
                {
                    return std::abs(x - conj_val) < tolerance;
                });

            if (it != vec.end()) 
            {
                sorted.push_back(*it);
                vec.erase(it);
            }
        }
    }

    return sorted;
}

//-----------------------------------------------------------------------------
// Bilinear transformation from s - domain to z - domain
inline std::vector<std::complex<double>> bilinear_transform(std::vector<std::complex<double>> s, std::complex<double>& gain)
{
    std::vector<std::complex<double>> result;

    gain = std::complex<double>(1.0, 0.0);

    // Transform
    result.reserve(s.size());
    for (const auto& si : s) 
    {
        result.push_back((2.0 + si) / (2.0 - si));
        gain *= (2.0 - si);
    }

    return result;
}   // end of bilinear_transform

//-----------------------------------------------------------------------------
// returns the [z,p,k] form
inline double chebyshev2_poles_zeros(int32_t N, double epsilon, std::vector<std::complex<double>> &z, std::vector<std::complex<double>> &p)
{
    uint32_t idx;
    double theta;
    double sigma, omega;
    bool is_odd = false;
    double k = 1.0;

    std::complex<double> p_temp;

    // inverse Chebyshev parameters
    double mu = std::asinh(1.0 / epsilon) / (double)N;

    // Chebyshev Type II has zeros on the imaginary axis.  Number of zeros and poles equals filter order N
    if ((N & 0x01) == 1)
    {
        is_odd = true;
    }

    std::complex<double> p_gain(1.0, 0.0), z_gain(1.0, 0.0);

    //Calculate zero locations(on imaginary axis)
    for (idx = 0; idx < N; ++idx)
    {
        // pole angles
        theta = (2.0 * (idx + 1) - 1) * M_1PI / (2.0 * N);
        z[idx] = std::complex<double>(0.0, 1.0 / std::cos(theta));

        // Calculate pole in s - domain
        sigma = -std::sinh(mu) * std::sin(theta);
        omega = std::cosh(mu) * std::cos(theta);

        // Poles are inverse of Chebyshev Type I poles
        p_temp = std::complex<double>(sigma, omega);
        p[idx] = std::complex<double>(1.0,0.0) / p_temp;

        // Calculate gain to ensure unit gain at DC(for lowpass)
        p_gain *= -p[idx];
        z_gain *= -z[idx];
    }

    auto dc_gain = z_gain / p_gain;
    //k = std::real(p_gain / z_gain);
    k = std::abs(p_gain / z_gain);

    if (is_odd == true)
    {
        double tmp = std::real(k * dc_gain);

        if (tmp < 0)
            k = -k;
    }

    return k;

}   // end of chebyshev2_poles_zeros

//-----------------------------------------------------------------------------
std::vector<std::vector<double>> zpk_to_sos(std::vector<std::complex<double>>& z, std::vector<std::complex<double>>& p)
{
    uint32_t idx;

    std::vector<std::vector<double>> sos_filter;
    const double tolerance = 1e-10;

    // Remove any infinite zeros (shouldn't have any, but check)
    std::vector<std::complex<double>> z_finite;
    for (const auto& zi : z) 
    {
        if (std::isfinite(zi.real()) && std::isfinite(zi.imag())) 
        {
            z_finite.push_back(zi);
        }
    }

    // Sort complex conjugate pairs
    std::vector<std::complex<double>> z_sorted = sort_conjugate_pairs(z);
    std::vector<std::complex<double>> p_sorted = sort_conjugate_pairs(p);

    // Determine number of sections needed
    size_t num_sections = (p_sorted.size() + 1) / 2;

    size_t idx_z = 0;
    size_t idx_p = 0;

    double gain = 1.0;

    for (idx = 0; idx < num_sections; ++idx)
    {
        std::vector<double> section(6, 0);

        // Get pole pair (or single real pole)
        if (idx_p < p_sorted.size()) 
        {
            if ((idx_p < (p_sorted.size() - 1)) && (std::abs(p_sorted[idx_p].imag()) > tolerance)) 
            {
                // Complex conjugate pair
                std::complex<double> p1 = p_sorted[idx_p];

                // Denominator: 
                section[3] = 1.0;
                section[4] = -2.0 * p1.real();
                section[5] = std::norm(p1);

                idx_p += 2;
            }
            else 
            {
                // Real pole
                std::complex<double> p1 = p_sorted[idx_p];

                section[3] = 1.0;
                section[4] = -p1.real();
                section[5] = 0.0;

                idx_p += 1;
            }
        }
        else 
        {
            section[3] = 1.0;
            section[4] = 0.0;
            section[5] = 0.0;
        }

        // Get zero pair (or single real zero)
        if (idx_z < z_sorted.size()) 
        {
            if ((idx_z < z_sorted.size() - 1) && (std::abs(z_sorted[idx_z].imag()) > tolerance)) 
            {
                std::complex<double> z1 = z_sorted[idx_z];

                // Numerator:
                section[0] = 1.0;
                section[1] = -2.0 * z1.real();
                section[2] = std::norm(z1);

                idx_z += 2;
            }
            else {
                // Real zero
                std::complex<double> z1 = z_sorted[idx_z];
                section[0] = 1.0;
                section[1] = -z1.real();
                section[2] = 0.0;

                idx_z += 1;
            }
        }
        else 
        {
            // No more zeros
            section[0] = 1.0;
            section[1] = 0.0;
            section[2] = 0.0;
        }

        //result.sos[i] = section;
        sos_filter.push_back(section);

        gain *= ((section[3] + section[4] + section[5]) / (section[0] + section[1] + section[2]));
    }

    // adjust for gain of coeffeicients - shooting for DC gain = 1
    sos_filter[0][0] *= gain;
    sos_filter[0][1] *= gain;
    sos_filter[0][2] *= gain;

    return sos_filter;

}   // end of zpk_to_sos

//-----------------------------------------------------------------------------
std::vector<std::vector<double>> chebyshev2_iir_sos(int32_t N, double cutoff_frequency, double r_s)
{
    uint32_t idx;
    double k = 1.0;

    // Calculate Chebyshev Type II parameters
    double epsilon = 1 / std::sqrt(std::pow(10, (r_s / 10.0)) - 1.0);

    // Calculate polesand zeros for normalized lowpass prototype
    std::vector<std::complex<double>> z(N, { 0.0,0.0 });
    std::vector<std::complex<double>> p(N, { 0.0,0.0 });
    k = chebyshev2_poles_zeros(N, epsilon, z, p);

    //Frequency transformation(lowpass to lowpass with cutoff Wn)
    double omega_warped = 2.0 * std::tan(M_1PI * cutoff_frequency); 

    for (idx = 0; idx < N; ++idx)
    {
        z[idx] *= omega_warped;
        p[idx] *= omega_warped;
    }
    
    // Bilinear transformation to z - domain
    //[zd, pd, kd] = bilinear_transform(z, p, k, 2);
    std::complex<double> kz(1.0,0.0), kp(1.0,0.0);
    std::vector<std::complex<double>> zd = bilinear_transform(z, kz);
    std::vector<std::complex<double>> pd = bilinear_transform(p, kp);

    //double kd = std::real((kz / kp));

    std::vector<std::vector<double>> sos_filter = zpk_to_sos(zd, pd);

    return sos_filter;

}   // end of chebyshev2_iir_sos


//-----------------------------------------------------------------------------
/**
 * Calculate coefficients for Direct Form II Butterworth IIR filter
 * implemented as Second-Order Sections (SOS)
 *
 * @param fc_normalized Normalized cutoff frequency (0 < fc < 0.5, where 0.5 = Nyquist)
 * @param order Filter order (must be positive integer)
 * @param isLowpass True for lowpass, false for highpass
 * @return Vector of SOS coefficient structures
 */
//std::vector<sos_coefficients> butterworth_sos_iir(double fc_normalized, int32_t order, bool low_pass = true) 
//{
//    int32_t idx;
//    //int32_t pole_index;
//    double theta;
//
//    // Pre-warp the cutoff frequency for bilinear transform
//    double wc = std::tan(M_2PI * fc_normalized);
//
//    // Number of second-order sections
//    int num_sections = (order + 1) / 2;
//    std::vector<sos_coefficients> sections(num_sections);
//
//    // Generate poles for analog Butterworth filter
//    // Poles are equally spaced on unit circle in s-plane
//    for (idx = 0; idx < num_sections; ++idx)
//    {
//        sos_coefficients& sos = sections[idx];
//
//        // For each SOS, we process a pair of complex conjugate poles
//        // (or a single real pole for odd orders)
//        //pole_index = idx;
//
//        // Angle for pole placement
//        theta = M_1PI * (2.0 * idx + order + 1.0) / (2.0 * order);
//
//        // Analog prototype poles (on unit circle, left half-plane) and scale by cutoff frequency
//        //std::complex<double> pole_s(-std::sin(theta) * wc, std::cos(theta) * wc);
//        std::complex<double> pole_s(std::cos(theta) * wc, std::sin(theta) * wc);
//
//        // Apply bilinear transform: s -> 2*(z-1)/(z+1)
//        // This maps analog pole to digital pole
//        std::complex<double> pole_z = (2.0 + pole_s) / (2.0 - pole_s);
//
//        // Handle last section for odd-order filters (single real pole)
//        if ((idx == num_sections - 1) && (order % 2 == 1))
//        {
//            // Single real pole case
//            //pole_z.imag(0.0);
//
//            if (low_pass == true)
//            {
//                // Lowpass: place zero at z = -1 (Nyquist)
//                sos.b0 = 2.0 / (2.0 + wc); // wc / (2.0 + wc);
//                sos.b1 = sos.b0;
//                sos.b2 = 0.0;
//                sos.gain = wc / (2.0 + wc);
//            }
//            else 
//            {
//                // Highpass: place zero at z = 1 (DC)
//                sos.b0 = 2.0 / (2.0 + wc);
//                sos.b1 = -sos.b0;
//                sos.b2 = 0.0;
//            }
//
//            sos.a0 = 1.0;
//            sos.a1 = -pole_z.real();
//            sos.a2 = 0.0;
//        }
//        else 
//        {
//            // Complex conjugate pole pair
//            double alpha = -2.0 * pole_z.real();
//            double beta = (pole_z.real() * pole_z.real()) + (pole_z.imag() * pole_z.imag());
//
//            if (low_pass == true)
//            {
//                // Lowpass: place zeros at z = -1 (Nyquist)
//                double K = beta; // Gain normalization
//                sos.b0 = beta; // K / ((1.0 + alpha + beta));
//                sos.b1 = 2.0 * sos.b0;
//                sos.b2 = sos.b0;
//                sos.gain = (1.0 + alpha + beta);
//            }
//            else 
//            {
//                // Highpass: place zeros at z = 1 (DC)
//                double K = 1.0; // Gain normalization
//                sos.b0 = beta; // K / ((1.0 - alpha + beta));
//                sos.b1 = -2.0 * sos.b0;
//                sos.b2 = sos.b0;
//                sos.gain = (1.0 - alpha + beta);
//            }
//
//            sos.a0 = 1.0;
//            sos.a1 = alpha;
//            sos.a2 = beta;
//        }
//    }
//
//    return sections;
//
//}   // end of butterworth_sos_iir

//-----------------------------------------------------------------------------
/**
 * Calculate Butterworth IIR filter coefficients as second-order sections to be used in a Direct Form II Transposed filter
 *
 * @param cutoff Normalized cutoff frequency (0 < cutoff < 1)
 * @param order Filter order (must be positive)
 * @return Vector of biquad coefficients for each second-order section
 */
std::vector<std::vector<double>> butterworth_iir_sos(int32_t order, double cutoff_frequency)
{
    uint32_t idx;
    double theta = 0.0;
    double gain = 1.0;

    std::vector<std::vector<double>> sos_filter;

	// quick checks to make sure the order is within appropriate values
    if (order < 1)
        throw std::invalid_argument("Filter order must be > 1");

    if (cutoff_frequency >= 0.5)
        throw std::invalid_argument("Normalized cutoff frequency must be < 0.5");

    // Determine number of sections needed
    int32_t num_sections = order >> 1;

    // Prewarp cutoff frequency for bilinear transform std::tan(M_2PI * cutoff_frequency);
    double omega_c = 2.0 * std::tan(M_1PI * cutoff_frequency);

    // Loop over complex-conjugate pole pairs
    for (idx = 0; idx < num_sections; ++idx) 
    {
        std::vector<double> section(6, 0);

        // analog Butterworth poles
        theta = M_1PI * (2.0 * idx + 1.0 + order) / (2.0 * order);

        std::complex<double> pole_s = std::complex<double>(omega_c * std::cos(theta), omega_c * std::sin(theta));

        // Compute digital poles - Bilinear transform : s -> (1 - z ^ -1) / (1 + z ^ -1)
        std::complex<double> pole_z = (2.0 + pole_s) / (2.0 - pole_s);

        section[0] = 1.0;
        section[1] = 2.0;
        section[2] = 1.0;
        section[3] = 1.0;
        section[4] = -2.0 * pole_z.real();
        section[5] = std::norm(pole_z);

        sos_filter.push_back(section);
        gain *= ((section[3] + section[4] + section[5]) / (section[0] + section[1] + section[2]));
    }

    // Handle odd order: one extra first-order section
    if ((order & 0x01) == 1) 
    {
        std::vector<double> section(6, 0);

        // analog Butterworth poles
        theta = M_1PI * (2 * num_sections + 1 + order) / (2 * order);
        std::complex<double> pole_s = std::polar(omega_c, theta);

        // Compute digital poles - Bilinear transform : s -> (1 - z ^ -1) / (1 + z ^ -1)
        std::complex<double> pole_z = (2.0 + pole_s) / (2.0 - pole_s);

        section[0] = 1.0;
        section[1] = 1.0;
        section[2] = 0.0;
        section[3] = 1.0;
        section[4] = -pole_z.real();
        section[5] = 0.0;

        sos_filter.push_back(section);
        gain *= ((section[3] + section[4] + section[5]) / (section[0] + section[1] + section[2]));

    }

    // adjust for gain of coeffeicients - shooting for DC gain = 1
    sos_filter[0][0] *= gain;
    sos_filter[0][1] *= gain;
    sos_filter[0][2] *= gain;

    return sos_filter;

}   // end of butterworth_iir_sos

}  // end of namespace DSP

#endif  // DSP_WINDOW_DEFINITION_H_
