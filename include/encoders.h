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

// ----------------------------------------------------------------------------
//https://web.archive.org/web/20110806114215/http://homepage.mac.com/afj/taplist.html
//https://in.ncu.edu.tw/ncume_ee/digilogi/prbs.htm
//**note : subtract 1 for 0 based indexing
//
// 4 - bits :
//   - 2 taps : [4, 3]
//
// 5 - bits :
//   - 2 taps : [5, 3]
//   - 4 taps : [5, 4, 3, 2] , [5, 4, 3, 1]
//
// 6 - bits :
//   - 2 taps : [6, 5]
//   - 4 taps : [6, 5, 4, 1] , [6, 5, 3, 2]
//
// 7 - bits :
//   - 2 taps : [7, 6] , [7, 4]
//   - 4 taps : [7, 6, 5, 4] , [7, 6, 5, 2], [7, 6, 4, 2], [7, 6, 4, 1], [7, 5, 4, 3]
//   - 6 taps : [7, 6, 5, 4, 3, 2] , [7, 6, 5, 4, 2, 1]
//
// 8 - bits :
//   - 4 taps : [8, 7, 6, 1] , [8, 7, 5, 3], [8, 7, 3, 2], [8, 6, 5, 4], [8, 6, 5, 3], [8, 6, 5, 2]
//   - 6 taps : [8, 7, 6, 5, 4, 2] , [8, 7, 6, 5, 2, 1]
//
// 9 - bits :
//   - 2 taps : [9, 5]
//   - 4 taps : [9, 8, 7, 2] , [9, 8, 6, 5], [9, 8, 5, 4], [9, 8, 5, 1], [9, 8, 4, 2], [9, 7, 6, 4], [9, 7, 5, 2], [9, 6, 5, 3]
//   - 6 taps : [9, 8, 7, 6, 5, 3] , [9, 8, 7, 6, 5, 1], [9, 8, 7, 6, 4, 3], [9, 8, 7, 6, 4, 2], [9, 8, 7, 6, 3, 2], [9, 8, 7, 6, 3, 1], [9, 8, 7, 6, 2, 1],
//              [9, 8, 7, 5, 4, 3], [9, 8, 7, 5, 4, 2], [9, 8, 6, 5, 4, 1], [9, 8, 6, 5, 3, 2], [9, 8, 6, 5, 3, 1], [9, 7, 6, 5, 4, 3], [9, 7, 6, 5, 4, 2]
//   - 8 taps : [9, 8, 7, 6, 5, 4, 3, 1]
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


#endif  // end of _ENCODERS_H_
