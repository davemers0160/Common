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
#include <utility>

// ----------------------------------------------------------------------------
//https://web.archive.org/web/20110806114215/http://homepage.mac.com/afj/taplist.html
//https://in.ncu.edu.tw/ncume_ee/digilogi/prbs.htm
//
// 4 - bits :
//   - 2 taps : [3,2]
//
// 5 - bits :
//   - 2 taps : [4,2]
//   - 4 taps : [4,3,2,1], [4,3,2,0]
//
// 6 - bits :
//   - 2 taps : [5,4]
//   - 4 taps : [5,4,3,0], [5,4,2,1]
//
// 7 - bits :
//   - 2 taps : [6,5], [6,3]
//   - 4 taps : [6,5,4,3], [6,5,4,1], [6,5,3,1], [6,5,3,0], [6,4,3,2]
//   - 6 taps : [6,5,4,3,2,1], [6,5,4,3,1,0]
//
// 8 - bits :
//   - 4 taps : [7,6,5,0], [7,6,4,2], [7,6,2,1], [7,5,4,3], [7,5,4,2], [7,5,4,1]
//   - 6 taps : [7,6,5,4,3,1], [7,6,5,4,1,0]
//
// 9 - bits :
//   - 2 taps : [8,4]
//   - 4 taps : [8,7,6,1], [8,7,5,4], [8,7,4,3], [8,7,4,0], [8,7,3,1], [8,6,5,3], [8,6,4,1], [8,5,4,2]
//   - 6 taps : [8,7,6,5,4,2], [8,7,6,5,4,0], [8,7,6,5,3,2], [8,7,6,5,3,1], [8,7,6,5,2,1], [8,7,6,5,2,0], [8,7,6,5,1,0],
//              [8,7,6,4,3,2], [8,7,6,4,3,1], [8,7,5,4,3,0], [8,7,5,4,2,1], [8,7,5,4,2,0], [8,6,5,4,3,2], [8,6,5,4,3,1]
//   - 8 taps : [8,7,6,5,4,3,2,0]
//
// 10-bits:
// - 2 taps: [10,7]
// - 4 taps: [10,9,8,5], [10,9,7,6], [10,9,7,3], [10,9,6,1], [10,9,5,2], [10,9,4,2], [10,8,7,5], [10,8,7,2], [10,8,5,4], [10,8,4,3]
// - 6 taps: [10,9,8,7,5,4], [10,9,8,7,4,1], [10,9,8,7,3,2], [10,9,8,6,5,1], [10,9,8,6,4,3], [10,9,8,6,4,2], [10,9,8,6,3,2], 
//           [10,9,8,6,2,1], [10,9,8,5,4,3], [10,9,8,4,3,2], [10,9,7,6,4,1], [10,9,7,5,4,2], [10,9,6,5,4,3], [10,8,7,6,5,2],
// - 8 taps: [10,9,8,7,6,5,4,3], [10,9,8,7,6,5,4,1], [10,9,8,7,6,4,3,1], [10,9,8,6,5,4,3,2], [10,9,7,6,5,4,3,2]
//
// 11-bits:
// - 2 taps: [11,9]
// - 4 taps: [11,10,9,7], [11,10,9,5], [11,10,9,2], [11,10,8,6], [11,10,8,1], [11,10,7,3], [11,10,7,2], [11,10,6,5], [11,10,4,3], [11,10,3,2], 
//           [11,9,8,6], [11,9,8,4], [11,9,8,3], [11,9,7,4], [11,9,7,2], [11,9,6,5], [11,9,6,3], [11,9,5,3], [11,8,6,4], [11,8,6,3], [11,7,6,5], [11,7,6,4]
// - 6 taps: [11,10,9,8,7,4], [11,10,9,8,7,1], [11,10,9,8,5,4], [11,10,9,8,4,3], [11,10,9,8,3,1], [11,10,9,7,5,1], [11,10,9,7,4,1], [11,10,9,6,5,4], 
//           [11,10,9,6,4,2], [11,10,9,6,3,1], [11,10,9,6,2,1], [11,10,9,5,4,3], [11,10,9,5,4,1], [11,10,9,5,3,1], [11,10,9,4,3,2], [11,10,8,7,6,5], 
//           [11,10,8,7,6,3], [11,10,8,7,5,3], [11,10,8,7,4,1], [11,10,8,6,5,4], [11,10,8,6,5,1], [11,10,8,6,4,3], [11,10,8,6,4,2], [11,10,8,5,3,2], 
//           [11,10,8,4,3,2], [11,10,7,6,5,3], [11,10,7,6,5,1], [11,10,7,6,4,2], [11,10,7,6,4,1], [11,10,7,6,3,2], [11,10,7,4,3,2], [11,9,8,7,6,3], 
//           [11,9,8,7,4,2], [11,9,8,6,5,2], [11,9,8,6,4,3], [11,9,7,6,5,4], [11,9,7,6,5,3],  [11,9,7,6,4,2], [11,9,6,5,4,3], [11,8,7,6,4,3]
// - 8 taps: [11,10,9,8,7,6,5,3], [11,10,9,8,7,6,5,2], [11,10,9,8,7,6,4,1], [11,10,9,8,7,6,3,2], [11,10,9,8,7,5,4,2], [11,10,9,8,7,5,3,2], [11,10,9,8,7,5,2,1],
//           [11,10,9,8,7,4,3,1], [11,10,9,8,7,4,2,1], [11,10,9,8,6,5,4,2], [11,10,9,8,6,5,3,2], [11,10,9,8,6,5,3,1], [11,10,9,8,6,4,3,2], [11,10,9,8,5,4,2,1],
//           [11,10,9,7,6,5,4,3], [11,10,9,7,6,5,4,1], [11,10,9,7,6,4,3,2], [11,10,9,7,5,4,3,1], [11,10,9,6,5,4,3,2], [11,10,9,6,5,4,3,1], [11,10,8,7,6,5,4,2],
//           [11,10,8,7,6,4,3,1], [11,10,8,7,5,4,3,2], [11,9,8,7,6,5,3,2], [11,9,8,7,6,4,3,2]

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
template <typename T>
inline constexpr int16_t sign(T val) 
{
    return (T(0) < val) - (val < T(0));
}   // end of sign

