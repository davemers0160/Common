#ifndef _MOD_H_
#define _MOD_H_

#include <cstdint>
#include <cmath>

inline uint64_t mod(int64_t a, int64_t n)
{
    return (uint64_t)(a - std::abs(n)*std::floor(a/(double)std::abs(n)));
}

#endif  // _MOD_H_