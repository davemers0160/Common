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
        w[idx] = 0.5f*(1.0f - std::cos(2.0f * M_PI * idx/(double)(N-1)));
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
        w[idx] = a0 - a1 * std::cos(2.0f * M_PI * idx/(double)(N-1));
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
        w[idx] = a0 - a1 * std::cos(2.0f * M_PI * idx / (double)(N-1)) + a2 * std::cos(4.0f * M_PI * idx / (double)(N-1));
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
        w[idx] = a0 - a1 * std::cos(2.0f * M_PI * idx / (double)(N-1)) + a2 * std::cos(4.0f * M_PI * idx / (double)(N-1)) - a3 * std::cos(6.0f * M_PI * idx / (double)(N-1));
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
        w[idx] = a0 - a1 * std::cos(2.0f * M_PI * idx / (double)(N-1)) + a2 * std::cos(4.0f * M_PI * idx / (double)(N-1)) - a3 * std::cos(6.0f * M_PI * idx / (double)(N-1));
    }

    return w;
}   // end of blackman_nuttall_window


//-----------------------------------------------------------------------------
template <typename T, typename funct>
std::vector<T> create_fir_filter(int64_t N, float fc, funct window_function)
{
    std::vector<T> g(N, 0);

    std::vector<float> w = window_function(N);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        if (abs((double)(idx -  ((N-1) >> 1))) < 1e-6)
            g[idx] = w[idx] * fc;
        else
            g[idx] = w[idx] * (std::sin(M_PI * fc * (idx - ((N - 1) >> 1))) / (M_PI * (idx - ((N - 1) >> 1))));
    }

    return g;

}   // end of create_fir_filter


//-----------------------------------------------------------------------------
template <typename funct>
std::vector<float> create_fir_filter(int64_t N, float fc, std::vector<float> w)
{
    if (w.size() != N )
    {
        std::cout << "Window size is not correct!" << std::endl;
        return;
    }

    std::vector<float> g(N , 0);

    //std::vector<float> w = window_function(N - 1);

    for (int64_t idx = 0; idx < N; ++idx)
    {
        if (abs((double)idx - (N / 2.0f)) < 1e-6)
            g[idx] = w[idx] * fc;
        else
            g[idx] = w[idx] * (std::sin(M_PI * fc * (idx - (N >> 1))) / (M_PI * (idx - (N >> 1))));
    }

    return g;

}   // end of create_fir_filter

}  // end of namespace DSP

#endif  // DSP_WINDOW_DEFINITION_H_