//-----------------------------------------------------------------------------
inline std::pair<int64_t, int64_t> closest_integer_divisors(int64_t n) 
{
    uint32_t idx;
    int sqrtN = sqrt(n);
    int64_t a = 1, b = n;

    for (idx = 2; idx <= sqrtN; ++idx) 
    {
        if (n % idx == 0) 
        {
            if (abs(idx - n / idx) < abs(a - b)) 
            {
                a = idx;
                b = n / idx;
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
inline std::vector<std::complex<float>> generate_square_qam_constellation(uint16_t num_bits)
{
    uint32_t idx, jdx;
    uint32_t index = 0;
    int16_t rows, cols;

    uint32_t num = 1 << num_bits;
    std::vector<std::complex<float>> bit_mapper(num);

    std::pair<int64_t, int64_t> int_div = closest_integer_divisors(num);
    rows = int_div.first;
    cols = int_div.second;

    // calculate the gray codes
    std::vector<uint32_t> gc = gray_code(num_bits);

    // create the base locations for the constellation
    std::vector<float> c_y(rows, 0);
    std::vector<float> c_x(cols, 0);

    float row_start = (-rows + 1);
    float row_scale = 1.0 / (float)abs(row_start);

    float col_start = (-cols + 1);
    float col_scale = 1.0 / (float)abs(col_start);

    // create the primary normalized points for the constellation
    for (idx = 0; idx < rows; ++idx)
    {
        c_y[idx] = (row_start * row_scale);
        row_start += 2;
    }

    for (idx = 0; idx < cols; ++idx)
    {
        c_x[idx] = (col_start * col_scale);
        col_start += 2;
    }

    // cycle through the rows x cols matrix and assign the constellation position based on the gray code. everything is placed in a zig zag pattern
    // Y
    for (idx = 0; idx < rows; ++idx)
    {
        // X
        for (jdx = 0; jdx < cols; ++jdx)
        {
            // check row and perform zig-zag assignment
            index = ((idx & 0x01) == 1) ? (idx + 1) * cols - (jdx + 1) : idx * cols + jdx;
            // assign to bit_mapper
            bit_mapper[gc[index]] = std::complex<float>(c_x[jdx], c_y[idx]);
        }
    }

    return bit_mapper;

}   // end of generate_square_qam_constellation


//-----------------------------------------------------------------------------
inline std::vector<std::complex<double>> generate_cross_qam_constellation(uint16_t num_bits)
{
    int32_t idx;

    uint32_t num = 1 << num_bits;
    std::vector<std::complex<double>> bit_mapper(num);
    std::vector<std::complex<double>> tmp_mapper(num);

    // Step 1: Get the integer divisors to determine the shape of the constellation.  Put the smallest value as the number of rows
    std::pair<int64_t, int64_t> int_div = closest_integer_divisors(num);
    int32_t rows = int_div.first;
    int32_t cols = int_div.second;

    // calculate the gray codes
    std::vector<uint32_t> gc = gray_code(num_bits);

    // Step 2: setup some variables 
    int32_t tmp1 = floor((num - 1) / (double)cols);

    int32_t i_max = 3 * (cols >> 2);
    int32_t i_start = 1 - cols;
    int32_t i_offset = cols >> 1;

    int32_t q_max = rows >> 1;
    int32_t q_start = 1 - rows;
    int32_t q_offset = 2 * rows;

    double i_data, q_data, i_mag, q_mag;
    std::complex<float> tmp_c;
    int16_t i_sign, q_sign;

    // Step 3: create the basic constellation
    for (idx = 0; idx<num; ++idx)
    {
        i_data = std::floor(idx / (double)rows);
        q_data = (double)(idx & tmp1);

        tmp_c = std::complex<double>((2 * i_data + i_start), (-1 * (2 * q_data + q_start)));

        i_mag = std::abs(std::floor(tmp_c.real()));

        // check max i value and move if needed
        if (i_mag > i_max)
        {
            q_mag = std::abs(std::floor(tmp_c.imag()));
            i_sign = sign(tmp_c.real());
            q_sign = sign(tmp_c.imag());

            // check max q value and move if needed
            if (q_mag > q_max)
            {
                tmp_c = std::complex<double>(i_sign * (i_mag - i_offset), (q_sign * (q_offset - q_mag)));
            }
            else
            {
                tmp_c = std::complex<double>(i_sign * (cols - i_mag), (q_sign * (rows + q_mag)));
            }
        }

        tmp_mapper[idx] = tmp_c;
    }   // end of for

    // Step 4: apply the gray code to rearrange the constellation
    for (idx = 0; idx < num; ++idx)
    {
        bit_mapper[idx] = tmp_mapper[gc[idx]];
        //std::cout << idx << "\t" << tmp_mapper[idx] << "\t\t" << gc[idx] << "\t" << bit_mapper[idx] << std::endl;
    }

    return bit_mapper;

}   // end of generate_cross_qam_constellation

//-----------------------------------------------------------------------------
void print_constellation(std::vector<std::complex<double>> con)
{

    uint32_t num = con.size();
    std::pair<int64_t, int64_t> int_div = closest_integer_divisors(num);
    int32_t rows = int_div.first;
    int32_t cols = int_div.second;

    int32_t rc_max = 3 * (cols >> 2) - 1;

    int32_t num_bits = std::log2(num);

    auto binary_string = [](int num, int num_bits)
    {
        // Determine the number of bits in an int
        //int num_bits = sizeof(int) * CHAR_BIT;

        std::string res = "";

        // Iterate from the most significant bit to the least significant bit
        for (int idx = num_bits - 1; idx >= 0; --idx)
        {
            // Use a bitwise AND operation to check if the i-th bit is set
            // (num >> i) shifts the i-th bit to the least significant position
            // (& 1) isolates that bit
            //printf("%d", (num >> idx) & 1);
            res += std::to_string((num >> idx) & 1);
        }
        //printf("\n"); // Print a newline after the binary string
        return res;
    };

    uint32_t index = 0;
    bool found = false;

    for (int32_t r = rc_max; r >= -rc_max; r -= 2)
    {
        for (int32_t c = -rc_max; c <= rc_max; c += 2)
        {
            found = false;
            index = 0;
            for (uint32_t mdx = 0; mdx < num; ++mdx)
            {
                if (((int32_t)(con[mdx].real()) == c) && ((int32_t)(con[mdx].imag()) == r))
                {
                    found = true;
                    index = mdx;
                    break;
                }
            }

            if (found == true)
            {
                //std::bitset<5> binary_index(index);
                //std::cout << binary_index << "  " << con[index] << "\t";
                std::cout << binary_string(index, num_bits) << " (" << index << ")\t";
            }
            else
            {
                std::cout << "\t\t";
            }
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}	// end of print_constellation


#endif  // end of _ENCODERS_H_
