#ifndef _ENCODERS_H_
#define _ENCODERS_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

#else

#endif

// C/C++ includes
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <complex>
#include <algorithm>
#include <functional>
#include <iostream>
#include <ostream>
#include <iomanip>
#include <pair>

// ----------------------------------------------------------------------------
//https://web.archive.org/web/20110806114215/http://homepage.mac.com/afj/taplist.html
//https://in.ncu.edu.tw/ncume_ee/digilogi/prbs.htm
//
// 4 - bits :
//   - 2 taps : [3, 2]
//
// 5 - bits :
//   - 2 taps : [4, 2]
//   - 4 taps : [4, 3, 2, 1], [4, 3, 2, 0]
//
// 6 - bits :
//   - 2 taps : [5, 4]
//   - 4 taps : [5, 4, 3, 0], [5, 4, 2, 1]
//
// 7 - bits :
//   - 2 taps : [6, 5], [6, 3]
//   - 4 taps : [6, 5, 4, 3], [6, 5, 4, 1], [6, 5, 3, 1], [6, 5, 3, 0], [6, 4, 3, 2]
//   - 6 taps : [6, 5, 4, 3, 2, 1], [6, 5, 4, 3, 1, 0]
//
// 8 - bits :
//   - 4 taps : [7, 6, 5, 0], [7, 6, 4, 2], [7, 6, 2, 1], [7, 5, 4, 3], [7, 5, 4, 2], [7, 5, 4, 1]
//   - 6 taps : [7, 6, 5, 4, 3, 1], [7, 6, 5, 4, 1, 0]
//
// 9 - bits :
//   - 2 taps : [8, 4]
//   - 4 taps : [8, 7, 6, 1], [8, 7, 5, 4], [8, 7, 4, 3], [8, 7, 4, 0], [8, 7, 3, 1], [8, 6, 5, 3], [8, 6, 4, 1], [8, 5, 4, 2]
//   - 6 taps : [8, 7, 6, 5, 4, 2], [8, 7, 6, 5, 4, 0], [8, 7, 6, 5, 3, 2], [8, 7, 6, 5, 3, 1], [8, 7, 6, 5, 2, 1], [8, 7, 6, 5, 2, 0], [8, 7, 6, 5, 1, 0],
//              [8, 7, 6, 4, 3, 2], [8, 7, 6, 4, 3, 1], [8, 7, 5, 4, 3, 0], [8, 7, 5, 4, 2, 1], [8, 7, 5, 4, 2, 0], [8, 6, 5, 4, 3, 2], [8, 6, 5, 4, 3, 1]
//   - 8 taps : [8, 7, 6, 5, 4, 3, 2, 0]
//
//-----------------------------------------------------------------------------
template<typename OUTPUT>
inline std::vector<OUTPUT> maximal_length_sequence(uint16_t N, std::vector<uint16_t> taps)
{
    uint64_t idx, jdx;
    uint16_t tmp;
    std::vector<OUTPUT> sr;

    // initialize the register
    std::deque<uint8_t> r(N, 0);
    r[0] = 1;

    // shift register 
    uint64_t sr_size = (1 << N) - 1;

    for (idx = 0; idx < sr_size; ++idx)
    {
        // sr.insert(sr.end(), rep, amplitude * (2 * r[N - 1] - 1));
        sr.insert(sr.end(), 1, r[N - 1]);

        tmp = 0;
        for (jdx = 0; jdx < taps.size(); ++jdx)
        {
            tmp += r[taps[jdx]];
        }
        tmp = tmp % 2;

        r.push_front(tmp);
        r.pop_back();
    }

    return sr;
}   // end of maximal_length_sequence

//-----------------------------------------------------------------------------
inline std::pair<int64_t, int64_t> closest_integer_divisors(int64_t n) 
{
    uint32_t idx;
    int sqrtN = sqrt(n);
    int64_t a = 1, b = n;

    for (idx = 2; idx <= sqrtN; ++idx) 
    {
        if (n % i == 0) 
        {
            if (abs(i - n / i) < abs(a - b)) 
            {
                a = i;
                b = n / i;
            }
        }
    }

    return std::make_pair(a, b);
}   // end of closest_integer_divisors

//-----------------------------------------------------------------------------
inline std::vector<uint32_t> gray_code(uint16_t num_bits)
{
    std::vector<uint32_t> gc;

    uint32_t idx;

    uint32_t num = 1 << (num_bits);

    for (idx = 0; idx < num; ++idx)
    {
        gc.push_back(idx ^ (idx >> 1));
    }

    return gc;
}   // end of gray_code

//-----------------------------------------------------------------------------
inline std::vector<std::complex<float>> generate_qam_constellation(uint16_t num_bits)
{
    uint32_t idx, jdx;

    uint32_t side_length = 1 << (num_bits >> 1);
    double step = 2.0;
    int16_t start = -side_length + 1;
    float scale = 1.0 / abs(start);
    uint32_t index = 0;

    std::vector<uint32_t> gc = gray_code(num_bits);
    std::vector<std::complex<float>> bit_mapper(1 << num_bits);

    // create the base locations for the constellation
    std::vector<float> c_p(side_length, 0);

    // create the primary normalized points for the constellation
    for (idx = 0; idx < side_length; ++idx)
    {
        c_p[idx] = (start * scale);
        start += step;
    }

    // cycle through the side_length x side_length matrix ans assign the constellation position based on the gray code
    // everything is placed in a zig zag pattern
    // Y
    for (idx = 0; idx < side_length; ++idx)
    {
        // X
        for (jdx = 0; jdx < side_length; ++jdx)
        {
            // check row and perform zig-zag assignment
            index = ((idx & 0x01) == 1) ? (side_length * (idx + 1) - 1) - jdx : jdx + (side_length * idx);

            // assign to bit_mapper
            bit_mapper[gc[index]] = std::complex<float>(c_p[jdx], c_p[idx]);
        }
    }

    return bit_mapper;

}   // end of generate_qam_constellation


//-----------------------------------------------------------------------------

#endif  // end of _ENCODERS_H_
