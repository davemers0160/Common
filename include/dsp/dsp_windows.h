#ifndef DSP_WINDOW_DEFINITION_H_
#define DSP_WINDOW_DEFINITION_H_

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
#include <numeric>

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
inline std::vector<double> generate_linspace(double start_val, double stop_val, int32_t num_points) 
{
    std::vector<double> result;

    // Handle case where no points are requested
    if (num_points <= 0) 
    {
        return result;
    }

    // Handle case where only one point is requested
    if (num_points == 1) 
    {
        result.push_back(stop_val);
        return result;
    }

    result.reserve(num_points);

    // Calculate the step size, (n - 1) intervals are needed to include both endpoints
    double step = (stop_val - start_val) / (static_cast<double>(num_points) - 1.0);

    for (int32_t idx = 0; idx < num_points; ++idx) 
    {
        // For the last point, we use stop_val directly to avoid 
        // accumulated floating point precision errors
        if (idx == num_points - 1) 
        {
            result.push_back(stop_val);
        }
        else 
        {
            result.push_back(start_val + idx * step);
        }
    }

    return result;
}   // end of generate_linspace

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

//-----------------------------------------------------------------------------
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
}   // end of blackman_harris_window

//-----------------------------------------------------------------------------
template <typename T, typename funct>
inline std::vector<T> create_fir_filter(int32_t N, double fc, funct window_function, double scale = 1.0)
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
            g[idx] = scale * w[idx] * (std::sin(t) /t);

        g_sum += g[idx];
    }

    g_sum = 1.0 / g_sum;

    // scale the filter to result in 0 gain
    std::transform(g.begin(), g.end(), g.begin(), [&](T element) { return element * g_sum; });

    return g;

}   // end of create_fir_filter


