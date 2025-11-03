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

//-----------------------------------------------------------------------------
// Structure to hold second-order section coefficients
struct sos_coefficients 
{
    double b0, b1, b2;  // Numerator coefficients
    double a0, a1, a2;  // Denominator coefficients (a0 is typically 1)
    double gain;
};

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
std::vector<std::vector<double>> create_butterworth_sos_filter(double cutoff_frequency, int32_t order)
{
    uint32_t idx;
    double theta = 0.0;
    std::complex<double> pole_s, pole_z;
    double a1, a2;
    double sum_a = 0.0;
    double sum_b = 4.0;
    double stage_gain = 0.0;
    double gain_scale;
    std::vector<std::vector<double>> sections;

	// quick checks to make sure the order is within appropriate values
    if (order < 1)
        std::throw std::invalid_argument("Filter order must be > 1");
    else if (order < 4)
        gain_scale = 0.9204;
    else if(order > 40)
        gain_scale = 0.978797;
    else
        gain_scale = -0.0000000715 * order * order * order * order + 0.00000933 * order * order * order - 0.0004626 * order * order + 0.010875 * order + 0.8693;
    
    // Prewarp cutoff frequency for bilinear transform
    double omega_c = std::tan(M_2PI * cutoff_frequency);

    // number of 2nd order sections: order/2
    int num_sections = order >> 1;

    // Loop over complex-conjugate pole pairs
    for (idx = 0; idx < num_sections; ++idx) 
    {
        // analog Butterworth poles
        theta = M_PI * (2.0 * idx + 1.0 + order) / (2.0 * order);
        pole_s = std::polar(omega_c, theta);

        // Compute digital poles - Bilinear transform : s -> (1 - z ^ -1) / (1 + z ^ -1)
        pole_z = (2.0 + pole_s) / (2.0 - pole_s);

        //a = [1 - 2 * real(pole_z) (pole_z) * conj(pole_z)];
        a1 = -2.0 * pole_z.real();
        a2 = (pole_z * std::conj(pole_z)).real();
        
        stage_gain = gain_scale * (1 + a1 + a2) / sum_b;
        std::vector<double> sos_stage{stage_gain, 2*stage_gain, stage_gain, 1.0, a1, a2};

        sections.push_back(sos_stage);
    }

    // Handle odd order: one extra first-order section
    if (order % 2 == 1) 
    {
        // analog Butterworth poles
        theta = M_PI * (2 * num_sections + 1 + order) / (2 * order);
        pole_s = std::polar(omega_c, theta);

        // Compute digital poles - Bilinear transform : s -> (1 - z ^ -1) / (1 + z ^ -1)
        pole_z = (2.0 + pole_s) / (2.0 - pole_s);

        a1 = -pole_z.real();

        stage_gain = gain_scale * (1 + a1 + 0.0) / (1.0 + 1.0 + 0.0);

        //b = [1, 1, 0], a = [1, -real(pole_z), 0];
        std::vector<double> sos_stage{ stage_gain, stage_gain, 0.0, 1.0, a1, 0.0 };

        sections.push_back(sos_stage);
    }

    return sections;

}   // end of create_butterworth_sos_filter

}  // end of namespace DSP

#endif  // DSP_WINDOW_DEFINITION_H_