//-----------------------------------------------------------------------------
template <typename T>
inline std::vector<T> create_fir_filter(int64_t N, double fc, std::vector<double> w, double scale = 1.0)
{
    int32_t idx;
    std::vector<T> g(N , 0);
    
    double t = 0.0;
    double g_sum = 0.0;

    if (w.size() != N )
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
    uint64_t N = (uint64_t)(span * samples_per_symbol + 1);

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
        if ((m[idx] & 0x01) == 1)
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
template <typename T>
inline std::vector< std::vector<T>> normalize_sos_filter_gain(std::vector< std::vector<T>> sos_filter, uint32_t num_frequency_points = 1000)
{
    uint32_t idx;
    double max_gain = 0.0;

    if (sos_filter.empty() == true)
    {
        std::cout << "SoS filter is empty" << std::endl;
        return sos_filter;
    }

    double step = M_2PI / (double)num_frequency_points;
    double omega = -M_1PI;

    // Iterate over the specified frequency range to find the peak gain
    for (idx = 0; idx < num_frequency_points; ++idx)
    {
        std::complex<double> z(cos(omega), sin(omega));
        std::complex<double> z_inv = 1.0 / z;
        std::complex<double> overall_response(1.0, 0.0);

        // Cascade the response of each SOS
        for (const auto& sos : sos_filter)
        {
            std::complex<double> numerator = sos[0] + sos[1] * z_inv + sos[2] * z_inv * z_inv;
            std::complex<double> denominator = sos[3] + sos[4] * z_inv + sos[5] * z_inv * z_inv;
            overall_response *= numerator / denominator;
        }

        double current_gain = std::abs(overall_response);
        if (current_gain > max_gain)
        {
            max_gain = current_gain;
        }

        omega += step;
    }

    std::cout << "Peak gain in the passband is: " << 20 * log10(max_gain) << " dB" << std::endl;

    double gain_correction_factor = 1.0 / max_gain;

    sos_filter[0][0] *= gain_correction_factor;
    sos_filter[0][1] *= gain_correction_factor;
    sos_filter[0][2] *= gain_correction_factor;

    return sos_filter;
}   // end of normalize_sos_filter_gain

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
inline double chebyshev2_poles_zeros(int32_t N, double epsilon, std::vector<std::complex<double>>& z, std::vector<std::complex<double>>& p)
{
    int32_t idx;
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
        p[idx] = std::complex<double>(1.0, 0.0) / p_temp;

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
template <typename T>
inline std::vector<std::vector<T>> zpk_to_sos(std::vector<std::complex<double>>& zeros, std::vector<std::complex<double>>& poles)
{
    uint32_t idx;

    std::vector<std::vector<T>> sos;

    if (zeros.size() != poles.size())
    {
        std::cerr << "The number of poles and zeros is not the same." << std::endl;
        return sos;
    }

    // Sort complex conjugate pairs
    std::vector<std::complex<double>> z_sorted = sort_conjugate_pairs(zeros);
    std::vector<std::complex<double>> p_sorted = sort_conjugate_pairs(poles);


    // Naive pairing: pole 2k with 2k+1, zero 2k with 2k+1
    // Better: sort by angle, pair nearest conjugates, etc.
    for (idx = 0; idx < p_sorted.size(); idx += 2)
    {
        std::complex<double> p1 = p_sorted[idx];
        std::complex<double> p2 = (idx + 1 < p_sorted.size()) ? p_sorted[idx + 1] : std::complex<double>(0.0, 0.0);

        std::complex<double> z1 = (idx < z_sorted.size()) ? z_sorted[idx] : std::complex<double>(0.0, 0.0);
        std::complex<double> z2 = (idx + 1 < z_sorted.size()) ? z_sorted[idx + 1] : std::complex<double>(0.0, 0.0);

        // Quadratic numerator: We usually set b0 = 1 for each section, scale overall gain later
        std::complex<double> b0 = 1.0;
        std::complex<double> b1 = -(z1 + z2);
        std::complex<double> b2 = z1 * z2;

        // Denominator
        std::complex<double> a0 = 1.0;
        std::complex<double> a1 = -(p1 + p2);
        std::complex<double> a2 = p1 * p2;

        // std::complex<double> check.  If T is complex then return the complex version of the sos filter otherwise return the real version
        if constexpr (std::is_same_v<T, std::complex<double>> == true)
            sos.push_back({ b0, b1, b2, a0, a1, a2 });
        else
            sos.push_back({ b0.real(), b1.real(), b2.real(), a0.real(), a1.real(), a2.real() });

    }

    return sos;

}   // end of zpk_to_sos_complex

//-----------------------------------------------------------------------------
//inline std::vector<std::vector<double>> zpk_to_sos(std::vector<std::complex<double>>& zeros, std::vector<std::complex<double>>& poles)
//{
//    uint32_t idx;
//
//    std::vector<std::vector<double>> sos_filter;
//
//    if (zeros.size() != poles.size())
//    {
//        std::cerr << "The number of poles and zeros is not the same." << std::endl;
//        return sos_filter;
//    }
//
//    // Sort complex conjugate pairs
//    std::vector<std::complex<double>> z_sorted = sort_conjugate_pairs(zeros);
//    std::vector<std::complex<double>> p_sorted = sort_conjugate_pairs(poles);
//
//    for (idx = 0; idx < p_sorted.size(); idx += 2)
//    {
//        std::complex<double> p1 = p_sorted[idx];
//        std::complex<double> p2 = (idx + 1 < p_sorted.size()) ? p_sorted[idx + 1] : std::complex<double>(0.0, 0.0);
//
//        std::complex<double> z1 = (idx < z_sorted.size()) ? z_sorted[idx] : std::complex<double>(0.0, 0.0);
//        std::complex<double> z2 = (idx + 1 < z_sorted.size()) ? z_sorted[idx + 1] : std::complex<double>(0.0, 0.0);
//
//        // Quadratic numerator: We usually set b0 = 1 for each section, scale overall gain later
//        double b0 = 1.0;
//        double b1 = -(z1 + z2).real();
//        double b2 = (z1 * z2).real();
//
//        // Denominator
//        double a0 = 1.0;
//        double a1 = -(p1 + p2).real();
//        double a2 = (p1 * p2).real();
//
//        sos_filter.push_back({ b0, b1, b2, a0, a1, a2 });
//
//    }
//
//    return sos_filter;
//
//}   // end of zpk_to_sos

//-----------------------------------------------------------------------------
inline std::vector<std::vector<std::complex<double>>> chebyshev2_lowpass_iir_sos(int32_t N, double cutoff_frequency, double r_s)
{
    int32_t idx;
    double k = 0.99;

    // Calculate Chebyshev Type II parameters
    double epsilon = 1 / std::sqrt(std::pow(10, (r_s / 10.0)) - 1.0);

    // Calculate polesand zeros for normalized lowpass prototype
    std::vector<std::complex<double>> z(N, { 0.0,0.0 });
    std::vector<std::complex<double>> p(N, { 0.0,0.0 });
    chebyshev2_poles_zeros(N, epsilon, z, p);

    //Frequency transformation(lowpass to lowpass with cutoff Wn)
    double omega_warped = 2.0 * std::tan(M_1PI * cutoff_frequency);

    for (idx = 0; idx < N; ++idx)
    {
        z[idx] *= omega_warped;
        p[idx] *= omega_warped;
    }

    // Bilinear transformation to z - domain
    std::complex<double> kz(1.0, 0.0), kp(1.0, 0.0);
    std::vector<std::complex<double>> zd = bilinear_transform(z, kz);
    std::vector<std::complex<double>> pd = bilinear_transform(p, kp);

    //double kd = std::real((kz / kp));

    std::vector<std::vector<std::complex<double>>> sos_filter = zpk_to_sos<std::complex<double>>(zd, pd);
    //std::vector<std::vector<double>> sos_filter = zpk_to_sos(zd, pd);

    return normalize_sos_filter_gain<std::complex<double>>(sos_filter);

}   // end of chebyshev2_lowpass_iir_sos

//-----------------------------------------------------------------------------
inline std::vector<std::vector<std::complex<double>>> chebyshev2_complex_bandpass_iir_sos(int32_t N, double normalized_center_freq, double normalized_cutoff_freq, double rs)
{
    // design real Chebyshev Type II lowpass prototype
    double epsilon = 1.0 / std::sqrt(std::pow(10.0, rs / 10.0) - 1.0);

    std::vector<std::complex<double>> z_lp(N, { 0.0, 0.0 });
    std::vector<std::complex<double>> p_lp(N, { 0.0, 0.0 });

    chebyshev2_poles_zeros(N, epsilon, z_lp, p_lp);  // your existing function

    // Scale prototype to desired cutoff (your original code did scaling via omega_warped)
    double omega_warped = 2.0 * std::tan(M_1PI * normalized_cutoff_freq / 2.0);
    for (auto& zz : z_lp) zz *= omega_warped;
    for (auto& pp : p_lp) pp *= omega_warped;

    // 2. Bilinear transform lowpass prototype --> digital lowpass
    std::complex<double> kz(1.0, 0.0);
    std::complex<double> kp(1.0, 0.0);   // usually same prewarping constant

    auto zd_lp = bilinear_transform(z_lp, kz);
    auto pd_lp = bilinear_transform(p_lp, kp);

    // apply complex frequency shift z --> z * exp(-j wo)
    std::complex<double> rot = std::exp(M_2PI * j * normalized_center_freq);

    std::vector<std::complex<double>> zd_bp(N);
    std::vector<std::complex<double>> pd_bp(N);

    for (int i = 0; i < N; ++i)
    {
        zd_bp[i] = zd_lp[i] * rot;
        pd_bp[i] = pd_lp[i] * rot;
    }

    // convert zpk --> second-order sections (complex)
    // It must pair conjugates (or near-conjugates) correctly when possible,
    // but since we expect complex coeffs anyway, we can pair arbitrarily
    // (but better to pair conjugates for numerical reasons when they exist)
    std::vector< std::vector<std::complex<double>>> sos_filter = zpk_to_sos<std::complex<double>>(zd_bp, pd_bp);

    return normalize_sos_filter_gain(sos_filter);
}   // end of chebyshev2_complex_bandpass_iir_sos

//-----------------------------------------------------------------------------
inline std::vector<std::vector<std::complex<double>>> chebyshev2_bandreject_iir_sos(int32_t N, double normalized_center_freq, double normalized_bandwidth, double r_s)
{
    int32_t idx;
    double k = 1.0; // Gain initialization

    // 1. Calculate Chebyshev Type II parameters (Stopband ripple/rejection)
    double epsilon = 1.0 / std::sqrt(std::pow(10.0, (r_s / 10.0)) - 1.0);

    // 2. Calculate poles and zeros for normalized lowpass prototype
    std::vector<std::complex<double>> z(N, { 0.0, 0.0 });
    std::vector<std::complex<double>> p(N, { 0.0, 0.0 });
    chebyshev2_poles_zeros(N, epsilon, z, p);

    // 3. Frequency transformation (Lowpass Prototype to Highpass)
    // Transformation: s_hp = omega_warped / s_lp
    double omega_warped = 2.0 * std::tan(M_1PI * normalized_bandwidth /2.0);

    std::vector<std::complex<double>> z_hp(N);
    std::vector<std::complex<double>> p_hp(N);

    for (idx = 0; idx < N; ++idx)
    {
        // Highpass transformation: inverse the prototype and scale by warped frequency
        // Handle potential division by zero for zeros at infinity in prototype
        p_hp[idx] = omega_warped / p[idx];

        if (std::abs(z[idx]) > 1e-15) {
            z_hp[idx] = omega_warped / z[idx];
        }
        else {
            // Analog zeros at infinity in LP prototype map to 0 in HP
            z_hp[idx] = std::complex<double>(0.0, 0.0);
        }
    }

    // 4. Bilinear transformation to z-domain
    std::complex<double> kz(1.0, 0.0), kp(1.0, 0.0);
    std::vector<std::complex<double>> zd = bilinear_transform(z_hp, kz);
    std::vector<std::complex<double>> pd = bilinear_transform(p_hp, kp);

    // apply complex frequency shift z --> z * exp(-j wo)
    std::complex<double> rot = std::exp(M_2PI * j * normalized_center_freq);

    std::vector<std::complex<double>> zd_br(N);
    std::vector<std::complex<double>> pd_br(N);

    for (int i = 0; i < N; ++i)
    {
        zd_br[i] = zd[i] * rot;
        pd_br[i] = pd[i] * rot;
    }
    // 5. ZPK to SOS
    // The gain 'k' usually needs correction to ensure 0dB in the passband (at Nyquist/Fs/2)
    //std::vector<std::vector<double>> sos_filter = zpk_to_sos(zd, pd, k);
    std::vector< std::vector<std::complex<double>>> sos_filter = zpk_to_sos<std::complex<double>>(zd_br, pd_br);

    // Normalize gain at Fs/2 (High-pass passband)
    // (You might need a normalize_gain function here depending on your zpk_to_sos implementation)

    return normalize_sos_filter_gain<std::complex<double>>(sos_filter);
}   // end of chebyshev2_bandreject_iir_sos

//-----------------------------------------------------------------------------
inline std::vector<std::vector<std::complex<double>>> chebyshev2_highpass_iir_sos(int32_t N, double cutoff_frequency, double r_s)
{
    int32_t idx;
    double k = 1.0; // Gain initialization

    // 1. Calculate Chebyshev Type II parameters (Stopband ripple/rejection)
    double epsilon = 1.0 / std::sqrt(std::pow(10.0, (r_s / 10.0)) - 1.0);

    // 2. Calculate poles and zeros for normalized lowpass prototype
    std::vector<std::complex<double>> z(N, { 0.0, 0.0 });
    std::vector<std::complex<double>> p(N, { 0.0, 0.0 });
    chebyshev2_poles_zeros(N, epsilon, z, p);

    // 3. Frequency transformation (Lowpass Prototype to Highpass)
    // Transformation: s_hp = omega_warped / s_lp
    double omega_warped = 2.0 * std::tan(M_1PI * cutoff_frequency);

    std::vector<std::complex<double>> z_hp(N);
    std::vector<std::complex<double>> p_hp(N);

    for (idx = 0; idx < N; ++idx)
    {
        // Highpass transformation: inverse the prototype and scale by warped frequency
        // Handle potential division by zero for zeros at infinity in prototype
        p_hp[idx] = omega_warped / p[idx];

        if (std::abs(z[idx]) > 1e-15) {
            z_hp[idx] = omega_warped / z[idx];
        }
        else {
            // Analog zeros at infinity in LP prototype map to 0 in HP
            z_hp[idx] = std::complex<double>(0.0, 0.0);
        }
    }

    // 4. Bilinear transformation to z-domain
    std::complex<double> kz(1.0, 0.0), kp(1.0, 0.0);
    std::vector<std::complex<double>> zd = bilinear_transform(z_hp, kz);
    std::vector<std::complex<double>> pd = bilinear_transform(p_hp, kp);

    // 5. ZPK to SOS
    // The gain 'k' usually needs correction to ensure 0dB in the passband (at Nyquist/Fs/2)
    std::vector<std::vector<std::complex<double>>> sos_filter = zpk_to_sos<std::complex<double>>(zd, pd);

    // Normalize gain at Fs/2 (High-pass passband)
    // (You might need a normalize_gain function here depending on your zpk_to_sos implementation)

    return normalize_sos_filter_gain<std::complex<double>>(sos_filter);
}   // end of chebyshev2_highpass_iir_sos

//-----------------------------------------------------------------------------
inline std::vector<std::vector<std::complex<double>>> chebyshev2_notch_iir_sos(uint64_t sample_rate, double notch_frequency, double notch_bandwidth)
{
    // convert frequencies to normalized radians
    double w0 = M_2PI * notch_frequency / (double)sample_rate;
    double bw_rad = M_2PI * notch_bandwidth / (double)sample_rate;

    // determine pole radius based on bandwidth
    double R = 1 - (bw_rad / 2.0);

    // define the zero and pole locations
    std::complex<double> z0 = std::exp(j * w0);
    std::complex<double> p0 = R * std::exp(j * w0);

    // create Second Order Section by squaring the first order notch this ensures a sharper null and meets the "second order" requirement.
    //    % H(z) = ((z - z0)(z - z0)) / ((z - p0)(z - p0))
    //b0 = 1.0; b1 = -2 * z0; b2 = z0 ^ 2; a0 = 1.0; a1 = -2 * p0; a2 = p0 ^ 2;
    //std::vector<std::complex<double>> sos = { {1.0, 0.0}, -2.0 * z0, z0 * z0, {1.0, 0.0}, -2.0 * p0, p0 * p0 };
    std::complex<double> b0 = 1.0;
    std::complex<double> b1 = -2.0 * z0;
    std::complex<double> b2 = z0 * z0;

    // Denominator
    std::complex<double> a0 = 1.0;
    std::complex<double> a1 = -2.0 * p0;
    std::complex<double> a2 = p0 * p0;

    std::vector<std::complex<double>> sos = { b0, b1, b2, a0, a1, a2 };

    std::vector<std::vector<std::complex<double>>> sos_filter = normalize_sos_filter_gain<std::complex<double>>({ sos });
     
    return sos_filter;

}   // end of chebyshev2_notch_iir_sos

//-----------------------------------------------------------------------------
/*!
@brief Calculate Butterworth IIR filter coefficients as second-order sections to be used in a Direct Form II Transposed filter
 
@param cutoff Normalized cutoff frequency (0 < cutoff < 1)
@param order Filter order (must be positive)
@return Vector of biquad coefficients for each second-order section
*/
inline std::vector<std::vector<double>> butterworth_iir_sos(int32_t order, double cutoff_frequency)
{
    int32_t idx;
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



inline std::vector<double> get_sos_filter_magnitude(std::vector<std::vector<std::complex<double>>> sos_filter, uint32_t num_points)
{
    int32_t idx, jdx;
    std::complex<double> numerator, denominator;

    std::vector<double> w = generate_linspace(-M_1PI, M_1PI, num_points);

    std::vector<std::complex<double>> z_inv(num_points);
    std::vector<std::complex<double>> z_inv_sq(num_points);
    std::vector<std::complex<double>> H(num_points, 1.0);

    std::vector<double> m(num_points, 0.0);

    // create z_inv and z_inv^2
    for (idx = 0; idx < num_points; ++idx)
    {
        z_inv[idx] = std::exp(-j * w[idx]);
        z_inv_sq[idx] = z_inv[idx] * z_inv[idx];
    }

    // loop through each section and multiply their frequency responses
    for (idx = 0; idx < sos_filter.size(); ++idx)
    {
        // ensure a0 is 1, as per standard SOS representation (division by a0)
        if (sos_filter[idx][3] != 1.0)
        {
            for (jdx = 0; jdx < 6; ++jdx)
            {
                sos_filter[idx][jdx] /= sos_filter[idx][3];
            }
        }
        
        // calculate frequency response for this section
        // numerator and denominator polynomial evaluation without polyval        
        for (jdx = 0; jdx < num_points; ++jdx)
        {
            numerator = sos_filter[idx][0] + (sos_filter[idx][1] * z_inv[jdx]) + (sos_filter[idx][2] * z_inv_sq[jdx]);
            denominator = sos_filter[idx][3] + (sos_filter[idx][4] * z_inv[jdx]) + (sos_filter[idx][5] * z_inv_sq[jdx]);

            H[jdx] *= (numerator / denominator);
        }           
    }

    // H = 20 * log10(abs(H));  % magnitude_dB
    for (idx = 0; idx < num_points; ++idx)
    {
        m[idx] = 20.0 * std::log10(std::abs(H[idx]));
    }

    return m;

}   // end of get_sos_filter_magnitude


}  // end of namespace DSP

#endif  // DSP_WINDOW_DEFINITION_H_
